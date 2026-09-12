# Data Quality

SQL scripts for validating data once loaded into the database.

Planned checks (to be implemented once schema is known):
- Row counts vs. source file
- NULL checks on key columns
- Duplicate primary-key checks
- Referential integrity checks (e.g. company/year keys)
- Invalid value checks (e.g. negative values in fields that should be non-negative)

