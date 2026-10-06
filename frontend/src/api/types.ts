// Types shared by the API client. Shapes mirror the /api/v1 JSON (snake_case
// on the wire, camelCase here).
export interface Holding {
  ticker: string
  name: string
  industry: string
  shares: number
  totalCost: number
  lastPrice: number
  lastPriceAt: string
  targetBuy: number | null
  targetPriceNote: string | null
  dividends: number
  realizedPL: number | null
  active: boolean
}

export interface Activity {
  date: string
  side: 'BUY' | 'SELL'
  shares: number
  price: number
  amount: number
  charges?: number
}

export interface DividendEvent {
  date: string // yyyy-mm
  year: number
  month: string
  amount: number
}

export interface DividendMonth {
  total: number
  items?: { ticker: string; amount: number }[]
}

export type DividendYearIndex = Record<number, DividendMonth[]>

export interface CapitalYear {
  year: number
  invested: number
  cumulativeCost: number
}

export interface PortfolioSummary {
  totalCost: number
  currentValue: number
  unrealizedPL: number
  realizedPL: number
  totalPL: number
  dividends: number
  valuePlusDivs: number
  totalReturnInclDivs: number
  currency: string
  asOf: string
  capitalByYear: CapitalYear[]
}

export interface CryptoHolding {
  symbol: string
  name: string
  amount: number
  avgCost: number
  lastPrice: number
  lastPriceAt?: string
}

export interface OhlcPoint {
  time: string // yyyy-mm-dd
  open: number
  high: number
  low: number
  close: number
}

export const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'] as const

export function yearDividendTotal(byYear: DividendYearIndex | null | undefined, year: number): number {
  return (byYear?.[year] ?? []).reduce((s, m) => s + m.total, 0)
}

export function dividendYearsOf(byYear: DividendYearIndex | null | undefined): number[] {
  return byYear ? Object.keys(byYear).map(Number).sort((a, b) => a - b) : []
}
