class WishlistsController < ApplicationController
  def show
    @products = Product.active
      .includes(:category, :product_images)
      .where(id: wishlist_product_ids)
      .order(:name)
  end
end
