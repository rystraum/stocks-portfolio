import { useEffect, useMemo, useState } from 'react'
import { MONTHS, dividendYears, dividendsByYear, yearDividendTotal } from '@/data/portfolio'
import { num, peso } from '@/lib/format'

const GOAL_KEY = 'div-goal-monthly'

/**
 * Monthly payout goal tracker. The thesis: dividends are reinvested until
 * the portfolio pays out a meaningful amount every single month.
 */
export default function GoalCard() {
  const [goal, setGoal] = useState<number>(() => {
    const raw = typeof window !== 'undefined' ? window.localStorage.getItem(GOAL_KEY) : null
    return raw ? Number(raw) : 10_000
  })
  const [editing, setEditing] = useState(false)
  const [draft, setDraft] = useState(String(goal))

  useEffect(() => {
    window.localStorage.setItem(GOAL_KEY, String(goal))
  }, [goal])

  const stats = useMemo(() => {
    const lastFullYear = dividendYears[dividendYears.length - 2] // 2025
    const ttmAvg = yearDividendTotal(lastFullYear) / 12
    const currentYear = dividendYears[dividendYears.length - 1]
    const elapsed = 7 // Jan–Jul 2026
    const monthsPaid = dividendsByYear[currentYear].slice(0, elapsed).filter((m) => m.total > 0).length
    // Weakest calendar months across full history → where new payers should be added
    const monthAvg = MONTHS.map((_, i) => {
      const vals = dividendYears.map((y) => dividendsByYear[y][i].total)
      return vals.reduce((s, v) => s + v, 0) / vals.length
    })
    const weakest = monthAvg
      .map((avg, i) => ({ month: MONTHS[i], avg }))
      .sort((a, b) => a.avg - b.avg)
      .slice(0, 3)
      .map((m) => m.month)
    return { ttmAvg, monthsPaid, elapsed, weakest }
  }, [])

  const progress = Math.min(100, (stats.ttmAvg / goal) * 100)
  const remaining = Math.max(0, goal - stats.ttmAvg)

  return (
    <div className="border border-line bg-card p-5">
      <div className="flex items-baseline justify-between">
        <h3 className="text-[13px] font-bold uppercase tracking-[0.14em]">Monthly payout goal</h3>
        {editing ? (
          <form
            className="flex items-center gap-1"
            onSubmit={(e) => {
              e.preventDefault()
              const v = Number(draft.replace(/[^0-9.]/g, ''))
              if (v > 0) setGoal(v)
              setEditing(false)
            }}
          >
            <input
              autoFocus
              value={draft}
              onChange={(e) => setDraft(e.target.value)}
              className="num w-24 border border-line bg-background px-1.5 py-0.5 text-right text-[12px] outline-none focus:border-foreground"
            />
            <button type="submit" className="bg-foreground px-2 py-0.5 text-[11px] font-medium text-background">
              Set
            </button>
          </form>
        ) : (
          <button
            onClick={() => {
              setDraft(String(goal))
              setEditing(true)
            }}
            className="text-[11px] font-medium text-muted-foreground underline decoration-dotted underline-offset-2 hover:text-foreground"
          >
            Edit goal
          </button>
        )}
      </div>

      <div className="mt-4 flex items-end justify-between">
        <div>
          <p className="num text-[30px] font-semibold leading-none tracking-tight text-div">{peso(stats.ttmAvg)}</p>
          <p className="mt-1 text-[12px] text-muted-foreground">avg per month over the last full year</p>
        </div>
        <p className="num text-[13px] text-muted-foreground">of {peso(goal, { decimals: 0 })}/mo</p>
      </div>

      <div className="mt-3 h-2 w-full bg-secondary">
        <div className="h-full bg-div transition-[width] duration-500" style={{ width: `${progress}%` }} />
      </div>
      <div className="num mt-1.5 flex justify-between text-[11px] text-muted-foreground">
        <span>{progress.toFixed(1)}% funded</span>
        <span>{peso(remaining, { decimals: 0 })}/mo to go</span>
      </div>

      <div className="mt-4 space-y-2 border-t border-line pt-3 text-[12px]">
        <div className="flex justify-between">
          <span className="text-muted-foreground">Months with a payout in 2026</span>
          <span className="num font-medium">
            {stats.monthsPaid} of {stats.elapsed}
          </span>
        </div>
        <div className="flex justify-between">
          <span className="text-muted-foreground">Historically thin months</span>
          <span className="num font-medium">{stats.weakest.join(' · ')}</span>
        </div>
        <p className="pt-1 text-[11px] leading-snug text-muted-foreground">
          Every payout is reinvested, so each year&apos;s income buys next year&apos;s raise.
          Add payers in the thin months to even out the monthly stream.
        </p>
      </div>
    </div>
  )
}

export function miniBars(values: number[], highlightLast = false) {
  const max = Math.max(...values, 1)
  return (
    <span className="inline-flex h-4 items-end gap-px">
      {values.map((v, i) => (
        <span
          key={i}
          className={highlightLast && i === values.length - 1 ? 'w-[3px] bg-div' : 'w-[3px] bg-foreground/30'}
          style={{ height: `${Math.max(8, (v / max) * 100)}%` }}
        />
      ))}
    </span>
  )
}

export { num }
