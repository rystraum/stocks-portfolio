import type { ReactNode } from 'react'
import { usePrivacy } from '@/lib/usePrivacy'
import { Link, Navigate, useParams } from 'react-router'
import { SignedPill } from '@/components/Stat'
import { fetchCryptoHolding } from '@/api/client'
import { ErrorNote, Loading, useApi } from '@/api/useApi'
import type { CryptoActivity } from '@/api/types'
import { money, niceDate, num, pct, pctOf, quotePrice, signedClass } from '@/lib/format'

function feeText(a: CryptoActivity, symbol: string, currency: string) {
  const parts: string[] = []
  if (a.feeCrypto) parts.push(`${num(a.feeCrypto, 6)} ${symbol}`)
  if (a.feeFiat) parts.push(money(a.feeFiat, currency, { decimals: 2 }))
  return parts.length ? parts.join(' · ') : '—'
}

export default function CryptoDetail() {
  usePrivacy()
  const { id = '' } = useParams()
  const { data: holding, loading, error } = useApi(() => fetchCryptoHolding(id), [id])

  if (!holding) {
    return error ? <ErrorNote message={error} /> : loading ? <Loading /> : <Navigate to="/crypto" replace />
  }

  const plPct = holding.totalFiat > 0 ? pctOf(holding.pnl, holding.totalFiat) : 0
  const lastAt = holding.lastPriceAt
    ? new Date(holding.lastPriceAt).toLocaleString('en-PH', { dateStyle: 'medium', timeStyle: 'short' })
    : '—'

  const rows: [string, ReactNode][] = [
    ['Quote currency', <span key="q" className="num">{holding.currency}</span>],
    [
      'Total crypto held',
      holding.amount > 0 ? (
        <span key="n" className="num">{num(holding.amount, 4)} {holding.symbol}</span>
      ) : (
        <span key="n0">0 — fully sold</span>
      ),
    ],
    ['Average cost', holding.avgCost > 0 ? money(holding.avgCost, holding.currency) : '—'],
    ['Fiat invested', holding.totalFiat > 0 ? money(holding.totalFiat, holding.currency) : '—'],
    ['Current value', holding.currentValue > 0 ? money(holding.currentValue, holding.currency) : '—'],
    ['Proceeds from sales', holding.totalProceeds > 0 ? money(holding.totalProceeds, holding.currency) : '—'],
    [
      'Total P/L',
      <span key="pl" className={`num font-semibold ${signedClass(holding.pnl)}`}>
        {money(holding.pnl, holding.currency, { sign: true })}
        {holding.totalFiat > 0 ? ` (${pct(plPct, 1, true)})` : ''}
      </span>,
    ],
  ]

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <Link to="/crypto" className="num text-[11px] font-semibold uppercase tracking-[0.14em] text-muted-foreground hover:text-foreground">
            ← Crypto
          </Link>
          <h2 className="mt-1 text-[30px] font-bold leading-none tracking-tight">
            {holding.name}{' '}
            <span className="num text-[18px] font-semibold text-muted-foreground">({holding.compound})</span>
          </h2>
          <p className="num mt-2 text-[11px] uppercase tracking-[0.14em] text-muted-foreground">
            {holding.symbol} quoted in {holding.currency} · last price {lastAt}
          </p>
        </div>
        <div className="text-right">
          <p className="num text-[34px] font-semibold leading-none tracking-tight">
            {holding.lastPrice != null ? quotePrice(holding.lastPrice, holding.currency) : '—'}
          </p>
          <div className="mt-1.5 flex justify-end">
            <SignedPill value={plPct} />
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
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

        <div className="border border-line bg-card lg:col-span-2">
          <h3 className="border-b border-line px-5 py-3 text-[13px] font-bold uppercase tracking-[0.14em]">Activities</h3>
          {holding.activities.length > 0 ? (
            <div className="scroll-thin max-h-[420px] overflow-y-auto">
              <table className="w-full border-collapse">
                <thead className="sticky top-0 bg-card">
                  <tr className="border-b border-line text-left">
                    <th className="num px-5 py-2 text-[10px] font-semibold uppercase tracking-[0.14em] text-muted-foreground">Date</th>
                    <th className="px-3 py-2 text-[10px] font-semibold uppercase tracking-[0.14em] text-muted-foreground">Type</th>
                    <th className="num px-3 py-2 text-right text-[10px] font-semibold uppercase tracking-[0.14em] text-muted-foreground">Amount</th>
                    <th className="num px-3 py-2 text-right text-[10px] font-semibold uppercase tracking-[0.14em] text-muted-foreground">Fiat ({holding.currency})</th>
                    <th className="num px-3 py-2 text-right text-[10px] font-semibold uppercase tracking-[0.14em] text-muted-foreground">Fee</th>
                    <th className="num px-5 py-2 text-right text-[10px] font-semibold uppercase tracking-[0.14em] text-muted-foreground">Forex</th>
                  </tr>
                </thead>
                <tbody>
                  {holding.activities.map((a, i) => (
                    <tr key={i} className="border-b border-line/50 text-[12px] last:border-0 hover:bg-[hsl(32_88%_46%/0.06)]">
                      <td className="num px-5 py-1.5">{niceDate(a.date)}</td>
                      <td className="px-3 py-1.5">
                        <span className={`num text-[11px] font-semibold uppercase ${a.type === 'buy' ? 'text-gain' : 'text-loss'}`}>{a.type}</span>
                        {a.notes && (
                          <span className="group relative ml-1.5 inline-block cursor-help text-muted-foreground">
                            [?]
                            <span
                              role="tooltip"
                              className="pointer-events-none absolute bottom-full left-0 z-50 mb-1 hidden w-64 whitespace-pre-wrap border border-line bg-card px-3 py-2 text-left text-[12px] font-normal normal-case leading-snug text-foreground shadow-lg group-hover:block"
                            >
                              {a.notes}
                            </span>
                          </span>
                        )}
                      </td>
                      <td className="num px-3 py-1.5 text-right">
                        {num(a.cryptoAmount, 4)} {holding.symbol}
                      </td>
                      <td className="num px-3 py-1.5 text-right">{money(a.fiatAmount, holding.currency)}</td>
                      <td className="num px-3 py-1.5 text-right text-muted-foreground">{feeText(a, holding.symbol, holding.currency)}</td>
                      <td className="num px-5 py-1.5 text-right">{quotePrice(a.forex, holding.currency)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : (
            <p className="px-5 py-6 text-[12px] text-muted-foreground">No activities on record for this pair.</p>
          )}
        </div>
      </div>
    </div>
  )
}
