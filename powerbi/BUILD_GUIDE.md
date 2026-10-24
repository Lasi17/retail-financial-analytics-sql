# Power BI Build Guide — Nike vs. Adidas

Goal: a 2-page Power BI dashboard built on the same star schema as the SQL project.
The KPIs are rebuilt as **DAX measures** (Power BI's formula language), not copied from the SQL view.

Files in `data/`: `companies.csv`, `quarters.csv`, `financials.csv`, `fx_rates.csv` (exported from `retail.db`).

---

## Tonight (Fri): setup + basics — 2 hrs
1. Install **Power BI Desktop** from the Microsoft Store (free).
2. Do Microsoft Learn's "Get started with Power BI" path. Focus on: Get Data, Model view, measures, slicers. Skip admin/gateway topics.

---

## Saturday: build

### Step 1 — Load the data (15 min)
- Home > Get Data > Text/CSV > load each of the 4 files.
- In the Data view, check types: `*_id` and `quarter_num` = Whole number; money columns and `usd_rate` = Decimal number.

### Step 2 — Model the star schema (20 min)
Go to **Model view**. Make sure you have exactly these two relationships (many-to-one, single direction):
- `financials[company_id]` → `companies[company_id]`
- `financials[quarter_id]` → `quarters[quarter_id]`

Delete any other relationship Power BI auto-created. `fx_rates` stays **unconnected** — its key is two columns (currency + quarter), so we look up the rate with a calculated column instead (Step 3).

Tidy up: hide the `*_id` columns (right-click > Hide in report view). Sort `quarters[label]` by `quarter_num` (select label > Column tools > Sort by column).

### Step 3 — Calculated column: Revenue in USD (10 min)
Select the `financials` table > New column:
```DAX
Revenue USD =
financials[revenue]
    * LOOKUPVALUE (
        fx_rates[usd_rate],
        fx_rates[currency], RELATED ( companies[currency] ),
        fx_rates[quarter_id], financials[quarter_id]
    )
```
Same logic as the JOIN to `fx_rates` in your SQL view.

### Step 4 — Measures (1 hr)
Home > Enter data > create an empty table named `_Measures`. Put every measure there.

**Size & profitability** (flow numbers — summing across quarters is fine)
```DAX
Revenue USD Total = SUM ( financials[Revenue USD] )

Gross Margin % = DIVIDE ( SUM ( financials[gross_profit] ), SUM ( financials[revenue] ) )

Operating Margin % = DIVIDE ( SUM ( financials[operating] ), SUM ( financials[revenue] ) )

Net Margin % = DIVIDE ( SUM ( financials[net_income] ), SUM ( financials[revenue] ) )
```

**Cash & earnings quality**
```DAX
Operating Cash Margin % = DIVIDE ( SUM ( financials[operating_cash_flow] ), SUM ( financials[revenue] ) )

Cash Conversion = DIVIDE ( SUM ( financials[operating_cash_flow] ), SUM ( financials[net_income] ) )
```

**Balance sheet** (point-in-time numbers — don't add 4 quarters of assets together; use the latest quarter in view)
```DAX
Current Ratio =
VAR q = MAX ( quarters[quarter_id] )
RETURN
    DIVIDE (
        CALCULATE ( SUM ( financials[current_asset] ), quarters[quarter_id] = q ),
        CALCULATE ( SUM ( financials[current_liab] ), quarters[quarter_id] = q )
    )

Debt to Asset =
VAR q = MAX ( quarters[quarter_id] )
RETURN
    DIVIDE (
        CALCULATE ( SUM ( financials[total_liab] ), quarters[quarter_id] = q ),
        CALCULATE ( SUM ( financials[total_asset] ), quarters[quarter_id] = q )
    )
```

**Growth** (own currency, like the SQL LAG query — use only in visuals split by company)
```DAX
Revenue QoQ % =
VAR cq = MAX ( quarters[quarter_num] )
VAR cur = SUM ( financials[revenue] )
VAR prev =
    CALCULATE ( SUM ( financials[revenue] ), REMOVEFILTERS ( quarters ), quarters[quarter_num] = cq - 1 )
RETURN
    IF ( cq > 1, DIVIDE ( cur - prev, prev ) )
```
Format all `%` measures as Percentage (1 decimal); ratios as Decimal (2 decimals); Revenue as Currency, no decimals.

### Step 5 — Page 1: "Performance Overview" (1.5 hrs)
- **Slicer**: `quarters[label]`.
- **4 KPI cards** (put Company on each with small multiples, or make 2 rows of cards — one per company): Revenue USD Total, Gross Margin %, Net Margin %, Current Ratio.
- **Clustered column chart**: X = quarter label, Y = Revenue USD Total, Legend = company Name.
- **Line chart**: X = quarter label, Y = Net Margin %, Legend = company Name.
- **Clustered bar**: Y = company Name, X = Gross Margin %.

### Step 6 — Page 2: "Earnings Quality" (1.5 hrs)
- **Slicer**: company Name (single select).
- **Clustered column chart**: X = quarter label, Y = SUM of net_income and SUM of operating_cash_flow side by side.
- **Matrix**: Rows = company Name, Columns = quarter label, Values = Cash Conversion, Operating Cash Margin %, Debt to Asset, Revenue QoQ %.
- **Card**: Cash Conversion.

### Step 7 — Check your numbers against SQL (15 min)
| Check | Expected |
|---|---|
| Revenue USD Total, Nike, all quarters | 46,309 |
| Revenue USD Total, Adidas, all quarters | ~28,044 |
| Current Ratio, Nike Q1 | 2.36 |
| Current Ratio, Adidas Q4 | 1.32 |
| Net Margin %, Nike Q4 | 1.9% |
| Cash Conversion, Adidas Q1 | negative (about -2.2) |

If these match, your model is right.

---

## Sunday: polish & package
- Chart titles should state the takeaway, written from what the dashboard shows (e.g. "Adidas Q1: profit, but negative operating cash flow").
- Add a text box note: Nike FY ends May 31, Adidas FY ends Dec 31 — "Q4" is a different calendar period for each.
- One consistent color per company across every visual.
- Save as `powerbi/nike_adidas_dashboard.pbix`, screenshot both pages into `powerbi/screenshots/`.
- Add a Power BI section to the main README and push to GitHub.

---

## Interview talking points (know these cold)
1. **Why a calculated column for USD revenue but measures for ratios?** The FX rate belongs to each row (company + quarter), so it's a column. Ratios must recalculate for whatever filter is applied, so they're measures.
2. **Why does full-year Net Margin differ slightly from the SQL average?** Power BI's measure divides total net income by total revenue (Nike ~7.0%). The SQL finding averaged the four quarterly margins (6.8%). Both are valid; ratio-of-totals weights bigger quarters more.
3. **Why not sum current assets across quarters?** They're balance-sheet snapshots, not flows. Adding four quarters double-counts, so the measure uses the latest quarter selected.
4. **Why isn't fx_rates connected?** Its key is two columns; Power BI relationships use one column, so a lookup handles it.
