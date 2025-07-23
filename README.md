# Knockoff-ML: A knockoff-based machine learning framework for controlled variable selection and risk prediction in EHR data.<br/>
# Overview:
* First, Knockoff-ML generates multiple knockoffs using the sequential conditional independent tuples (SCIT) algorithm. Next, both the original and knockoff datasets are fed into ML models. Following this, Knockoff-ML computes feature importance (FI) for each feature using SHapley Additive exPlanation (SHAP) values. Then Knockoff-ML calculates knockoff statistics and identify key features with false discovery rate (FDR) control. Finally, Knockoff-ML trains risk prediction models with identified key features.
![flowchart2](https://github.com/user-attachments/assets/7c8373e5-4ee0-49d2-bacc-0a539304528d)
---
## Repo Contents:
* `Knockoff_ML.R`: R scripts for generating multiple knockoffs and calculating knockoff statistics for controlled variable selection.
* `Knockoff_ML_FI.ipynb`: Python notebook for computing feature importance, leveraging SHAP values.

---

## Workflow Steps
**Step1:** Generate multiple knockoffs using `generate_knockoff` function from `Knockoff_ML.R` file.<br/>
```bash
X_mk <- generate_knockoff(X, M=5, corr_max=0.75, scaled=TRUE, seed=12345, subsample=TRUE)
```
X represents your original dataset, M is the number of multiple knockoffs. This function will return a list containing your original data, the generated knockoff data, and subsampling indices.<br/>
**Step2:** Compute feature imporatnce using functions in the `Knockoff_ML_FI.ipynb` file. <br/>
Note: Knockoff-ML is a flexible framework that can incorporate various type of machine learning models, you can choose any machine learning models suitable for your work.<br/>
**Step3:** Identify features with FDR control using `Get_select_info` function in the `Knockoff_ML.R` file.<br/>
```bash
Select_info <- Get_select_info(Feature_name=colnames(X),t(FI[1,]),FI[2:6,],M=5,fdr=0.1),
```
FI should be an (M+1)*p data frame, where M is the number of knockoffs, and p is the number of features. The first row of FI contain the feature importance for the original data, and rows 2 through M+1 should contain the feature importance for the knockoff data. This function will return a data frame including information about knockoff statistics and selection results.<br/>
**Step4:** Train prediction models using identified features by Knockoff-ML.<br/>
**Example data:** Note that data access to the MIMIC IV need Data Use Agreement with PhysioNet. We do not provide the datasets directly in this repository. However, for your convenience, we've included an example dataset in the `Data.zip` file. You can use this example data to reproduce and test the workflow demonstrated in our code.
