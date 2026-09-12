# src/

Reusable Python code, separated from the exploratory notebooks so that logic
used more than once (loading, feature engineering, model utilities) lives in
one place and is testable.

- `data/` — loading and cleaning functions (e.g. `load_raw_data()`, validation helpers)
- `features/` — financial ratio and risk-indicator calculations
- `models/` — model training/evaluation helper functions
- `utils/` — shared helpers (config loading, path handling, logging)

Notebooks should import from here rather than duplicating logic inline, once
functions stabilize enough to be extracted.
