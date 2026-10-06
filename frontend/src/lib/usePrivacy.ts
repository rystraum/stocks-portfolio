import { useSyncExternalStore } from 'react'
import { isRedacted, setRedacted, subscribeRedact } from './privacy'

export function usePrivacy() {
  const redact = useSyncExternalStore(subscribeRedact, isRedacted)
  return { redact, setRedacted }
}
