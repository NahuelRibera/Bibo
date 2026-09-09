class HomeController < ApplicationController
  def index
    @categories = Category.ordered
    @trending_products = Product.active.trending.includes(:category, :product_images).order(:name).limit(8)
    @featured_products = Product.active.featured.includes(:category, :product_images).order(:name).limit(8)
  end
end
