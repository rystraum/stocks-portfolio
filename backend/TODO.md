# Test Coverage Priority List

**Current Coverage: 3.04%** (62/2038 lines)

## CRITICAL PRIORITY (Data-updating from scrapers - highest risk)

1. **PSE** ✅ **HAS TESTS**
   - Scrapes price updates & dividend announcements from PSE
   - High complexity (web scraping, HTML parsing, datetime handling, error recovery)
   - Used in: PriceUpdateJob, PriceUpdateCompanies, CompaniesController

2. **PriceUpdateCompanies** ⚠️ **NO TESTS**
   - Orchestrates batch price updates
   - Used in: CompaniesController, scheduled via launchd

3. **CoinMarketCap** ⚠️ **NO TESTS**
   - Updates crypto prices from CoinMarketCap API
   - Used in: CryptoPriceUpdate, scheduled execution

4. **CryptoPriceUpdate** ⚠️ **NO TESTS**
   - Orchestrates all crypto price updates
   - Master coordinator for crypto data updates

5. **ConvertDividendAnnouncement** ⚠️ **NO TESTS**
   - Converts announcements to user cash dividends
   - Data integrity, money calculations, complex matching logic
   - Used in: DividendAnnouncementsController

## HIGH PRIORITY (Core calculation services)

6. **ActivitiesCalculator** ⚠️ **NO TESTS**
   - Foundational calculator for buy/sell metrics
   - Used by: UserPortfolioCompany, CompanyAnnualSummary

7. **UserPortfolioCompany** ✅ **HAS TESTS** (needs expansion)
   - Complex portfolio metrics & calculations
   - Extensively used across views, components, and services

8. **CompanySet** ⚠️ **NO TESTS**
   - Portfolio aggregation & sorting
   - Used in: PortfolioController, CashDividendsController, Resources, Tools

9. **Permissions** ⚠️ **NO TESTS**
   - Authorization logic
   - Security implications

## LOW PRIORITY (Display-only services)

- **CashDividendSet** - Display organization only
- **CompanyAnnualSummary** - Display wrapper, delegates to ActivitiesCalculator
- **UserPortfolio** - Simple wrapper class

## Already Tested ✅

- **Coinsph** - Crypto price updates
- **CostBasisCalculator** - Cost basis calculations
- **CostsCalculator** - Historical costs

---

## Recommended Testing Order

1. **PSE** - Most critical & complex scraper (covered)
2. **ActivitiesCalculator** - Foundation for other calculators
3. **PriceUpdateCompanies** - Batch orchestration
4. **CoinMarketCap** - Second data source
5. **CryptoPriceUpdate** - Crypto orchestration
6. **ConvertDividendAnnouncement** - Data integrity
7. **CompanySet** - Complex aggregation
8. **Permissions** - Security
9. Expand **UserPortfolioCompany** tests
