import { useEffect, useState } from 'react'

interface ApiState<T> {
  data: T | null
  loading: boolean
  error: string | null
}

export function useApi<T>(fetcher: () => Promise<T>, deps: readonly unknown[] = []): ApiState<T> {
  const [state, setState] = useState<ApiState<T>>({ data: null, loading: true, error: null })
  useEffect(() => {
    let alive = true
    setState({ data: null, loading: true, error: null })
    fetcher()
      .then((data) => {
        if (alive) setState({ data, loading: false, error: null })
      })
      .catch((e: Error) => {
        if (alive) setState({ data: null, loading: false, error: e.message })
      })
    return () => {
      alive = false
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps)
  return state
}

export function Loading({ label = 'Loading…' }: { label?: string }) {
  return (
    <div className="flex h-40 items-center justify-center text-[13px] text-muted-foreground">{label}</div>
  )
}

export function ErrorNote({ message }: { message: string }) {
  return (
    <div className="flex h-40 items-center justify-center text-[13px] text-red-700">
      Could not load data: {message}
    </div>
  )
}
