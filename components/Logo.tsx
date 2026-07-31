import Image from "next/image";
import { cn } from "@/lib/cn";

const SIZES = {
  sm: 28,
  md: 56,
  lg: 112,
} as const;

interface LogoProps {
  size?: keyof typeof SIZES;
  className?: string;
}

export function Logo({ size = "sm", className }: LogoProps) {
  const px = SIZES[size];

  return (
    <Image
      src="/logo.png"
      alt="FinEsse"
      width={px}
      height={px}
      priority={size === "lg"}
      className={cn("select-none", className)}
    />
  );
}
