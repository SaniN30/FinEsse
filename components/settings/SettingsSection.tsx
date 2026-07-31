interface SettingsSectionProps {
  title: string;
  description?: string;
  children: React.ReactNode;
}

export function SettingsSection({ title, description, children }: SettingsSectionProps) {
  return (
    <section className="rounded-[var(--radius-card)] border border-surface-border bg-surface p-6 shadow-soft sm:p-8">
      <h2 className="text-lg font-semibold tracking-tight">{title}</h2>
      {description ? (
        <p className="mt-1 text-sm text-neutral-500">{description}</p>
      ) : null}
      <div className="mt-6 space-y-5">{children}</div>
    </section>
  );
}
