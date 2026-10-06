import { useApi } from './useApi'
import { fetchMe } from './client'

export const OWNER_EMAIL = 'rystraum@gmail.com'

/** Returns whether the signed-in user is the owner (who sees the utility controls). */
export function useOwner(): { isOwner: boolean; loading: boolean } {
  const { data, loading } = useApi(fetchMe)
  return { isOwner: data?.email === OWNER_EMAIL, loading }
}
