import { describe, expect, it, vi } from 'vitest'
import { MemoryRouter } from 'react-router'
import { render, screen, waitFor } from '@testing-library/react'
import CryptoDetail from './CryptoDetail'
import { fetchCryptoHolding } from '@/api/client'

vi.mock('@/api/client', () => ({
  fetchCryptoHolding: vi.fn(),
}))

const holding = {
  symbol: 'BNB',
  name: 'BNB',
  currency: 'PHP',
  compound: 'BNBPHP',
  lastPrice: 49311.1,
  lastPriceAt: '2026-10-06T01:01:52.000+08:00',
  amount: 0.56984395,
  avgCost: 45642.09,
  totalFiat: 26009.12,
  totalProceeds: 0,
  currentValue: 28100,
  pnl: 2090.88,
  activities: [
    { date: '2026-09-16', type: 'buy', cryptoAmount: 0.0449, fiatAmount: 2003.09, feeCrypto: 0.00006735, feeFiat: 0, forex: 44679.27, notes: 'weekly auto-buy' },
    { date: '2026-01-10', type: 'buy', cryptoAmount: 0.5, fiatAmount: 24000, feeCrypto: null, feeFiat: 0, forex: 48000, notes: null },
  ],
}

describe('CryptoDetail', () => {
  it('shows the pair position summary and activities', async () => {
    vi.mocked(fetchCryptoHolding).mockResolvedValue(holding as any)
    render(<MemoryRouter><CryptoDetail /></MemoryRouter>)

    await waitFor(() => {
      expect(screen.getByText(/BNBPHP/)).toBeTruthy()
    })

    expect(screen.getByText(/0\.5698/)).toBeTruthy()
    expect(screen.getByText(/₱45,642/)).toBeTruthy()
    expect(screen.getByText(/\+₱2,090/)).toBeTruthy()
    expect(screen.getByText('Sep 16, 2026')).toBeTruthy()
    expect(screen.getByText('weekly auto-buy')).toBeTruthy()
  })
})
