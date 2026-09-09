class CategoriesController < ApplicationController
  def index
    @categories = Category.ordered
  end

  def show
    @category = Category.find_by!(slug: params[:slug])
    @products = @category.products.active.includes(:category, :product_images).order(:name)
  end
end
