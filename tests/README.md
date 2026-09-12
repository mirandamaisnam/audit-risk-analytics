# Tests

Unit tests for the reusable code in `src/` — primarily feature-engineering
and data-validation functions where correctness matters (e.g. a financial
ratio calculation should be tested against known inputs/outputs).

Not every notebook needs a test; this folder covers `src/` modules only.

Planned: `test_features.py`, `test_data.py` once corresponding `src/` modules exist.
