export default function JobReadyLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return <div className="theme-tier-jobready flex flex-1 flex-col">{children}</div>;
}
