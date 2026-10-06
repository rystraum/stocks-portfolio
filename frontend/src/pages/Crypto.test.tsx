import { describe, expect, it, vi } from 'vitest'
import { MemoryRouter } from 'react-router'
import { render, screen, waitFor } from '@testing-library/react'
import Crypto from './Crypto'
import { fetchCryptoHoldings } from '@/api/client'

vi.mock('@/api/client', () => ({
  fetchCryptoHoldings: vi.fn(),
}))

const portfolio = {
  usdtPhp: 60,
  holdings: [
    { symbol: 'BNB', name: 'BNB', amount: 0.5, avgCost: 45000, lastPrice: 50000, lastPriceAt: '2026-10-06T01:01:52.000+08:00', currency: 'PHP' },
    { symbol: 'SOL', name: 'Solana', amount: 2, avgCost: 100, lastPrice: 120, lastPriceAt: '2026-10-06T01:01:52.000+08:00', currency: 'USDT' },
  ],
}

describe('Crypto', () => {
  it('shows each asset in its own quote currency and converts aggregates to PHP', async () => {
    vi.mocked(fetchCryptoHoldings).mockResolvedValue(portfolio as any)
    render(<MemoryRouter><Crypto /></MemoryRouter>)

    await waitFor(() => {
      expect(screen.getByText('Total · PHP')).toBeTruthy()
    })

    // BNB is PHP-quoted: cost ₱22,500, value ₱25,000 (row + PHP subtotal)
    expect(screen.getAllByText('₱22,500').length).toBe(2)
    expect(screen.getAllByText('₱25,000').length).toBe(2)

    // SOL is USDT-quoted: $100 avg, $120 last, $200 cost, $240 value — never peso
    expect(screen.getByText('$100')).toBeTruthy()
    expect(screen.getByText('$120')).toBeTruthy()
    expect(screen.getAllByText('$200').length).toBe(2)
    expect(screen.getAllByText('$240').length).toBe(2)
    expect(screen.queryByText('₱240')).toBeNull()

    // PHP aggregates: 25,000 + 240 × 60 = ₱39,400 market value
    expect(screen.getByText(/₱39,400/)).toBeTruthy()
    expect(screen.getByText('Total · USDT')).toBeTruthy()

    // Rows link to the pair detail page
    const link = screen.getByRole('link', { name: /BNB/ })
    expect(link).toHaveAttribute('href', '/crypto/BNBPHP')
  })
})
