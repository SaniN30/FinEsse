export type CurrencyCode = "USD" | "INR" | "GBP" | "EUR" | "CAD" | "AUD" | "JPY";

export interface CurrencyDefinition {
  code: CurrencyCode;
  name: string;
  symbol: string;
  /** Decimal digits this currency is conventionally displayed with. */
  decimalDigits: number;
  /**
   * Static rate to convert 1 USD into this currency. Ledger amounts are
   * always stored as USD cents (see supabase/migrations/00000000000003_ledger.sql);
   * this is purely a display/input conversion for a virtual pocket-money
   * feature, not a real FX rate feed -- see AGENTS.md's "Multi-currency
   * pocket money" note for why a static table is enough here.
   */
  usdRate: number;
}

export const SUPPORTED_CURRENCIES: Record<CurrencyCode, CurrencyDefinition> = {
  USD: { code: "USD", name: "US Dollar", symbol: "$", decimalDigits: 2, usdRate: 1 },
  INR: { code: "INR", name: "Indian Rupee", symbol: "₹", decimalDigits: 2, usdRate: 83 },
  GBP: { code: "GBP", name: "British Pound", symbol: "£", decimalDigits: 2, usdRate: 0.79 },
  EUR: { code: "EUR", name: "Euro", symbol: "€", decimalDigits: 2, usdRate: 0.92 },
  CAD: { code: "CAD", name: "Canadian Dollar", symbol: "$", decimalDigits: 2, usdRate: 1.36 },
  AUD: { code: "AUD", name: "Australian Dollar", symbol: "$", decimalDigits: 2, usdRate: 1.52 },
  JPY: { code: "JPY", name: "Japanese Yen", symbol: "¥", decimalDigits: 0, usdRate: 149 },
};

export const DEFAULT_CURRENCY: CurrencyCode = "USD";

export function isSupportedCurrency(value: string | null | undefined): value is CurrencyCode {
  return typeof value === "string" && value in SUPPORTED_CURRENCIES;
}

export function currencyOrDefault(value: string | null | undefined): CurrencyCode {
  return isSupportedCurrency(value) ? value : DEFAULT_CURRENCY;
}

/** For SelectField-style currency pickers (signup, settings, parent dashboard). */
export const CURRENCY_OPTIONS: { value: CurrencyCode; label: string }[] = Object.values(
  SUPPORTED_CURRENCIES,
).map((definition) => ({
  value: definition.code,
  label: `${definition.name} (${definition.symbol})`,
}));
