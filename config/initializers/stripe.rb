# Stripe test-mode configuration. Bibo must keep working (catalogue, cart,
# wishlist) even when these are unset - only checkout itself is disabled in
# that case. See CheckoutsController for the "Stripe not configured" guard.
Stripe.api_key = ENV["STRIPE_SECRET_KEY"]

Rails.application.config.x.stripe_publishable_key = ENV["STRIPE_PUBLISHABLE_KEY"]
Rails.application.config.x.stripe_webhook_secret = ENV["STRIPE_WEBHOOK_SECRET"]
