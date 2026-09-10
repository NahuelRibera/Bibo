class CheckoutsController < ApplicationController
  before_action :require_stripe_configured, only: :create

  # Starts a Stripe Checkout Session. Every price here comes from the
  # database: the browser only ever supplied product/variant ids and
  # quantities when items were added to the cart, never amounts.
  def create
    items = current_cart.cart_items.includes(product_variant: :product).to_a

    if items.empty?
      return redirect_to cart_path, alert: "Your cart is empty."
    end

    unless items.all? { |item| checkoutable?(item) }
      return redirect_to cart_path,
        alert: "Some items in your cart are no longer available in that quantity. Please review your cart."
    end

    order = build_order(items)

    begin
      stripe_session = Stripe::Checkout::Session.create(
        mode: "payment",
        line_items: stripe_line_items(order),
        shipping_options: stripe_shipping_options(order),
        success_url: checkout_success_url(order_token: order.token),
        cancel_url: checkout_cancel_url(order_token: order.token),
        metadata: { order_token: order.token }
      )
      order.update!(stripe_checkout_session_id: stripe_session.id)
      redirect_to stripe_session.url, allow_other_host: true
    rescue Stripe::StripeError => e
      Rails.logger.error("[Stripe] checkout session creation failed: #{e.message}")
      order.cancel!
      redirect_to cart_path, alert: "We couldn't start checkout just now. Please try again in a moment."
    end
  end

  # The browser lands here after Stripe, but reaching this URL is not proof
  # of payment on its own: we ask Stripe for the session's real status
  # before treating the order as paid. If the webhook already confirmed it
  # (which can easily happen first), this is a no-op thanks to
  # Order#confirm_payment! being idempotent.
  def success
    order = Order.find_by(token: params[:order_token])
    return redirect_to cart_path, alert: "We couldn't find that order." unless order

    if order.pending? && order.stripe_checkout_session_id.present? && stripe_configured?
      begin
        stripe_session = Stripe::Checkout::Session.retrieve(order.stripe_checkout_session_id)
        if stripe_session.payment_status == "paid"
          order.confirm_payment!(
            payment_intent_id: stripe_session.payment_intent,
            customer_email: stripe_session.customer_details&.email
          )
        end
      rescue Stripe::StripeError => e
        Rails.logger.error("[Stripe] checkout session retrieve failed: #{e.message}")
      end
    end

    retire_cart! if order.reload.paid?
    redirect_to order_path(order)
  end

  def cancel
    @order = Order.find_by(token: params[:order_token])
    @order&.cancel!
  end

  private

  def require_stripe_configured
    return if stripe_configured?

    redirect_to cart_path, alert: "Demo checkout is unavailable because Stripe test credentials are not configured."
  end

  def checkoutable?(item)
    variant = item.product_variant
    variant.purchasable? && variant.product.active? && item.quantity <= variant.stock
  end

  def build_order(items)
    order = nil

    ActiveRecord::Base.transaction do
      order = Order.create!(status: "pending", currency: "eur")

      subtotal_cents = items.sum do |item|
        variant = item.product_variant
        line_total_cents = variant.price_cents * item.quantity

        order.order_items.create!(
          product_variant: variant,
          product_name: variant.product.name,
          product_slug: variant.product.slug,
          variant_label: variant.label == "Standard" ? nil : variant.label,
          sku: variant.sku,
          unit_price_cents: variant.price_cents,
          quantity: item.quantity,
          line_total_cents: line_total_cents
        )

        line_total_cents
      end

      shipping_cents = Cart.shipping_cents_for(subtotal_cents)
      order.update!(
        subtotal_cents: subtotal_cents,
        shipping_cents: shipping_cents,
        total_cents: subtotal_cents + shipping_cents
      )
    end

    order
  end

  def stripe_line_items(order)
    order.order_items.map do |item|
      {
        quantity: item.quantity,
        price_data: {
          currency: order.currency,
          unit_amount: item.unit_price_cents,
          product_data: { name: item.display_name },
        },
      }
    end
  end

  def stripe_shipping_options(order)
    [{
      shipping_rate_data: {
        type: "fixed_amount",
        fixed_amount: { amount: order.shipping_cents, currency: order.currency },
        display_name: order.shipping_cents.zero? ? "Free shipping" : "Standard shipping",
      },
    }]
  end

  # The order that was just paid for should stop behaving like an active
  # cart. Only the browser session knows which cart that was, so this can
  # only happen here (a webhook has no session), and only once payment is
  # actually confirmed.
  def retire_cart!
    session.delete(:cart_token)
    @current_cart = nil
  end
end
