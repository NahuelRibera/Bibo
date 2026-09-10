# Receives Stripe's server-to-server webhook calls. Deliberately does not
# inherit from ApplicationController: there is no browser session or CSRF
# token on these requests, only a Stripe-Signature header that we verify
# ourselves against STRIPE_WEBHOOK_SECRET.
class StripeWebhooksController < ActionController::Base
  skip_before_action :verify_authenticity_token, raise: false

  def create
    secret = Rails.application.config.x.stripe_webhook_secret
    if secret.blank?
      Rails.logger.warn("[Stripe webhook] STRIPE_WEBHOOK_SECRET is not configured; rejecting webhook")
      return head :service_unavailable
    end

    begin
      event = Stripe::Webhook.construct_event(request.body.read, request.headers["Stripe-Signature"], secret)
    rescue JSON::ParserError, Stripe::SignatureVerificationError => e
      Rails.logger.warn("[Stripe webhook] rejected: #{e.message}")
      return head :bad_request
    end

    handle_checkout_completed(event.data.object) if event.type == "checkout.session.completed"

    head :ok
  end

  private

  # Order#confirm_payment! is itself idempotent (guarded by the order's own
  # status under a row lock), so a redelivered event, or one that arrives
  # after the success-page check already confirmed the order, is a safe
  # no-op rather than a duplicate stock decrement.
  def handle_checkout_completed(session)
    order = Order.find_by(stripe_checkout_session_id: session.id)
    return unless order
    return unless session.payment_status == "paid"

    order.confirm_payment!(
      payment_intent_id: session.payment_intent,
      customer_email: session.customer_details&.email
    )
  end
end
