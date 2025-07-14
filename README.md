**Knockoff-ML: A knockoff-based machine learning framework for controlled variable selection and risk prediction in EHR data.** <br/>
**Overview:** <br/>
First, Knockoff-ML generates multiple knockoffs using the SCIT algorithm. Next, both the original and knockoff datasets are fed into ML models. Following this, Knockoff-ML computes feature importance (FI) for each feature using SHapley Additive exPlanation (SHAP) values. Then Knockoff-ML calculates knockoff \(q\) values and identify key features with false discovery rate (FDR) control. Finally, Knockoff-ML trains risk prediction models with identified key features.
![flowchart2](https://github.com/user-attachments/assets/60683386-4ac0-4817-8905-66cdcf315b22)
**Repo Contents:** <br/>
Knockoff_ML.R: r codes for multiple knockoffs generation and knockoff statistics cauculation for controlled variable selection. <br/>
Knockoff_ML_FI.ipynb: python codes for feature importance calculation using SHAP values.
