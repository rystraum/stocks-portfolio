import { Link, NavLink, useLocation } from 'react-router'
import { cn } from '@/lib/utils'
import { useOwner } from '@/api/useOwner'

const NAV = [
  { to: '/', label: 'Overview', end: true },
  { to: '/stocks', label: 'Stocks', end: false },
  { to: '/dividends', label: 'Dividends', end: false },
  { to: '/crypto', label: 'Crypto', end: false },
]

const OWNER_NAV = [{ to: '/utilities', label: 'Utilities', end: false }]

export default function Layout({ children }: { children: React.ReactNode }) {
  const { pathname } = useLocation()
  const { isOwner } = useOwner()
  const navItems = isOwner ? [...NAV, ...OWNER_NAV] : NAV
  const section = navItems.find((n) => (n.end ? pathname === n.to : pathname.startsWith(n.to)))?.label ?? 'Overview'
  return (
    <div className="min-h-screen">
      <header className="sticky top-0 z-40 bg-[#131311] text-[#f4f1ea]">
        <div className="mx-auto flex h-12 max-w-[1440px] items-center justify-between px-4 md:px-8">
          <div className="flex items-center gap-6">
            <Link to="/" className="flex items-baseline gap-2">
              <span className="text-[15px] font-bold tracking-tight">Portfolio</span>
            </Link>
            <nav className="flex items-center gap-1">
              {navItems.map((item) => (
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

    </div>
  )
}
