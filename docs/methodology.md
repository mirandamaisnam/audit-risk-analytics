# Methodology

This document records the analytical approach taken at each stage of the project, including decisions made and why. It should be updated as work progresses — not written retroactively at the end.

## 1. Business Problem

[TO BE COMPLETED]

*Guiding question: How can financial and transactional data analytics be used to identify areas of elevated financial reporting and internal-control risk that may require further investigation? This project does not claim to prove fraud — it identifies risk indicators and potential exceptions that would warrant further investigation in a real audit engagement.*

## 2. Data Sources

- **Phase 1:** `data_FraudDetection_JAR2020.csv` (Bao et al. 2020, AAER-labeled) — [TO BE COMPLETED: description once inspected]
- **Phase 2:** [TO BE COMPLETED once company/peer group and public data source are finalized]
- **Phase 3:** Synthetic transaction/control dataset — [TO BE COMPLETED: generation approach]

## 3. Data Preparation

[TO BE COMPLETED — cleaning steps, missing-value handling, duplicate handling, outlier treatment, and the reasoning behind each decision.]

## 4. Exploratory Analysis

[TO BE COMPLETED — key distributions, class balance, univariate/bivariate findings.]

## 5. Feature Engineering

[TO BE COMPLETED — financial ratios and risk indicators derived, and the business rationale for each.]

## 6. Model Development (Phase 1 — Misstatement Risk)

- **Target definition:** [TO BE COMPLETED]
- **Train/test strategy:** [TO BE COMPLETED]
- **Models evaluated:** [TO BE COMPLETED]
- **Class imbalance handling:** [TO BE COMPLETED]

## 7. Model Evaluation

[TO BE COMPLETED — metrics used (precision, recall, F1, ROC-AUC, PR-AUC, confusion matrix) and results, once computed. No numbers should appear here until the model has actually been run.]

## 8. SQL Analysis

[TO BE COMPLETED — which analytical techniques were used (joins, CTEs, window functions, etc.) and what business questions they answered.]

## 9. Control Testing (Phase 3)

[TO BE COMPLETED — which control exception tests were implemented and against what synthetic data.]

## 10. Power BI Data Modeling

[TO BE COMPLETED — schema design, relationships, key DAX measures and why they were needed.]

## 11. Risk Scoring

[TO BE COMPLETED — how individual risk indicators/model outputs are combined into an overall risk view, if applicable.]

## 12. Findings

[TO BE COMPLETED AFTER ANALYSIS]

## 13. Limitations

- Public financial data limitations: [TO BE COMPLETED]
- Research dataset limitations (age, scope, label quality): [TO BE COMPLETED]
- Historical-label limitations (past misstatements may not reflect current risk factors): [TO BE COMPLETED]
- Synthetic-data limitations (control testing is illustrative, not real): [TO BE COMPLETED]
- Class imbalance: [TO BE COMPLETED]
- Model limitations, false positives/negatives: [TO BE COMPLETED]
- **This project does not prove fraud.** Risk indicators and model outputs highlight areas warranting further investigation, consistent with how analytics support — but do not replace — professional audit judgment.
