class ApplicationController < ActionController::Base
  helper_method :current_cart, :wishlist_product_ids, :in_wishlist?, :stripe_configured?

  private

  def stripe_configured?
    Stripe.api_key.present?
  end

  def current_cart
    @current_cart ||= find_or_create_cart
  end

  def find_or_create_cart
    cart = Cart.find_by(token: session[:cart_token])
    return cart if cart

    cart = Cart.create!
    session[:cart_token] = cart.token
    cart
  end

  # The wishlist is guest/session-backed like the cart's identifying token,
  # but doesn't need its own database table: it's just a list of product
  # ids the visitor has starred, so a plain session array is sufficient
  # and keeps this feature lightweight.
  def wishlist_product_ids
    session[:wishlist_product_ids] ||= []
  end

  def in_wishlist?(product)
    wishlist_product_ids.include?(product.id)
  end
end
