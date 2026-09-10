class WishlistItemsController < ApplicationController
  def create
    @product = Product.active.find(params[:product_id])
    session[:wishlist_product_ids] = wishlist_product_ids | [@product.id]

    respond_to do |format|
      format.html { redirect_back fallback_location: product_path(@product), notice: "Added #{@product.name} to your wishlist." }
      format.turbo_stream
    end
  end

  def destroy
    # Product#to_param returns the slug (for pretty /products/:slug URLs),
    # so wishlist_item_path(product) — and thus params[:id] here — carries
    # the slug rather than the numeric id.
    @product = Product.find_by!(slug: params[:id])
    session[:wishlist_product_ids] = wishlist_product_ids - [@product.id]

    respond_to do |format|
      format.html { redirect_back fallback_location: wishlist_path, notice: "Removed #{@product.name} from your wishlist." }
      format.turbo_stream
    end
  end
end
