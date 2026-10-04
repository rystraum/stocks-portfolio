# API v1 — stocks-portfolio

JSON API consumed by the Vite frontend served at /v2/ on the same origin.

## Conventions

- Base path: /api/v1 — JSON only, no HTML fallbacks
- Auth: the existing Rails session cookie (same origin, same user). Unauthenticated → 401 { "error": { "code": "unauthenticated", "message": "..." } }
- Money: PHP, JSON numbers, 2 decimals
- Dates: yyyy-mm-dd · Datetimes: ISO 8601 UTC
- Keys: snake_case (mapped to the existing camelCase TS interfaces in a thin client layer)
- No pagination in v1 (single-user portfolio; arrays are complete)
- Errors: 400/401/404/500 with { "error": { "code": "...", "message": "..." } }
- Caching: summary/holdings/dividends → no-cache · price-history → max-age=3600 (nightly price job)

## Endpoints

### GET /api/v1/portfolio/summary

    {
      "total_cost": 598937.69,
      "current_value": 612345.67,
      "unrealized_pl": 13407.98,
      "realized_pl": -21125.55,
      "total_pl": -7717.57,
      "dividends": 118234.10,
      "value_plus_divs": 730579.77,
      "total_return_incl_divs": 131642.08,
      "currency": "PHP",
      "as_of": "2026-10-04T15:00:00Z",
      "capital_by_year": [
        { "year": 2018, "invested": 19615.44, "cumulative_cost": 88021.76 }
      ]
    }

Derived server-side: total_cost / unrealized_pl from CostBasisCalculator (remaining cost
basis) + latest prices; realized_pl from SELL allocations; dividends =
SUM(cash_dividends.amount); capital_by_year.invested = gross BUYs per calendar year,
cumulative_cost = running total (mirrors frontend capitalByYear).

### GET /api/v1/holdings?include_inactive=true

    [
      {
        "ticker": "AREIT",
        "name": "AREIT, Inc.",
        "industry": "REIT",
        "shares": 1100,
        "total_cost": 38760.57,
        "last_price": 37.50,
        "last_price_at": "2026-08-25T14:50:00Z",
        "target_buy": 35.00,
        "dividends": 8024.40,
        "realized_pl": null,
        "active": true
      }
    ]

Field sources: shares = BUY − SELL totals (ActivitiesCalculator) · total_cost =
remaining cost basis (CostBasisCalculator) · last_price/last_price_at = latest
price_updates.price / datetime · target_buy = companies.target_buy_price ·
dividends = SUM(cash_dividends.amount) · realized_pl = SELL proceeds − allocated
cost of sold shares (null when no sells) · active = NOT companies.inactive AND
shares > 0.

### GET /api/v1/holdings/:ticker

    {
      ...holding fields,
      "activities": [
        { "date": "2023-03-10", "side": "BUY", "shares": 600, "price": 30.12, "amount": 18072.00, "charges": 45.00 }
      ],
      "dividends": [
        { "date": "2026-03-15", "amount": 613.80, "pay_date": "2026-03-15", "ex_date": "2026-02-28" }
      ]
    }

activities ordered by date asc (BUY and SELL); dividends newest first. Replaces the
frontend's synthetic generateActivities() and dividendsForTicker().

### GET /api/v1/holdings/:ticker/price-history?days=365

    {
      "ticker": "AREIT",
      "days": 365,
      "points": [
        { "time": "2026-08-25", "open": 37.20, "high": 37.60, "low": 37.00, "close": 37.50 }
      ]
    }

From price_updates (open/high/low, price as close, datetime). days: 30 | 90 | 365
(default 365). Drops the mock volume field (not in DB).

### GET /api/v1/dividends?year=2026

    {
      "year": 2026,
      "months": [
        { "month": 1, "total": 1241.66, "items": [ { "ticker": "AC", "amount": 82.89 } ] }
      ],
      "total": 1241.66
    }

From cash_dividends grouped by pay_date calendar month (items present only where
itemized — i.e. always, since every row has a company). year optional (default:
current). Replaces dividendsByYear / yearDividendTotal.

### GET /api/v1/crypto/holdings

    {
      "currency": "PHP",
      "holdings": [
        { "symbol": "BTC", "name": "Bitcoin", "amount": 0.0214, "avg_cost": 3120000, "last_price": 6480000, "last_price_at": "2026-10-04T14:50:00Z" }
      ]
    }

From crypto_currencies (name/ticker/last_price/last_price_at) + crypto_activities
(BUY/SELL → remaining amount, average cost per asset). Replaces the mock
cryptoHoldings.

### GET /api/v1/crypto/holdings/:symbol/activities  (v1.1, optional)

Same activity shape as holdings/:ticker (side/share/price/amount), from
crypto_activities.

## Implementation notes

- Controllers in Api::V1 namespace (app/controllers/api/v1/); routes:
  namespace :api { namespace :v1 do resources :holdings, only: [:index, :show] ... }
- Reuse the dashboard's existing code path (UserPortfolio, CostBasisCalculator,
  ActivitiesCalculator, CompanySet) so v2 and v1 numbers always agree — never
  re-derive cost basis inline in controllers
- Frontend: replace src/data/portfolio.ts with src/api/ client (fetch +
  snake_case → camelCase mapping into the existing interfaces) plus a small
  caching hook; keep the current TS types as the contract
- All amounts stay in PHP; no FX conversion endpoints in v1
