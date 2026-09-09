require "test_helper"

class CartItemTest < ActiveSupport::TestCase
  test "quantity must be at least 1" do
    item = CartItem.new(cart: Cart.create!, product_variant: create_variant, quantity: 0)
    assert_not item.valid?
    assert_includes item.errors[:quantity], "must be greater than or equal to 1"
  end

  test "the database also rejects a quantity below 1" do
    item = CartItem.create!(cart: Cart.create!, product_variant: create_variant(stock: 5), quantity: 1)
    assert_raises(ActiveRecord::StatementInvalid) { item.update_column(:quantity, 0) }
  end

  test "quantity cannot exceed the variant's stock" do
    variant = create_variant(stock: 2)
    item = CartItem.new(cart: Cart.create!, product_variant: variant, quantity: 3)

    assert_not item.valid?
    assert_includes item.errors[:quantity], "exceeds available stock"
  end

  test "the same variant cannot appear twice in one cart" do
    cart = Cart.create!
    variant = create_variant(stock: 10)
    CartItem.create!(cart: cart, product_variant: variant, quantity: 1)
    duplicate = CartItem.new(cart: cart, product_variant: variant, quantity: 1)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:product_variant_id], "has already been taken"
  end

  test "line_subtotal_cents multiplies variant price by quantity" do
    variant = create_variant(price_cents: 1250, stock: 10)
    item = CartItem.create!(cart: Cart.create!, product_variant: variant, quantity: 3)

    assert_equal 3750, item.line_subtotal_cents
  end
end
