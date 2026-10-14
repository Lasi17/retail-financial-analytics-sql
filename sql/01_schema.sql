-- ============================================================
-- 01_schema.sql
-- Creates the database structure: three linked tables.
-- Run this FIRST.
-- ============================================================

-- Drop old objects first so this script can be re-run cleanly.
-- (Order matters: view first, then the child table, then parents.)
DROP VIEW  IF EXISTS kpi_quarterly;
DROP TABLE IF EXISTS fx_rates;
DROP TABLE IF EXISTS financials;
DROP TABLE IF EXISTS companies;
DROP TABLE IF EXISTS quarters;

-- Dimension table: the companies we track.
CREATE TABLE companies (
    Name       TEXT NOT NULL,
    company_id INTEGER PRIMARY KEY,
    currency   TEXT NOT NULL,
    ticker     TEXT NOT NULL UNIQUE
);

-- Dimension table: the time periods.
CREATE TABLE quarters (
    quarter_id  INTEGER PRIMARY KEY,
    fiscal_year INTEGER NOT NULL,
    label       TEXT NOT NULL,
    quarter_num INTEGER NOT NULL
);

-- Fact table: one row per company per quarter.
CREATE TABLE financials (
    company_id          INTEGER NOT NULL,
    quarter_id          INTEGER NOT NULL,
    revenue             REAL,
    gross_profit        REAL,
    operating           REAL,
    net_income          REAL,
    current_asset       REAL,
    current_liab        REAL,
    total_asset         REAL,
    total_liab          REAL,
    operating_cash_flow REAL,
    ending_cash         REAL,
    PRIMARY KEY (company_id, quarter_id),
    FOREIGN KEY (company_id) REFERENCES companies(company_id),
    FOREIGN KEY (quarter_id) REFERENCES quarters(quarter_id)
);

-- Lookup table: average exchange rate to USD for each currency and quarter.
-- Used by the view to convert Adidas revenue (EUR) into USD.
CREATE TABLE fx_rates (
    currency    TEXT    NOT NULL,
    quarter_id  INTEGER NOT NULL,
    usd_rate    REAL    NOT NULL,
    PRIMARY KEY (currency, quarter_id),
    FOREIGN KEY (quarter_id) REFERENCES quarters(quarter_id)
);
