# D2C Web Funnel Analysis 
### December 2025 | GA4 Clickstream Analysis

---

## Project Overview

This project analyses the D2C web purchase funnel for Vaidya, an Ayurvedic wellness brand, using one month of GA4 clickstream data (December 2025). 
The goal is to identify where users drop off in the purchase funnel, diagnose the root causes, and recommend prioritised actions for the product and growth teams.

---
## Business Questions Answered

1. What is the overall funnel conversion rate and where is the 
   biggest drop-off?
2. How does conversion differ across devices and channels?
3. Which traffic sources drive the highest revenue efficiency?
4. How did performance trend week over week in December?
5. What are the highest-impact actions to improve conversion?

---
## Key Findings

- Session-to-purchase CVR: 1.99% | Product view-to-purchase: 2.65%
- Primary funnel leak: Product View → ATC at 11.4% 
  (291,000 sessions lost at this single step)
- 91% mobile traffic but desktop AOV is 39% higher (₹835 vs ₹599)
- CRM channels (WhatsApp, Skendra, Limechat) generate 
  ₹35–61 revenue/session vs ₹17 for Google CPC
- Week 4 revenue jumped 28% over Week 1 driven by 
  year-end demand — not higher basket sizes

---
## Tech Stack

| Layer | Tool |
|---|---|
| Data extraction | Python (pandas, pyarrow) |
| Data storage | PostgreSQL (local) |
| Analysis | SQL (PostgreSQL) |
| Dashboard | Metabase |
| Documentation | Markdown, Google Docs |
|

---
## Data Notes & Assumptions

- Dataset: 32 parquet files, 5.9M raw events, December 2025
- Funnel events filtered to 10 relevant event types (1.8M rows)
- Four tables loaded to PostgreSQL:
  - `funnel_events` — 1,814,094 rows
  - `session_attribution` — 465,462 rows
  - `purchase_params` — 8,872 rows
  - `cart_params` — 74,283 rows
- Session CVR uses distinct session_id as denominator
- Revenue deduplication: SUM(DISTINCT value) per session
- Sessions with no session_start event (17,903) included 
  with source/medium marked as unknown

---

## QA Findings Summary

| # | Finding | Impact |
|---|---|---|
| QA-1 | File 1 has 3 rows — Dec 9 spillover | Low |
| QA-2 | 5 distinct domains in page_location | Medium |
| QA-3 | 9.7% sessions have no attribution data | Medium |
| QA-4 | Essay/spam URLs — 0.43% of sessions | Low |
| QA-5 | ₹ symbol in cart price fields | Low |
| QA-6 | WhatsApp source name typo — standardised | Low |
| QA-7 | Tax column 100% null — dropped | Low |
| QA-8 | 1 duplicate transaction_id (#106707) | Low |
| QA-9 | 72 sessions purchased without checkout event | Low |
| QA-10 | Duplicate add_to_cart events within sessions | Medium |
| QA-11 | 17,903 sessions missing session_start | Medium |
| QA-12 | Multiple user_ids per session_id | Medium |
| QA-13 | Internal channel UTM misconfigured | Medium |

---
## Recommendations Summary

| # | Recommendation | Expected Impact |
|---|---|---|
| 1 | Shift 15-20% CPC budget to affiliate + CRM | +₹8-10L monthly revenue |
| 2 | Surface shipping and COD cost on product page | Checkout CVR 44% → 52% |
| 3 | Move coupon visibility to cart from payment | ATC→Checkout CVR 52.8% → 60% |

---

## AI Assistance Disclosure

This project used AI tools in a supporting capacity:

- **Claude AI (Anthropic)** — assisted with ETL pipeline architecture, data validation logic, and documentation structure.
- **NotebookLM (Google)** — used to synthesise findings, revisit key insights, and explore analytical narratives.

All core analysis, SQL queries, funnel logic, business interpretation, and recommendations were independently developed and validated.

---

