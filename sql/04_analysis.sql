-- ============================================================
-- 04_analysis.sql
-- The analytical queries. Run these AFTER building the database
-- (01, 02, 03). Run each query ONE AT A TIME by highlighting it.
-- ============================================================

-- 1. Quarter-over-quarter revenue growth (CTE + LAG window function)
--    Uses revenue in each company's own currency, so exchange-rate
--    moves don't distort the growth rate.
WITH ranked AS (
	SELECT Name, quarter, quarter_num, revenue,
	       LAG(revenue) OVER (PARTITION BY Name ORDER BY quarter_num) AS prev_rev
	FROM kpi_quarterly
)
SELECT Name, quarter, revenue,
       ROUND((revenue - prev_rev) * 100.0 / prev_rev, 1) AS growth
FROM ranked
WHERE prev_rev IS NOT NULL
ORDER BY Name, quarter_num;

-- 2. Full-year revenue ranking (GROUP BY + RANK window function)
--    Uses revenue_usd so both companies are ranked in the same currency.
WITH fy AS (
	SELECT Name, SUM(revenue_usd) AS fy_revenue_usd
	FROM kpi_quarterly GROUP BY Name
)
SELECT Name, fy_revenue_usd,
	RANK() OVER (ORDER BY fy_revenue_usd DESC) AS revenue_rank
FROM fy;

-- 3. Each quarter's net margin vs the company's own average (window AVG)
SELECT Name, quarter, net_margin,
	ROUND(AVG(net_margin) OVER (PARTITION BY Name), 1) AS avg_net_margin,
	ROUND(net_margin - AVG(net_margin) OVER (PARTITION BY Name), 1) AS delta
FROM kpi_quarterly
ORDER BY Name, quarter_num;

-- 4. Cash conversion: does reported profit turn into real cash?
SELECT Name, quarter, net_income, operating_cash_flow,
	ROUND(operating_cash_flow * 1.0 / net_income, 2) AS cash_conversion
FROM kpi_quarterly
ORDER BY ticker, quarter_num;

-- 5. KPI snapshot: all key ratios side by side
SELECT Name, revenue, quarter, gross_margin, net_margin,
	current_ratio, debt_to_asset
FROM kpi_quarterly
ORDER BY ticker, quarter_num;