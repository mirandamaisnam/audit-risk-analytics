# Schema

DDL scripts for creating the project's database schema.

Schema is intentionally NOT defined yet — the actual table structure depends on
the columns discovered when `data_FraudDetection_JAR2020.csv` is inspected in
`notebooks/01_data_understanding.ipynb`.

Planned files (to be created once schema is known):
- `create_tables.sql` — core tables (misstatement risk facts, company dimension, year dimension)
- `create_views.sql` — analytical views used by Power BI

