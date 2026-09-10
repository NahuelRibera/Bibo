class ProductsController < ApplicationController
  def index
    @categories = Category.ordered
    @colours = Product.available_colours
    @selected_sort = Product::SORT_OPTIONS.key?(params[:sort]) ? params[:sort] : "featured"

    @products = Product.active
      .includes(:category, :product_images)
      .in_category(params[:category])
      .with_colour(params[:colour])
      .search(params[:q])
      .sorted(@selected_sort)
  end

  def show
    @product = Product.active
      .includes(:category, :product_images, :product_variants, :reviews)
      .find_by!(slug: params[:slug])
  end
end
