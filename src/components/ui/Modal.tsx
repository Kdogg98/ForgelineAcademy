import { useEffect, useId, useRef } from 'react';
import { createPortal } from 'react-dom';
import { X } from 'lucide-react';

/**
 * The one dialog shell for the app. Sizing rules (do not override per dialog):
 * - phone (<640px): full-screen sheet (100dvh), header + footer pinned, body scrolls
 * - sm+: centered panel, max-h 90dvh, width by `size`, body scrolls inside
 * Rendered in a portal on <body> so `.card` (backdrop-blur) parents can't trap
 * `position: fixed`, and above the sticky Nav (z-60).
 */
const SIZES = { sm: 'sm:max-w-md', md: 'sm:max-w-lg', lg: 'sm:max-w-3xl' } as const;
let openCount = 0;

export function Modal({ title, icon, subtitle, onClose, children, footer, size = 'md' }: {
  title: React.ReactNode;
  icon?: React.ReactNode;
  subtitle?: React.ReactNode;
  onClose: () => void;
  children: React.ReactNode;
  footer?: React.ReactNode;
  size?: keyof typeof SIZES;
}) {
  const id = useId();
  const panel = useRef<HTMLDivElement>(null);
  const closeRef = useRef(onClose);
  closeRef.current = onClose;

  useEffect(() => {
    const prevFocus = document.activeElement as HTMLElement | null;
    openCount += 1;
    const prevOverflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    // Focus the first form control (or the panel) once mounted.
    const t = window.setTimeout(() => {
      const el = panel.current?.querySelector<HTMLElement>('[data-autofocus], input:not([disabled]):not([type=checkbox]), select:not([disabled]), textarea:not([disabled])');
      (el ?? panel.current)?.focus({ preventScroll: true });
    }, 0);
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') { e.stopPropagation(); closeRef.current(); return; }
      if (e.key !== 'Tab' || !panel.current) return;
      const f = Array.from(panel.current.querySelectorAll<HTMLElement>('a[href],button:not([disabled]),input:not([disabled]),select:not([disabled]),textarea:not([disabled]),[tabindex]:not([tabindex="-1"])'));
      if (!f.length) return;
      const first = f[0], last = f[f.length - 1];
      if (e.shiftKey && document.activeElement === first) { e.preventDefault(); last.focus(); }
      else if (!e.shiftKey && document.activeElement === last) { e.preventDefault(); first.focus(); }
    };
    document.addEventListener('keydown', onKey);
    return () => {
      window.clearTimeout(t);
      document.removeEventListener('keydown', onKey);
      openCount -= 1;
      if (openCount === 0) document.body.style.overflow = prevOverflow;
      prevFocus?.focus?.({ preventScroll: true });
    };
  }, []);

  return createPortal(
    <div className="fixed inset-0 z-[80] flex items-end sm:items-center justify-center bg-black/60 sm:p-4"
      onMouseDown={(e) => { if (e.target === e.currentTarget) onClose(); }}>
      <div ref={panel} role="dialog" aria-modal="true" aria-labelledby={`${id}-t`} tabIndex={-1}
        className={`flex flex-col w-full ${SIZES[size]} h-[100dvh] sm:h-auto sm:max-h-[90dvh] bg-navy-900 border border-steel-700/60 sm:rounded-xl shadow-2xl outline-none`}>
        <div className="shrink-0 flex items-start justify-between gap-3 px-4 sm:px-5 pt-[max(1rem,env(safe-area-inset-top))] sm:pt-4 pb-3 border-b border-steel-700/50">
          <div className="min-w-0">
            <h2 id={`${id}-t`} className="font-display text-lg font-semibold text-white flex items-center gap-2 break-words">{icon}{title}</h2>
            {subtitle && <p className="text-xs text-steel-500 mt-0.5 break-words">{subtitle}</p>}
          </div>
          <button type="button" onClick={onClose} aria-label="Close" className="shrink-0 -mr-1 p-1.5 rounded-md text-steel-400 hover:text-white hover:bg-navy-800"><X className="w-5 h-5" /></button>
        </div>
        <div className="flex-1 min-h-0 overflow-y-auto overscroll-contain px-4 sm:px-5 py-4">{children}</div>
        {footer && (
          <div className="shrink-0 flex flex-wrap items-center justify-end gap-2 px-4 sm:px-5 py-3 pb-[max(0.75rem,env(safe-area-inset-bottom))] sm:pb-3 border-t border-steel-700/50 bg-navy-900 sm:rounded-b-xl">{footer}</div>
        )}
      </div>
    </div>,
    document.body,
  );
}
