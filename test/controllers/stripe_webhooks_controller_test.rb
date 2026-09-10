require "test_helper"

class StripeWebhooksControllerTest < ActionDispatch::IntegrationTest
  WEBHOOK_SECRET = "whsec_test_secret"

  setup do
    @original_secret = Rails.application.config.x.stripe_webhook_secret
    Rails.application.config.x.stripe_webhook_secret = WEBHOOK_SECRET
  end

  teardown do
    Rails.application.config.x.stripe_webhook_secret = @original_secret
  end

  def checkout_completed_payload(session_id:, payment_status: "paid", email: "buyer@example.com")
    {
      id: "evt_#{SecureRandom.hex(8)}",
      type: "checkout.session.completed",
      data: {
        object: {
          id: session_id,
          payment_status: payment_status,
          payment_intent: "pi_#{SecureRandom.hex(8)}",
          customer_details: { email: email },
        },
      },
    }.to_json
  end

  def post_webhook(payload, secret: WEBHOOK_SECRET)
    post "/webhooks/stripe", params: payload, headers: {
      "Content-Type" => "application/json",
      "Stripe-Signature" => stripe_signature_header(payload, secret: secret),
    }
  end

  test "a validly signed checkout.session.completed event marks the matching order paid" do
    order = create_order
    create_order_item(order: order)
    order.update!(stripe_checkout_session_id: "cs_test_123")

    payload = checkout_completed_payload(session_id: "cs_test_123")
    post_webhook(payload)

    assert_response :success
    assert order.reload.paid?
    assert_equal "buyer@example.com", order.customer_email
  end

  test "an invalid signature is rejected and the order is left untouched" do
    order = create_order
    order.update!(stripe_checkout_session_id: "cs_test_123")

    payload = checkout_completed_payload(session_id: "cs_test_123")
    post "/webhooks/stripe", params: payload, headers: {
      "Content-Type" => "application/json",
      "Stripe-Signature" => "t=1,v1=not_a_real_signature",
    }

    assert_response :bad_request
    assert order.reload.pending?
  end

  test "an event for an unknown session is ignored safely" do
    payload = checkout_completed_payload(session_id: "cs_test_does_not_exist")

    post_webhook(payload)

    assert_response :success
  end

  test "an unrelated event type is ignored safely" do
    order = create_order
    order.update!(stripe_checkout_session_id: "cs_test_123")

    payload = { id: "evt_1", type: "payment_intent.created", data: { object: { id: "pi_1" } } }.to_json
    post_webhook(payload)

    assert_response :success
    assert order.reload.pending?
  end

  test "redelivering the same event is idempotent and does not double-decrement stock" do
    variant = create_variant(stock: 10)
    order = create_order
    create_order_item(order: order, product_variant: variant, quantity: 3)
    order.update!(stripe_checkout_session_id: "cs_test_123")

    payload = checkout_completed_payload(session_id: "cs_test_123")
    post_webhook(payload)
    assert_equal 7, variant.reload.stock

    # Stripe redelivers the identical event (e.g. because the first ack was lost).
    post_webhook(payload)

    assert_response :success
    assert_equal 7, variant.reload.stock
  end

  test "without STRIPE_WEBHOOK_SECRET configured, the endpoint refuses rather than skipping verification" do
    Rails.application.config.x.stripe_webhook_secret = nil
    order = create_order
    order.update!(stripe_checkout_session_id: "cs_test_123")

    payload = checkout_completed_payload(session_id: "cs_test_123")
    post "/webhooks/stripe", params: payload, headers: { "Content-Type" => "application/json", "Stripe-Signature" => "t=1,v1=whatever" }

    assert_response :service_unavailable
    assert order.reload.pending?
  end
end
