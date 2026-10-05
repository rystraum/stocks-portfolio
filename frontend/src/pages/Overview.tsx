import { useMemo, useState } from 'react'
import { Link } from 'react-router'
import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  Cell,
  Pie,
  PieChart,
  ReferenceLine,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts'
import GoalCard from '@/components/GoalCard'
import { SignedPill, Stat } from '@/components/Stat'
import { MONTHS, dividendYearsOf, yearDividendTotal } from '@/api/types'
import { fetchDividendsAll, fetchHoldings, fetchSummary } from '@/api/client'
import { ErrorNote, Loading, useApi } from '@/api/useApi'
import { compact, pct, pctOf, peso } from '@/lib/format'

const INK = '#16150f'
const DIV = 'hsl(32 88% 46%)'

function ChartTip({ active, payload, label }: any) {
  if (!active || !payload?.length) return null
  return (
    <div className="border border-line bg-card px-3 py-2 shadow-sm">
      <p className="num text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">{label}</p>
      {payload.map((p: any) => (
        <p key={p.dataKey} className="num text-[12px]" style={{ color: p.color }}>
          {p.name}: {peso(p.value)}
        </p>
      ))}
    </div>
  )
}

export default function Overview() {
  const { data: t, error: tErr } = useApi(fetchSummary)
  const { data: holdings, error: holdingsErr } = useApi(fetchHoldings)
  const { data: dividendsByYear, error: divsErr } = useApi(fetchDividendsAll)
  const dividendYears = dividendYearsOf(dividendsByYear)

  const growthData = useMemo(() => {
    let cumDivs = 0
    return (t?.capitalByYear ?? []).map((c) => {
      cumDivs += yearDividendTotal(dividendsByYear, c.year)
      return {
        year: c.year,
        'Capital in': c.cumulativeCost,
        'Dividends banked': Math.round(cumDivs * 100) / 100,
      }
    })
  }, [t, dividendsByYear])

  const [incomeYear, setIncomeYear] = useState<number>(0)
  const incomeData = useMemo(
    () =>
      (dividendsByYear?.[incomeYear] ?? []).map((m, i) => ({
        month: MONTHS[i],
        amount: Math.round(m.total * 100) / 100,
      })),
    [incomeYear, dividendsByYear]
  )
  const incomeAvg = yearDividendTotal(dividendsByYear, incomeYear) / (incomeYear === new Date().getFullYear() ? new Date().getMonth() + 1 : 12)

  const allocation = useMemo(() => {
    const rows = (holdings ?? [])
      .filter((h) => h.shares > 0)
      .map((h) => ({ ticker: h.ticker, value: h.shares * h.lastPrice }))
      .sort((a, b) => b.value - a.value)
    const top = rows.slice(0, 7)
    const rest = rows.slice(7).reduce((s, r) => s + r.value, 0)
    return [...top, { ticker: 'Other', value: rest }]
  }, [holdings])

  const topEarners = useMemo(
    () =>
      [...(holdings ?? [])]
        .filter((h) => h.dividends > 0)
        .sort((a, b) => b.dividends - a.dividends)
        .slice(0, 6),
    [holdings]
  )
  const maxEarner = topEarners[0]?.dividends ?? 1

  const DONUT_COLORS = ['#16150f', '#3d3a2e', '#6b6650', '#8f8a72', '#b3ad95', '#cfc9b3', DIV, '#a8a294']

  const err = tErr ?? holdingsErr ?? divsErr
  if (err) return <ErrorNote message={err} />
  if (!t || !holdings || !dividendsByYear) return <Loading />

  return (
    <div className="space-y-8">
      {/* KPI strip */}
      <div className="grid grid-cols-2 gap-x-6 gap-y-6 lg:grid-cols-4">
        <Stat
          label="Capital in · cost basis"
          value={peso(t.totalCost)}
          sub="Deposits only — nothing ever withdrawn"
        />
        <Stat
          label="Market value today"
          value={peso(t.currentValue)}
          tone={t.unrealizedPL >= 0 ? 'gain' : 'loss'}
          sub={
            <span className="num">
              {peso(t.unrealizedPL, { sign: true })} ({pct(pctOf(t.unrealizedPL, t.totalCost), 1, true)}) on open
              positions
            </span>
          }
        />
        <Stat
          label="Dividends banked"
          value={peso(t.dividends)}
          tone="div"
          sub={
            <span className="num">
              {pct(pctOf(t.dividends, t.totalCost))} of capital back — every peso reinvested
            </span>
          }
        />
        <Stat
          label="True position"
          value={peso(t.totalReturnInclDivs, { sign: true })}
          tone={t.totalReturnInclDivs >= 0 ? 'gain' : 'loss'}
          sub={
            <span className="num">
              {pct(pctOf(t.totalReturnInclDivs, t.totalCost), 1, true)} incl. dividends & recycled sales
            </span>
          }
        />
      </div>

      {/* Growth + goal */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        <div className="border border-line bg-card p-5 lg:col-span-2">
          <div className="flex flex-wrap items-baseline justify-between gap-2">
            <h3 className="text-[13px] font-bold uppercase tracking-[0.14em]">Capital in vs. dividends out</h3>
            <p className="num text-[11px] text-muted-foreground">cumulative, by year</p>
          </div>
          <div className="mt-4 h-[280px]">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={growthData} margin={{ top: 4, right: 4, bottom: 0, left: 4 }}>
                <XAxis dataKey="year" tick={{ fontSize: 11, fontFamily: 'IBM Plex Mono' }} stroke={INK} tickLine={false} axisLine={{ stroke: '#d9d3c4' }} />
                <YAxis
                  tickFormatter={(v: number) => compact(v)}
                  tick={{ fontSize: 11, fontFamily: 'IBM Plex Mono' }}
                  stroke={INK}
                  tickLine={false}
                  axisLine={false}
                  width={48}
                />
                <Tooltip content={<ChartTip />} />
                <Area isAnimationActive={false} type="monotone" dataKey="Capital in" stroke={INK} fill={INK} fillOpacity={0.08} strokeWidth={1.5} />
                <Area isAnimationActive={false} type="monotone" dataKey="Dividends banked" stroke={DIV} fill={DIV} fillOpacity={0.18} strokeWidth={2} />
              </AreaChart>
            </ResponsiveContainer>
          </div>
          <p className="mt-3 text-[12px] leading-snug text-muted-foreground">
            The amber curve is cash the portfolio has paid you back — {peso(t.dividends)} so far, all of it recycled
            into more shares. Market value dipped below cost in 2026, but the income curve has never gone down.
          </p>
        </div>

        <GoalCard />
      </div>

      {/* Monthly income + allocation + earners */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        <div className="border border-line bg-card p-5">
          <div className="flex items-baseline justify-between">
            <h3 className="text-[13px] font-bold uppercase tracking-[0.14em]">Monthly income</h3>
            <div className="flex gap-1">
              {dividendYears.slice(-4).map((y) => (
                <button
                  key={y}
                  onClick={() => setIncomeYear(y)}
                  className={`num px-1.5 py-0.5 text-[11px] ${
                    incomeYear === y ? 'bg-foreground text-background' : 'text-muted-foreground hover:text-foreground'
                  }`}
                >
                  {y}
                </button>
              ))}
            </div>
          </div>
          <div className="mt-4 h-[220px]">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={incomeData} margin={{ top: 8, right: 0, bottom: 0, left: 0 }}>
                <XAxis dataKey="month" tick={{ fontSize: 10, fontFamily: 'IBM Plex Mono' }} stroke={INK} tickLine={false} axisLine={false} interval={0} />
                <YAxis tickFormatter={(v: number) => compact(v)} tick={{ fontSize: 10, fontFamily: 'IBM Plex Mono' }} stroke={INK} tickLine={false} axisLine={false} width={40} />
                <Tooltip content={<ChartTip />} cursor={{ fill: 'rgba(22,21,15,0.05)' }} />
                <ReferenceLine y={incomeAvg} stroke={INK} strokeDasharray="3 3" strokeOpacity={0.5} />
                <Bar isAnimationActive={false} dataKey="amount" name="Dividends" fill={DIV} maxBarSize={22} />
              </BarChart>
            </ResponsiveContainer>
          </div>
          <p className="num mt-2 text-[11px] text-muted-foreground">
            {incomeYear} total {peso(yearDividendTotal(dividendsByYear, incomeYear))} · avg {peso(incomeAvg)}/mo (dashed)
          </p>
        </div>

        <div className="border border-line bg-card p-5">
          <h3 className="text-[13px] font-bold uppercase tracking-[0.14em]">Where the money sits</h3>
          <div className="mt-2 flex items-center">
            <div className="h-[210px] w-1/2">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie isAnimationActive={false} data={allocation} dataKey="value" nameKey="ticker" innerRadius={56} outerRadius={88} paddingAngle={1} strokeWidth={0}>
                    {allocation.map((_, i) => (
                      <Cell key={i} fill={DONUT_COLORS[i % DONUT_COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip
                    content={({ active, payload }: any) =>
                      active && payload?.length ? (
                        <div className="border border-line bg-card px-2.5 py-1.5 shadow-sm">
                          <p className="num text-[12px]">
                            <b>{payload[0].name}</b> {peso(payload[0].value)} · {pct(pctOf(payload[0].value, t.currentValue))}
                          </p>
                        </div>
                      ) : null
                    }
                  />
                </PieChart>
              </ResponsiveContainer>
            </div>
            <ul className="w-1/2 space-y-1.5 pl-3">
              {allocation.map((a, i) => (
                <li key={a.ticker} className="flex items-center gap-2 text-[12px]">
                  <span className="h-2 w-2 shrink-0" style={{ background: DONUT_COLORS[i % DONUT_COLORS.length] }} />
                  <Link to={`/stocks/${a.ticker}`} className="num font-medium hover:underline">
                    {a.ticker}
                  </Link>
                  <span className="num ml-auto text-muted-foreground">{pct(pctOf(a.value, t.currentValue))}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>

        <div className="border border-line bg-card p-5">
          <div className="flex items-baseline justify-between">
            <h3 className="text-[13px] font-bold uppercase tracking-[0.14em]">Dividend workhorses</h3>
            <span className="num text-[11px] text-muted-foreground">all-time</span>
          </div>
          <ul className="mt-4 space-y-3">
            {topEarners.map((h) => {
              const total = h.shares > 0 ? h.shares * h.lastPrice - h.totalCost + h.dividends : (h.realizedPL ?? 0) + h.dividends
              return (
                <li key={h.ticker}>
                  <div className="flex items-baseline justify-between">
                    <Link to={`/stocks/${h.ticker}`} className="num text-[13px] font-semibold hover:underline">
                      {h.ticker}
                    </Link>
                    <span className="num text-[13px] text-div">{peso(h.dividends)}</span>
                  </div>
                  <div className="mt-1 flex items-center gap-2">
                    <div className="h-1.5 flex-1 bg-secondary">
                      <div className="h-full bg-div" style={{ width: `${(h.dividends / maxEarner) * 100}%` }} />
                    </div>
                    <SignedPill value={h.totalCost > 0 ? pctOf(total, h.totalCost) : 0} />
                  </div>
                </li>
              )
            })}
          </ul>
          <p className="mt-4 border-t border-line pt-3 text-[11px] leading-snug text-muted-foreground">
            DMC alone has returned {pct(pctOf(37422, 131049.98))} of its cost basis in cash.
          </p>
        </div>
      </div>
    </div>
  )
}
