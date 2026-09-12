# Data Directory

This folder is organized into three subdirectories, each with a distinct role. Keeping raw, processed, and external data physically separate is a core data-engineering practice: it makes the pipeline auditable (fitting, for this project) and prevents accidental loss of the original source data.

## `data/raw/`

**Immutable. Never edit, overwrite, or delete files here once added.**

This holds source data exactly as received, with no cleaning, renaming, or transformation.

- `data_FraudDetection_JAR2020.csv` — the AAER-labeled accounting misstatement/fraud research dataset from Bao, Ke, Li, Yu & Zhang (2020), *"Detecting Accounting Fraud in Publicly Traded U.S. Firms Using a Machine Learning Approach,"* Journal of Accounting Research.

**Rules for this folder:**
- Do not rename columns, drop rows, or "fix" values here — any correction happens downstream and is coded, not manual, so it's reproducible.
- Do not overwrite this file if a newer version becomes available — add it as a new, clearly versioned file instead (e.g. `data_FraudDetection_JAR2020_v2.csv`) and document why in `docs/methodology.md`.
- If the file is large or its license/terms restrict redistribution, do **not** commit it to GitHub — see "Committing data to GitHub" below.

## `data/processed/`

Cleaned, validated, and transformed data produced *by this project's code* (notebooks/scripts in `src/`). Every file here should be reproducible by re-running the pipeline against `data/raw/`.

Examples of what will land here as the project progresses:
- Cleaned versions of the fraud-detection dataset (missing values handled, dtypes fixed)
- Engineered feature tables (ratios, risk indicators)
- Company-year datasets prepared for SQL loading or Power BI

## `data/external/`

Any supplementary data pulled in from outside the primary research dataset — for example, public financial statement data used in Phase 2 peer benchmarking, or reference tables (sector classifications, ticker-to-CIK mappings).

## Data provenance

Every dataset added to this project — raw or external — should be documented in `docs/data_dictionary.md` with its source, retrieval date, and any known limitations. This is standard practice in audit and financial analytics work: findings are only as credible as the traceability of the data behind them.

## Committing data to GitHub

- Small, publicly shareable research datasets (like the AAER CSV, if its license permits redistribution) can be committed.
- Large files, anything under a restrictive license, or anything containing information that shouldn't be public should **not** be committed — add them to `.gitignore` instead and document how to obtain them in this README.
- When in doubt, don't commit — a `.gitkeep` placeholder plus instructions is safer than accidentally publishing something you don't have rights to redistribute.
