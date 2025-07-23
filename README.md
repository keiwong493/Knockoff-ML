# Knockoff-ML: A knockoff-based machine learning framework for controlled variable selection and risk prediction in EHR data.<br/>
## Overview:
* First, Knockoff-ML generates multiple knockoffs using the sequential conditional independent tuples (SCIT) algorithm. Next, both the original and knockoff datasets are fed into ML models. Following this, Knockoff-ML computes feature importance (FI) for each feature using SHapley Additive exPlanation (SHAP) values. Then Knockoff-ML calculates knockoff statistics and identify key features with false discovery rate (FDR) control. Finally, Knockoff-ML trains risk prediction models with identified key features.
![flowchart2](https://github.com/user-attachments/assets/7c8373e5-4ee0-49d2-bacc-0a539304528d)
---
## Repo Contents:
* `Knockoff-ML.R`: R scripts for generating multiple knockoffs and calculating knockoff statistics for controlled variable selection.
* `Knockoff-ML_FI.ipynb`: Python notebook for computing feature importance, leveraging SHAP values.
* `Knockoff-ML_Prediction.ipynb`: Python notebook for risk prediction with features identified by Knockoff-ML.
* `Data.zip`: An example dataset which contains original data, knockoff data, outcome, subsampling indices, feature importance, selection information, and prediction results. This dataset can be used to test the workflow code.

---

## Workflow Steps:
**Step1:** Generate multiple knockoffs using `generate_knockoff` function from `Knockoff-ML.R` file.<br/>
```bash
#load data
X <- read.csv('/Data/X.csv')
#generate knockoffs
M <- 5
X_mk <- generate_knockoff(X=X, M=M, scaled=TRUE, subsample=TRUE)
#write knockoffs and index
for(i in 1:M){
  write.csv(X_mk$X_MK[,,i],paste0('/Data/X_k',i,'.csv'),row.names = F))
  }
write.table(X_mk$Index,paste0('/Data/Index.csv'),row.names = F, col.names = F)
```
- **X:** Original dataset. <br/>
- **M:** A positive integer for the number of knockoffs. The default is 5.<br/>
- **scaled:** Logical indicating whether continuous variables have been normalized. The default is TRUE.<br/>
- **subsample:** Logical indicating whether subsampling should be performed for SHAP value calculation. The default is TRUE. <br/>

This function (`generate_knockoff`) will return a list containing your original data, the generated knockoff data, and subsampling indices.<br/>

**Step2:** Compute feature imporatnce using `calculate_fi` function in the `Knockoff-ML_FI.ipynb` file. <br/>
```bash
#load data 
X = pd.read_csv('/Data/X.csv')
y = pd.read_csv('/Data/y.csv')
index = pd.read_csv('/Data/Index.csv', header=None)
#calculate feature importance
calculate_fi(X, y, index, models=['catb', 'ligb', 'xgb', 'gbdt', 'rf'], M=5, kopath='/Data', outpath='/Data')
```
- **X**: Original dataset. <br/>
- **y**: Outcome of interest.<br/>
- **index**: Index for subsampling in SHAP calculation.<br/>
- **models**: A list of ML models used within Knockoff-ML.<br/>
- **M**: A positive integer for the number of knockoffs.<br/>
- **kopath:** Path to the knockoff data. Please ensure that each knockoff dataset is saved as a CSV file following the naming convention `X_ki.csv`, where i denotes the i-th knockoff.<br/>
- **outpath:** Path to save feature importance.<br/>

The function (`calculate_fi`) will write .csv files of feature importance for each ML model.<br/>

**Note:** Knockoff-ML is a flexible framework that can incorporate various type of machine learning models, you can choose any machine learning models suitable for your work.<br/>

**Step3:** Identify features with FDR control using `Get_select_info` function in the `Knockoff_ML.R` file.<br/>
```bash
#load data
X <- read.csv('/Data/X.csv')
M <- 5
#feature selection with FDR control
for(model in c("catb","ligb","xgb","gbdt","rf")){
  FI <- read.csv(paste0('/Data/',model,'_fi.csv'))
  Select_info <- Get_select_info(Feature_name=colnames(X),T_0=t(FI[1,]),T_K=FI[2:M+1,],M=M,fdr=0.1),
  write.csv(Select_info,paste0('/Data/',model,'_select.csv'),row.names = F)
  }
```
- **FI:** An (M+1)*p data frame, where M is the number of knockoffs, and p is the number of features. The first row of FI should contain the feature importance for the original data, and rows 2 through M+1 should contain the feature importance for the knockoff data. <br/>
- **Feature name:** The feature names of the original dataset.<br/>
- **X:** Original dataset. <br/>
- **T_0:** A numeric vector of length p for the feature importance of p features in the original dataset.
- **T_K:** An M*p data frame for the feature importance of p features in each knockoff dataset.
- **M:** A positive integer for the number of knockoffs.<br/>
- **fdr:** A real number in a range of (0,1) indicating the target FDR level. The default is 0.1.<br/>

The function (`Get_select_info`) will return a data frame including information about knockoff statistics and selection results.<br/>

**Step4:** Train prediction models and return prediction results using `koml_prediction` function in the `Knockoff-ML_Prediction.ipynb` file with identified features by Knockoff-ML.<br/>
```bash
#load data 
X = pd.read_csv('/Data/X.csv')
y = pd.read_csv('/Data/y.csv')
#Train prediction models and return prediction results
koml_prediction(X, y, models=['catb', 'ligb', 'xgb', 'gbdt', 'rf'], colpath='/Data',outpath='/Data')
```
- **X:** Original dataset. <br/>
- **y:** Outcome of interest.<br/>
- **models:** A list of ML models used within Knockoff-ML.<br/>
- **colpath:** Path to feature selection information obtained in **Step3**.<br/>
- **outpath:** Path to save prediction results.<br/>

The function (`koml_prediction`) will write .csv files of prediction results for each ML model.<br/>

## Example data:
Note that data access to the MIMIC IV need Data Use Agreement with PhysioNet. We are unable to provide the datasets directly in this repository. However, for your convenience, we've included an example dataset in the `Data.zip` file. You can use this example data to reproduce and test the workflow demonstrated in our code.

## Dependencies:
The code should run with the following environment.

"R version 4.4.1", "Matrix 1.7.0".

"Python version 3.9.13", "numpy 1.21.6", "pandas 1.4.4", "shap 0.46.0", "scikit-learn 1.5.2", "catboost 1.1.1", "lightgbm 3.3.5", "xgboost 1.7.5". 
