import { useMemo } from 'react'
import { Cell, Pie, PieChart, ResponsiveContainer, Tooltip, type TooltipProps } from 'recharts'
import { Stat } from '@/components/Stat'
import { fetchCryptoHoldings } from '@/api/client'
import { ErrorNote, Loading, useApi } from '@/api/useApi'
import { cn } from '@/lib/utils'
import { money, num, pct, pctOf, peso, quotePrice, signedClass } from '@/lib/format'

const COLORS = ['#16150f', '#6b6650', '#b3ad95', 'hsl(32 88% 46%)']

export default function Crypto() {
  const { data, error: cryptoErr } = useApi(fetchCryptoHoldings)
  const usdtPhp = data?.usdtPhp ?? null
  // Aggregates are in PHP (the site's display currency); USDT/USDC-quoted rows are
  // converted at the live USDT/PHP market rate from the user's own USDT/PHP pair.
  const toPhp = (v: number, currency: string) => (currency === 'PHP' ? v : usdtPhp ? v * usdtPhp : 0)

  const rows = useMemo(
    () =>
      (data?.holdings ?? []).map((c) => {
        const cost = c.amount * c.avgCost
        const value = c.amount * c.lastPrice
        return { ...c, cost, value, pl: value - cost }
      }),
    [data]
  )

  const totalValue = rows.reduce((s, r) => s + toPhp(r.value, r.currency), 0)
  const totalCost = rows.reduce((s, r) => s + toPhp(r.cost, r.currency), 0)
  const pl = totalValue - totalCost
  const hasForeign = rows.some((r) => r.currency !== 'PHP')
  const foreignValue = rows.reduce((s, r) => (r.currency === 'PHP' ? s : s + toPhp(r.value, r.currency)), 0)

  const groups = useMemo(() => {
    const present = [...new Set(rows.map((r) => r.currency))]
    const order = ['PHP', 'USDT', 'USDC'].filter((c) => present.includes(c))
    const rest = present.filter((c) => !['PHP', 'USDT', 'USDC'].includes(c)).sort()
    return [...order, ...rest].map((c) => {
      const gRows = rows.filter((r) => r.currency === c)
      return {
        currency: c,
        cost: gRows.reduce((s, r) => s + r.cost, 0),
        value: gRows.reduce((s, r) => s + r.value, 0),
      }
    })
  }, [rows])

  const alloc = rows.map((r) => ({
    ...r,
    label: `${r.symbol} ${r.currency}`,
    value: toPhp(r.value, r.currency),
  }))

  if (cryptoErr) return <ErrorNote message={cryptoErr} />
  if (!data) return <Loading />

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-2 gap-x-6 gap-y-5 md:grid-cols-4">
        <Stat label="Cost basis" value={peso(totalCost)} sub="tracking only — not part of the dividend thesis" />
        <Stat
          label="Market value"
          value={peso(totalValue)}
          sub={
            hasForeign && usdtPhp ? (
              <span className="num">
                {peso(foreignValue)} USDT/USDC at {peso(usdtPhp)}/USDT
              </span>
            ) : undefined
          }
        />
        <Stat
          label="Unrealized P/L"
          value={peso(pl, { sign: true })}
          tone={pl >= 0 ? 'gain' : 'loss'}
          sub={<span className="num">{pct(pctOf(pl, totalCost), 1, true)}</span>}
        />
        <Stat label="Assets" value={String(rows.length)} sub="no staking income tracked" />
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        <div className="scroll-thin overflow-x-auto border border-line bg-card lg:col-span-2">
          <table className="w-full min-w-[640px] border-collapse">
            <thead>
              <tr className="bg-[#131311] text-[#f4f1ea]/70">
                {['Asset', 'Holdings', 'Avg cost', 'Last', 'Cost basis', 'Value', 'P/L'].map((h, i) => (
                  <th
                    key={h}
                    className={cn(
                      'num whitespace-nowrap px-3 py-2 text-[10px] font-semibold uppercase tracking-[0.12em]',
                      i === 0 ? 'text-left' : 'text-right'
                    )}
                  >
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {rows.map((r) => (
                <tr
                  key={`${r.symbol}-${r.currency}`}
                  className="border-t border-line text-[13px] transition-colors hover:bg-[hsl(32_88%_46%/0.07)]"
                >
                  <td className="px-3 py-2">
                    <div className="num font-semibold">{r.symbol}</div>
                    <div className="text-[11px] text-muted-foreground">{r.name}</div>
                  </td>
                  <td className="num px-3 py-2 text-right">{num(r.amount, 4)}</td>
                  <td className="num px-3 py-2 text-right">{quotePrice(r.avgCost, r.currency)}</td>
                  <td className="num px-3 py-2 text-right">{quotePrice(r.lastPrice, r.currency)}</td>
                  <td className="num px-3 py-2 text-right">{money(r.cost, r.currency, { decimals: 0 })}</td>
                  <td className="num px-3 py-2 text-right font-medium">{money(r.value, r.currency, { decimals: 0 })}</td>
                  <td className="px-3 py-2 text-right">
                    <div className={cn('num', signedClass(r.pl))}>{money(r.pl, r.currency, { sign: true, decimals: 0 })}</div>
                    <div className={cn('num text-[10px]', signedClass(r.pl))}>{pct(pctOf(r.pl, r.cost), 1, true)}</div>
                  </td>
                </tr>
              ))}
            </tbody>
            <tfoot>
              {groups.map((g) => (
                <tr key={g.currency} className="border-t-2 border-foreground bg-secondary/70 text-[13px] font-semibold">
                  <td className="num px-3 py-2.5 uppercase tracking-wide">Total · {g.currency}</td>
                  <td colSpan={3} />
                  <td className="num px-3 py-2.5 text-right">{money(g.cost, g.currency, { decimals: 0 })}</td>
                  <td className="num px-3 py-2.5 text-right">{money(g.value, g.currency, { decimals: 0 })}</td>
                  <td className={cn('num px-3 py-2.5 text-right', signedClass(g.value - g.cost))}>
                    {money(g.value - g.cost, g.currency, { sign: true, decimals: 0 })}
                  </td>
                </tr>
              ))}
            </tfoot>
          </table>
        </div>

        <div className="border border-line bg-card p-5">
          <h3 className="text-[13px] font-bold uppercase tracking-[0.14em]">Allocation</h3>
          <div className="mt-2 h-[220px]">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie isAnimationActive={false} data={alloc} dataKey="value" nameKey="label" innerRadius={52} outerRadius={84} paddingAngle={2} strokeWidth={0}>
                  {alloc.map((r, i) => (
                    <Cell key={r.label} fill={COLORS[i % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip
                  content={({ active, payload }: TooltipProps<number, string>) =>
                    active && payload?.length ? (
                      <div className="border border-line bg-card px-2.5 py-1.5 shadow-sm">
                        <p className="num text-[12px]">
                          <b>{payload[0].name}</b> {peso(payload[0].value ?? 0, { decimals: 0 })} · {pct(pctOf(payload[0].value ?? 0, totalValue))}
                        </p>
                      </div>
                    ) : null
                  }
                />
              </PieChart>
            </ResponsiveContainer>
          </div>
          <ul className="space-y-1.5">
            {alloc.map((r, i) => (
              <li key={r.label} className="flex items-center gap-2 text-[12px]">
                <span className="h-2 w-2" style={{ background: COLORS[i % COLORS.length] }} />
                <span className="num font-medium">
                  {r.symbol}
                  <span className="ml-0.5 text-[10px] font-normal text-muted-foreground">{r.currency}</span>
                </span>
                <span className="num ml-auto text-muted-foreground">{pct(pctOf(r.value, totalValue))}</span>
              </li>
            ))}
          </ul>
        </div>
      </div>

      <p className="text-[12px] text-muted-foreground">
        The crypto sleeve sits outside the deposit-only dividend strategy — P/L here is tracking-only, not part of
        the dividend thesis.
      </p>
      {hasForeign && (
        <p className="text-[12px] text-muted-foreground">
          Each asset is shown in its own quote currency; KPIs, totals, and allocation convert USDT/USDC rows to PHP
          {usdtPhp
            ? ` at ${peso(usdtPhp)}/USDT (live USDT/PHP rate)`
            : ' — no USDT/PHP rate available, so they are excluded from PHP totals'}
          .
        </p>
      )}
    </div>
  )
}
