import { useMemo, useState } from 'react'
import { Link } from 'react-router'
import { SignedPill, Stat } from '@/components/Stat'
import { fetchHoldings, fetchSummary } from '@/api/client'
import type { Holding } from '@/api/types'
import { Loading, useApi } from '@/api/useApi'
import { cn } from '@/lib/utils'
import { num, pct, pctOf, peso, signedClass } from '@/lib/format'

type SortKey = 'ticker' | 'value' | 'weight' | 'pl' | 'plPct' | 'divs' | 'totalPct'

function marketValue(h: Holding) {
  return h.shares * h.lastPrice
}
function unrealized(h: Holding) {
  return h.shares > 0 ? marketValue(h) - h.totalCost : (h.realizedPL ?? 0)
}
function totalReturn(h: Holding) {
  return unrealized(h) + h.dividends
}
function totalReturnPct(h: Holding) {
  const base = h.totalCost > 0 ? h.totalCost : Math.abs(h.realizedPL ?? 0) + h.dividends
  return base === 0 ? 0 : pctOf(totalReturn(h), base)
}

export default function Stocks() {
  const { data: t } = useApi(fetchSummary)
  const { data: holdings } = useApi(fetchHoldings)
  const [sortKey, setSortKey] = useState<SortKey>('value')
  const [sortDir, setSortDir] = useState<-1 | 1>(-1)
  const [query, setQuery] = useState('')
  const [showRecycled, setShowRecycled] = useState(true)
  const [showInactive, setShowInactive] = useState(false)

  const rows = useMemo(() => {
    const q = query.trim().toUpperCase()
    const list = (holdings ?? []).filter((h) => {
      if (!h.active && !showInactive) return false
      if (h.active && h.shares === 0 && !showRecycled) return false
      if (q && !h.ticker.includes(q) && !h.name.toUpperCase().includes(q)) return false
      return true
    })
    const get: Record<SortKey, (h: Holding) => number | string> = {
      ticker: (h) => h.ticker,
      value: (h) => marketValue(h),
      weight: (h) => (t ? pctOf(marketValue(h), t.currentValue) : 0),
      pl: (h) => unrealized(h),
      plPct: (h) => (h.totalCost > 0 ? pctOf(unrealized(h), h.totalCost) : 0),
      divs: (h) => h.dividends,
      totalPct: (h) => totalReturnPct(h),
    }
    return [...list].sort((a, b) => {
      const va = get[sortKey](a)
      const vb = get[sortKey](b)
      const cmp = typeof va === 'string' ? va.localeCompare(vb as string) : va - (vb as number)
      return cmp * sortDir
    })
  }, [query, showRecycled, showInactive, sortKey, sortDir, t])

  const activeCount = (holdings ?? []).filter((h) => h.shares > 0).length

  function th(key: SortKey | null, label: string, align: 'left' | 'right' = 'right') {
    const active = key && sortKey === key
    return (
      <th
        className={cn(
          'num whitespace-nowrap px-3 py-2 text-[10px] font-semibold uppercase tracking-[0.12em]',
          align === 'right' ? 'text-right' : 'text-left',
          key ? 'cursor-pointer select-none hover:text-[#f4f1ea]' : ''
        )}
        onClick={
          key
            ? () => {
                if (sortKey === key) setSortDir((d) => (d === 1 ? -1 : 1))
                else {
                  setSortKey(key)
                  setSortDir(key === 'ticker' ? 1 : -1)
                }
              }
            : undefined
        }
      >
        {label}
        {active && <span className="ml-1 text-[#0f0]">{sortDir === 1 ? '↑' : '↓'}</span>}
      </th>
    )
  }

  if (!t || !holdings) return <Loading />

  return (
    <div className="space-y-6">
      {/* Summary strip */}
      <div className="grid grid-cols-2 gap-x-6 gap-y-5 md:grid-cols-4">
        <Stat label="Positions" value={String(activeCount)} sub={`${holdings.length - activeCount} recycled or inactive`} />
        <Stat label="Cost basis" value={peso(t.totalCost)} sub={`market value ${peso(t.currentValue)}`} />
        <Stat
          label="Unrealized P/L"
          value={peso(t.unrealizedPL, { sign: true })}
          tone={t.unrealizedPL >= 0 ? 'gain' : 'loss'}
          sub={<span className="num">{pct(pctOf(t.unrealizedPL, t.totalCost), 1, true)} on cost</span>}
        />
        <Stat
          label="Total return incl. dividends"
          value={peso(t.totalReturnInclDivs, { sign: true })}
          tone={t.totalReturnInclDivs >= 0 ? 'gain' : 'loss'}
          sub={<span className="num">{pct(pctOf(t.totalReturnInclDivs, t.totalCost), 1, true)} — the number that matters</span>}
        />
      </div>

      {/* Controls */}
      <div className="flex flex-wrap items-center gap-x-5 gap-y-2">
        <input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Filter ticker or name…"
          className="num w-52 border border-line bg-card px-2.5 py-1.5 text-[12px] outline-none placeholder:text-muted-foreground/60 focus:border-foreground"
        />
        {[
          { label: 'Recycled (0 shares)', on: showRecycled, set: setShowRecycled },
          { label: 'Inactive / delisted', on: showInactive, set: setShowInactive },
        ].map((c) => (
          <button
            key={c.label}
            onClick={() => c.set(!c.on)}
            className={cn(
              'num border px-2.5 py-1.5 text-[11px] font-medium uppercase tracking-wide transition-colors',
              c.on ? 'border-foreground bg-foreground text-background' : 'border-line text-muted-foreground hover:text-foreground'
            )}
          >
            {c.label}
          </button>
        ))}
        <span className="num ml-auto text-[11px] text-muted-foreground">{rows.length} rows</span>
      </div>

      {/* Holdings table */}
      <div className="scroll-thin overflow-x-auto border border-line bg-card">
        <table className="w-full min-w-[1080px] border-collapse">
          <thead className="sticky top-0">
            <tr className="bg-[#131311] text-[#f4f1ea]/70">
              {th('ticker', 'Company', 'left')}
              {th(null, 'Shares')}
              {th(null, 'Avg cost')}
              {th(null, 'Last')}
              {th(null, 'Cost basis')}
              {th('value', 'Value')}
              {th('weight', 'Weight', 'left')}
              {th('pl', 'P/L')}
              {th('divs', 'Dividends')}
              {th('totalPct', 'Total incl. divs')}
            </tr>
          </thead>
          <tbody>
            {rows.map((h) => {
              const value = marketValue(h)
              const pl = unrealized(h)
              const tot = totalReturn(h)
              const totPct = totalReturnPct(h)
              const dimmed = h.shares === 0
              return (
                <tr
                  key={h.ticker}
                  className={cn(
                    'group border-t border-line text-[13px] transition-colors hover:bg-[hsl(32_88%_46%/0.07)]',
                    dimmed && 'text-muted-foreground',
                    !h.active && 'bg-secondary/60'
                  )}
                >
                  <td className="px-3 py-2">
                    <div className="flex items-center gap-2">
                      <Link to={`/stocks/${h.ticker}`} className="num font-semibold text-foreground group-hover:underline">
                        {h.ticker}
                      </Link>
                      {!h.active && <span className="num text-[9px] uppercase tracking-wide text-loss">inactive</span>}
                      {h.active && dimmed && <span className="num text-[9px] uppercase tracking-wide text-muted-foreground">recycled</span>}
                    </div>
                    <div className="max-w-[180px] truncate text-[11px] text-muted-foreground">{h.name}</div>
                  </td>
                  <td className="num px-3 py-2 text-right">{h.shares > 0 ? num(h.shares, 0) : '—'}</td>
                  <td className="num px-3 py-2 text-right">{h.shares > 0 ? num(h.totalCost / h.shares) : '—'}</td>
                  <td className="px-3 py-2 text-right">
                    <div className="num">{num(h.lastPrice)}</div>
                    {h.targetBuy != null && (
                      <div className={cn('num text-[10px]', h.lastPrice <= h.targetBuy ? 'text-gain' : 'text-muted-foreground')}>
                        target {num(h.targetBuy)}
                      </div>
                    )}
                  </td>
                  <td className="num px-3 py-2 text-right">{h.totalCost > 0 ? peso(h.totalCost) : '—'}</td>
                  <td className="num px-3 py-2 text-right font-medium">{value > 0 ? peso(value) : '—'}</td>
                  <td className="px-3 py-2">
                    {value > 0 ? (
                      <div className="flex items-center gap-2">
                        <div className="h-1.5 w-14 bg-secondary">
                          <div className="h-full bg-foreground" style={{ width: `${Math.min(100, pctOf(value, t.currentValue) * 4.5)}%` }} />
                        </div>
                        <span className="num text-[11px] text-muted-foreground">{pct(pctOf(value, t.currentValue))}</span>
                      </div>
                    ) : (
                      <span className="num text-[11px] text-muted-foreground">—</span>
                    )}
                  </td>
                  <td className="px-3 py-2 text-right">
                    <div className={cn('num', signedClass(pl))}>{peso(pl, { sign: true })}</div>
                    {h.totalCost > 0 && <div className={cn('num text-[10px]', signedClass(pl))}>{pct(pctOf(pl, h.totalCost), 1, true)}</div>}
                  </td>
                  <td className="num px-3 py-2 text-right text-div">{h.dividends > 0 ? peso(h.dividends) : '—'}</td>
                  <td className="px-3 py-2 text-right">
                    <div className={cn('num font-medium', signedClass(tot))}>{peso(tot, { sign: true })}</div>
                    <SignedPill value={totPct} className="mt-0.5" />
                  </td>
                </tr>
              )
            })}
          </tbody>
          <tfoot>
            <tr className="border-t-2 border-foreground bg-secondary/70 text-[13px] font-semibold">
              <td className="num px-3 py-2.5 uppercase tracking-wide">Total</td>
              <td />
              <td />
              <td />
              <td className="num px-3 py-2.5 text-right">{peso(t.totalCost)}</td>
              <td className="num px-3 py-2.5 text-right">{peso(t.currentValue)}</td>
              <td />
              <td className={cn('num px-3 py-2.5 text-right', signedClass(t.totalPL))}>{peso(t.totalPL, { sign: true })}</td>
              <td className="num px-3 py-2.5 text-right text-div">{peso(t.dividends)}</td>
              <td className={cn('num px-3 py-2.5 text-right', signedClass(t.totalReturnInclDivs))}>
                {peso(t.totalReturnInclDivs, { sign: true })}
              </td>
            </tr>
          </tfoot>
        </table>
      </div>

      <p className="text-[12px] text-muted-foreground">
        P/L on recycled rows is realized — proceeds from those sales funded the positions above. Dividends are all-time
        cash received and already reinvested. Click a ticker for the position detail.
      </p>
    </div>
  )
}
