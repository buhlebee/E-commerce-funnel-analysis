# E-Commerce Funnel Analysis

## Overview

This project analyzes how users move through an e-commerce funnel from view → cart → purchase using PostgreSQL and Power BI. The goal was to measure conversion rates and identify where the biggest drop-offs occur.

## Dataset

- **Source:** E-commerce behavior events dataset (Kaggle)
- Five monthly files covering October 2019 to February 2020
- Events include `view`, `cart`, `remove_from_cart`, and `purchase`

## Tools Used

- **PostgreSQL** for cleaning and analysis
- **Power BI** for the dashboard report

## Dashboard Preview

### Funnel Overview
![Funnel Overview](Screenshots/Funnel%20Overview.png)

### Dashboard Interactions
![Dashboard interactions](Screenshots/Dashboard%20interactions.gif)

### Product Detail (Drill-Through)
![Products table drillthrough](Screenshots/products%20table%20drillthrough.png)

## What I Did

**1. Combined the monthly files**

I first created the tables with every column typed as TEXT, which made it easier to combine the five monthly tables with `UNION ALL` without running into data type mismatches. After combining the data, I converted each column to its correct type.

**2. Cleaned the data**

I removed extra whitespace, checked for duplicates, and used `ROW_NUMBER()` to identify exact duplicate events. Rows with the same user, event type, product, and timestamp were treated as duplicates and removed, then I created a clean table.

**3. Built the funnel tables**

I created two versions of the funnel:
- `funnel_stages` — one row per user, for overall conversion calculations
- `funnel_stages_detailed` — one row per user, month, product, and category, for deeper analysis

**4. Calculated conversion rates**

I calculated:
- View-to-cart conversion
- Cart-to-purchase conversion
- Overall view-to-purchase conversion
- Drop-off counts and percentages between stages

`NULLIF` was used to avoid division by zero errors.

**5. Prepared Power BI tables**

I built summary tables specifically for Power BI so the report could load pre-aggregated data instead of calculating everything from raw event-level records.

**6. Built the Power BI report**

I imported the data into Power BI using the import from database function, and once I had the tables I needed, I built out the report.

The report includes:
- KPI cards
- A funnel visual
- Monthly conversion trends
- Top categories
- A drill-through page showing the top products within a selected category

## Key Findings and Recommendations

- About 75% of users who viewed a product never added it to their cart. This suggests there may be opportunities to improve product pages ,better product descriptions, customer reviews, or more competitive pricing.
- About 72% of users who added an item to their cart did not complete a purchase. This could point to friction during checkout, such as unexpected shipping costs, a complicated checkout flow, or limited payment options  worth investigating to reduce cart abandonment.
- Overall view-to-purchase conversion was approximately 6–7%. Improving conversion at either the view-to-cart or cart-to-purchase stage could meaningfully impact overall sales, targeted promotions or discounts could help close that gap.

## Project Files

- `cleaned_data.sql` — data import and cleaning
- `FUNNEL_STAGES_FORMATION.sql` — funnel table creation
- `FUNNEL_CONVERSION_CALCULATIONS.sql` — conversion calculations and Power BI export tables

## Limitations

- Product and category IDs in the source dataset are anonymized numeric values with no associated names. As a result, this analysis particularly the drill-through page  should be read as a demonstration of the technique rather than a narrative about specific products or categories.
- The dataset covers only five months, so longer-term seasonal trends could not be analyzed.
- `remove_from_cart` events were included in the detailed table but not in the headline conversion metrics.
