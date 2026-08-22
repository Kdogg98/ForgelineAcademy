import { useRef, type ReactNode } from 'react';
import { ChevronLeft, ChevronRight } from 'lucide-react';

export function Carousel({
  title,
  subtitle,
  children,
}: {
  title: string;
  subtitle?: string;
  children: ReactNode;
}) {
  const scrollRef = useRef<HTMLDivElement>(null);

  function scrollBy(dir: number) {
    const el = scrollRef.current;
    if (!el) return;
    el.scrollBy({ left: dir * (el.clientWidth * 0.8), behavior: 'smooth' });
  }

  return (
    <section className="mb-12">
      <div className="flex items-end justify-between mb-5 px-1">
        <div>
          <div className="rok-bar mb-3" />
          <h2 className="section-title text-2xl">{title}</h2>
          {subtitle && (
            <p className="text-sm text-steel-400 mt-1">{subtitle}</p>
          )}
        </div>
        <div className="flex gap-2">
          <button
            onClick={() => scrollBy(-1)}
            className="p-2 rounded-md bg-navy-800 border border-steel-700 text-steel-300 hover:text-white hover:border-rok-500/50 transition-colors"
            aria-label="Scroll left"
          >
            <ChevronLeft className="w-4 h-4" />
          </button>
          <button
            onClick={() => scrollBy(1)}
            className="p-2 rounded-md bg-navy-800 border border-steel-700 text-steel-300 hover:text-white hover:border-rok-500/50 transition-colors"
            aria-label="Scroll right"
          >
            <ChevronRight className="w-4 h-4" />
          </button>
        </div>
      </div>
      <div
        ref={scrollRef}
        className="flex gap-4 overflow-x-auto no-scrollbar pb-2 -mx-1 px-1 scroll-smooth"
      >
        {children}
      </div>
    </section>
  );
}