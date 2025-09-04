# Prediction of Medical Care Abandonment in Italy Using Population Survey Data

## About

This repository investigates the phenomenon of medical care abandonment in Italy, utilizing data from the 2019 European Health Interview Survey (EHIS). By applying advanced machine learning methods—including XGBoost and multinomial logistic regression—we identify individuals most at risk of forgoing necessary healthcare services. The project features robust preprocessing, feature selection (LASSO and gain-based importance), stability analysis via bootstrap resampling, and a conformal prediction framework for uncertainty-aware predictions. Results highlight key risk factors, regional disparities, and demonstrate XGBoost’s superior performance in identifying vulnerable populations, offering actionable insights for policymakers and healthcare providers.

## Abstract

This study investigates medical care abandonment in Italy using the 2019 EHIS dataset. We apply machine learning methods—XGBoost and multinomial logistic regression—to classify individuals at risk of forgoing necessary healthcare services. Preprocessing, feature selection, and stability analysis ensure robustness, while a conformal prediction framework provides uncertainty quantification. XGBoost outperforms logistic regression in identifying healthcare avoiders, especially in minority behavior classes. These findings support the design of targeted interventions to reduce inequalities and improve healthcare access.

## Repository Structure

- **Data Preprocessing:** Scripts for cleaning, handling missing values, and feature engineering using thematic grouping and skip logic.
- **Exploratory Data Analysis:** Notebooks and visualizations showing patterns by age, gender, geography, and social factors.
- **Modeling:** Implementation of multinomial logistic regression and XGBoost classifiers, including population weighting.
- **Feature Selection:** LASSO and XGBoost gain-based importance, with bootstrap stability analysis.
- **Uncertainty Quantification:** Conformal prediction framework, including Mondrian inductive conformal prediction.
- **Interpretability:** SHAP analysis for global and local model explanations.
- **Results & Evaluation:** Confusion matrices, classification reports, and population-weighted metrics.

## Results

- **Model performance:** XGBoost achieves higher precision and F1-score for healthcare avoiders, with better recall and fewer false positives than logistic regression.
- **Feature importance:** Renunciation indicators (dental care, medication, mental health) are the strongest predictors of care abandonment.
- **Uncertainty quantification:** Conformal prediction sets provide valid coverage and smaller average set sizes for XGBoost.
- **Interpretability:** SHAP analysis offers insights into how socio-demographic and health-related features drive risk.

## Authors

- Emanuele Iaccarino
- Alessia Migneco
- Sara Pantini  
_Sapienza University of Rome_

## License

Distributed under the MIT License. See `LICENSE` for more information.
