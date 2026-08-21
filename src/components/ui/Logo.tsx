import { Hexagon } from 'lucide-react';

export function Logo({ className = '', size = 'default' }: { className?: string; size?: 'default' | 'lg' | 'sm' }) {
  const iconSize = size === 'lg' ? 'w-10 h-10' : size === 'sm' ? 'w-7 h-7' : 'w-8 h-8';
  const textSize = size === 'lg' ? 'text-xl' : size === 'sm' ? 'text-base' : 'text-lg';
  const subSize = size === 'lg' ? 'text-[11px]' : 'text-[10px]';

  return (
    <div className={`flex items-center gap-2.5 ${className}`}>
      <div className="relative">
        <Hexagon className={`${iconSize} text-rok-500`} strokeWidth={1.7} />
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="w-2.5 h-2.5 rounded-full bg-gradient-to-br from-rok-400 to-crimson-500 shadow-sm" />
        </div>
      </div>
      <div className="leading-none">
        <div className={`font-display ${textSize} font-bold text-white tracking-tight`}>
          ForgeLine
        </div>
        <div className={`${subSize} font-semibold uppercase tracking-[0.18em] text-steel-400`}>
          Academy
        </div>
      </div>
    </div>
  );
}