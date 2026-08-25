import { cn } from '@/lib/utils'

export function Stat({
  label,
  value,
  sub,
  tone,
  className,
}: {
  label: string
  value: string
  sub?: React.ReactNode
  tone?: 'gain' | 'loss' | 'div' | 'ink'
  className?: string
}) {
  return (
    <div className={cn('border-t-2 border-[#16150f] pt-3', className)}>
      <p className="num text-[10px] font-medium uppercase tracking-[0.16em] text-muted-foreground">{label}</p>
      <p
        className={cn(
          'num mt-1.5 text-[24px] font-semibold leading-none tracking-tight md:text-[28px]',
          tone === 'gain' && 'text-gain',
          tone === 'loss' && 'text-loss',
          tone === 'div' && 'text-div'
        )}
      >
        {value}
      </p>
      {sub && <div className="mt-2 text-[12px] leading-snug text-muted-foreground">{sub}</div>}
    </div>
  )
}

export function SignedPill({ value, suffix = '%', className }: { value: number; suffix?: string; className?: string }) {
  const pos = value > 0
  const zero = value === 0
  return (
    <span
      className={cn(
        'num inline-flex items-center px-1.5 py-0.5 text-[11px] font-medium',
        zero
          ? 'bg-secondary text-muted-foreground'
          : pos
            ? 'bg-[hsl(152_66%_30%/0.12)] text-gain'
            : 'bg-[hsl(8_66%_45%/0.10)] text-loss',
        className
      )}
    >
      {zero ? '—' : `${pos ? '+' : '−'}${Math.abs(value).toFixed(1)}${suffix}`}
    </span>
  )
}
