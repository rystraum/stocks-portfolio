import { useMemo, useState } from 'react'
import {
  Bar,
  Cell,
  ComposedChart,
  Line,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
  BarChart,
} from 'recharts'
import GoalCard from '@/components/GoalCard'
import { Stat } from '@/components/Stat'
import { MONTHS, dividendYearsOf, yearDividendTotal, type DividendMonth } from '@/api/types'
import { fetchDividendsAll, fetchSummary } from '@/api/client'
import { ErrorNote, Loading, useApi } from '@/api/useApi'
import { cn } from '@/lib/utils'
import { compact, pct, pctOf, peso } from '@/lib/format'

const INK = '#16150f'
const DIV = 'hsl(32 88% 46%)'
const QUARTERS = ['Q1', 'Q2', 'Q3', 'Q4'] as const

interface Bucket {
  total: number
  items: { ticker: string; amount: number }[]
  payoutCount: number
}

interface HoverCell {
  year: number
  idx: number
}

/** Side panel listing the ticker breakdown of the hovered ladder cell. */
function LadderPanel({
  heading,
  bucket,
  hint,
}: {
  heading: string
  bucket: Bucket | null
  hint: string
}) {
  return (
    <div className="flex flex-col border border-line bg-card p-5">
      <h3 className="text-[13px] font-bold uppercase tracking-[0.14em]">{heading}</h3>
      {bucket && bucket.total > 0 ? (
        <>
          <p className="num mt-2 text-[24px] font-semibold tracking-tight text-div">{peso(bucket.total)}</p>
          <p className="num text-[11px] text-muted-foreground">{bucket.payoutCount} payouts</p>
          <ul className="mt-4 flex-1 space-y-1.5 overflow-y-auto">
            {bucket.items
              .slice()
              .sort((a, b) => b.amount - a.amount)
              .map((it) => (
                <li key={it.ticker} className="flex items-baseline justify-between border-b border-line/60 pb-1">
                  <span className="num text-[12px] font-semibold">{it.ticker}</span>
                  <span className="num text-[12px]">{peso(it.amount)}</span>
                </li>
              ))}
          </ul>
        </>
      ) : (
        <p className="mt-4 flex-1 text-[12px] leading-relaxed text-muted-foreground">
          {bucket ? 'No dividends landed in this period.' : hint}
        </p>
      )}
    </div>
  )
}

/** Amber heatmap cell shared by both ladders. */
function HeatCell({
  value,
  max,
  future,
  onEnter,
}: {
  value: number
  max: number
  future: boolean
  onEnter: () => void
}) {
  const intensity = value / max
  return (
    <td className="p-0.5">
      <div
        onMouseEnter={onEnter}
        className={cn(
          'num flex h-9 items-center justify-center text-[10px] transition-transform',
          future
            ? 'border border-dashed border-line text-muted-foreground/50'
            : value > 0
              ? 'cursor-default text-[#131311] hover:scale-105'
              : 'text-muted-foreground/40'
        )}
        style={!future && value > 0 ? { backgroundColor: `hsl(32 88% 46% / ${0.12 + intensity * 0.75})` } : undefined}
      >
        {future ? '·' : value > 0 ? compact(value) : '·'}
      </div>
    </td>
  )
}

function Legend({ currentYear, unit }: { currentYear: number; unit: string }) {
  return (
    <div className="mt-3 flex items-center gap-2 text-[11px] text-muted-foreground">
      <span className="num">less</span>
      {[0.12, 0.3, 0.5, 0.7, 0.87].map((o) => (
        <span key={o} className="h-3 w-6" style={{ backgroundColor: `hsl(32 88% 46% / ${o})` }} />
      ))}
      <span className="num">more</span>
      <span className="ml-3">
        dashed = {unit} still ahead in {currentYear}
      </span>
    </div>
  )
}

export default function Dividends() {
  const [hoverMonth, setHoverMonth] = useState<HoverCell | null>(null)
  const [hoverQuarter, setHoverQuarter] = useState<HoverCell | null>(null)
  const { data: t, error: tErr } = useApi(fetchSummary)
  const { data: dividendsByYear, error: divsErr } = useApi(fetchDividendsAll)
  const dividendYears = dividendYearsOf(dividendsByYear)
  const currentYear = dividendYears[dividendYears.length - 1]

  const yearly = useMemo(
    () =>
      dividendYears.map((y) => {
        const total = yearDividendTotal(dividendsByYear, y)
        const cost = (t?.capitalByYear ?? []).find((c) => c.year === y)?.cumulativeCost ?? 1
        const prev = y > dividendYears[0] ? yearDividendTotal(dividendsByYear, y - 1) : 0
        return {
          year: y,
          total: Math.round(total * 100) / 100,
          yieldOnCost: pctOf(total, cost),
          yoy: prev > 0 ? pctOf(total - prev, prev) : null,
        }
      }),
    [dividendsByYear, t]
  )

  // Quarterly aggregation: sum each year's months into Q1–Q4 buckets
  const quarterlyByYear = useMemo(() => {
    const out: Record<number, Bucket[]> = {}
    for (const y of dividendYears) {
      out[y] = QUARTERS.map((_, q) => {
        const months = (dividendsByYear?.[y] ?? []).slice(q * 3, q * 3 + 3)
        const byTicker = new Map<string, number>()
        let payoutCount = 0
        for (const m of months) {
          for (const it of m.items ?? []) {
            byTicker.set(it.ticker, (byTicker.get(it.ticker) ?? 0) + it.amount)
            payoutCount++
          }
        }
        return {
          total: months.reduce((s, m) => s + m.total, 0),
          items: [...byTicker.entries()].map(([ticker, amount]) => ({ ticker, amount })),
          payoutCount,
        }
      })
    }
    return out
  }, [dividendsByYear, t])

  const maxQuarter = useMemo(() => {
    let max = 1
    for (const y of dividendYears) for (const q of quarterlyByYear[y]) max = Math.max(max, q.total)
    return max
  }, [quarterlyByYear])

  const maxMonth = useMemo(() => {
    let max = 1
    for (const y of dividendYears) for (const m of dividendsByYear?.[y] ?? []) max = Math.max(max, m.total)
    return max
  }, [dividendsByYear])

  const quarterCoverage = useMemo(
    () =>
      QUARTERS.map((label, q) => {
        const vals = dividendYears.map((y) => quarterlyByYear[y][q])
        const payers = new Set(vals.flatMap((v) => v.items.map((it) => it.ticker)))
        const nonzero = vals.filter((v) => v.total > 0)
        return {
          quarter: label,
          avg: nonzero.length ? nonzero.reduce((s, v) => s + v.total, 0) / nonzero.length : 0,
          payers: payers.size,
          years: nonzero.length,
        }
      }),
    [quarterlyByYear]
  )
  const maxQuarterAvg = Math.max(...quarterCoverage.map((c) => c.avg), 1)

  const monthCoverage = useMemo(
    () =>
      MONTHS.map((label, i) => {
        const vals = dividendYears
          .map((y) => dividendsByYear?.[y]?.[i])
          .filter((m): m is DividendMonth => Boolean(m))
        const payers = new Set(vals.flatMap((v) => v.items?.map((it) => it.ticker) ?? []))
        const nonzero = vals.filter((v) => v.total > 0)
        return {
          month: label,
          avg: nonzero.length ? nonzero.reduce((s, v) => s + v.total, 0) / nonzero.length : 0,
          payers: payers.size,
          years: nonzero.length,
        }
      }),
    [dividendsByYear]
  )
  const maxMonthAvg = Math.max(...monthCoverage.map((c) => c.avg), 1)

  const bestYear = yearly.length
    ? yearly.reduce((a, b) => (b.total > a.total ? b : a))
    : null
  const ttm = yearly[yearly.length - 2]

  const hoveredMonthBucket: Bucket | null = hoverMonth
    ? (() => {
        const m = dividendsByYear?.[hoverMonth.year]?.[hoverMonth.idx]
        if (!m) return null
        return { total: m.total, items: m.items ?? [], payoutCount: m.items?.length ?? 0 }
      })()
    : null
  const hoveredQuarterBucket: Bucket | null = hoverQuarter ? quarterlyByYear[hoverQuarter.year][hoverQuarter.idx] : null

  const coverageTip = () => ({ active, payload, label }: any) =>
    active && payload?.length ? (
      <div className="border border-line bg-card px-3 py-2 shadow-sm">
        <p className="num text-[11px] font-semibold text-muted-foreground">{label}</p>
        <p className="num text-[12px] text-div">avg {peso(payload[0].payload.avg)}</p>
        <p className="num text-[11px] text-muted-foreground">
          {payload[0].payload.payers} distinct payers · paid in {payload[0].payload.years} of {dividendYears.length} years
        </p>
      </div>
    ) : null

  const err = tErr ?? divsErr
  if (err) return <ErrorNote message={err} />
  if (!t || !dividendsByYear || !bestYear || !ttm) return <Loading />

  return (
    <div className="space-y-8">
      <div className="grid grid-cols-2 gap-x-6 gap-y-5 lg:grid-cols-4">
        <Stat
          label="Dividends banked · all-time"
          value={peso(t.dividends)}
          tone="div"
          sub="100% reinvested into more shares"
        />
        <Stat
          label="Best year"
          value={peso(bestYear.total)}
          sub={<span className="num">{bestYear.year} · {pct(pctOf(bestYear.total - yearDividendTotal(dividendsByYear, bestYear.year - 1), yearDividendTotal(dividendsByYear, bestYear.year - 1)), 0, true)} YoY</span>}
        />
        <Stat
          label={`Yield on cost · ${ttm.year}`}
          value={pct(ttm.yieldOnCost)}
          tone="div"
          sub={<span className="num">{peso(ttm.total)} on a {peso((t?.capitalByYear ?? []).find((c) => c.year === ttm.year)?.cumulativeCost ?? 0, { decimals: 0 })} base</span>}
        />
        <Stat
          label="Monthly average"
          value={peso(ttm.total / 12)}
          sub={<span className="num">{ttm.year} full-year · 2018 was {peso(yearDividendTotal(dividendsByYear, 2018) / 12)}</span>}
        />
      </div>

      {/* 1 · Annual */}
      <div className="border border-line bg-card p-5">
        <div className="flex flex-wrap items-baseline justify-between gap-2">
          <h3 className="text-[13px] font-bold uppercase tracking-[0.14em]">Annual — dividends per year</h3>
          <p className="num text-[11px] text-muted-foreground">bars: cash received · line: yield on cost</p>
        </div>
        <div className="mt-4 h-[260px]">
          <ResponsiveContainer width="100%" height="100%">
            <ComposedChart data={yearly} margin={{ top: 8, right: 4, bottom: 0, left: 4 }}>
              <XAxis dataKey="year" tick={{ fontSize: 11, fontFamily: 'IBM Plex Mono' }} stroke={INK} tickLine={false} axisLine={{ stroke: '#d9d3c4' }} />
              <YAxis yAxisId="l" tickFormatter={(v: number) => compact(v)} tick={{ fontSize: 11, fontFamily: 'IBM Plex Mono' }} stroke={INK} tickLine={false} axisLine={false} width={44} />
              <YAxis yAxisId="r" orientation="right" tickFormatter={(v: number) => `${v}%`} tick={{ fontSize: 11, fontFamily: 'IBM Plex Mono' }} stroke={INK} tickLine={false} axisLine={false} width={36} domain={[0, 8]} />
              <Tooltip
                content={({ active, payload, label }: any) =>
                  active && payload?.length ? (
                    <div className="border border-line bg-card px-3 py-2 shadow-sm">
                      <p className="num text-[11px] font-semibold text-muted-foreground">{label}</p>
                      <p className="num text-[12px] text-div">{peso(payload[0].payload.total)}</p>
                      <p className="num text-[11px] text-muted-foreground">
                        yield on cost {payload[0].payload.yieldOnCost.toFixed(1)}%
                        {payload[0].payload.yoy != null && ` · YoY ${payload[0].payload.yoy >= 0 ? '+' : ''}${payload[0].payload.yoy.toFixed(0)}%`}
                      </p>
                    </div>
                  ) : null
                }
              />
              <Bar isAnimationActive={false} yAxisId="l" dataKey="total" name="Dividends" fill={DIV} maxBarSize={40}>
                {yearly.map((y) => (
                  <Cell key={y.year} fillOpacity={y.year === currentYear ? 0.45 : 1} />
                ))}
              </Bar>
              <Line isAnimationActive={false} yAxisId="r" type="monotone" dataKey="yieldOnCost" name="Yield on cost" stroke={INK} strokeWidth={1.5} dot={{ r: 2.5, fill: INK }} />
            </ComposedChart>
          </ResponsiveContainer>
        </div>
        <p className="mt-3 text-[12px] text-muted-foreground">
          {currentYear} is partial (through June). Yield on cost has climbed every single year — from 1.6% in 2018 to{' '}
          {pct(ttm.yieldOnCost)} in {ttm.year} — because the cost base only grows while dividends compound on top of it.
        </p>
      </div>

      {/* 2 · Ladder — quarterly */}
      <div className="grid grid-cols-1 gap-6 xl:grid-cols-3">
        <div className="border border-line bg-card p-5 xl:col-span-2">
          <div className="flex flex-wrap items-baseline justify-between gap-2">
            <h3 className="text-[13px] font-bold uppercase tracking-[0.14em]">Ladder — quarterly</h3>
            <p className="num text-[11px] text-muted-foreground">hover a cell for the breakdown</p>
          </div>
          <div className="scroll-thin mt-4 overflow-x-auto">
            <table className="w-full min-w-[480px] border-collapse">
              <thead>
                <tr>
                  <th className="num px-2 py-1 text-left text-[10px] font-semibold uppercase tracking-[0.12em] text-muted-foreground">Year</th>
                  {QUARTERS.map((q) => (
                    <th key={q} className="num px-1 py-1 text-center text-[10px] font-semibold uppercase tracking-wide text-muted-foreground">
                      {q}
                    </th>
                  ))}
                  <th className="num px-2 py-1 text-right text-[10px] font-semibold uppercase tracking-[0.12em] text-muted-foreground">Total</th>
                </tr>
              </thead>
              <tbody>
                {[...dividendYears].reverse().map((y) => (
                  <tr key={y} className="border-t border-line">
                    <td className="num px-2 py-1 text-[12px] font-semibold">{y}</td>
                    {quarterlyByYear[y].map((b, q) => (
                      <HeatCell
                        key={q}
                        value={b.total}
                        max={maxQuarter}
                        future={y === currentYear && q >= 2}
                        onEnter={() => setHoverQuarter({ year: y, idx: q })}
                      />
                    ))}
                    <td className="num px-2 py-1 text-right text-[12px] font-semibold text-div">{peso(yearDividendTotal(dividendsByYear, y), { decimals: 0 })}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <Legend currentYear={currentYear} unit="quarters" />
        </div>

        <LadderPanel
          heading={hoverQuarter ? `${QUARTERS[hoverQuarter.idx]} ${hoverQuarter.year}` : 'Quarter breakdown'}
          bucket={hoveredQuarterBucket}
          hint="Hover any quarter in the ladder to see exactly which tickers paid and how much."
        />
      </div>

      {/* 3 · Quarter coverage */}
      <div className="border border-line bg-card p-5">
        <div className="flex flex-wrap items-baseline justify-between gap-2">
          <h3 className="text-[13px] font-bold uppercase tracking-[0.14em]">Quarter coverage</h3>
          <p className="num text-[11px] text-muted-foreground">avg amount when paid · distinct payers since 2018</p>
        </div>
        <div className="mt-4 h-[240px]">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={quarterCoverage} margin={{ top: 8, right: 4, bottom: 0, left: 4 }}>
              <XAxis dataKey="quarter" tick={{ fontSize: 11, fontFamily: 'IBM Plex Mono' }} stroke={INK} tickLine={false} axisLine={{ stroke: '#d9d3c4' }} interval={0} />
              <YAxis tickFormatter={(v: number) => compact(v)} tick={{ fontSize: 11, fontFamily: 'IBM Plex Mono' }} stroke={INK} tickLine={false} axisLine={false} width={44} />
              <Tooltip content={coverageTip()} cursor={{ fill: 'rgba(22,21,15,0.05)' }} />
              <Bar isAnimationActive={false} dataKey="avg" name="Avg payout" maxBarSize={64}>
                {quarterCoverage.map((c) => (
                  <Cell key={c.quarter} fill={c.avg < maxQuarterAvg * 0.25 ? 'hsl(8 66% 45% / 0.55)' : DIV} />
                ))}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </div>
        <p className="mt-3 text-[12px] leading-snug text-muted-foreground">
          PSE dividend payers cluster around Q2 (annual meeting season) and Q4. A quarter that stays red means the
          portfolio depends on one or two payers for that stretch — a candidate for rebalancing when recycling dividends.
        </p>
      </div>

      {/* 4 · Ladder — monthly */}
      <div className="grid grid-cols-1 gap-6 xl:grid-cols-3">
        <div className="border border-line bg-card p-5 xl:col-span-2">
          <div className="flex flex-wrap items-baseline justify-between gap-2">
            <h3 className="text-[13px] font-bold uppercase tracking-[0.14em]">Ladder — monthly</h3>
            <p className="num text-[11px] text-muted-foreground">hover a cell for the breakdown</p>
          </div>
          <div className="scroll-thin mt-4 overflow-x-auto">
            <table className="w-full min-w-[720px] border-collapse">
              <thead>
                <tr>
                  <th className="num px-2 py-1 text-left text-[10px] font-semibold uppercase tracking-[0.12em] text-muted-foreground">Year</th>
                  {MONTHS.map((m) => (
                    <th key={m} className="num px-1 py-1 text-center text-[10px] font-semibold uppercase tracking-wide text-muted-foreground">
                      {m}
                    </th>
                  ))}
                  <th className="num px-2 py-1 text-right text-[10px] font-semibold uppercase tracking-[0.12em] text-muted-foreground">Total</th>
                </tr>
              </thead>
              <tbody>
                {[...dividendYears].reverse().map((y) => (
                  <tr key={y} className="border-t border-line">
                    <td className="num px-2 py-1 text-[12px] font-semibold">{y}</td>
                    {dividendsByYear[y].map((m, i) => (
                      <HeatCell
                        key={i}
                        value={m.total}
                        max={maxMonth}
                        future={y === currentYear && i >= 7}
                        onEnter={() => setHoverMonth({ year: y, idx: i })}
                      />
                    ))}
                    <td className="num px-2 py-1 text-right text-[12px] font-semibold text-div">{peso(yearDividendTotal(dividendsByYear, y), { decimals: 0 })}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <Legend currentYear={currentYear} unit="months" />
        </div>

        <LadderPanel
          heading={hoverMonth ? `${MONTHS[hoverMonth.idx]} ${hoverMonth.year}` : 'Month breakdown'}
          bucket={hoveredMonthBucket}
          hint="Hover any month in the ladder to see exactly which tickers paid and how much."
        />
      </div>

      {/* 5 · Month coverage */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        <div className="border border-line bg-card p-5 lg:col-span-2">
          <div className="flex flex-wrap items-baseline justify-between gap-2">
            <h3 className="text-[13px] font-bold uppercase tracking-[0.14em]">Month coverage — building toward every-month payouts</h3>
            <p className="num text-[11px] text-muted-foreground">avg amount when paid · distinct payers since 2018</p>
          </div>
          <div className="mt-4 h-[240px]">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={monthCoverage} margin={{ top: 8, right: 4, bottom: 0, left: 4 }}>
                <XAxis dataKey="month" tick={{ fontSize: 11, fontFamily: 'IBM Plex Mono' }} stroke={INK} tickLine={false} axisLine={{ stroke: '#d9d3c4' }} interval={0} />
                <YAxis tickFormatter={(v: number) => compact(v)} tick={{ fontSize: 11, fontFamily: 'IBM Plex Mono' }} stroke={INK} tickLine={false} axisLine={false} width={44} />
                <Tooltip content={coverageTip()} cursor={{ fill: 'rgba(22,21,15,0.05)' }} />
                <Bar isAnimationActive={false} dataKey="avg" name="Avg payout" maxBarSize={34}>
                  {monthCoverage.map((c) => (
                    <Cell key={c.month} fill={c.avg < maxMonthAvg * 0.25 ? 'hsl(8 66% 45% / 0.55)' : DIV} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>
          <p className="mt-3 text-[12px] leading-snug text-muted-foreground">
            Red months are the gaps in the monthly-paycheck goal — February and August have historically been thin.
            Companies that declare in those months are worth a look next time dividends get recycled.
          </p>
        </div>
        <GoalCard />
      </div>
    </div>
  )
}
