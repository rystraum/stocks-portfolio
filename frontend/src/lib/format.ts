export function peso(n: number, opts: { decimals?: number; sign?: boolean } = {}): string {
  const { decimals = 2, sign = false } = opts
  const abs = Math.abs(n).toLocaleString('en-PH', {
    minimumFractionDigits: decimals,
    maximumFractionDigits: decimals,
  })
  const prefix = n < 0 ? '-₱' : sign && n > 0 ? '+₱' : '₱'
  return `${prefix}${abs}`
}

export function num(n: number, decimals = 2): string {
  return n.toLocaleString('en-PH', { minimumFractionDigits: decimals, maximumFractionDigits: decimals })
}

export function compact(n: number): string {
  if (Math.abs(n) >= 1_000_000) return `${(n / 1_000_000).toFixed(2)}M`
  if (Math.abs(n) >= 10_000) return `${(n / 1_000).toFixed(1)}K`
  if (Math.abs(n) >= 1_000) return `${(n / 1_000).toFixed(2)}K`
  return n.toFixed(0)
}

export function pct(n: number, decimals = 1, sign = false): string {
  const s = n < 0 ? '-' : sign && n > 0 ? '+' : ''
  return `${s}${Math.abs(n).toFixed(decimals)}%`
}

export function pctOf(part: number, whole: number): number {
  return whole === 0 ? 0 : (part / whole) * 100
}

export function signedClass(n: number): string {
  return n > 0 ? 'text-gain' : n < 0 ? 'text-loss' : 'text-muted-foreground'
}

export function niceDate(iso: string): string {
  const [y, m, d] = iso.split('-').map(Number)
  return new Date(y, m - 1, d).toLocaleDateString('en-PH', { year: 'numeric', month: 'short', day: 'numeric' })
}
