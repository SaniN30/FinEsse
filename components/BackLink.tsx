import Link from "next/link";

interface BackLinkProps {
  href: string;
  label: string;
  className?: string;
}

export function BackLink({ href, label, className }: BackLinkProps) {
  return (
    <Link
      href={href}
      className={`mb-6 inline-flex items-center gap-1.5 text-sm font-medium text-muted-foreground hover:text-primary-500 ${className ?? ""}`}
    >
      <span aria-hidden="true">&larr;</span>
      {label}
    </Link>
  );
}
