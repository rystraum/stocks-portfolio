import type {
  Activity,
  CapitalYear,
  CryptoHolding,
  CryptoHoldingDetail,
  CryptoPortfolio,
  DividendEvent,
  DividendYearIndex,
  Holding,
  OhlcPoint,
  PortfolioSummary,
} from './types'
import { MONTHS } from './types'

const BASE = '/api/v1'

async function get<T>(path: string): Promise<T> {
  // X-Requested-With makes Devise return 401 (not a 302 to the sign-in HTML)
  // when there's no session, so the caller gets a clean error instead of a
  // redirect into an HTML page.
  const res = await fetch(`${BASE}${path}`, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
  if (res.status === 401) {
    // Not signed in: the /v2/ SPA has no login of its own, so hand off to the
    // Devise sign-in page. Both initial fetches will 401; the redirect is
    // idempotent, so firing it from more than one of them is safe.
    window.location.assign('/users/sign_in')
    throw new Error('Not signed in')
  }
  if (!res.ok) {
    const body = (await res.json().catch(() => null)) as { error?: { message?: string } } | null
    throw new Error(body?.error?.message ?? `Request failed (${res.status})`)
  }
  return res.json() as Promise<T>
}

// --- raw wire shapes (snake_case) -------------------------------------------------

interface RawHolding {
  ticker: string
  name: string
  industry: string
  shares: number
  total_cost: number
  last_price: number
  last_price_at: string
  target_buy: number | null
  target_price_note: string | null
  dividends: number
  realized_pl: number | null
  active: boolean
}
interface RawActivity {
  date: string
  side: string
  shares: number
  price: number
  amount: number
  charges: number
}
type RawHoldingBase = Omit<RawHolding, 'dividends'>
interface RawHoldingDetail extends RawHoldingBase {
  activities: RawActivity[]
  dividends_total: number
  dividends: { date: string; amount: number; pay_date: string; ex_date: string | null }[]
}
interface RawCapitalYear {
  year: number
  invested: number
  cumulative_cost: number
}
interface RawSummary {
  total_cost: number
  current_value: number
  unrealized_pl: number
  realized_pl: number
  total_pl: number
  dividends: number
  value_plus_divs: number
  total_return_incl_divs: number
  currency: string
  as_of: string
  capital_by_year: RawCapitalYear[]
}
interface RawCryptoHolding {
  symbol: string
  name: string
  currency: string
  amount: number
  avg_cost: number
  last_price: number
  last_price_at: string | null
}
interface RawOhlc {
  time: string
  open: number
  high: number
  low: number
  close: number
}

// --- mappers ----------------------------------------------------------------------

function holdingFrom(r: RawHoldingBase, dividends: number): Holding {
  return {
    ticker: r.ticker,
    name: r.name,
    industry: r.industry,
    shares: r.shares,
    totalCost: r.total_cost,
    lastPrice: r.last_price,
    lastPriceAt: new Date(r.last_price_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }),
    targetBuy: r.target_buy,
    targetPriceNote: r.target_price_note,
    dividends,
    realizedPL: r.realized_pl,
    active: r.active,
  }
}

function activitiesFrom(rows: RawActivity[]): Activity[] {
  return rows.map((a) => ({
    date: a.date,
    side: a.side as Activity['side'],
    shares: a.shares,
    price: a.price,
    amount: a.amount,
    charges: a.charges,
  }))
}

function dividendEventsFrom(rows: { date: string; amount: number; pay_date: string }[]): DividendEvent[] {
  return rows.map((d) => ({
    date: d.pay_date.slice(0, 7),
    year: Number(d.pay_date.slice(0, 4)),
    month: MONTHS[Number(d.pay_date.slice(5, 7)) - 1],
    amount: d.amount,
  }))
}

export type HoldingDetail = Holding & {
  activities: Activity[]
  dividendEvents: DividendEvent[]
}

// --- fetchers ---------------------------------------------------------------------

export async function fetchSummary(): Promise<PortfolioSummary> {
  const r = await get<RawSummary>('/portfolio/summary')
  return {
    totalCost: r.total_cost,
    currentValue: r.current_value,
    unrealizedPL: r.unrealized_pl,
    realizedPL: r.realized_pl,
    totalPL: r.total_pl,
    dividends: r.dividends,
    valuePlusDivs: r.value_plus_divs,
    totalReturnInclDivs: r.total_return_incl_divs,
    currency: r.currency,
    asOf: r.as_of,
    capitalByYear: r.capital_by_year.map((c): CapitalYear => ({
      year: c.year,
      invested: c.invested,
      cumulativeCost: c.cumulative_cost,
    })),
  }
}

export async function fetchHoldings(includeInactive = true): Promise<Holding[]> {
  const rows = await get<RawHolding[]>(`/holdings?include_inactive=${includeInactive ? 'true' : 'false'}`)
  return rows.map((r) => holdingFrom(r as RawHoldingBase, r.dividends))
}

export async function fetchHolding(ticker: string): Promise<HoldingDetail> {
  const r = await get<RawHoldingDetail>(`/holdings/${encodeURIComponent(ticker)}`)
  const h = holdingFrom(r, r.dividends_total)
  return {
    ...h,
    activities: activitiesFrom(r.activities),
    dividendEvents: dividendEventsFrom(r.dividends),
  }
}

export async function fetchPriceHistory(ticker: string, days: number): Promise<OhlcPoint[]> {
  const r = await get<{ points: RawOhlc[] }>(`/holdings/${encodeURIComponent(ticker)}/price-history?days=${days}`)
  // Daily bars: drop any point missing OHLC, keep the last point per date, and
  // sort ascending — the candlestick chart requires strictly ascending unique
  // dates and throws otherwise.
  const byDate = new Map<string, OhlcPoint>()
  for (const p of r.points) {
    if (p.open == null || p.high == null || p.low == null || p.close == null) continue
    byDate.set(p.time, p)
  }
  return [...byDate.values()].sort((a, b) => (a.time < b.time ? -1 : a.time > b.time ? 1 : 0))
}

export async function fetchDividendsAll(): Promise<DividendYearIndex> {
  const r = await get<{ years: Record<string, unknown>; years_list: number[] }>('/dividends')
  const byYear: DividendYearIndex = {}
  for (const year of r.years_list) byYear[year] = (r.years[String(year)] as DividendYearIndex[typeof year])
  return byYear
}

export async function fetchCryptoHoldings(): Promise<CryptoPortfolio> {
  const r = await get<{ usdt_php: number | null; holdings: RawCryptoHolding[] }>('/crypto/holdings')
  return {
    usdtPhp: r.usdt_php ?? null,
    holdings: r.holdings.map((c): CryptoHolding => ({
      symbol: c.symbol,
      name: c.name,
      amount: c.amount,
      avgCost: c.avg_cost,
      lastPrice: c.last_price,
      lastPriceAt: c.last_price_at ?? undefined,
      currency: c.currency,
    })),
  }
}

interface RawCryptoActivity {
  date: string
  type: string
  crypto_amount: number
  fiat_amount: number
  fee_crypto: number | null
  fee_fiat: number | null
  forex: number
  notes: string | null
}

interface RawCryptoHoldingDetail {
  symbol: string
  name: string
  currency: string
  compound: string
  last_price: number | null
  last_price_at: string | null
  amount: number
  avg_cost: number
  total_fiat: number
  total_proceeds: number
  current_value: number
  pnl: number
  activities: RawCryptoActivity[]
}

export async function fetchCryptoHolding(id: string): Promise<CryptoHoldingDetail> {
  const r = await get<RawCryptoHoldingDetail>(`/crypto/holdings/${encodeURIComponent(id)}`)
  return {
    symbol: r.symbol,
    name: r.name,
    currency: r.currency,
    compound: r.compound,
    lastPrice: r.last_price,
    lastPriceAt: r.last_price_at,
    amount: r.amount,
    avgCost: r.avg_cost,
    totalFiat: r.total_fiat,
    totalProceeds: r.total_proceeds,
    currentValue: r.current_value,
    pnl: r.pnl,
    activities: r.activities.map((a) => ({
      date: a.date,
      type: a.type as 'buy' | 'sell',
      cryptoAmount: a.crypto_amount,
      fiatAmount: a.fiat_amount,
      feeCrypto: a.fee_crypto,
      feeFiat: a.fee_fiat,
      forex: a.forex,
      notes: a.notes,
    })),
  }
}
