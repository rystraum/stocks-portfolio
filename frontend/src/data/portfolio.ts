// Portfolio dataset — transcribed from the tracker's screens (Aug 25, 2026 snapshot).
// All amounts in PHP.

export interface Holding {
  ticker: string
  name: string
  industry: string
  shares: number
  totalCost: number // cost basis of current shares
  lastPrice: number
  lastPriceAt: string
  targetBuy: number | null
  dividends: number // all-time cash dividends received from this ticker
  realizedPL: number | null // realized P/L for fully-sold positions
  active: boolean
}

export const holdings: Holding[] = [
  { ticker: 'ABS',   name: 'ABS-CBN Corp',            industry: 'Media',        shares: 2000,  totalCost: 10846.42,  lastPrice: 3.68,    lastPriceAt: 'Aug 25, 2026 11:56', targetBuy: null,  dividends: 0,       realizedPL: null,      active: true },
  { ticker: 'AC',    name: 'Ayala Corporation',       industry: 'Conglomerate', shares: 20,    totalCost: 14531.97,  lastPrice: 509.0,   lastPriceAt: 'Aug 25, 2026 11:59', targetBuy: null,  dividends: 785.26,  realizedPL: null,      active: true },
  { ticker: 'ACEN',  name: 'ACEN Corporation',        industry: 'Energy',       shares: 527,   totalCost: 8353.56,   lastPrice: 2.88,    lastPriceAt: 'Aug 25, 2026 14:50', targetBuy: null,  dividends: 192.4,   realizedPL: null,      active: true },
  { ticker: 'AREIT', name: 'AREIT, Inc.',             industry: 'REIT',         shares: 1100,  totalCost: 38760.57,  lastPrice: 37.5,    lastPriceAt: 'Aug 25, 2026 14:50', targetBuy: 35.0,  dividends: 8024.4,  realizedPL: null,      active: true },
  { ticker: 'BPI',   name: 'Bank of the Philippine Islands', industry: 'Banking', shares: 151, totalCost: 13851.07, lastPrice: 105.5,   lastPriceAt: 'Aug 25, 2026 14:50', targetBuy: 95.64, dividends: 2714.13, realizedPL: null,      active: true },
  { ticker: 'CLI',   name: 'Cebu Landmasters, Inc.',  industry: 'Real Estate',  shares: 6000,  totalCost: 15392.71,  lastPrice: 2.15,    lastPriceAt: 'Aug 25, 2026 11:56', targetBuy: 2.58,  dividends: 1296.0,  realizedPL: null,      active: true },
  { ticker: 'CNVRG', name: 'Converge ICT Solutions',  industry: 'Telecom',      shares: 300,   totalCost: 5813.27,   lastPrice: 9.46,    lastPriceAt: 'Aug 25, 2026 11:56', targetBuy: 12.64, dividends: 132.3,   realizedPL: null,      active: true },
  { ticker: 'CREIT', name: 'Citicore Energy REIT',    industry: 'REIT',         shares: 19000, totalCost: 50586.29,  lastPrice: 3.27,    lastPriceAt: 'Aug 25, 2026 14:50', targetBuy: 2.9,   dividends: 8066.7,  realizedPL: null,      active: true },
  { ticker: 'DMC',   name: 'DMCI Holdings, Inc.',     industry: 'Conglomerate', shares: 14200, totalCost: 131049.98, lastPrice: 7.85,    lastPriceAt: 'Aug 25, 2026 14:50', targetBuy: 9.5,   dividends: 37422.0, realizedPL: null,      active: true },
  { ticker: 'FILRT', name: 'Filinvest REIT Corp.',    industry: 'REIT',         shares: 300,   totalCost: 11773.94,  lastPrice: 2.92,    lastPriceAt: 'Aug 25, 2026 14:50', targetBuy: 2.86,  dividends: 3412.8,  realizedPL: null,      active: true },
  { ticker: 'GLO',   name: 'Globe Telecom, Inc.',     industry: 'Telecom',      shares: 35,    totalCost: 62378.47,  lastPrice: 1686.0,  lastPriceAt: 'Aug 25, 2026 11:59', targetBuy: 1650,  dividends: 5530.5,  realizedPL: null,      active: true },
  { ticker: 'LTG',   name: 'LT Group, Inc.',          industry: 'Conglomerate', shares: 6200,  totalCost: 62554.87,  lastPrice: 15.18,   lastPriceAt: 'Aug 25, 2026 11:56', targetBuy: 13.7,  dividends: 13450.5, realizedPL: null,      active: true },
  { ticker: 'MER',   name: 'Manila Electric Company', industry: 'Utilities',    shares: 50,    totalCost: 12919.12,  lastPrice: 479.0,   lastPriceAt: 'Aug 25, 2026 14:37', targetBuy: 530,   dividends: 5512.98, realizedPL: null,      active: true },
  { ticker: 'PIZZA', name: "Shakey's Pizza Asia Ventures", industry: 'Consumer', shares: 500,  totalCost: 5287.59,   lastPrice: 5.78,    lastPriceAt: 'Aug 25, 2026 11:59', targetBuy: null,  dividends: 234.9,   realizedPL: null,      active: true },
  { ticker: 'PNX3B', name: 'Phoenix Petroleum PNXP3B', industry: 'Energy · Preferred', shares: 150, totalCost: 9681.24, lastPrice: 26.5,  lastPriceAt: 'May 12, 2026 14:41', targetBuy: null,  dividends: 182.48,  realizedPL: null,      active: true },
  { ticker: 'PNX4',  name: 'Phoenix Petroleum PNXP4', industry: 'Energy · Preferred', shares: 20, totalCost: 13158.73, lastPrice: 199.8, lastPriceAt: 'May 12, 2026 09:43', targetBuy: null,  dividends: 851.4,   realizedPL: null,      active: true },
  { ticker: 'PSE',   name: 'The Philippine Stock Exchange', industry: 'Financials', shares: 2, totalCost: 974.86,    lastPrice: 207.0,   lastPriceAt: 'Aug 25, 2026 11:56', targetBuy: null,  dividends: 1514.34, realizedPL: null,      active: true },
  { ticker: 'RCR',   name: 'RL Commercial REIT',      industry: 'REIT',         shares: 2000,  totalCost: 13346.8,   lastPrice: 7.27,    lastPriceAt: 'Aug 25, 2026 11:57', targetBuy: null,  dividends: 3048.67, realizedPL: null,      active: true },
  { ticker: 'SCC',   name: 'Semirara Mining and Power', industry: 'Mining & Energy', shares: 800, totalCost: 28711.63, lastPrice: 18.42,  lastPriceAt: 'Aug 25, 2026 11:56', targetBuy: 31.95, dividends: 1800.0,  realizedPL: null,      active: true },
  { ticker: 'SMC2O', name: 'San Miguel Corp Series 2-O', industry: 'Conglomerate · Preferred', shares: 640, totalCost: 52240.46, lastPrice: 79.1, lastPriceAt: 'Aug 25, 2026 14:50', targetBuy: null, dividends: 1306.13, realizedPL: null,    active: true },
  { ticker: 'TEL',   name: 'PLDT Inc.',               industry: 'Telecom',      shares: 20,    totalCost: 25103.85,  lastPrice: 1188.0,  lastPriceAt: 'Aug 25, 2026 11:56', targetBuy: 1280,  dividends: 2115.0,  realizedPL: null,      active: true },
  // Fully recycled positions (0 shares — proceeds were rolled into new buys)
  { ticker: 'ALI',   name: 'Ayala Land, Inc.',        industry: 'Real Estate',  shares: 0, totalCost: 0, lastPrice: 15.52, lastPriceAt: 'Aug 25, 2026 11:56', targetBuy: null, dividends: 2046.91, realizedPL: -12558.58, active: true },
  { ticker: 'FRUIT', name: 'Fruitas Holdings, Inc.',  industry: 'Consumer',     shares: 0, totalCost: 0, lastPrice: 0.65,  lastPriceAt: 'Aug 25, 2026 11:57', targetBuy: null, dividends: 162.0,   realizedPL: -3684.62,  active: true },
  { ticker: 'GMA7',  name: 'GMA Network, Inc.',       industry: 'Media',        shares: 0, totalCost: 0, lastPrice: 4.24,  lastPriceAt: 'Aug 25, 2026 11:59', targetBuy: null, dividends: 8428.5,  realizedPL: 8085.3,    active: true },
  { ticker: 'PHN',   name: 'PHINMA Corporation',      industry: 'Conglomerate', shares: 0, totalCost: 0, lastPrice: 15.86, lastPriceAt: 'Jul 10, 2026 14:50', targetBuy: null, dividends: 980.1,   realizedPL: 2238.48,   active: true },
  { ticker: 'URC',   name: 'Universal Robina Corp',   industry: 'Consumer',     shares: 0, totalCost: 0, lastPrice: 62.0,   lastPriceAt: 'Aug 25, 2026 11:56', targetBuy: null, dividends: 1311.39, realizedPL: -5439.7,   active: true },
  // Inactive / delisted
  { ticker: 'EDC',   name: 'Energy Development Corp', industry: 'Energy · Delisted', shares: 0, totalCost: 0, lastPrice: 7.25, lastPriceAt: 'Jan 02, 2020', targetBuy: null, dividends: 0, realizedPL: 639.49, active: false },
  { ticker: 'FBP2',  name: 'FPH Preferred Series B2', industry: 'Conglomerate · Preferred', shares: 0, totalCost: 0, lastPrice: 1005.0, lastPriceAt: 'Mar 17, 2020', targetBuy: null, dividends: 890.96, realizedPL: 70.79, active: false },
  { ticker: 'FGENF', name: 'First Gen Preferred F',   industry: 'Energy · Preferred', shares: 0, totalCost: 0, lastPrice: 80.0, lastPriceAt: 'Jan 02, 2020', targetBuy: null, dividends: 144.0, realizedPL: -343.05, active: false },
  { ticker: 'GLOPP', name: 'Globe Preferred',         industry: 'Telecom · Preferred', shares: 0, totalCost: 0, lastPrice: 510.0, lastPriceAt: 'May 11, 2026', targetBuy: null, dividends: 1404.15, realizedPL: -224.05, active: false },
  { ticker: 'SMC2C', name: 'San Miguel Corp Series 2-C', industry: 'Conglomerate · Preferred', shares: 0, totalCost: 0, lastPrice: 76.35, lastPriceAt: 'May 12, 2026', targetBuy: null, dividends: 243.0, realizedPL: -455.48, active: false },
  { ticker: 'SMC2I', name: 'San Miguel Corp Series 2-I', industry: 'Conglomerate · Preferred', shares: 0, totalCost: 0, lastPrice: 75.25, lastPriceAt: 'May 11, 2026', targetBuy: 74.66, dividends: 3752.51, realizedPL: 51.13, active: false },
]

// ---------------------------------------------------------------------------
// Dividends: month-by-month, with per-ticker breakdown where itemized.
// ---------------------------------------------------------------------------

export interface DividendMonth {
  total: number
  items?: { ticker: string; amount: number }[]
}

export const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'] as const

export const dividendsByYear: Record<number, DividendMonth[]> = {
  2018: [
    { total: 0 }, { total: 0 }, { total: 0 }, { total: 72.58, items: [{ ticker: 'MER', amount: 72.58 }] },
    { total: 315.0, items: [{ ticker: 'GMA7', amount: 315.0 }] }, { total: 0 },
    { total: 289.47, items: [{ ticker: 'BPI', amount: 113.4 }, { ticker: 'FGENF', amount: 144.0 }, { ticker: 'SMC2I', amount: 32.07 }] },
    { total: 117.01, items: [{ ticker: 'GLOPP', amount: 117.01 }] },
    { total: 175.08, items: [{ ticker: 'FBP2', amount: 127.28 }, { ticker: 'MER', amount: 47.8 }] },
    { total: 208.83, items: [{ ticker: 'ALI', amount: 158.76 }, { ticker: 'PIZZA', amount: 18.0 }, { ticker: 'SMC2I', amount: 32.07 }] },
    { total: 0 },
    { total: 256.88, items: [{ ticker: 'DMC', amount: 129.6 }, { ticker: 'FBP2', amount: 127.28 }] },
  ],
  2019: [
    { total: 209.62, items: [{ ticker: 'BPI', amount: 113.4 }, { ticker: 'SMC2I', amount: 96.22 }] },
    { total: 117.01, items: [{ ticker: 'GLOPP', amount: 117.01 }] },
    { total: 450.38, items: [{ ticker: 'ALI', amount: 163.8 }, { ticker: 'FBP2', amount: 127.28 }, { ticker: 'PHN', amount: 118.8 }, { ticker: 'URC', amount: 40.5 }] },
    { total: 191.57, items: [{ ticker: 'MER', amount: 95.35 }, { ticker: 'SMC2I', amount: 96.22 }] },
    { total: 749.34, items: [{ ticker: 'DMC', amount: 129.6 }, { ticker: 'GMA7', amount: 445.5 }, { ticker: 'PSE', amount: 174.24 }] },
    { total: 240.68, items: [{ ticker: 'BPI', amount: 113.4 }, { ticker: 'FBP2', amount: 127.28 }] },
    { total: 140.77, items: [{ ticker: 'SMC2I', amount: 96.22 }, { ticker: 'URC', amount: 44.55 }] },
    { total: 135.01, items: [{ ticker: 'GLOPP', amount: 117.01 }, { ticker: 'PIZZA', amount: 18.0 }] },
    { total: 176.46, items: [{ ticker: 'FBP2', amount: 127.28 }, { ticker: 'MER', amount: 49.18 }] },
    { total: 96.22, items: [{ ticker: 'SMC2I', amount: 96.22 }] },
    { total: 163.8, items: [{ ticker: 'ALI', amount: 163.8 }] },
    { total: 359.48, items: [{ ticker: 'BPI', amount: 113.4 }, { ticker: 'FBP2', amount: 127.28 }, { ticker: 'PHN', amount: 118.8 }] },
  ],
  2020: [
    { total: 96.22, items: [{ ticker: 'SMC2I', amount: 96.22 }] },
    { total: 117.01, items: [{ ticker: 'GLOPP', amount: 117.01 }] },
    { total: 414.92, items: [{ ticker: 'ALI', amount: 168.84 }, { ticker: 'FBP2', amount: 127.28 }, { ticker: 'PHN', amount: 118.8 }] },
    { total: 705.47, items: [{ ticker: 'DMC', amount: 475.2 }, { ticker: 'MER', amount: 93.55 }, { ticker: 'SMC2I', amount: 96.22 }, { ticker: 'URC', amount: 40.5 }] },
    { total: 0 },
    { total: 157.95, items: [{ ticker: 'BPI', amount: 113.4 }, { ticker: 'URC', amount: 44.55 }] },
    { total: 533.99, items: [{ ticker: 'GMA7', amount: 297.0 }, { ticker: 'SMC2I', amount: 192.44 }, { ticker: 'URC', amount: 44.55 }] },
    { total: 235.83, items: [{ ticker: 'GLOPP', amount: 234.03 }, { ticker: 'PIZZA', amount: 1.8 }] },
    { total: 126.82, items: [{ ticker: 'MER', amount: 126.82 }] },
    { total: 96.22, items: [{ ticker: 'SMC2I', amount: 96.22 }] },
    { total: 113.4, items: [{ ticker: 'BPI', amount: 113.4 }] },
    { total: 0 },
  ],
  2021: [
    { total: 96.22, items: [{ ticker: 'SMC2I', amount: 96.22 }] },
    { total: 234.03, items: [{ ticker: 'GLOPP', amount: 234.03 }] },
    { total: 85.55, items: [{ ticker: 'ALI', amount: 85.55 }] },
    { total: 1902.7, items: [{ ticker: 'DMC', amount: 1296.0 }, { ticker: 'MER', amount: 352.08 }, { ticker: 'PSE', amount: 158.4 }, { ticker: 'SMC2I', amount: 96.22 }] },
    { total: 2670.3, items: [{ ticker: 'GMA7', amount: 2551.5 }, { ticker: 'PHN', amount: 118.8 }] },
    { total: 153.9, items: [{ ticker: 'BPI', amount: 113.4 }, { ticker: 'URC', amount: 40.5 }] },
    { total: 217.72, items: [{ ticker: 'SMC2C', amount: 121.5 }, { ticker: 'SMC2I', amount: 96.22 }] },
    { total: 502.79, items: [{ ticker: 'AC', amount: 31.14 }, { ticker: 'GLOPP', amount: 468.05 }, { ticker: 'PIZZA', amount: 3.6 }] },
    { total: 576.76, items: [{ ticker: 'AREIT', amount: 118.8 }, { ticker: 'FILRT', amount: 100.8 }, { ticker: 'MER', amount: 227.56 }, { ticker: 'URC', amount: 129.6 }] },
    { total: 217.72, items: [{ ticker: 'SMC2C', amount: 121.5 }, { ticker: 'SMC2I', amount: 96.22 }] },
    { total: 2415.96, items: [{ ticker: 'ALI', amount: 85.68 }, { ticker: 'DMC', amount: 2160.0 }, { ticker: 'PNX4', amount: 170.28 }] },
    { total: 315.0, items: [{ ticker: 'BPI', amount: 113.4 }, { ticker: 'FILRT', amount: 201.6 }] },
  ],
  2022: [
    { total: 127.36, items: [{ ticker: 'AC', amount: 31.14 }, { ticker: 'SMC2I', amount: 96.22 }] },
    { total: 253.08, items: [{ ticker: 'PNX4', amount: 170.28 }, { ticker: 'RCR', amount: 82.8 }] },
    { total: 455.4, items: [{ ticker: 'AREIT', amount: 253.8 }, { ticker: 'FILRT', amount: 201.6 }] },
    { total: 3331.09, items: [{ ticker: 'DMC', amount: 2160.0 }, { ticker: 'MER', amount: 460.17 }, { ticker: 'PHN', amount: 148.5 }, { ticker: 'PSE', amount: 217.8 }, { ticker: 'SMC2I', amount: 96.22 }, { ticker: 'URC', amount: 248.4 }] },
    { total: 3206.43, items: [{ ticker: 'FILRT', amount: 208.8 }, { ticker: 'GMA7', amount: 2740.5 }, { ticker: 'PNX4', amount: 170.28 }, { ticker: 'RCR', amount: 86.85 }] },
    { total: 350.47, items: [{ ticker: 'AREIT', amount: 259.2 }, { ticker: 'PNX3B', amount: 91.27 }] },
    { total: 109.72, items: [{ ticker: 'PIZZA', amount: 13.5 }, { ticker: 'SMC2I', amount: 96.22 }] },
    { total: 289.0, items: [{ ticker: 'AC', amount: 31.14 }, { ticker: 'PNX4', amount: 170.28 }, { ticker: 'RCR', amount: 87.58 }] },
    { total: 1018.48, items: [{ ticker: 'AREIT', amount: 264.6 }, { ticker: 'FILRT', amount: 158.4 }, { ticker: 'GLO', amount: 243.0 }, { ticker: 'MER', amount: 261.27 }, { ticker: 'PNX3B', amount: 91.21 }] },
    { total: 96.22, items: [{ ticker: 'SMC2I', amount: 96.22 }] },
    { total: 3765.28, items: [{ ticker: 'ALI', amount: 85.36 }, { ticker: 'AREIT', amount: 264.6 }, { ticker: 'DMC', amount: 3240.0 }, { ticker: 'RCR', amount: 175.32 }] },
    { total: 516.96, items: [{ ticker: 'BPI', amount: 133.56 }, { ticker: 'FILRT', amount: 158.4 }, { ticker: 'GLO', amount: 225.0 }] },
  ],
  2023: [
    { total: 316.9, items: [{ ticker: 'AC', amount: 62.28 }, { ticker: 'CREIT', amount: 158.4 }, { ticker: 'SMC2I', amount: 96.22 }] },
    { total: 175.68, items: [{ ticker: 'RCR', amount: 175.68 }] },
    { total: 746.95, items: [{ ticker: 'ALI', amount: 94.18 }, { ticker: 'AREIT', amount: 280.8 }, { ticker: 'FILRT', amount: 146.97 }, { ticker: 'GLO', amount: 225.0 }] },
    { total: 4288.96, items: [{ ticker: 'DMC', amount: 3240.0 }, { ticker: 'MER', amount: 496.26 }, { ticker: 'PHN', amount: 178.2 }, { ticker: 'PNX4', amount: 170.28 }, { ticker: 'SMC2I', amount: 96.22 }, { ticker: 'URC', amount: 108.0 }] },
    { total: 2728.26, items: [{ ticker: 'CREIT', amount: 275.4 }, { ticker: 'GMA7', amount: 2079.0 }, { ticker: 'PSE', amount: 198.0 }, { ticker: 'RCR', amount: 175.86 }] },
    { total: 1117.35, items: [{ ticker: 'AREIT', amount: 421.2 }, { ticker: 'BPI', amount: 211.68 }, { ticker: 'FILRT', amount: 146.97 }, { ticker: 'GLO', amount: 337.5 }] },
    { total: 537.32, items: [{ ticker: 'BPI', amount: 102.7 }, { ticker: 'CREIT', amount: 338.4 }, { ticker: 'SMC2I', amount: 96.22 }] },
    { total: 420.59, items: [{ ticker: 'AC', amount: 244.55 }, { ticker: 'RCR', amount: 176.04 }] },
    { total: 1568.68, items: [{ ticker: 'ACEN', amount: 54.97 }, { ticker: 'AREIT', amount: 429.3 }, { ticker: 'FILRT', amount: 210.87 }, { ticker: 'GLO', amount: 337.5 }, { ticker: 'MER', amount: 383.4 }, { ticker: 'URC', amount: 152.64 }] },
    { total: 689.56, items: [{ ticker: 'CREIT', amount: 529.2 }, { ticker: 'SMC2I', amount: 160.36 }] },
    { total: 3637.77, items: [{ ticker: 'ALI', amount: 140.55 }, { ticker: 'DMC', amount: 3240.0 }, { ticker: 'FRUIT', amount: 81.0 }, { ticker: 'RCR', amount: 176.22 }] },
    { total: 1564.18, items: [{ ticker: 'AREIT', amount: 544.5 }, { ticker: 'BPI', amount: 228.31 }, { ticker: 'FILRT', amount: 210.87 }, { ticker: 'GLO', amount: 337.5 }, { ticker: 'LTG', amount: 243.0 }] },
  ],
  2024: [
    { total: 758.07, items: [{ ticker: 'AC', amount: 68.51 }, { ticker: 'CREIT', amount: 529.2 }, { ticker: 'SMC2I', amount: 160.36 }] },
    { total: 176.4, items: [{ ticker: 'RCR', amount: 176.4 }] },
    { total: 1912.14, items: [{ ticker: 'ALI', amount: 129.15 }, { ticker: 'AREIT', amount: 544.5 }, { ticker: 'FILRT', amount: 198.99 }, { ticker: 'GLO', amount: 337.5 }, { ticker: 'LTG', amount: 702.0 }] },
    { total: 1222.13, items: [{ ticker: 'MER', amount: 505.57 }, { ticker: 'PHN', amount: 178.2 }, { ticker: 'PSE', amount: 378.0 }, { ticker: 'SMC2I', amount: 160.36 }] },
    { total: 4876.2, items: [{ ticker: 'CREIT', amount: 583.2 }, { ticker: 'DMC', amount: 3888.0 }, { ticker: 'PIZZA', amount: 90.0 }, { ticker: 'RCR', amount: 178.2 }, { ticker: 'URC', amount: 136.8 }] },
    { total: 2587.12, items: [{ ticker: 'AREIT', amount: 554.4 }, { ticker: 'BPI', amount: 269.08 }, { ticker: 'FILRT', amount: 184.14 }, { ticker: 'GLO', amount: 337.5 }, { ticker: 'LTG', amount: 1242.0 }] },
    { total: 833.64, items: [{ ticker: 'AC', amount: 75.36 }, { ticker: 'ACEN', amount: 68.72 }, { ticker: 'CREIT', amount: 529.2 }, { ticker: 'SMC2I', amount: 160.36 }] },
    { total: 554.4, items: [{ ticker: 'AREIT', amount: 554.4 }] },
    { total: 2731.27, items: [{ ticker: 'FILRT', amount: 184.14 }, { ticker: 'GLO', amount: 337.5 }, { ticker: 'LTG', amount: 1431.0 }, { ticker: 'MER', amount: 463.27 }, { ticker: 'RCR', amount: 178.56 }, { ticker: 'URC', amount: 136.8 }] },
    { total: 820.07, items: [{ ticker: 'CREIT', amount: 529.2 }, { ticker: 'SMC2I', amount: 160.36 }, { ticker: 'SMC2O', amount: 130.51 }] },
    { total: 3992.14, items: [{ ticker: 'ALI', amount: 183.52 }, { ticker: 'DMC', amount: 3499.2 }, { ticker: 'FRUIT', amount: 81.0 }, { ticker: 'RCR', amount: 228.42 }] },
    { total: 3034.42, items: [{ ticker: 'AREIT', amount: 574.2 }, { ticker: 'BPI', amount: 269.08 }, { ticker: 'FILRT', amount: 184.14 }, { ticker: 'GLO', amount: 337.5 }, { ticker: 'LTG', amount: 1669.5 }] },
  ],
  2025: [
    { total: 895.43, items: [{ ticker: 'AC', amount: 75.36 }, { ticker: 'CREIT', amount: 529.2 }, { ticker: 'SMC2I', amount: 160.36 }, { ticker: 'SMC2O', amount: 130.51 }] },
    { total: 181.8, items: [{ ticker: 'RCR', amount: 181.8 }] },
    { total: 1277.78, items: [{ ticker: 'ALI', amount: 181.94 }, { ticker: 'AREIT', amount: 574.2 }, { ticker: 'FILRT', amount: 184.14 }, { ticker: 'GLO', amount: 337.5 }] },
    { total: 8847.01, items: [{ ticker: 'CLI', amount: 324.0 }, { ticker: 'DMC', amount: 4860.0 }, { ticker: 'LTG', amount: 1431.0 }, { ticker: 'MER', amount: 618.12 }, { ticker: 'SCC', amount: 900.0 }, { ticker: 'SMC2I', amount: 160.37 }, { ticker: 'SMC2O', amount: 130.52 }, { ticker: 'TEL', amount: 423.0 }] },
    { total: 1304.46, items: [{ ticker: 'CREIT', amount: 594.0 }, { ticker: 'PSE', amount: 378.0 }, { ticker: 'RCR', amount: 188.46 }, { ticker: 'URC', amount: 144.0 }] },
    { total: 1378.51, items: [{ ticker: 'AREIT', amount: 574.2 }, { ticker: 'BPI', amount: 282.67 }, { ticker: 'FILRT', amount: 184.14 }, { ticker: 'GLO', amount: 337.5 }] },
    { total: 2628.48, items: [{ ticker: 'ACEN', amount: 68.71 }, { ticker: 'CREIT', amount: 837.9 }, { ticker: 'LTG', amount: 1431.0 }, { ticker: 'SMC2I', amount: 160.36 }, { ticker: 'SMC2O', amount: 130.51 }] },
    { total: 172.89, items: [{ ticker: 'AC', amount: 82.89 }, { ticker: 'PIZZA', amount: 90.0 }] },
    { total: 4342.32, items: [{ ticker: 'AREIT', amount: 584.1 }, { ticker: 'FILRT', amount: 184.14 }, { ticker: 'GLO', amount: 337.5 }, { ticker: 'LTG', amount: 1674.0 }, { ticker: 'MER', amount: 509.76 }, { ticker: 'RCR', amount: 188.82 }, { ticker: 'TEL', amount: 864.0 }] },
    { total: 1128.77, items: [{ ticker: 'CREIT', amount: 837.9 }, { ticker: 'SMC2I', amount: 160.36 }, { ticker: 'SMC2O', amount: 130.51 }] },
    { total: 6354.86, items: [{ ticker: 'ALI', amount: 184.46 }, { ticker: 'DMC', amount: 5270.4 }, { ticker: 'SCC', amount: 900.0 }] },
    { total: 3574.24, items: [{ ticker: 'AREIT', amount: 613.8 }, { ticker: 'BPI', amount: 309.85 }, { ticker: 'FILRT', amount: 169.29 }, { ticker: 'GLO', amount: 337.5 }, { ticker: 'LTG', amount: 1953.0 }, { ticker: 'RCR', amount: 190.8 }] },
  ],
  2026: [
    { total: 1241.66, items: [{ ticker: 'AC', amount: 82.89 }, { ticker: 'CREIT', amount: 837.9 }, { ticker: 'SMC2I', amount: 160.36 }, { ticker: 'SMC2O', amount: 160.51 }] },
    { total: 0 },
    { total: 3878.4, items: [{ ticker: 'ALI', amount: 221.32 }, { ticker: 'AREIT', amount: 613.8 }, { ticker: 'FILRT', amount: 178.2 }, { ticker: 'GLO', amount: 337.5 }, { ticker: 'LTG', amount: 1674.0 }, { ticker: 'RCR', amount: 200.16 }, { ticker: 'SMC2I', amount: 160.36 }, { ticker: 'SMC2O', amount: 493.06 }] },
    { total: 1710.54, items: [{ ticker: 'CNVRG', amount: 132.3 }, { ticker: 'MER', amount: 750.24 }, { ticker: 'TEL', amount: 828.0 }] },
    { total: 1939.5, items: [{ ticker: 'CLI', amount: 972.0 }, { ticker: 'CREIT', amount: 957.6 }, { ticker: 'PSE', amount: 9.9 }] },
    { total: 4838.4, items: [{ ticker: 'DMC', amount: 3834.0 }, { ticker: 'FILRT', amount: 16.2 }, { ticker: 'GLO', amount: 787.5 }, { ticker: 'RCR', amount: 200.7 }] },
    { total: 0 }, { total: 0 }, { total: 0 }, { total: 0 }, { total: 0 }, { total: 0 },
  ],
}

export const dividendYears = Object.keys(dividendsByYear).map(Number).sort((a, b) => a - b)

export function yearDividendTotal(year: number): number {
  return dividendsByYear[year].reduce((s, m) => s + m.total, 0)
}

// ---------------------------------------------------------------------------
// Capital deployed per year (gross) and cumulative cost base at end of year.
// Money only flows in; sales proceeds and dividends are recycled into buys.
// ---------------------------------------------------------------------------

export interface CapitalYear {
  year: number
  invested: number // gross new capital added during the year
  cumulativeCost: number // total cost base at end of year
}

export const capitalByYear: CapitalYear[] = [
  { year: 2018, invested: 19615.44, cumulativeCost: 88021.76 },
  { year: 2019, invested: 7597.93, cumulativeCost: 95619.69 },
  { year: 2020, invested: 19873.87, cumulativeCost: 115493.56 },
  { year: 2021, invested: 75135.9, cumulativeCost: 190629.46 },
  { year: 2022, invested: 58366.71, cumulativeCost: 248996.17 },
  { year: 2023, invested: 84066.01, cumulativeCost: 333062.18 },
  { year: 2024, invested: 96345.74, cumulativeCost: 429407.92 },
  { year: 2025, invested: 135073.0, cumulativeCost: 564480.92 },
  { year: 2026, invested: 34456.77, cumulativeCost: 598937.69 },
]

// ---------------------------------------------------------------------------
// Derived portfolio totals
// ---------------------------------------------------------------------------

export const portfolioTotals = (() => {
  const totalCost = holdings.reduce((s, h) => s + h.totalCost, 0)
  const currentValue = holdings.reduce((s, h) => s + h.shares * h.lastPrice, 0)
  const unrealizedPL = holdings.reduce((s, h) => s + (h.shares > 0 ? h.shares * h.lastPrice - h.totalCost : 0), 0)
  const realizedPL = holdings.reduce((s, h) => s + (h.realizedPL ?? 0), 0)
  const dividends = holdings.reduce((s, h) => s + h.dividends, 0)
  return {
    totalCost,
    currentValue,
    unrealizedPL,
    realizedPL,
    dividends,
    totalPL: unrealizedPL + realizedPL,
    valuePlusDivs: currentValue + dividends,
    totalReturnInclDivs: currentValue + dividends + realizedPL - totalCost,
  }
})()

// ---------------------------------------------------------------------------
// Crypto sleeve (mock — feature flagged "coming soon" in the original)
// ---------------------------------------------------------------------------

export interface CryptoHolding {
  symbol: string
  name: string
  amount: number
  avgCost: number
  lastPrice: number
}

export const cryptoHoldings: CryptoHolding[] = [
  { symbol: 'BTC', name: 'Bitcoin', amount: 0.0214, avgCost: 3120000, lastPrice: 6480000 },
  { symbol: 'ETH', name: 'Ethereum', amount: 0.42, avgCost: 148000, lastPrice: 196000 },
  { symbol: 'SOL', name: 'Solana', amount: 6.5, avgCost: 7200, lastPrice: 9800 },
  { symbol: 'XRP', name: 'Ripple', amount: 400, avgCost: 28, lastPrice: 34.5 },
]

// ---------------------------------------------------------------------------
// Deterministic pseudo-random series for price charts (mock market data)
// ---------------------------------------------------------------------------

export function seededRandom(seed: number) {
  let s = seed >>> 0
  return () => {
    s = (Math.imul(s, 1664525) + 1013904223) >>> 0
    return s / 4294967296
  }
}

export function seedFromTicker(ticker: string): number {
  let h = 2166136261
  for (let i = 0; i < ticker.length; i++) {
    h ^= ticker.charCodeAt(i)
    h = Math.imul(h, 16777619)
  }
  return Math.abs(h)
}

export interface OhlcPoint {
  time: string // yyyy-mm-dd
  open: number
  high: number
  low: number
  close: number
  volume: number
}

/** Generate `days` of OHLC data ending at `endPrice` on 2026-08-25 (trading days only). */
export function generatePriceSeries(ticker: string, endPrice: number, days: number): OhlcPoint[] {
  const rand = seededRandom(seedFromTicker(ticker))
  const points: OhlcPoint[] = []
  const end = new Date(2026, 7, 25)
  const dates: Date[] = []
  const d = new Date(end)
  while (dates.length < days) {
    if (d.getDay() !== 0 && d.getDay() !== 6) dates.unshift(new Date(d))
    d.setDate(d.getDate() - 1)
  }
  // Walk backwards from end price so the series lands exactly on last price
  const closes: number[] = new Array(days)
  closes[days - 1] = endPrice
  for (let i = days - 2; i >= 0; i--) {
    const drift = (rand() - 0.485) * 0.028
    closes[i] = Math.max(endPrice * 0.2, closes[i + 1] / (1 + drift))
  }
  for (let i = 0; i < days; i++) {
    const close = closes[i]
    const open = i === 0 ? close * (1 + (rand() - 0.5) * 0.02) : closes[i - 1] * (1 + (rand() - 0.5) * 0.012)
    const high = Math.max(open, close) * (1 + rand() * 0.015)
    const low = Math.min(open, close) * (1 - rand() * 0.015)
    points.push({
      time: dates[i].toISOString().slice(0, 10),
      open: round2(open),
      high: round2(high),
      low: round2(low),
      close: round2(close),
      volume: Math.floor(rand() * 900_000 + 50_000),
    })
  }
  return points
}

function round2(n: number) {
  return Math.round(n * 100) / 100
}

// ---------------------------------------------------------------------------
// Synthetic lot history that reconciles exactly with shares & cost basis
// ---------------------------------------------------------------------------

export interface Activity {
  date: string
  side: 'BUY' | 'SELL'
  shares: number
  price: number
  amount: number
}

const LOT_DATES = ['2021-03-15', '2022-01-24', '2022-09-12', '2023-03-10', '2023-10-26', '2024-04-22', '2025-02-17', '2025-11-10']

export function generateActivities(ticker: string, shares: number, totalCost: number): Activity[] {
  if (shares === 0 || totalCost === 0) return []
  const rand = seededRandom((seedFromTicker(ticker) ^ 0x9e3779b9) >>> 0)
  const lotCount = 2 + Math.floor(rand() * 3) // 2–4 lots
  const cps = totalCost / shares
  const lots: Activity[] = []
  let sharesLeft = shares
  let costLeft = totalCost
  const dateOffset = Math.floor(rand() * (LOT_DATES.length - lotCount))
  for (let i = 0; i < lotCount; i++) {
    const isLast = i === lotCount - 1
    const lotShares = isLast ? sharesLeft : Math.max(1, Math.round(sharesLeft * (0.25 + rand() * 0.4) / 10) * 10)
    const lotPrice = isLast ? costLeft / lotShares : cps * (0.82 + rand() * 0.4)
    lots.push({
      date: LOT_DATES[dateOffset + i],
      side: 'BUY',
      shares: lotShares,
      price: round2(lotPrice),
      amount: round2(lotShares * lotPrice),
    })
    sharesLeft -= lotShares
    costLeft -= lotShares * lotPrice
  }
  return lots
}

/** Per-ticker dividend events, newest first, assembled from the ladder data. */
export function dividendsForTicker(ticker: string) {
  const events: { date: string; year: number; month: string; amount: number }[] = []
  for (const year of dividendYears) {
    dividendsByYear[year].forEach((m, i) => {
      const hit = m.items?.find((it) => it.ticker === ticker)
      if (hit) events.push({ date: `${year}-${String(i + 1).padStart(2, '0')}`, year, month: MONTHS[i], amount: hit.amount })
    })
  }
  return events.sort((a, b) => b.date.localeCompare(a.date))
}
