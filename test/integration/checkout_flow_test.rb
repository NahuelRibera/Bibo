require "test_helper"

class CheckoutFlowTest < ActionDispatch::IntegrationTest
  setup do
    @original_api_key = Stripe.api_key
    Stripe.api_key = "sk_test_fake"
  end

  teardown do
    Stripe.api_key = @original_api_key
  end

  test "an empty cart cannot check out" do
    post checkout_path
    assert_redirected_to cart_path
    assert_equal "Your cart is empty.", flash[:alert]
  end

  test "without Stripe configured, checkout is disabled with a clear message and the cart is untouched" do
    Stripe.api_key = nil
    variant = create_variant(stock: 5)
    post cart_items_path, params: { product_variant_id: variant.id, quantity: 1 }

    post checkout_path

    assert_redirected_to cart_path
    assert_equal "Demo checkout is unavailable because Stripe test credentials are not configured.", flash[:alert]
    assert_equal 0, Order.count
  end

  test "an inactive variant blocks checkout" do
    variant = create_variant(stock: 5)
    post cart_items_path, params: { product_variant_id: variant.id, quantity: 1 }
    variant.update_column(:active, false)

    post checkout_path

    assert_redirected_to cart_path
    assert_match "no longer available", flash[:alert]
    assert_equal 0, Order.count
  end

  test "a quantity that now exceeds stock blocks checkout" do
    variant = create_variant(stock: 5)
    post cart_items_path, params: { product_variant_id: variant.id, quantity: 5 }
    variant.update_column(:stock, 2)

    post checkout_path

    assert_redirected_to cart_path
    assert_match "no longer available", flash[:alert]
    assert_equal 0, Order.count
  end

  test "checkout uses the current database price, not whatever the price was when it was added to the cart" do
    variant = create_variant(price_cents: 1000, stock: 5)
    post cart_items_path, params: { product_variant_id: variant.id, quantity: 2 }
    variant.update_column(:price_cents, 2500) # price changes after the item was added

    fake_session = fake_stripe_session
    Stripe::Checkout::Session.stub(:create, ->(**kwargs) {
      line_item = kwargs[:line_items].first
      assert_equal 2500, line_item[:price_data][:unit_amount], "Stripe line item must use the current DB price"
      fake_session
    }) do
      post checkout_path
    end

    order = Order.last
    assert_equal 5000, order.subtotal_cents # 2 x 2500, not 2 x 1000
    assert_equal 2500, order.order_items.first.unit_price_cents
  end

  test "shipping is charged below the free shipping threshold" do
    variant = create_variant(price_cents: 1000, stock: 5)
    post cart_items_path, params: { product_variant_id: variant.id, quantity: 2 } # 2000 cents

    Stripe::Checkout::Session.stub(:create, ->(**_kwargs) { fake_stripe_session }) do
      post checkout_path
    end

    order = Order.last
    assert_equal 2000, order.subtotal_cents
    assert_equal Cart::SHIPPING_CENTS, order.shipping_cents
    assert_equal 2000 + Cart::SHIPPING_CENTS, order.total_cents
  end

  test "shipping is free at or above the threshold" do
    variant = create_variant(price_cents: 4500, stock: 5)
    post cart_items_path, params: { product_variant_id: variant.id, quantity: 1 }

    Stripe::Checkout::Session.stub(:create, ->(**_kwargs) { fake_stripe_session }) do
      post checkout_path
    end

    order = Order.last
    assert_equal 0, order.shipping_cents
    assert_equal 4500, order.total_cents
  end

  test "a successful session creation redirects to Stripe and stores the session id" do
    variant = create_variant(price_cents: 1000, stock: 5)
    post cart_items_path, params: { product_variant_id: variant.id, quantity: 1 }

    fake_session = fake_stripe_session
    Stripe::Checkout::Session.stub(:create, ->(**_kwargs) { fake_session }) do
      post checkout_path
    end

    assert_redirected_to fake_session.url
    assert_equal fake_session.id, Order.last.stripe_checkout_session_id
    assert Order.last.pending?
  end

  test "a Stripe API failure during session creation is handled gracefully, not a 500" do
    variant = create_variant(price_cents: 1000, stock: 5)
    post cart_items_path, params: { product_variant_id: variant.id, quantity: 1 }

    Stripe::Checkout::Session.stub(:create, ->(**_kwargs) { raise Stripe::APIConnectionError.new("boom") }) do
      post checkout_path
    end

    assert_redirected_to cart_path
    assert_match "couldn't start checkout", flash[:alert]
    assert Order.last.cancelled?
  end

  test "browse a product, choose an exact variant, add to cart, and check out from server-side prices" do
    product = create_product(name: "Glass Storage Jars")
    create_variant(product: product, sku: "WRONG", option_label: "Set of 2", colour: "Natural", price_cents: 1999, stock: 10)
    chosen = create_variant(product: product, sku: "CHOSEN", option_label: "Set of 3", colour: "Walnut", price_cents: 2499, stock: 10)

    get product_path(product)
    assert_response :success

    post cart_items_path, params: { product_variant_id: chosen.id, quantity: 2 }
    assert_redirected_to cart_path

    fake_session = fake_stripe_session
    Stripe::Checkout::Session.stub(:create, ->(**_kwargs) { fake_session }) do
      post checkout_path
    end
    assert_redirected_to fake_session.url

    order = Order.last
    item = order.order_items.sole
    assert_equal "CHOSEN", item.sku
    assert_equal "Set of 3, Walnut", item.variant_label
    assert_equal 4998, item.line_total_cents # 2 x 2499

    # Simulate Stripe confirming payment (this would normally happen via the
    # success redirect or the webhook - both funnel through confirm_payment!)
    order.confirm_payment!(payment_intent_id: "pi_test_1", customer_email: "buyer@example.com")

    assert order.reload.paid?
    assert_equal 8, chosen.reload.stock
  end

  test "checkout success verifies payment with Stripe rather than trusting the redirect alone" do
    variant = create_variant(price_cents: 1000, stock: 5)
    post cart_items_path, params: { product_variant_id: variant.id, quantity: 1 }

    order = nil
    Stripe::Checkout::Session.stub(:create, ->(**_kwargs) { fake_stripe_session }) do
      post checkout_path
      order = Order.last
    end

    # Stripe says this session has NOT actually been paid yet.
    Stripe::Checkout::Session.stub(:retrieve, ->(_id) { fake_stripe_session(payment_status: "unpaid") }) do
      get checkout_success_url(order_token: order.token)
    end

    assert order.reload.pending?, "an unpaid Stripe session must not mark the order paid"
  end

  test "checkout success marks the order paid when Stripe confirms payment, and retires the cart" do
    variant = create_variant(price_cents: 1000, stock: 5)
    post cart_items_path, params: { product_variant_id: variant.id, quantity: 1 }
    cart_token_before = session[:cart_token]

    order = nil
    Stripe::Checkout::Session.stub(:create, ->(**_kwargs) { fake_stripe_session }) do
      post checkout_path
      order = Order.last
    end

    Stripe::Checkout::Session.stub(:retrieve, ->(_id) { fake_stripe_session(payment_status: "paid", email: "buyer@example.com") }) do
      get checkout_success_url(order_token: order.token)
    end

    assert_redirected_to order_path(order)
    assert order.reload.paid?
    assert_equal "buyer@example.com", order.customer_email
    assert_not_equal cart_token_before, session[:cart_token]
  end

  test "checkout cancel marks a pending order cancelled and leaves the cart alone" do
    variant = create_variant(price_cents: 1000, stock: 5)
    post cart_items_path, params: { product_variant_id: variant.id, quantity: 1 }

    order = nil
    Stripe::Checkout::Session.stub(:create, ->(**_kwargs) { fake_stripe_session }) do
      post checkout_path
      order = Order.last
    end

    get checkout_cancel_url(order_token: order.token)

    assert_response :success
    assert order.reload.cancelled?

    cart = Cart.find_by(token: session[:cart_token])
    assert_equal 1, cart.cart_items.count
  end

  test "a guest cannot view an order via a guessed or sequential id, only its own token" do
    order = create_order
    create_order_item(order: order)

    get order_path(order.token)
    assert_response :success

    get "/orders/#{order.id}"
    assert_response :not_found
  end
end
