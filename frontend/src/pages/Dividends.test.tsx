import { describe, expect, it, vi } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import { MemoryRouter } from 'react-router'
import Dividends from './Dividends'
import { fetchDividendsAll, fetchSummary } from '@/api/client'

vi.mock('@/api/client', () => ({
  fetchSummary: vi.fn(),
  fetchDividendsAll: vi.fn(),
}))

const summary = {
  totalCost: 100000, currentValue: 120000, unrealizedPL: 20000, realizedPL: 0,
  totalPL: 20000, dividends: 5000, valuePlusDivs: 125000, totalReturnInclDivs: 25000,
  currency: 'PHP', asOf: '2026-01-01',
  capitalByYear: [{ year: 2025, invested: 100000, cumulativeCost: 100000 }],
}

const mkYear = (total: number) => Array.from({ length: 12 }, (_, i) => ({ month: i + 1, total }))
const dividendsByYear = {
  2024: mkYear(100),
  2025: mkYear(150),
  2026: mkYear(200),
}

describe('Dividends', () => {
  it('does not crash on first paint before dividend data resolves', async () => {
    vi.mocked(fetchSummary).mockResolvedValue(summary as any)
    vi.mocked(fetchDividendsAll).mockResolvedValue(dividendsByYear as any)

    // Regression: bestYear ran a seed-less reduce over the (initially empty)
    // yearly array on the first paint, throwing "Reduce of empty array with
    // no initial value" and blanking the page before the data resolved.
    render(<MemoryRouter><Dividends /></MemoryRouter>)

    await waitFor(() => {
      expect(screen.getByText('Best year')).toBeInTheDocument()
    })
  })
})
