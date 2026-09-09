class ApplicationController < ActionController::Base
  helper_method :current_cart

  private

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
end
