# Retail Financial Performance Analytics (SQL)

A SQL analytics project comparing the quarterly financial performance of **Nike** and **Adidas** across 2025. Raw financial data is stored in a normalized relational database, and analytical SQL queries turn it into finance KPIs — margins, liquidity, leverage, and cash-flow quality.

This project extends an earlier Excel dashboard comparing the same companies, rebuilt as a proper SQL database with version control.

## Business question

How do Nike and Adidas compare across 2025 on profitability, liquidity, leverage, and the quality of their earnings (does reported profit turn into real cash)?

## Database design

The database uses a simple **star schema** — two dimension tables and one fact table:

| Table | Type | Description |
|---|---|---|
| `companies` | Dimension | Company name, ticker, currency |
| `quarters` | Dimension | Fiscal year, quarter label |
| `financials` | Fact | One row per company per quarter: revenue, profit, assets, liabilities, cash flow |

Tables are linked with **primary keys and foreign keys**, and `financials` uses a **composite primary key** (`company_id`, `quarter_id`) so each company can have only one row per quarter.

A view, `kpi_quarterly`, joins the three tables and calculates the finance ratios so the analysis queries stay clean.

## KPIs calculated

- **Gross / operating / net margin** — profitability
- **Current ratio** — short-term liquidity
- **Debt-to-asset** — leverage
- **Operating cash margin** and **cash-to-revenue** — cash strength
- **Cash conversion** (operating cash flow ÷ net income) — earnings quality

## SQL techniques used

- Multi-table `JOIN`s across a normalized schema
- A reusable **`VIEW`** for the KPI layer
- **CTEs** (`WITH`) to structure multi-step queries
- **Window functions**: `LAG` (quarter-over-quarter growth), `RANK` (revenue ranking), and `AVG OVER` (each quarter vs. the company's own average)

## How to run

1. Open `retail.db` in [DB Browser for SQLite](https://sqlitebrowser.org/) (or any SQLite tool).
2. In the **Execute SQL** tab, run the scripts in the `/sql` folder in order:
   - `01_schema.sql` — creates the tables
   - `02_data.sql` — loads the data
   - `03_view.sql` — creates the KPI view
3. Open `04_analysis.sql` and run each query **one at a time** (highlight it, then Run) to see the results.

## Key findings

- **Nike leads on scale and profitability** — higher revenue (rank #1), stronger margins, and a healthier current ratio (~2.2 vs. Adidas ~1.3).
- **Both companies posted a sharp profitability drop in their respective Q4** — net margin fell to roughly 2% for each, well below their own yearly averages. Because the fiscal calendars differ, these are different calendar periods, so this is a coincidence of each company's own cycle rather than a single industry-wide event.
- **Adidas showed a Q1 cash-flow red flag** — it reported a profit (+429) but *burned* cash from operations (-934), a negative cash-conversion signal that net income alone would hide.

## Data sources

Quarterly figures are taken from Nike's and Adidas's own investor relations reporting for **fiscal year 2025**.

## Comparability caveats

Two things make a naive head-to-head comparison misleading, and both are handled deliberately here:

- **The fiscal calendars do not align.** Nike's fiscal 2025 ended **May 31, 2025**; Adidas reports on the **calendar year**, ending December 31, 2025. So "Q4" is March-May 2025 for Nike and October-December 2025 for Adidas. Quarter-over-quarter trends are valid *within* each company, but a shared movement in the same quarter label is not evidence of a shared market event.
- **The reporting currencies differ.** Adidas reports in EUR and Nike in USD; the `currency` column records each company's native currency. Figures are not currency-converted, so cross-company comparison is done with **ratios and margins** rather than absolute values.

---

*Built by Lasya Hari — Management Information Systems major, Finance minor, Drexel University.*
