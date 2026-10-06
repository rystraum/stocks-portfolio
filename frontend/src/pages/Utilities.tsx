import { useState } from 'react'
import { usePrivacy } from '@/lib/usePrivacy'
import { updatePrices } from '@/api/client'
import { Loading } from '@/api/useApi'
import { useOwner } from '@/api/useOwner'

const OPEN_JSON_URL = '/portfolio/stocks.json'

export default function Utilities() {
  usePrivacy()
  const { isOwner, loading } = useOwner()
  const [busy, setBusy] = useState(false)
  const [message, setMessage] = useState<string | null>(null)

  if (loading) return <Loading />
  if (!isOwner) {
    return (
      <div className="border border-line bg-card p-6 text-[13px] text-muted-foreground">
        You don't have access to this page.
      </div>
    )
  }

  async function handleUpdatePrices() {
    setBusy(true)
    setMessage(null)
    try {
      await updatePrices()
      setMessage('Price updates queued for every portfolio holding. Check back in a couple of minutes.')
    } catch (e) {
      setMessage(`Update failed: ${(e as Error).message}`)
    } finally {
      setBusy(false)
    }
  }

  return (
    <div className="space-y-6">
      <div className="border border-line bg-card p-5">
        <h3 className="text-[13px] font-bold uppercase tracking-[0.14em]">Update Prices</h3>
        <p className="mt-2 text-[12px] leading-snug text-muted-foreground">
          Fetch the latest PSE price for every holding you own, in the background. This is the same action as the
          old tracker's <span className="num">/portfolio/stocks</span> "update prices" button.
        </p>
        <div className="mt-4 flex items-center gap-3">
          <button
            onClick={handleUpdatePrices}
            disabled={busy}
            className="num bg-foreground px-3 py-1.5 text-[12px] font-medium text-background disabled:opacity-50"
          >
            {busy ? 'Queuing…' : 'Update all prices'}
          </button>
          {message && <span className="text-[12px] text-muted-foreground">{message}</span>}
        </div>
      </div>

      <div className="border border-line bg-card p-5">
        <h3 className="text-[13px] font-bold uppercase tracking-[0.14em]">Open JSON</h3>
        <p className="mt-2 text-[12px] leading-snug text-muted-foreground">
          Open the raw JSON dump of your portfolio (holdings, prices, cost basis) the same way the old tracker did.
        </p>
        <div className="mt-4">
          <a
            href={OPEN_JSON_URL}
            target="_blank"
            rel="noreferrer"
            className="num inline-block bg-foreground px-3 py-1.5 text-[12px] font-medium text-background"
          >
            Open JSON
          </a>
        </div>
      </div>
    </div>
  )
}
