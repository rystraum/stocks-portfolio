import { useState } from 'react'
import { backfillPrices, updateFromPSE } from '@/api/client'
import { useOwner } from '@/api/useOwner'

/** Owner-only per-stock controls (update price from PSE, backfill missing days). */
export default function UtilitiesPanel({ ticker }: { ticker: string }) {
  const { isOwner, loading } = useOwner()
  const [busy, setBusy] = useState(false)
  const [message, setMessage] = useState<string | null>(null)

  if (loading || !isOwner) return null

  async function handle(action: 'pse' | 'backfill') {
    setBusy(true)
    setMessage(null)
    try {
      if (action === 'pse') {
        const r = await updateFromPSE(ticker)
        setMessage(r.ok ? `Price updated from PSE to ${r.last_price}` : 'Price update failed.')
      } else {
        const r = await backfillPrices(ticker)
        setMessage(`Backfilled ${r.created} missing day(s) for ${ticker}.`)
      }
    } catch (e) {
      setMessage(`Action failed: ${(e as Error).message}`)
    } finally {
      setBusy(false)
    }
  }

  return (
    <div className="border border-line bg-card">
      <h3 className="border-b border-line px-5 py-3 text-[13px] font-bold uppercase tracking-[0.14em]">Utilities</h3>
      <div className="px-5 py-4">
        <p className="text-[12px] leading-snug text-muted-foreground">
          Owner-only controls for <span className="num">{ticker}</span>.
        </p>
        <div className="mt-4 flex flex-wrap items-center gap-2">
          <button
            onClick={() => handle('pse')}
            disabled={busy}
            className="num bg-foreground px-3 py-1.5 text-[12px] font-medium text-background disabled:opacity-50"
          >
            {busy ? 'Working…' : 'Update from PSE'}
          </button>
          <button
            onClick={() => handle('backfill')}
            disabled={busy}
            className="num bg-foreground px-3 py-1.5 text-[12px] font-medium text-background disabled:opacity-50"
          >
            Backfill missing days
          </button>
        </div>
        {message && <p className="mt-3 text-[12px] text-muted-foreground">{message}</p>}
      </div>
    </div>
  )
}
