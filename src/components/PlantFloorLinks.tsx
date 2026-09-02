/** Real <a href> links so crawlers and users reach crawlable HTML landings. */

const LINKS: { href: string; label: string }[] = [
  { href: '/vfd-ground-fault', label: 'VFD ground fault' },
  { href: '/vfd-overcurrent', label: 'VFD overcurrent' },
  { href: '/motor-megger', label: 'Motor megger & PI' },
  { href: '/control-valve-troubleshooting', label: 'Control valve troubleshooting' },
  { href: '/4-20ma-loop-troubleshooting', label: '4-20 mA loop troubleshooting' },
  { href: '/paths/mechanical', label: 'Mechanical path' },
  { href: '/paths/electrical', label: 'Electrical path' },
];

export function PlantFloorLinks({ compact = false }: { compact?: boolean }) {
  if (compact) {
    return (
      <ul className="space-y-2 text-sm">
        {LINKS.map((l) => (
          <li key={l.href}>
            <a href={l.href} className="text-steel-400 hover:text-rok-400 transition-colors">
              {l.label}
            </a>
          </li>
        ))}
      </ul>
    );
  }

  return (
    <div className="rounded-xl border border-steel-700/50 bg-navy-950/40 p-4 sm:p-5">
      <p className="text-xs font-bold uppercase tracking-wider text-rok-400 mb-3">
        Plant-floor troubleshooting
      </p>
      <div className="flex flex-wrap gap-2">
        {LINKS.map((l) => (
          <a
            key={l.href}
            href={l.href}
            className="px-3 py-1.5 rounded-full text-xs font-semibold border border-steel-700 bg-navy-800 text-steel-200 hover:border-rok-500/60 hover:text-white transition-colors"
          >
            {l.label}
          </a>
        ))}
      </div>
      <p className="text-xs text-steel-500 mt-3">
        78 courses · 44 free (Mechanical + Electrical). Dedicated pages for search and curl-no-JS.
      </p>
    </div>
  );
}
