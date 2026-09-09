class ProductImage < ApplicationRecord
  belongs_to :product

  validates :image_path, presence: true
end
