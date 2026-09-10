require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "assigns a unique token on creation" do
    order = create_order
    assert order.token.present?
  end

  test "defaults to pending status" do
    order = Order.create!(currency: "eur", subtotal_cents: 1000, shipping_cents: 499, total_cents: 1499)
    assert_equal "pending", order.status
    assert order.pending?
  end

  test "rejects an unknown status" do
    order = create_order
    order.status = "refunded"
    assert_not order.valid?
    assert_includes order.errors[:status], "is not included in the list"
  end

  test "the database also rejects an unknown status" do
    order = create_order

    assert_raises(ActiveRecord::StatementInvalid) { order.update_column(:status, "refunded") }
  end

  test "requires total to equal subtotal plus shipping" do
    order = Order.new(currency: "eur", subtotal_cents: 1000, shipping_cents: 499, total_cents: 9999)

    assert_not order.valid?
    assert_includes order.errors[:total_cents], "must equal subtotal plus shipping"
  end

  test "the database also rejects a total that does not match subtotal plus shipping" do
    order = create_order(subtotal_cents: 1000, shipping_cents: 499)

    assert_raises(ActiveRecord::StatementInvalid) { order.update_column(:total_cents, 1) }
  end

  test "the database rejects negative subtotal, shipping and total" do
    order = create_order

    assert_raises(ActiveRecord::StatementInvalid) { order.update_columns(subtotal_cents: -1, total_cents: order.shipping_cents - 1) }
  end

  test "confirm_payment! marks the order paid and decrements stock exactly once" do
    variant = create_variant(stock: 10)
    order = create_order
    create_order_item(order: order, product_variant: variant, quantity: 3)

    order.confirm_payment!(payment_intent_id: "pi_123", customer_email: "buyer@example.com")

    assert order.reload.paid?
    assert_equal "pi_123", order.stripe_payment_intent_id
    assert_equal "buyer@example.com", order.customer_email
    assert_equal 7, variant.reload.stock

    # Calling it again (as a retried webhook or the success-page check both
    # might) must not decrement stock a second time.
    order.confirm_payment!(payment_intent_id: "pi_123", customer_email: "buyer@example.com")
    assert_equal 7, variant.reload.stock
  end

  test "confirm_payment! never drives stock negative" do
    variant = create_variant(stock: 2)
    order = create_order
    create_order_item(order: order, product_variant: variant, quantity: 5)

    order.confirm_payment!(payment_intent_id: "pi_123")

    assert_equal 0, variant.reload.stock
  end

  test "cancel! cancels a pending order" do
    order = create_order
    order.cancel!
    assert order.reload.cancelled?
  end

  test "cancel! does not touch a paid order" do
    order = create_order
    create_order_item(order: order)
    order.confirm_payment!(payment_intent_id: "pi_123")

    order.cancel!

    assert order.reload.paid?
  end

  test "confirm_payment! never revives a cancelled order, even from a late webhook" do
    variant = create_variant(stock: 10)
    order = create_order
    create_order_item(order: order, product_variant: variant, quantity: 3)
    order.cancel!

    result = order.confirm_payment!(payment_intent_id: "pi_123")

    assert_equal false, result
    assert order.reload.cancelled?
    assert_equal 10, variant.reload.stock
  end

  test "to_param uses the token, not the numeric id" do
    order = create_order
    assert_equal order.token, order.to_param
  end
end
