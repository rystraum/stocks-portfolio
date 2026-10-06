import { Route, Routes } from 'react-router'
import Layout from '@/components/Layout'
import Overview from '@/pages/Overview'
import Stocks from '@/pages/Stocks'
import Dividends from '@/pages/Dividends'
import StockDetail from '@/pages/StockDetail'
import Crypto from '@/pages/Crypto'
import CryptoDetail from '@/pages/CryptoDetail'
import Utilities from '@/pages/Utilities'

export default function App() {
  return (
    <Layout>
      <Routes>
        <Route path="/" element={<Overview />} />
        <Route path="/stocks" element={<Stocks />} />
        <Route path="/stocks/:ticker" element={<StockDetail />} />
        <Route path="/dividends" element={<Dividends />} />
        <Route path="/crypto" element={<Crypto />} />
        <Route path="/crypto/:id" element={<CryptoDetail />} />
        <Route path="/utilities" element={<Utilities />} />
        <Route path="*" element={<Overview />} />
      </Routes>
    </Layout>
  )
}
