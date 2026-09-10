ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock" # for Object#stub, used to fake Stripe API calls in tests

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Small builders shared across model/integration tests. The domain has
    # enough required associations (product -> category, variant -> product)
    # that hand-rolling these in every test would be repetitive.
    def create_category(name: "Category #{SecureRandom.hex(4)}")
      Category.create!(name: name)
    end

    def create_product(category: create_category, name: "Sample Product #{SecureRandom.hex(4)}", base_price_cents: 1000)
      Product.create!(
        category: category,
        name: name,
        short_description: "Short description.",
        description: "Full description.",
        base_price_cents: base_price_cents
      )
    end

    def create_variant(product: create_product, sku: nil, colour: nil, option_label: nil, price_cents: 1000, stock: 10, active: true)
      ProductVariant.create!(
        product: product,
        sku: sku || "SKU-#{SecureRandom.hex(4)}",
        colour: colour,
        option_label: option_label,
        price_cents: price_cents,
        stock: stock,
        active: active
      )
    end

    def create_order(status: "pending", subtotal_cents: 1000, shipping_cents: 499)
      Order.create!(
        status: status,
        currency: "eur",
        subtotal_cents: subtotal_cents,
        shipping_cents: shipping_cents,
        total_cents: subtotal_cents + shipping_cents
      )
    end

    def create_order_item(order: create_order, product_variant: create_variant, quantity: 1)
      unit_price_cents = product_variant.price_cents

      OrderItem.create!(
        order: order,
        product_variant: product_variant,
        product_name: product_variant.product.name,
        product_slug: product_variant.product.slug,
        variant_label: product_variant.label == "Standard" ? nil : product_variant.label,
        sku: product_variant.sku,
        unit_price_cents: unit_price_cents,
        quantity: quantity,
        line_total_cents: unit_price_cents * quantity
      )
    end

    # A minimal stand-in for a Stripe::Checkout::Session, exposing just the
    # fields the app reads (id/url on creation, payment_status/payment_intent/
    # customer_details on retrieval) so tests never hit the real Stripe API.
    def fake_stripe_session(id: "cs_test_#{SecureRandom.hex(8)}", url: "https://checkout.stripe.com/pay/#{SecureRandom.hex(8)}",
                             payment_status: "unpaid", payment_intent: "pi_test_#{SecureRandom.hex(8)}", email: nil)
      OpenStruct.new(
        id: id,
        url: url,
        payment_status: payment_status,
        payment_intent: payment_intent,
        customer_details: email ? OpenStruct.new(email: email) : nil
      )
    end

    # Builds a real, validly-signed Stripe-Signature header value the same
    # way Stripe itself would, using the gem's own signing helper - so
    # webhook tests exercise the actual verification path, not a stub of it.
    def stripe_signature_header(payload, secret:, timestamp: Time.now)
      signature = Stripe::Webhook::Signature.compute_signature(timestamp, payload, secret)
      Stripe::Webhook::Signature.generate_header(timestamp, signature)
    end
  end
end
