export default function CollegeLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return <div className="theme-tier-college flex flex-1 flex-col">{children}</div>;
}
