# Bibo

Bibo is a full-stack e-commerce project for affordable home essentials and
decor. It includes a product catalogue with variants, search and filtering,
reviews, a guest cart, wishlist, and Stripe Checkout in test mode. I built it
as a portfolio project to cover the main parts of an online shopping experience
from browsing to order confirmation.

## Features

- Product catalogue with categories, search, filtering (category/colour)
  and sorting
- Generic product variants (colour, size) that adapt per product, no
  hardcoded product logic
- Product image gallery
- Reviews with a cached average rating per product
- Guest cart tied to specific product variants
- Session-based wishlist
- Stripe Checkout in test mode, with orders stored in the database
- Order confirmation page with a shareable link
- Responsive layout, keyboard-accessible nav, gallery, tabs and controls

## Tech stack

- Ruby on Rails
- PostgreSQL
- ERB views
- Hotwire (Turbo + Stimulus)
- Hand-written CSS, no frontend framework
- Stripe (test mode)
- Minitest

## How it works

Users can browse the catalogue, search or filter products, choose the right
colour or size, add a specific variant to the cart and continue to Stripe
Checkout. Once a test payment is confirmed, Bibo creates the order confirmation
and keeps a snapshot of what was purchased.

Adding to cart creates a `CartItem` for that exact variant. Checkout
rebuilds the cart from the database (ignoring anything the browser sent),
creates an `Order` with `OrderItem` snapshots, and opens a Stripe Checkout
Session. When Stripe confirms payment, either through the redirect back to
the app or through a webhook, the order is marked paid and stock is
decremented once.


## Key technical decisions

- **Prices are integer cents**, not floats, everywhere from the database up
  to the Stripe line items.
- **`CartItem` points to a `ProductVariant`, not a `Product`**, so "Set of 4,
  Walnut" and "Set of 2, Natural" stay separate cart lines.
- **Checkout recalculates everything server-side.** The browser only ever
  sends a variant id and a quantity; price, subtotal, shipping and total
  are all read fresh from PostgreSQL before Stripe is involved.
- **`OrderItem` stores a snapshot** of the product name, variant, SKU and
  price at purchase time, so an order still shows what was bought even if
  the product is later renamed or repriced.
- **Search uses plain PostgreSQL `ILIKE`**, not an external search service.
  The catalogue is small enough that it doesn't need one.
- **The wishlist is just an array of product ids in the session**, not a
  database table. It's guest-only, so there's no need for anything heavier.
- **Stripe runs in test mode only.** Without test credentials configured,
  checkout is disabled with a short explanation, but the rest of the app
  still works.

## Project structure

| Path | What's there |
|---|---|
| `app/models` | `Product`, `ProductVariant`, `Category`, `Review`, `Cart`, `CartItem`, `Order`, `OrderItem` |
| `app/controllers` | Catalogue, cart, wishlist, checkout, orders, static pages, Stripe webhook |
| `app/views` | ERB templates and partials |
| `app/javascript/controllers` | Stimulus controllers (gallery, variant selector, tabs, cart quantity, mobile nav, etc.) |
| `db` | Migrations and `seeds.rb` |
| `test` | Model, controller and integration tests |
| `docs` | Notes on remaining work, like real product photography |

## Setup

Requires Ruby 3.1.2 and a local PostgreSQL server.

```bash
git clone <this-repo>
cd Bibo
bundle install
bin/rails db:prepare   # creates the databases and runs migrations
bin/rails db:seed      # loads the demo catalogue, safe to re-run
bin/rails server
```

Then open `http://localhost:3000`.

## Stripe test mode

Stripe Checkout is included for testing the full purchase flow, but Bibo does
not process real payments. Test credentials are kept outside the repository,
and the rest of the store can be used normally without configuring Stripe.

Copy `.env.example` to `.env` and add your own test keys from
[dashboard.stripe.com/test/apikeys](https://dashboard.stripe.com/test/apikeys):

```
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...   # only needed to test the webhook locally
```

Stripe is optional when running the project locally. Without
`STRIPE_SECRET_KEY`, checkout stays disabled and the rest of the catalogue,
wishlist and cart continue to work normally. With test credentials configured,
Stripe Checkout can be tested using `4242 4242 4242 4242`, any future expiry
date and CVC.

## Tests

```bash
bin/rails test
```

Latest run: **107 runs, 275 assertions, 0 failures, 0 errors, 0 skips.**

Stripe calls in the tests are stubbed, nothing hits the real Stripe API.
The webhook tests do generate a real signed payload, so signature
verification itself is actually exercised.

## Demo data

`db/seeds.rb` is idempotent and currently creates 8 categories, 12
products, 30 variants, 24 product images and 36 reviews.

## Current scope / future improvements

For now, the project keeps a few things deliberately simple:

- No persistent accounts or order history, orders are guest-only and
  reachable by their own link
- No admin panel, products only come from seeds
- No stock reservation during checkout, just a stock check at checkout
  time and a decrement once payment is confirmed
- Product photos are placeholder graphics, not real photography (see
  `docs/IMAGE_ASSET_PLAN.md`)
- No production Stripe setup or real payments
