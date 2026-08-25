import { Route, Routes } from 'react-router'
import Layout from '@/components/Layout'
import Overview from '@/pages/Overview'
import Stocks from '@/pages/Stocks'
import Dividends from '@/pages/Dividends'
import StockDetail from '@/pages/StockDetail'
import Crypto from '@/pages/Crypto'

export default function App() {
  return (
    <Layout>
      <Routes>
        <Route path="/" element={<Overview />} />
        <Route path="/stocks" element={<Stocks />} />
        <Route path="/stocks/:ticker" element={<StockDetail />} />
        <Route path="/dividends" element={<Dividends />} />
        <Route path="/crypto" element={<Crypto />} />
        <Route path="*" element={<Overview />} />
      </Routes>
    </Layout>
  )
}
