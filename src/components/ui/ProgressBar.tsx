export function ProgressBar({
  value,
  className = '',
  showLabel = false,
  size = 'md',
}: {
  value: number;
  className?: string;
  showLabel?: boolean;
  size?: 'sm' | 'md';
}) {
  const clamped = Math.max(0, Math.min(100, value));
  const h = size === 'sm' ? 'h-1.5' : 'h-2.5';
  return (
    <div className={`w-full ${className}`}>
      <div
        className={`relative w-full ${h} rounded-full bg-navy-950/80 overflow-hidden`}
      >
        <div
          className="absolute inset-y-0 left-0 rounded-full bg-gradient-to-r from-rok-500 to-rok-400 transition-all duration-500"
          style={{ width: `${clamped}%` }}
        />
      </div>
      {showLabel && (
        <div className="mt-1 text-xs font-medium text-steel-400">
          {clamped}% complete
        </div>
      )}
    </div>
  );
}