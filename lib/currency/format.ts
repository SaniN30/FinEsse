import { currencyOrDefault, SUPPORTED_CURRENCIES, type CurrencyCode } from "@/lib/currency/config";

/**
 * Converts a canonical USD-cents ledger amount into the given display
 * currency's smallest unit (e.g. paise for INR), rounding to that
 * currency's conventional decimal digits.
 */
export function usdCentsToDisplayUnits(usdCents: number, currency: CurrencyCode): number {
  const { usdRate, decimalDigits } = SUPPORTED_CURRENCIES[currency];
  const majorUnits = (usdCents / 100) * usdRate;
  const scale = 10 ** decimalDigits;
  return Math.round(majorUnits * scale);
}

/** Inverse of usdCentsToDisplayUnits: a user-entered amount -> canonical USD cents. */
export function displayAmountToUsdCents(displayMajorUnits: number, currency: CurrencyCode): number {
  const { usdRate } = SUPPORTED_CURRENCIES[currency];
  return Math.round((displayMajorUnits / usdRate) * 100);
}

/**
 * Formats a canonical USD-cents ledger amount for display in the given
 * currency, e.g. formatUsdCents(1000, "INR") -> "₹83.00".
 */
export function formatUsdCents(usdCents: number, currency: string | null | undefined): string {
  const resolvedCurrency = currencyOrDefault(currency);
  const { decimalDigits } = SUPPORTED_CURRENCIES[resolvedCurrency];
  const isNegative = usdCents < 0;
  const displayUnits = usdCentsToDisplayUnits(Math.abs(usdCents), resolvedCurrency);
  const scale = 10 ** decimalDigits;
  const formatted = new Intl.NumberFormat(undefined, {
    style: "currency",
    currency: resolvedCurrency,
    minimumFractionDigits: decimalDigits,
    maximumFractionDigits: decimalDigits,
  }).format(displayUnits / scale);
  return isNegative ? `-${formatted}` : formatted;
}
