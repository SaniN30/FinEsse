export default function SchoolLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return <div className="theme-tier-school flex flex-1 flex-col">{children}</div>;
}
