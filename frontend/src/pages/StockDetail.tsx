import { useEffect, useMemo, useRef, useState } from 'react'
import { Link, Navigate, useParams } from 'react-router'
import { CandlestickSeries, createChart, type IChartApi, type PriceFormatCustom } from 'lightweight-charts'
import { SignedPill } from '@/components/Stat'
import UtilitiesPanel from '@/components/UtilitiesPanel'
import { fetchHolding, fetchPriceHistory, fetchSummary } from '@/api/client'
import { ErrorNote, Loading, useApi } from '@/api/useApi'
import { usePrivacy } from '@/lib/usePrivacy'
import { cn } from '@/lib/utils'
import { niceDate, num, pct, pctOf, peso, signedClass } from '@/lib/format'

const RANGES = [
  { label: '1M', days: 22 },
  { label: '3M', days: 66 },
  { label: '12M', days: 260 },
]

export default function StockDetail() {
  const { ticker = '' } = useParams()
  const { data: holding, loading: loadingHolding, error: holdingErr } = useApi(() => fetchHolding(ticker), [ticker])
  const { data: summary } = useApi(fetchSummary)
  const [range, setRange] = useState(RANGES[1])
  const { data: seriesData } = useApi(() => fetchPriceHistory(ticker, range.days), [ticker, range.days])
  const chartRef = useRef<HTMLDivElement>(null)
  const chartApi = useRef<IChartApi | null>(null)
  const { redact } = usePrivacy()
  const redactFormat: PriceFormatCustom = { type: 'custom', formatter: () => '•••••', minMove: 0.01 }

  const value = holding ? holding.shares * holding.lastPrice : 0
  const pl = holding ? (holding.shares > 0 ? value - holding.totalCost : (holding.realizedPL ?? 0)) : 0
  const total = holding ? pl + holding.dividends : 0
  const cps = holding && holding.shares > 0 ? holding.totalCost / holding.shares : 0

  const activities = holding?.activities ?? []
  const dividends = holding?.dividendEvents ?? []
  const divsByYear = useMemo(() => {
    const m = new Map<number, number>()
    for (const d of dividends) m.set(d.year, (m.get(d.year) ?? 0) + d.amount)
    return [...m.entries()].sort((a, b) => b[0] - a[0])
  }, [dividends])

  useEffect(() => {
    if (!chartRef.current || !holding) return
    const chart = createChart(chartRef.current, {
      autoSize: true,
      layout: {
        background: { color: 'transparent' },
        textColor: '#16150f',
        fontFamily: 'IBM Plex Mono, monospace',
        fontSize: 11,
      },
      grid: {
        vertLines: { color: 'rgba(22,21,15,0.06)' },
        horzLines: { color: 'rgba(22,21,15,0.06)' },
      },
      rightPriceScale: { borderColor: 'rgba(22,21,15,0.15)' },
      timeScale: { borderColor: 'rgba(22,21,15,0.15)', timeVisible: false },
      crosshair: { mode: 0 },
      ...(redact ? { priceFormat: redactFormat } : {}),
    })
    chartApi.current = chart
    return () => {
      chart.remove()
      chartApi.current = null
    }
  }, [holding, redact])

  useEffect(() => {
    const chart = chartApi.current
    if (!chart || !holding) return
    const data = seriesData ?? []
    const series = chart.addSeries(CandlestickSeries, {
      upColor: 'hsl(152, 66%, 30%)',
      downColor: 'hsl(8, 66%, 45%)',
      wickUpColor: 'hsl(152, 66%, 30%)',
      wickDownColor: 'hsl(8, 66%, 45%)',
      borderVisible: false,
      ...(redact ? { priceFormat: redactFormat } : {}),
    })
    series.setData(data)
    if (cps > 0) {
      series.createPriceLine({
        price: cps,
        color: 'hsl(32, 88%, 46%)',
        lineWidth: 1,
        lineStyle: 2,
        axisLabelVisible: true,
        title: 'avg cost',
      })
    }
    if (holding.targetBuy != null) {
      series.createPriceLine({
        price: holding.targetBuy,
        color: 'hsl(220, 60%, 50%)',
        lineWidth: 1,
        lineStyle: 1,
        axisLabelVisible: true,
        title: 'target',
      })
    }
    chart.timeScale().fitContent()
    return () => {
      // Skip when the chart was already removed (effect 1's cleanup runs first,
      // e.g. when `holding` changes) — removeSeries on a removed chart throws
      // and unmounts the whole app.
      if (chartApi.current === chart) chart.removeSeries(series)
    }
  }, [holding, range, cps, seriesData, redact])

  if (!holding) return holdingErr ? <ErrorNote message={holdingErr} /> : loadingHolding ? <Loading /> : <Navigate to="/stocks" replace />

  const rows: [string, React.ReactNode][] = [
    ['Shares held', holding.shares > 0 ? num(holding.shares, 0) : '0 — fully recycled'],
    ['Average cost', holding.shares > 0 ? peso(cps) : '—'],
    ['Cost basis', holding.totalCost > 0 ? peso(holding.totalCost) : '—'],
    ['Market value', value > 0 ? peso(value) : '—'],
    ['Portfolio weight', value > 0 ? pct(pctOf(value, summary?.currentValue ?? 0)) : '—'],
    [
      holding.shares > 0 ? 'Unrealized P/L' : 'Realized P/L',
      <span key="pl" className={cn('num', signedClass(pl))}>
        {peso(pl, { sign: true })}
        {holding.totalCost > 0 && ` (${pct(pctOf(pl, holding.totalCost), 1, true)})`}
      </span>,
    ],
    ['Dividends received', <span key="d" className="num text-div">{peso(holding.dividends)}</span>],
    [
      'Total return incl. divs',
      <span key="t" className={cn('num font-semibold', signedClass(total))}>
        {peso(total, { sign: true })}
      </span>,
    ],
  ]

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <Link to="/stocks" className="num text-[11px] uppercase tracking-[0.14em] text-muted-foreground hover:text-foreground">
            ← Stocks
          </Link>
          <h2 className="mt-1 text-[30px] font-bold leading-none tracking-tight">
            {holding.name} <span className="num text-[18px] font-semibold text-muted-foreground">({holding.ticker})</span>
          </h2>
          <p className="num mt-2 text-[11px] uppercase tracking-[0.14em] text-muted-foreground">
            {holding.industry} · last price {holding.lastPriceAt}
          </p>
        </div>
        <div className="text-right">
          <p className="num text-[34px] font-semibold leading-none tracking-tight">{num(holding.lastPrice)}</p>
          <div className="mt-1.5 flex items-center justify-end gap-2">
            <SignedPill value={holding.totalCost > 0 ? pctOf(pl, holding.totalCost) : 0} />
            {holding.targetBuy != null && (
              <span
                className={cn(
                  'num group relative px-1.5 py-0.5 text-[11px] font-medium',
                  holding.targetPriceNote && 'cursor-help',
                  holding.lastPrice <= holding.targetBuy ? 'bg-[hsl(152_66%_30%/0.12)] text-gain' : 'bg-secondary text-muted-foreground'
                )}
              >
                target {num(holding.targetBuy)}
                {holding.targetPriceNote && (
                  <span
                    role="tooltip"
                    className="pointer-events-none absolute right-0 top-full z-50 mt-1.5 hidden w-64 whitespace-pre-wrap border border-line bg-card px-3 py-2 text-left text-[12px] font-normal leading-snug text-foreground shadow-lg group-hover:block"
                  >
                    {holding.targetPriceNote}
                  </span>
                )}
              </span>
            )}
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        {/* Chart */}
        <div className="border border-line bg-card p-5 lg:col-span-2">
          <div className="flex items-baseline justify-between">
            <h3 className="text-[13px] font-bold uppercase tracking-[0.14em]">Price</h3>
            <div className="flex gap-1">
              {RANGES.map((r) => (
                <button
                  key={r.label}
                  onClick={() => setRange(r)}
                  className={cn(
                    'num px-2 py-0.5 text-[11px]',
                    range.label === r.label ? 'bg-foreground text-background' : 'text-muted-foreground hover:text-foreground'
                  )}
                >
                  {r.label}
                </button>
              ))}
            </div>
          </div>
          <div ref={chartRef} className="mt-3 h-[320px]" />
          <p className="mt-2 text-[11px] text-muted-foreground">
            Amber dashed line marks your average cost{cps > 0 ? ` (${peso(cps)})` : ''}
            {holding.targetBuy != null ? `, solid blue line your buy target (${num(holding.targetBuy)})` : ''}. Price history is your live PSE feed.
          </p>
          {holding.targetPriceNote && (
            <p className="mt-1.5 whitespace-pre-wrap text-[11px] leading-snug text-muted-foreground">
              <span className="font-semibold text-foreground/70">Target note:</span> {holding.targetPriceNote}
            </p>
          )}
        </div>

        {/* Position summary + owner utilities */}
        <div className="space-y-6">
          <div className="border border-line bg-card">
            <h3 className="border-b border-line px-5 py-3 text-[13px] font-bold uppercase tracking-[0.14em]">Position</h3>
            <dl>
              {rows.map(([k, v]) => (
                <div key={k} className="flex items-baseline justify-between border-b border-line/60 px-5 py-2.5 last:border-0">
                  <dt className="text-[12px] text-muted-foreground">{k}</dt>
                  <dd className="num text-[13px]">{v}</dd>
                </div>
              ))}
            </dl>
          </div>
          <UtilitiesPanel ticker={holding.ticker} />
        </div>
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        {/* Dividend history */}
        <div className="border border-line bg-card lg:col-span-2">
          <div className="flex items-baseline justify-between border-b border-line px-5 py-3">
            <h3 className="text-[13px] font-bold uppercase tracking-[0.14em]">Dividend history</h3>
            <span className="num text-[11px] text-div">{peso(holding.dividends)} all-time</span>
          </div>
          {dividends.length > 0 ? (
            <div className="scroll-thin max-h-[300px] overflow-y-auto">
              <table className="w-full border-collapse">
                <thead className="sticky top-0 bg-card">
                  <tr className="border-b border-line text-left">
                    <th className="num px-5 py-2 text-[10px] font-semibold uppercase tracking-[0.12em] text-muted-foreground">Month</th>
                    <th className="num px-3 py-2 text-right text-[10px] font-semibold uppercase tracking-[0.12em] text-muted-foreground">Amount</th>
                    <th className="num px-5 py-2 text-right text-[10px] font-semibold uppercase tracking-[0.12em] text-muted-foreground">Per share</th>
                  </tr>
                </thead>
                <tbody>
                  {dividends.map((d, i) => (
                    <tr key={i} className="border-b border-line/50 text-[12px] hover:bg-[hsl(32_88%_46%/0.06)]">
                      <td className="num px-5 py-1.5">{d.month} {d.year}</td>
                      <td className="num px-3 py-1.5 text-right text-div">{peso(d.amount)}</td>
                      <td className="num px-5 py-1.5 text-right text-muted-foreground">
                        {holding.shares > 0 ? peso(d.amount / holding.shares, { decimals: 3 }) : '—'}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : (
            <p className="px-5 py-6 text-[12px] text-muted-foreground">No dividends on record for this ticker.</p>
          )}
          {divsByYear.length > 0 && (
            <div className="flex flex-wrap gap-x-4 gap-y-1 border-t border-line px-5 py-3">
              {divsByYear.map(([y, amt]) => (
                <span key={y} className="num text-[11px] text-muted-foreground">
                  {y} <b className="text-div">{peso(amt, { decimals: 0 })}</b>
                </span>
              ))}
            </div>
          )}
        </div>

        {/* Activities */}
        <div className="border border-line bg-card">
          <h3 className="border-b border-line px-5 py-3 text-[13px] font-bold uppercase tracking-[0.14em]">Buy lots</h3>
          {activities.length > 0 ? (
            <table className="w-full border-collapse">
              <thead>
                <tr className="border-b border-line text-left">
                  <th className="num px-5 py-2 text-[10px] font-semibold uppercase tracking-[0.12em] text-muted-foreground">Date</th>
                  <th className="num px-3 py-2 text-right text-[10px] font-semibold uppercase tracking-[0.12em] text-muted-foreground">Shares</th>
                  <th className="num px-3 py-2 text-right text-[10px] font-semibold uppercase tracking-[0.12em] text-muted-foreground">Price</th>
                  <th className="num px-5 py-2 text-right text-[10px] font-semibold uppercase tracking-[0.12em] text-muted-foreground">Amount</th>
                </tr>
              </thead>
              <tbody>
                {activities.map((a, i) => (
                  <tr key={i} className="border-b border-line/50 text-[12px] hover:bg-[hsl(32_88%_46%/0.06)]">
                    <td className="num px-5 py-1.5">{niceDate(a.date)}</td>
                    <td className="num px-3 py-1.5 text-right">{num(a.shares, 0)}</td>
                    <td className="num px-3 py-1.5 text-right">{num(a.price)}</td>
                    <td className="num px-5 py-1.5 text-right">{peso(a.amount)}</td>
                  </tr>
                ))}
              </tbody>
              <tfoot>
                <tr className="bg-secondary/70 text-[12px] font-semibold">
                  <td className="num px-5 py-2 uppercase tracking-wide">Total</td>
                  <td className="num px-3 py-2 text-right">{num(holding.shares, 0)}</td>
                  <td className="num px-3 py-2 text-right">{num(cps)}</td>
                  <td className="num px-5 py-2 text-right">{peso(holding.totalCost)}</td>
                </tr>
              </tfoot>
            </table>
          ) : (
            <p className="px-5 py-6 text-[12px] text-muted-foreground">
              No open lots — this position was fully sold and the proceeds recycled into other holdings.
            </p>
          )}
        </div>
      </div>
    </div>
  )
}
