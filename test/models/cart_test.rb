require "test_helper"

class CartTest < ActiveSupport::TestCase
  test "assigns a unique token on creation" do
    cart = Cart.create!
    assert cart.token.present?
  end

  test "adding a variant creates a cart item" do
    cart = Cart.create!
    variant = create_variant(price_cents: 1000, stock: 10)

    cart.add_variant(variant, 2)

    assert_equal 1, cart.cart_items.count
    assert_equal 2, cart.cart_items.first.quantity
  end

  test "adding the same variant again merges into the existing item" do
    cart = Cart.create!
    variant = create_variant(price_cents: 1000, stock: 10)

    cart.add_variant(variant, 2)
    cart.add_variant(variant, 3)

    assert_equal 1, cart.cart_items.count
    assert_equal 5, cart.cart_items.first.quantity
  end

  test "adding a different variant stays as a separate item" do
    product = create_product
    cart = Cart.create!
    variant_a = create_variant(product: product, sku: "A", colour: "Natural", stock: 10)
    variant_b = create_variant(product: product, sku: "B", colour: "Walnut", stock: 10)

    cart.add_variant(variant_a, 1)
    cart.add_variant(variant_b, 1)

    assert_equal 2, cart.cart_items.count
  end

  test "adding a variant clamps quantity to available stock" do
    cart = Cart.create!
    variant = create_variant(stock: 3)

    cart.add_variant(variant, 10)

    assert_equal 3, cart.cart_items.first.quantity
  end

  test "raises when adding an inactive variant" do
    cart = Cart.create!
    variant = create_variant(active: false, stock: 10)

    assert_raises(ArgumentError) { cart.add_variant(variant, 1) }
  end

  test "raises when adding an out-of-stock variant" do
    cart = Cart.create!
    variant = create_variant(stock: 0)

    assert_raises(ArgumentError) { cart.add_variant(variant, 1) }
  end

  test "subtotal sums line subtotals across items" do
    product = create_product
    cart = Cart.create!
    variant_a = create_variant(product: product, sku: "A", colour: "Natural", price_cents: 1000, stock: 10)
    variant_b = create_variant(product: product, sku: "B", colour: "Walnut", price_cents: 2500, stock: 10)

    cart.add_variant(variant_a, 2) # 2000
    cart.add_variant(variant_b, 1) # 2500

    assert_equal 4500, cart.subtotal_cents
  end

  test "charges flat shipping below the free shipping threshold" do
    cart = Cart.create!
    variant = create_variant(price_cents: 1000, stock: 10)
    cart.add_variant(variant, 3) # 3000 cents, below 4000 threshold

    assert_equal Cart::SHIPPING_CENTS, cart.shipping_cents
  end

  test "gives free shipping at or above the threshold" do
    cart = Cart.create!
    variant = create_variant(price_cents: 4000, stock: 10)
    cart.add_variant(variant, 1)

    assert_equal 0, cart.shipping_cents
  end

  test "charges no shipping on an empty cart" do
    cart = Cart.create!
    assert_equal 0, cart.shipping_cents
  end

  test "total is subtotal plus shipping" do
    cart = Cart.create!
    variant = create_variant(price_cents: 1000, stock: 10)
    cart.add_variant(variant, 2) # subtotal 2000, shipping 499

    assert_equal 2499, cart.total_cents
  end
end
