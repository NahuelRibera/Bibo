class ProductsController < ApplicationController
  def index
    @products = Product.active.includes(:category, :product_images).order(:name)
  end

  def show
    @product = Product.active
      .includes(:category, :product_images, :product_variants, :reviews)
      .find_by!(slug: params[:slug])
  end
end
