-- ============================================================================
-- sql/01_schema/create_views.sql
--
-- Audit Risk Analytics — Phase 5, initial reusable views (PostgreSQL)
--
-- These are deliberately simple, reusable building blocks for later SQL
-- analysis (sql/02-05) and Power BI — not analysis in themselves. No
-- financial-risk interpretation, flagging, or scoring logic lives here;
-- that belongs in sql/03_financial_analysis and later phases, consistent
-- with "do not create complicated analysis yet."
-- ============================================================================

-- ----------------------------------------------------------------------------
-- vw_financial_risk_base
-- ----------------------------------------------------------------------------
-- A flat, joined, one-row-per-company-fiscal-year view over the star schema —
-- the single starting point most later queries and the Power BI model should
-- read from, rather than each query re-joining the three tables independently.
--
-- p_aaer is included but is deliberately positioned last and aliased with an
-- explicit "_metadata_only" suffix, so it is visibly separated from the
-- analytical/predictive columns and is not mistaken for a feature by anyone
-- writing downstream SQL or building a Power BI measure.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_financial_risk_base AS
SELECT
    f.gvkey,
    f.fyear,
    f.misstate,

    -- 28 raw accounting variables
    f.act, f.ap, f.at, f.ceq, f.che, f.cogs, f.csho, f.dlc, f.dltis, f.dltt,
    f.dp, f.ib, f.invt, f.ivao, f.ivst, f.lct, f.lt, f.ni, f.ppegt, f.pstk,
    f.re, f.rect, f.sale, f.sstk, f.txp, f.txt, f.xint, f.prcc_f,

    -- 14 existing financial ratio / derived variables
    f.dch_wc, f.ch_rsst, f.dch_rec, f.dch_inv, f.soft_assets, f.ch_cs,
    f.ch_cm, f.ch_roa, f.issue, f.bm, f.dpi, f.reoa, f."EBIT", f.ch_fcf,

    -- Label-related metadata — clearly separated, not a predictor
    f.p_aaer AS p_aaer_metadata_only
FROM fact_financial_risk f
JOIN dim_company c ON c.gvkey = f.gvkey
JOIN dim_year    y ON y.fyear = f.fyear;

COMMENT ON VIEW vw_financial_risk_base IS
    'Flat join of fact_financial_risk with dim_company/dim_year. p_aaer is aliased p_aaer_metadata_only and kept last to signal it is not a predictor (see Notebook 4).';

-- ----------------------------------------------------------------------------
-- vw_yearly_misstatement_summary
-- ----------------------------------------------------------------------------
-- One row per fiscal year: observation count, positive count, and positive
-- rate. Mirrors the yearly target-rate tables already computed in
-- Notebook 1 (Section 9/21) and Notebook 3 (Section 9) — reimplemented here
-- in SQL, not a new analytical claim.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_yearly_misstatement_summary AS
SELECT
    fyear,
    COUNT(*)                                            AS n_observations,
    SUM(misstate)                                       AS n_positive,
    ROUND(100.0 * SUM(misstate) / NULLIF(COUNT(*), 0), 4) AS positive_rate_pct
FROM fact_financial_risk
GROUP BY fyear
ORDER BY fyear;

COMMENT ON VIEW vw_yearly_misstatement_summary IS
    'Yearly observation count, positive (historically AAER-associated) count, and positive rate — the same metric computed in Notebook 1/3, reimplemented in SQL.';

-- ----------------------------------------------------------------------------
-- vw_company_financial_summary
-- ----------------------------------------------------------------------------
-- One row per company: years of history, positive-year count, and whether
-- the company has both a positive and a negative labeled year — mirrors the
-- company-level structure analysis in Notebook 1 (Section 22) and Notebook 3
-- (Section 8), reimplemented in SQL. No financial-ratio aggregation is
-- included yet — that belongs in sql/03_financial_analysis.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_company_financial_summary AS
SELECT
    gvkey,
    COUNT(*)                                AS n_years,
    MIN(fyear)                              AS first_fyear,
    MAX(fyear)                              AS last_fyear,
    SUM(misstate)                           AS n_positive_years,
    (COUNT(DISTINCT misstate) > 1)          AS has_mixed_labels
FROM fact_financial_risk
GROUP BY gvkey
ORDER BY gvkey;

COMMENT ON VIEW vw_company_financial_summary IS
    'Per-company observation count, year range, positive-year count, and mixed-label flag — mirrors Notebook 1 Section 22 / Notebook 3 Section 8, reimplemented in SQL.';
