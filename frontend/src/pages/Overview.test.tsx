import { describe, expect, it, vi } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import { MemoryRouter } from 'react-router'
import Overview from './Overview'
import { fetchDividendsAll, fetchHoldings, fetchSummary } from '@/api/client'

vi.mock('@/api/client', () => ({
  fetchSummary: vi.fn(),
  fetchHoldings: vi.fn(),
  fetchDividendsAll: vi.fn(),
}))

const summary = {
  totalCost: 100000, currentValue: 120000, unrealizedPL: 20000, realizedPL: 0,
  totalPL: 20000, dividends: 5000, valuePlusDivs: 125000, totalReturnInclDivs: 25000,
  currency: 'PHP', asOf: '2026-01-01',
  capitalByYear: [{ year: 2025, invested: 100000, cumulativeCost: 100000 }],
}

const holdings = [
  { ticker: 'DMC', name: 'DMC Phils', industry: 'Mining', shares: 100, totalCost: 50000, lastPrice: 500, lastPriceAt: 'Jan 1, 2026', targetBuy: null, dividends: 2000, realizedPL: null, active: true },
]

const mkYear = (total: number) => Array.from({ length: 12 }, (_, i) => ({ month: i + 1, total }))
const dividendsByYear: Record<number, Array<{ month: number; total: number }>> = {
  2024: mkYear(100),
  2025: mkYear(150),
  2026: mkYear(200),
}

describe('Overview', () => {
  it('defaults the monthly-income chart to the most recent year with data', async () => {
    vi.mocked(fetchSummary).mockResolvedValue(summary as any)
    vi.mocked(fetchHoldings).mockResolvedValue(holdings as any)
    vi.mocked(fetchDividendsAll).mockResolvedValue(dividendsByYear as any)
    render(<MemoryRouter><Overview /></MemoryRouter>)
    await waitFor(() => {
      const btn = screen.getByRole('button', { name: '2026' })
      expect(btn).toHaveClass('bg-foreground')
    })
    // caption must follow the effective year — first load used to say "0 total ₱0.00"
    expect(screen.getByText(/2026 total/)).toBeTruthy()
    expect(screen.queryByText(/^0 total/)).toBeNull()
  })
})
