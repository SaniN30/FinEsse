-- Adds a per-profile display currency for the Pocket Money Planner.
-- Ledger amounts (accounts/postings.amount_cents) stay canonical USD cents
-- unchanged -- this column only controls which currency a profile's own
-- balances/goals are converted to and formatted in on read, via the static
-- rate table in lib/currency/config.ts. See AGENTS.md's "Multi-currency
-- pocket money" note for the full design rationale.
alter table profiles
  add column currency text not null default 'USD'
  check (currency in ('USD', 'INR', 'GBP', 'EUR', 'CAD', 'AUD', 'JPY'));

comment on column profiles.currency is
  'Display currency for this profile''s pocket-money amounts. Ledger storage stays USD cents; conversion is static-rate, display-only (see lib/currency/config.ts).';
