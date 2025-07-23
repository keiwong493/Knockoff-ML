#Knockoff_ML

# Generate knockoffs -------------------------------------------------------

sparse.cor <- function(x){
  n <- nrow(x)
  cMeans <- colMeans(x)
  covmat <- (as.matrix(crossprod(x)) - n*tcrossprod(cMeans))/(n-1)
  sdvec <- sqrt(diag(covmat))
  cormat <- covmat/tcrossprod(sdvec)
  list(cov=covmat,cor=cormat)
}

sparse.cov.cross <- function(x,y){
  n <- nrow(x)
  cMeans.x <- colMeans(x);cMeans.y <- colMeans(y)
  covmat <- (as.matrix(crossprod(x,y)) - n*tcrossprod(cMeans.x,cMeans.y))/(n-1)
  list(cov=covmat)
}

create.MK <- function(X,M=5,corr_max=0.75) {
  
  X <- as.matrix(X)
  sparse.fit <- sparse.cor(X)
  cor.X <- sparse.fit$cor
  cor.X[is.na(cor.X)] <- 0
  cor.X[is.infinite(cor.X)] <- 0
  cov.X <- sparse.fit$cov
  cov.X[is.na(cov.X)] <- 0
  cov.X[is.infinite(cov.X)] <- 0
  Sigma.distance = as.dist(1 - abs(cor.X))
  if(ncol(X)>1){
    fit = hclust(Sigma.distance, method="single")
    corr_max = corr_max
    clusters = cutree(fit, h=1-corr_max)
  }else{clusters<-1}
  
  #temp.M<-matrix(1,M+1,M+1)
  #cov.M<-kronecker(temp.M,cov.X)
  
  #X_k<-matrix(0,nrow(X),ncol(X));index.exist<-c()
  X_k<-array(0,dim=c(nrow(X),ncol(X),M));index.exist<-c()
  for (k in unique(clusters)){
    cluster.fitted<-cluster.residuals<-matrix(NA,nrow(X),sum(clusters==k))
    for(i in which(clusters==k)){
      #print(i)
      temp<-abs(cor.X[i,]);temp[which(clusters==k)]<-0
      
      index<-order(temp,decreasing=T)
      index<-setdiff(index[1:min(length(index),sum(temp>0.001),floor((nrow(X))^(1/3)))],i)
      
      
      y<-X[,i]
      if(length(index)==0){fitted.values<-mean(y)}else{
        
        x<-X[,index,drop=F];temp.xy<-rbind(mean(y),crossprod(x,y)/length(y)-colMeans(x)*mean(y))
        x.exist<-c()
        for(j in 1:M){
          x.exist<-cbind(x.exist,X_k[,intersect(index,index.exist),j])
        }
        temp.xy<-rbind(temp.xy,crossprod(x.exist,y)/length(y)-colMeans(x.exist)*mean(y))
        
        temp.cov.cross<-sparse.cov.cross(x,x.exist)$cov
        temp.cov<-sparse.cor(x.exist)$cov
        temp.xx<-cov.X[index,index]
        temp.xx<-rbind(cbind(temp.xx,temp.cov.cross),cbind(t(temp.cov.cross),temp.cov))
        
        temp.xx<-cbind(0,temp.xx)
        temp.xx<-rbind(c(1,rep(0,ncol(temp.xx)-1)),temp.xx)
        
        pca.fit<-princomp(covmat=temp.xx)
        v<-pca.fit$loadings
        cump<-cumsum(pca.fit$sdev^2)/sum(pca.fit$sdev^2)
        n.pc<-which(cump>=0.999)[1]#nrow(temp.xx)#nrow(temp.xx)#
        pca.index<-intersect(1:n.pc,which(pca.fit$sdev!=0))#which(cump<=0.99)
        #calculate
        #inverse ZZ matrix
        temp.inv<-v[,pca.index,drop=F]%*%(pca.fit$sdev[pca.index]^(-2)*t(v[,pca.index,drop=F]))
        #beta coefficients
        temp.beta<-temp.inv%*%temp.xy
        
        temp.j<-1
        fitted.values<-temp.beta[1]+crossprod(t(x),temp.beta[(temp.j+1):(temp.j+ncol(x)),,drop=F])-sum(colMeans(x)*temp.beta[(temp.j+1):(temp.j+ncol(x)),,drop=F])
        temp.j<-temp.j+ncol(x)
        for(j in 1:M){
          temp.x<-as.matrix(X_k[,intersect(index,index.exist),j])
          if(ncol(temp.x)>=1){
            fitted.values<-fitted.values+crossprod(t(temp.x),temp.beta[(temp.j+1):(temp.j+ncol(temp.x)),,drop=F])-sum(colMeans(temp.x)*temp.beta[(temp.j+1):(temp.j+ncol(temp.x)),,drop=F])
          }
          temp.j<-temp.j+ncol(temp.x)
        }
      }
      residuals<-y-fitted.values
      cluster.fitted[,match(i,which(clusters==k))]<-as.vector(fitted.values)
      cluster.residuals[,match(i,which(clusters==k))]<-as.vector(residuals)
      
      index.exist<-c(index.exist,i)
    }
    #sample mutiple knockoffs
    cluster.sample.index<-sapply(1:M,function(x)sample(1:nrow(X)))
    for(j in 1:M){
      X_k[,which(clusters==k),j]<-cluster.fitted+cluster.residuals[cluster.sample.index[,j],,drop=F]
    }
  }
  return(X_k)
}

generate_knockoff <- function(X,M=5,corr_max=0.75,scaled=FALSE,seed=12345,subsample=TRUE){
  #scale continuous variables
  if(!scaled){
    for(i in 1:ncol(X)){
      if (length(unique(X[,i])) > 2) {
        X[,i] <- as.vector(scale(X[,i]))
      }
    }
  }
  
  X<-as.matrix(X)
  
  #generate knockoff
  X_MK<-create.MK(X,M=M,corr_max=corr_max)

  #subsample for faster shap values calculation
  if(subsample){
    library(irlba)
    X<-as.matrix(X)
    n.AL=floor(10*nrow(X)^(1/3)*log(nrow(X)))
    svd.X.u<-irlba(X,nv=floor(sqrt(ncol(X)*log(ncol(X)))))$u
    h1<-rowSums(svd.X.u^2)
    h2<-rep(1,nrow(X))
    prob1<-h1/sum(h1)
    prob2<-h2/sum(h2)
    prob<-0.5*prob1+0.5*prob2
    set.seed(seed)
    index.AL<-sample(1:nrow(X),min(n.AL,nrow(X)),replace = FALSE,prob=prob)
    index.AL<-index.AL-1
    index.AL<-data.frame(index.AL)
    colnames(index.AL)<-"Index"
    
    out<-list()
    out$X<-X
    out$X_MK<-X_MK
    out$Index<-index.AL
    return(out)
  }
  else{
    out<-list()
    out$X<-X
    out$X_MK<-X_MK
    out$Index<-1:nrow(X)
    return(out)
  }
}



# Knockoff filter ---------------------------------------------------------

calculate_w_kappatau<-function(q1,q2,M=M){
  out<-list()
  t1<-q1
  t2<-q2
  t2_med<-apply(t2,2,median)
  t2_max<-apply(t2,2,max)
  out$w<-(t1-t2_med)*(t1>=t2_max)
  out$w.raw<-t1-t2_med
  out$kappatau<-MK.statistic(t1,t(t2),method="median")
  out$q<-MK.q.byStat(out$kappatau[,1],out$kappatau[,2],M=M)
  return(out)
}

MK.statistic<-function (T_0,T_k,method='median'){
  T_0<-as.matrix(T_0);T_k<-as.matrix(T_k)
  T.temp<-cbind(T_0,T_k)
  T.temp[is.na(T.temp)]<-0
  
  which.max.alt<-function(x){
    temp.index<-which(x==max(x))
    if(length(temp.index)!=1){return(temp.index[2])}else{return(temp.index[1])}
  }
  kappa<-apply(T.temp,1,which.max.alt)-1
  
  if(method=='max'){tau<-apply(T.temp,1,max)-apply(T.temp,1,max.nth,n=2)}
  if(method=='median'){
    Get.OtherMedian<-function(x){median(x[-which.max(x)])}
    tau<-apply(T.temp,1,max)-apply(T.temp,1,Get.OtherMedian)
  }
  return(cbind(kappa,tau))
}

MK.threshold.byStat<-function (kappa,tau,M,fdr = 0.1){
  b<-order(tau,decreasing=T)
  c_0<-kappa[b]==0
  ratio<-c();temp_0<-0
  for(i in 1:length(b)){
    #if(i==1){temp_0=c_0[i]}
    temp_0<-temp_0+c_0[i]
    temp_1<-i-temp_0
    temp_ratio<-(1/M+1/M*temp_1)/max(1,temp_0)
    ratio<-c(ratio,temp_ratio)
  }
  ok<-which(ratio<=fdr)
  if(length(ok)>0){
    #ok<-ok[which(ok-ok[1]:(ok[1]+length(ok)-1)<=0)]
    return(tau[b][ok[length(ok)]])
  }else{return(Inf)}
}

MK.threshold<-function (T_0,T_k, fdr = 0.1,method='median'){
  stat<-MK.statistic(T_0,T_k,method=method)
  kappa<-stat[,1];tau<-stat[,2]
  t<-MK.threshold.byStat(kappa,tau,M=ncol(T_k),fdr=fdr)
  return(t)
}

MK.q.byStat<-function (kappa,tau,M){
  b<-order(tau,decreasing=T)
  c_0<-kappa[b]==0
  ratio<-c();temp_0<-0
  for(i in 1:length(b)){
    #if(i==1){temp_0=c_0[i]}
    temp_0<-temp_0+c_0[i]
    temp_1<-i-temp_0
    temp_ratio<-(1/M+1/M*temp_1)/max(1,temp_0)
    ratio<-c(ratio,temp_ratio)
  }
  q<-rep(1,length(tau));index_bound<-max(which(tau[b]>0))
  for(i in 1:length(b)){
    temp.index<-i:min(length(b),index_bound)
    if(length(temp.index)==0){next}
    q[b[i]]<-min(ratio[temp.index])*c_0[i]+1-c_0[i]
  }
  return(q)
}

Get_select_info<-function(Feature_name,T_0,T_K,M=5,fdr=0.1){
  out<-calculate_w_kappatau(T_0,T_K,M=M)
  thr.w<-MK.threshold.byStat(out$kappatau[,1],out$kappatau[,2],M=M,fdr=fdr)
  highlight<-which(out$w>=thr.w)
  output<-data.frame(feature=Feature_name,
                     kappa=out$kappatau[,1],
                     tau=out$kappatau[,2],
                     w=as.vector(out$w),
                     q=as.vector(out$q),
                     threshold.w=thr.w,
                     select=FALSE)
  output$select[highlight]<-TRUE
  return(output)
}
