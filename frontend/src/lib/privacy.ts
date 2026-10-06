const KEY = 'portfolio-privacy-redact'

let redact =
  typeof localStorage !== 'undefined' && localStorage.getItem(KEY) === '1'

const subs = new Set<() => void>()

export function isRedacted(): boolean {
  return redact
}

export function setRedacted(v: boolean) {
  if (redact === v) return
  redact = v
  try {
    localStorage.setItem(KEY, v ? '1' : '0')
  } catch {
    // storage unavailable (private mode) — in-memory only
  }
  subs.forEach((f) => f())
}

export function subscribeRedact(cb: () => void): () => void {
  subs.add(cb)
  return () => {
    subs.delete(cb)
  }
}
