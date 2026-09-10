class OrdersController < ApplicationController
  # Looked up by an unguessable token (see Order#generate_token), the same
  # way Cart already is, rather than a sequential id, so this URL can be
  # safely shared as a guest's receipt link without exposing other orders.
  def show
    @order = Order.includes(order_items: { product_variant: { product: :product_images } })
      .find_by!(token: params[:token])
  end
end
