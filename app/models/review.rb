class Review < ApplicationRecord
  belongs_to :product

  validates :reviewer_name, presence: true
  validates :title, presence: true
  validates :body, presence: true
  validates :rating, presence: true, inclusion: { in: 1..5 }

  after_commit :update_product_stats

  private

  def update_product_stats
    product.update_review_stats!
  end
end
