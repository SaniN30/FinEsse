import { describe, expect, it } from "vitest";
import { formatUsdCents, displayAmountToUsdCents } from "@/lib/currency/format";

describe("formatUsdCents", () => {
  it("formats USD cents with the dollar symbol and two decimals", () => {
    expect(formatUsdCents(5000, "USD")).toBe("$50.00");
  });

  it("formats INR by converting the static USD rate and using the rupee symbol", () => {
    expect(formatUsdCents(1000, "INR")).toBe("₹830.00");
  });

  it("defaults to USD when currency is missing or unsupported", () => {
    expect(formatUsdCents(2500, null)).toBe("$25.00");
    expect(formatUsdCents(2500, "XYZ")).toBe("$25.00");
  });

  it("formats JPY with zero decimal digits", () => {
    expect(formatUsdCents(10000, "JPY")).toBe("¥14,900");
  });

  it("preserves the negative sign for negative amounts", () => {
    expect(formatUsdCents(-5000, "USD")).toBe("-$50.00");
  });
});

describe("displayAmountToUsdCents", () => {
  it("converts a user-entered INR amount back into canonical USD cents", () => {
    expect(displayAmountToUsdCents(830, "INR")).toBe(1000);
  });

  it("round-trips a USD amount unchanged", () => {
    expect(displayAmountToUsdCents(50, "USD")).toBe(5000);
  });
});
