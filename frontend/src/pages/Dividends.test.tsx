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

  it('shades current-year periods with data, dashes only the ones with none yet', async () => {
    vi.mocked(fetchSummary).mockResolvedValue(summary as any)
    const cur = new Date().getFullYear()
    const mo = (i: number, total: number) => ({ month: i + 1, total })
    const divs: any = {
      [cur - 1]: [mo(0, 100), mo(1, 0), mo(2, 0), mo(3, 0), mo(4, 0), mo(5, 0), mo(6, 0), mo(7, 0), mo(8, 0), mo(9, 0), mo(10, 0), mo(11, 0)],
      [cur]: [
        mo(0, 50), mo(1, 50), mo(2, 50), // Q1 = 150
        mo(3, 50), mo(4, 50), mo(5, 50), // Q2 = 150
        mo(6, 50), mo(7, 50), mo(8, 50), // Q3 = 150 (rendered blank before the fix)
        mo(9, 0), mo(10, 0), mo(11, 0), // Q4 = 0 (no payouts yet)
      ],
    }
    vi.mocked(fetchDividendsAll).mockResolvedValue(divs)

    const { container } = render(<MemoryRouter><Dividends /></MemoryRouter>)
    await waitFor(() => { expect(screen.getByText('Best year')).toBeInTheDocument() })

    const qTable = Array.from(container.querySelectorAll('table')).find(
      (t) => Array.from(t.querySelectorAll('thead th')).some((th) => th.textContent === 'Q1'),
    )
    const rowOf = (year: string) =>
      Array.from(qTable!.querySelectorAll('tbody tr')).find(
        (r) => r.querySelector('td')?.textContent?.trim() === year,
      )
    const cell = (tr: Element, idx: number) => tr.querySelectorAll('td')[idx].querySelector('div')!

    // current year: Q3 has data -> shaded; Q4 has none yet -> dashed
    const curRow = rowOf(String(cur))!
    expect(cell(curRow, 3).className).not.toContain('border-dashed')
    expect(cell(curRow, 4).className).toContain('border-dashed')
    // previous year is final: data -> shaded, zero -> not dashed
    const prevRow = rowOf(String(cur - 1))!
    expect(cell(prevRow, 1).className).not.toContain('border-dashed')
    expect(cell(prevRow, 2).className).not.toContain('border-dashed')
  })

  it('keeps the current year in the ladders (and legend) before its first payout', async () => {
    vi.mocked(fetchSummary).mockResolvedValue(summary as any)
    const cur = new Date().getFullYear()
    const mo = (i: number, total: number) => ({ month: i + 1, total })
    const divs: any = {
      [cur - 1]: [mo(0, 100), mo(1, 0), mo(2, 0), mo(3, 0), mo(4, 0), mo(5, 0), mo(6, 0), mo(7, 0), mo(8, 0), mo(9, 0), mo(10, 0), mo(11, 0)],
    }
    vi.mocked(fetchDividendsAll).mockResolvedValue(divs)

    const { container } = render(<MemoryRouter><Dividends /></MemoryRouter>)
    await waitFor(() => { expect(screen.getByText('Best year')).toBeInTheDocument() })

    const qTable = Array.from(container.querySelectorAll('table')).find(
      (t) => Array.from(t.querySelectorAll('thead th')).some((th) => th.textContent === 'Q1'),
    )
    const curRow = Array.from(qTable!.querySelectorAll('tbody tr')).find(
      (r) => r.querySelector('td')?.textContent?.trim() === String(cur),
    )
    expect(curRow).toBeTruthy() // current-year row exists even with no data yet
    const cells = Array.from(curRow!.querySelectorAll('td')).slice(1, 5) // Q1-Q4
    expect(cells.every((td) => td.querySelector('div')!.className.includes('border-dashed'))).toBe(true)
    // legend tracks the real calendar year
    expect(container.textContent).toContain(`no payouts yet in ${cur}`)
  })
})
