-- ============================================================================
-- sql/01_schema/create_tables.sql
--
-- Audit Risk Analytics — Phase 5, SQL schema (PostgreSQL)
--
-- Source: data/raw/data_FraudDetection_JAR2020.csv (Bao, Ke, Li, Yu & Zhang 2020)
-- Verified structure (notebooks/01_data_understanding.ipynb, docs/data_dictionary.md):
--   146,045 rows, 46 columns, 18,444 unique companies, fiscal years 1990-2014,
--   one row = one company-fiscal-year observation (unique on gvkey, fyear).
--
-- This script does not invent any business field beyond what the Python phase
-- established. Column list, meanings, and exclusions match docs/data_dictionary.md
-- and notebooks 01-04 exactly.
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- dim_company
-- ----------------------------------------------------------------------------
-- One row per unique company identifier (gvkey). gvkey is a Compustat company
-- identifier, not a financial measure — it is stored here as a dimension key,
-- never as a predictive/analytical feature (consistent with Notebook 4, where
-- gvkey was excluded from the model's feature matrix and used only for
-- grouping/validation).
--
-- No additional company attributes (name, sector, etc.) exist in the source
-- file, so none are invented here. This table exists to give gvkey a proper
-- dimensional home and a clean foreign-key target for fact_financial_risk.
-- ----------------------------------------------------------------------------
CREATE TABLE dim_company (
    gvkey       INTEGER PRIMARY KEY,
    -- Populated by a post-load INSERT (SELECT DISTINCT gvkey FROM the raw load
    -- table) — see sql/01_schema/README.md for the intended load sequence.
    created_at  TIMESTAMP NOT NULL DEFAULT now()
);

COMMENT ON TABLE  dim_company IS
    'Company dimension. gvkey is a Compustat company identifier used only for grouping/joins — never a predictive feature (see docs/data_dictionary.md and Notebook 4).';
COMMENT ON COLUMN dim_company.gvkey IS
    'Compustat company identifier. Verified in Notebook 1 as one of 18,444 unique values in the source file.';

-- ----------------------------------------------------------------------------
-- dim_year
-- ----------------------------------------------------------------------------
-- One row per fiscal year in scope (1990-2014). fyear is treated as a time
-- dimension, not an ordinary numeric predictor — Notebook 4 excluded fyear
-- from the model's feature matrix because the target's base rate drifts
-- materially across fiscal years (Notebook 1, Section 21; Notebook 3, Section 9).
-- fyear is retained here to support temporal filtering, grouping, and the
-- chronological train/validation/test framing used in Notebook 4.
-- ----------------------------------------------------------------------------
CREATE TABLE dim_year (
    fyear       INTEGER PRIMARY KEY,
    CONSTRAINT chk_fyear_range CHECK (fyear BETWEEN 1900 AND 2100)
);

COMMENT ON TABLE  dim_year IS
    'Fiscal year dimension. fyear drifts in target base rate across the sample (Notebook 1/3) and was excluded as a direct model feature in Notebook 4 — retained here for temporal filtering and grouping only.';
COMMENT ON COLUMN dim_year.fyear IS
    'Fiscal year, 1990-2014 in the source file. Verified range in Notebook 1, Section 9.';

-- ----------------------------------------------------------------------------
-- fact_financial_risk
-- ----------------------------------------------------------------------------
-- One row per company-fiscal-year observation — the same grain established
-- and verified in Notebook 1 (rows exactly equal unique (gvkey, fyear) pairs;
-- zero duplicates). Contains:
--   - the target (misstate)
--   - label-related metadata (p_aaer) — see note below
--   - the 28 raw Compustat accounting variables
--   - the 14 existing financial ratio / derived variables
--
-- p_aaer handling: p_aaer is AAER (Accounting and Auditing Enforcement Release)
-- reference metadata, verified in Notebook 1/2 to be non-null if and only if
-- misstate = 1 — i.e. it is a direct label proxy. It is retained in this
-- table ONLY for identification/traceability (e.g. linking a historically
-- labeled observation to its specific enforcement action), exactly as
-- Notebook 4 retained it outside the feature matrix. p_aaer MUST NOT be
-- joined or selected into any predictive/analytical feature set — see
-- sql/01_schema/README.md and vw_financial_risk_base in create_views.sql,
-- which surfaces it under a clearly separated column so it is never
-- mistaken for a predictor by downstream SQL or Power BI.
--
-- Data types: all raw and ratio financial variables are stored as
-- DOUBLE PRECISION rather than a fixed-scale NUMERIC(p,s). The source data
-- is floating-point, spans a wide range of magnitudes (small ratios like
-- book-to-market alongside raw dollar variables in the hundreds of
-- thousands), and a fixed-precision NUMERIC risks silent truncation or
-- load failures if a future refresh of the source data has more extreme
-- values than this sample. DOUBLE PRECISION avoids that failure mode at
-- the cost of exact decimal precision, which is not required for this
-- analytical/statistical use case.
-- ----------------------------------------------------------------------------
CREATE TABLE fact_financial_risk (
    -- Grain / keys -----------------------------------------------------------
    gvkey           INTEGER NOT NULL,
    fyear           INTEGER NOT NULL,

    -- Target ------------------------------------------------------------------
    -- Historically AAER-associated indicator, NOT proof of fraud (Notebooks
    -- 1-4 terminology). Stored as SMALLINT rather than BOOLEAN so it behaves
    -- identically to the 0/1 int used throughout the Python phase (sums,
    -- rates, and BI measures over it need no CASE/CAST translation).
    misstate        SMALLINT NOT NULL,

    -- Label-related metadata — NOT a predictor -------------------------------
    p_aaer          INTEGER,          -- non-null iff misstate = 1 (verified, Notebook 1/2)

    -- 28 raw accounting variables (Compustat fundamentals annual) ------------
    act             DOUBLE PRECISION,  -- Current Assets, Total
    ap              DOUBLE PRECISION,  -- Accounts Payable, Trade
    at              DOUBLE PRECISION,  -- Assets, Total
    ceq             DOUBLE PRECISION,  -- Common/Ordinary Equity, Total
    che             DOUBLE PRECISION,  -- Cash and Short-Term Investments
    cogs            DOUBLE PRECISION,  -- Cost of Goods Sold
    csho            DOUBLE PRECISION,  -- Common Shares Outstanding
    dlc             DOUBLE PRECISION,  -- Debt in Current Liabilities, Total
    dltis           DOUBLE PRECISION,  -- Long-Term Debt Issuance
    dltt            DOUBLE PRECISION,  -- Long-Term Debt, Total
    dp              DOUBLE PRECISION,  -- Depreciation and Amortization
    ib              DOUBLE PRECISION,  -- Income Before Extraordinary Items
    invt            DOUBLE PRECISION,  -- Inventories, Total
    ivao            DOUBLE PRECISION,  -- Investment and Advances, Other
    ivst            DOUBLE PRECISION,  -- Short-Term Investments, Total
    lct             DOUBLE PRECISION,  -- Current Liabilities, Total
    lt              DOUBLE PRECISION,  -- Liabilities, Total
    ni              DOUBLE PRECISION,  -- Net Income (Loss)
    ppegt           DOUBLE PRECISION,  -- Property, Plant and Equipment, Total
    pstk            DOUBLE PRECISION,  -- Preferred/Preference Stock (Capital), Total
    re              DOUBLE PRECISION,  -- Retained Earnings
    rect            DOUBLE PRECISION,  -- Receivables, Total
    sale            DOUBLE PRECISION,  -- Sales/Turnover (Net)
    sstk            DOUBLE PRECISION,  -- Sale of Common and Preferred Stock
    txp             DOUBLE PRECISION,  -- Income Taxes Payable
    txt             DOUBLE PRECISION,  -- Income Taxes, Total
    xint            DOUBLE PRECISION,  -- Interest and Related Expense, Total
    prcc_f          DOUBLE PRECISION,  -- Price Close, Annual, Fiscal

    -- 14 existing financial ratio / derived variables -------------------------
    dch_wc          DOUBLE PRECISION,  -- WC accruals
    ch_rsst         DOUBLE PRECISION,  -- RSST accruals
    dch_rec         DOUBLE PRECISION,  -- Change in receivables
    dch_inv         DOUBLE PRECISION,  -- Change in inventory
    soft_assets     DOUBLE PRECISION,  -- % soft assets
    ch_cs           DOUBLE PRECISION,  -- Change in cash sales
    ch_cm           DOUBLE PRECISION,  -- Change in cash margin
    ch_roa          DOUBLE PRECISION,  -- Change in return on assets
    issue           SMALLINT,          -- Actual issuance flag (0/1; empirically verified, Notebook 1)
    bm              DOUBLE PRECISION,  -- Book-to-market ratio
    dpi             DOUBLE PRECISION,  -- Depreciation index
    reoa            DOUBLE PRECISION,  -- Retained earnings over total assets
    "EBIT"          DOUBLE PRECISION,  -- Earnings before interest and taxes, over total assets
    ch_fcf          DOUBLE PRECISION,  -- Change in free cash flows

    -- Constraints --------------------------------------------------------------
    CONSTRAINT pk_fact_financial_risk PRIMARY KEY (gvkey, fyear),
    CONSTRAINT fk_fact_company FOREIGN KEY (gvkey) REFERENCES dim_company (gvkey),
    CONSTRAINT fk_fact_year    FOREIGN KEY (fyear) REFERENCES dim_year (fyear),
    CONSTRAINT chk_misstate_binary CHECK (misstate IN (0, 1)),
    CONSTRAINT chk_issue_binary    CHECK (issue IS NULL OR issue IN (0, 1))
);

COMMENT ON TABLE fact_financial_risk IS
    'Company-fiscal-year fact table (grain verified in Notebook 1: one row per (gvkey, fyear), no duplicates). Contains the target, label metadata, and the 42 financial variables established in the Python phase.';
COMMENT ON COLUMN fact_financial_risk.misstate IS
    'Historically AAER-associated indicator (0/1). NOT proof of fraud — see docs/data_dictionary.md and Notebook 1, Section 10.';
COMMENT ON COLUMN fact_financial_risk.p_aaer IS
    'AAER reference number. Label-related metadata only — verified non-null iff misstate = 1. MUST NOT be used as a predictive/analytical feature (Notebook 4, Section 3/11/20).';
COMMENT ON COLUMN fact_financial_risk.issue IS
    'Actual securities-issuance flag. Empirically verified in Notebook 1 to equal (dltis > 0 OR sstk > 0) for every row.';

-- ----------------------------------------------------------------------------
-- Indexes
-- ----------------------------------------------------------------------------
-- The primary key already provides an index on (gvkey, fyear). Additional
-- indexes below support the query patterns this project actually uses:
-- company-level lookups/joins, year-level aggregation (dashboard/temporal
-- analysis), target-based filtering (severely imbalanced — an index helps
-- any query that isolates the small misstate = 1 subset), and the combined
-- year + target filter used repeatedly in Notebook 1/3's temporal-by-target
-- analysis (e.g. "positive rate by year").
-- ----------------------------------------------------------------------------
CREATE INDEX idx_fact_gvkey            ON fact_financial_risk (gvkey);
CREATE INDEX idx_fact_fyear            ON fact_financial_risk (fyear);
CREATE INDEX idx_fact_misstate         ON fact_financial_risk (misstate);
CREATE INDEX idx_fact_fyear_misstate   ON fact_financial_risk (fyear, misstate);
CREATE INDEX idx_fact_gvkey_fyear      ON fact_financial_risk (gvkey, fyear); -- mirrors PK order for planner flexibility on partial-key lookups

COMMIT;
