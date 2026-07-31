import { Logo } from "@/components/Logo";

export function Footer() {
  return (
    <footer className="mt-auto border-t border-surface-border/70 px-6 py-8">
      <div className="mx-auto flex max-w-6xl flex-col items-center justify-between gap-3 text-xs text-neutral-500 sm:flex-row">
        <div className="flex items-center gap-2">
          <Logo size="sm" className="h-5 w-5" />
          <span>FinEsse</span>
        </div>
        <span>Money skills that grow with you.</span>
      </div>
    </footer>
  );
}
