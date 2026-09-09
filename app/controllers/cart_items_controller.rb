class CartItemsController < ApplicationController
  before_action :set_cart

  def create
    variant = ProductVariant.find(params[:product_variant_id])
    quantity = params[:quantity].to_i
    quantity = 1 if quantity < 1

    if variant.purchasable?
      @cart.add_variant(variant, quantity)
      redirect_to cart_path, notice: "Added #{variant.product.name} to your cart."
    else
      redirect_to product_path(variant.product), alert: "That variant is currently out of stock."
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to products_path, alert: "That item is no longer available."
  end

  def update
    item = @cart.cart_items.find(params[:id])
    quantity = params[:quantity].to_i

    if quantity < 1
      item.destroy
    else
      item.update(quantity: [quantity, item.product_variant.stock].min)
    end

    redirect_to cart_path
  end

  def destroy
    @cart.cart_items.find(params[:id]).destroy
    redirect_to cart_path
  end

  private

  def set_cart
    @cart = current_cart
  end
end
