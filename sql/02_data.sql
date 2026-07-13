-- ============================================================
-- 02_data.sql
-- Inserts the sample data. Run this SECOND (after 01_schema.sql).
-- ============================================================

INSERT INTO companies (Name, company_id, currency, ticker) VALUES
	('Nike Inc', 1, 'USD', 'NKE'),
	('Adidas AG', 2, 'EUR', 'ADDYY');

INSERT INTO quarters (quarter_id, fiscal_year, label, quarter_num) VALUES
	(1, 2025, 'Q1 2025', 1),
	(2, 2025, 'Q2 2025', 2),
	(3, 2025, 'Q3 2025', 3),
	(4, 2025, 'Q4 2025', 4);

INSERT INTO financials (company_id, quarter_id, revenue, gross_profit, operating, net_income, current_asset, current_liab, total_asset, total_liab, operating_cash_flow, ending_cash) VALUES
	(1, 1, 11589, 5257, 1209, 1051, 25040, 10628, 37867, 23923, 394, 8485),
	(1, 2, 12354, 5389, 2384, 1163, 24980, 11246, 37959, 23922, 1049, 7979),
	(1, 3, 11269, 4675, 788, 794, 24608, 11223, 37793, 23786, 1792, 8601),
	(1, 4, 11097, 4469, 321, 211, 23362, 10566, 36579, 23366, 463, 7464),
	(2, 1, 6153, 3205, 610, 429, 11521, 8942, 20091, 14004, -934, 1432),
	(2, 2, 5952, 3077, 546, 381, 11234, 8961, 19499, 13945, 18, 768),
	(2, 3, 6630, 3435, 736, 485, 11967, 9133, 20147, 14068, 641, 1030),
	(2, 4, 6076, 3088, 164, 91, 11977, 9094, 20262, 14137, 1026, 1617);