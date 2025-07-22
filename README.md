**Knockoff-ML: A knockoff-based machine learning framework for controlled variable selection and risk prediction in EHR data.** <br/>
**Overview:** <br/>
First, Knockoff-ML generates multiple knockoffs using the sequential conditional independent tuples (SCIT) algorithm. Next, both the original and knockoff datasets are fed into ML models. Following this, Knockoff-ML computes feature importance (FI) for each feature using SHapley Additive exPlanation (SHAP) values. Then Knockoff-ML calculates knockoff statistics and identify key features with false discovery rate (FDR) control. Finally, Knockoff-ML trains risk prediction models with identified key features.
![flowchart2](https://github.com/user-attachments/assets/7c8373e5-4ee0-49d2-bacc-0a539304528d)
**Repo Contents:** <br/>
Knockoff_ML.R: r codes for multiple knockoffs generation and knockoff statistics cauculation for controlled variable selection. <br/>
Knockoff_ML_FI.ipynb: python codes for feature importance calculation using SHAP values.<br/>
**Step1:** Generate multiple knockoffs using generate_knockoff function in the Knockoff_ML.R file.<br/>
**Step2:** Compute feature imporatnce using functions in the Knockoff_ML_FI.ipynb file. <br/>
Note: Knockoff-ML is a flexible framework that can incorporate various type of machine learning models, you can choose any machine learning models suitable for your work.<br/>
**Step3:** Identify features using Get_select_info function in the Knockoff_ML.R file.<br/>
**Step4:** Train prediction models using identified features by Knockoff-ML.
