import { afterEach, describe, expect, it } from 'vitest'
import { compact, money, num, pct, peso, price, quotePrice } from './format'
import { isRedacted, setRedacted } from './privacy'

describe('privacy redaction', () => {
  afterEach(() => setRedacted(false))

  it('hides money values but keeps percentages when redacted', () => {
    setRedacted(true)
    expect(isRedacted()).toBe(true)
    expect(peso(1234.56)).toBe('•••••')
    expect(peso(1234.56, { sign: true })).toBe('•••••')
    expect(money(1234.56, 'PHP')).toBe('•••••')
    expect(money(1234.56, 'USDT')).toBe('•••••')
    expect(num(12.34)).toBe('•••••')
    expect(price(119.62)).toBe('•••••')
    expect(quotePrice(119.62, 'USDT')).toBe('•••••')
    expect(compact(23820)).toBe('•••••')
    expect(pct(8.4, 1, true)).toBe('+8.4%')
    expect(pct(-27.1)).toBe('-27.1%')
  })

  it('shows values when redaction is off', () => {
    setRedacted(false)
    expect(isRedacted()).toBe(false)
    expect(peso(1234.56)).toBe('₱1,234.56')
    expect(money(1234.56, 'USDT')).toBe('$1,234.56')
    expect(num(12.34)).toBe('12.34')
    expect(compact(23820)).toBe('23.8K')
    expect(pct(8.4, 1, true)).toBe('+8.4%')
  })
})
