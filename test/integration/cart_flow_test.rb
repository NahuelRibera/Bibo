require "test_helper"

class CartFlowTest < ActionDispatch::IntegrationTest
  test "adding, merging, updating and removing a variant through the cart endpoints" do
    product = create_product(base_price_cents: 1000)
    variant_a = create_variant(product: product, sku: "FLOW-A", colour: "Natural", price_cents: 1000, stock: 5)
    variant_b = create_variant(product: product, sku: "FLOW-B", colour: "Walnut", price_cents: 3500, stock: 5)

    post cart_items_path, params: { product_variant_id: variant_a.id, quantity: 1 }
    assert_redirected_to cart_path

    post cart_items_path, params: { product_variant_id: variant_a.id, quantity: 2 }
    post cart_items_path, params: { product_variant_id: variant_b.id, quantity: 1 }

    get cart_path
    assert_response :success

    cart = Cart.find_by(token: session[:cart_token])
    assert_equal 2, cart.cart_items.count
    assert_equal 3, cart.cart_items.find_by(product_variant: variant_a).quantity
    assert_equal 6500, cart.subtotal_cents
    assert_equal 0, cart.shipping_cents # >= 4000 threshold

    item_a = cart.cart_items.find_by(product_variant: variant_a)
    patch cart_item_path(item_a), params: { quantity: 1 }
    assert_equal 1, item_a.reload.quantity

    item_b = cart.cart_items.find_by(product_variant: variant_b)
    delete cart_item_path(item_b)
    assert_equal 1, cart.cart_items.count
  end

  test "cannot add more than available stock through the endpoint" do
    variant = create_variant(price_cents: 1000, stock: 2)

    post cart_items_path, params: { product_variant_id: variant.id, quantity: 5 }
    assert_redirected_to cart_path

    cart = Cart.find_by(token: session[:cart_token])
    assert_equal 2, cart.cart_items.first.quantity
  end

  test "cannot add an inactive variant" do
    variant = create_variant(price_cents: 1000, stock: 5, active: false)

    post cart_items_path, params: { product_variant_id: variant.id, quantity: 1 }

    assert_redirected_to product_path(variant.product)
  end
end
