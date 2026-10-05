import { describe, expect, it, vi } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import { MemoryRouter } from 'react-router'
import Stocks from './Stocks'
import { fetchHoldings, fetchSummary } from '@/api/client'

vi.mock('@/api/client', () => ({
  fetchSummary: vi.fn(),
  fetchHoldings: vi.fn(),
}))

const summary = {
  totalCost: 100000, currentValue: 120000, unrealizedPL: 20000, realizedPL: 0,
  totalPL: 20000, dividends: 5000, valuePlusDivs: 125000, totalReturnInclDivs: 25000,
  currency: 'PHP', asOf: '2026-01-01',
  capitalByYear: [{ year: 2025, invested: 100000, cumulativeCost: 100000 }],
}

const holdings = [
  { ticker: 'DMC', name: 'DMC Phils', industry: 'Mining', shares: 100, totalCost: 50000, lastPrice: 500, lastPriceAt: 'Jan 1, 2026', targetBuy: null, dividends: 2000, realizedPL: null, active: true },
  { ticker: 'ACME', name: 'Acme Corp', industry: 'Tech', shares: 50, totalCost: 50000, lastPrice: 700, lastPriceAt: 'Jan 1, 2026', targetBuy: null, dividends: 3000, realizedPL: null, active: true },
]

describe('Stocks', () => {
  it('lists active positions as soon as holdings load (no manual toggle)', async () => {
    vi.mocked(fetchSummary).mockResolvedValue(summary as any)
    vi.mocked(fetchHoldings).mockResolvedValue(holdings as any)
    render(<MemoryRouter><Stocks /></MemoryRouter>)
    // Regression: the rows memo must depend on `holdings`, otherwise the
    // table stays empty until a filter toggle forces a re-run.
    await waitFor(() => expect(screen.getByText('DMC')).toBeTruthy())
    expect(screen.getByText('ACME')).toBeTruthy()
  })
})
