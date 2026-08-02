import type { Metadata } from "next";
import { Inter, Baloo_2 } from "next/font/google";
import { AuthProvider } from "@/lib/supabase/auth-context";
import "./globals.css";
import { Footer } from "@/components/Footer";
import { MotionProvider } from "@/components/MotionProvider";
import { StickyNotesWidget } from "@/components/sticky-notes/StickyNotesWidget";

const baloo2 = Baloo_2({
  variable: "--font-baloo-2",
  subsets: ["latin"],
  weight: ["500", "600", "700", "800"],
});

const inter = Inter({
  variable: "--font-inter",
  subsets: ["latin"],
  weight: ["400", "500", "600"],
});

export const metadata: Metadata = {
  title: "FinEsse — Money skills that grow with you",
  description:
    "FinEsse teaches financial literacy in three stages — School, College, and Job-Ready — so the money skills you learn actually meet you where you are.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      className={`${baloo2.variable} ${inter.variable} h-full antialiased`}
    >
      <body className="min-h-full flex flex-col bg-background text-foreground">
        <script
          dangerouslySetInnerHTML={{
            __html: `try{var t=localStorage.getItem("finesse-theme");if(t==="light"||t==="dark"){document.documentElement.setAttribute("data-theme",t);}}catch(e){}`,
          }}
        />
        <MotionProvider>
          <AuthProvider>
            {children}
            <Footer />
            <StickyNotesWidget />
          </AuthProvider>
        </MotionProvider>
      </body>
    </html>
  );
}
