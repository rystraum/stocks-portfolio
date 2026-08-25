import { Link, NavLink, useLocation } from 'react-router'
import { cn } from '@/lib/utils'

const NAV = [
  { to: '/', label: 'Overview', end: true },
  { to: '/stocks', label: 'Stocks', end: false },
  { to: '/dividends', label: 'Dividends', end: false },
  { to: '/crypto', label: 'Crypto', end: false },
]

export default function Layout({ children }: { children: React.ReactNode }) {
  const { pathname } = useLocation()
  const section = NAV.find((n) => (n.end ? pathname === n.to : pathname.startsWith(n.to)))?.label ?? 'Overview'
  return (
    <div className="min-h-screen">
      <header className="sticky top-0 z-40 bg-[#131311] text-[#f4f1ea]">
        <div className="mx-auto flex h-12 max-w-[1440px] items-center justify-between px-4 md:px-8">
          <div className="flex items-center gap-6">
            <Link to="/" className="flex items-baseline gap-2">
              <span className="text-[15px] font-bold tracking-tight">Portfolio</span>
              <span className="num text-[10px] uppercase tracking-[0.18em] text-[#f4f1ea]/50">PSE · PHP</span>
            </Link>
            <nav className="flex items-center gap-1">
              {NAV.map((item) => (
                <NavLink
                  key={item.to}
                  to={item.to}
                  end={item.end}
                  className={({ isActive }) =>
                    cn(
                      'px-3 py-1.5 text-[13px] font-medium transition-colors duration-150',
                      isActive
                        ? 'bg-[#f4f1ea] text-[#131311]'
                        : 'text-[#f4f1ea]/60 hover:text-[#f4f1ea]'
                    )
                  }
                >
                  {item.label}
                </NavLink>
              ))}
            </nav>
          </div>
          <div className="num hidden items-center gap-2 text-[11px] text-[#f4f1ea]/50 md:flex">
            <span className="inline-block h-1.5 w-1.5 rounded-full bg-[#0f0]" />
            snapshot · Aug 25, 2026
          </div>
        </div>
      </header>

      <main className="mx-auto max-w-[1440px] px-4 py-6 md:px-8 md:py-8">
        <div className="mb-5 flex items-baseline justify-between border-b border-line pb-3">
          <h1 className="text-[26px] font-bold leading-none tracking-tight md:text-[32px]">{section}</h1>
        </div>
        {children}
      </main>

      <footer className="mx-auto max-w-[1440px] px-4 pb-10 md:px-8">
        <p className="border-t border-line pt-4 text-[12px] text-muted-foreground">
          Frontend redesign concept — figures are a snapshot of the live tracker. Money only goes in:
          sale proceeds are recycled, dividends are reinvested, nothing is withdrawn.
        </p>
      </footer>
    </div>
  )
}
