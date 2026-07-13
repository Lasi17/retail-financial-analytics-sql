-- ============================================================
-- 03_view.sql
-- Creates the KPI view that calculates all finance ratios.
-- Run this THIRD (after data is loaded).
-- ============================================================

DROP VIEW IF EXISTS kpi_quarterly;

CREATE VIEW kpi_quarterly AS
	SELECT c.Name, c.ticker, f.revenue, f.gross_profit,
	f.operating, f.current_asset, f.current_liab,
	f.total_asset, f.total_liab, f.net_income,
	f.operating_cash_flow, f.ending_cash,
	q.quarter_num, q.fiscal_year, q.label AS quarter,
	ROUND(f.gross_profit * 100.0 / f.revenue, 1) AS gross_margin,
	ROUND(f.operating   * 100.0 / f.revenue, 1) AS operating_margin,
	ROUND(f.net_income  * 100.0 / f.revenue, 1) AS net_margin,
	ROUND(f.current_asset / f.current_liab, 2)  AS current_ratio,
	ROUND(f.total_liab / f.total_asset, 2)      AS debt_to_asset,
	ROUND(f.operating_cash_flow * 100.0 / f.revenue, 2) AS operating_cash_margin,
	ROUND(f.ending_cash * 100.0 / f.revenue, 2)         AS cash_to_rev
	FROM financials f
	JOIN companies c ON c.company_id = f.company_id
	JOIN quarters q ON q.quarter_id = f.quarter_id;
