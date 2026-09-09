class Product < ApplicationRecord
  belongs_to :category
  has_many :product_variants, dependent: :destroy
  has_many :product_images, -> { order(:position) }, dependent: :destroy
  has_many :reviews, dependent: :destroy

  before_validation :generate_slug

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :short_description, presence: true
  validates :description, presence: true
  validates :base_price_cents, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  scope :active, -> { where(active: true) }
  scope :featured, -> { where(featured: true) }
  scope :trending, -> { where(trending: true) }

  def to_param
    slug
  end

  def default_variant
    product_variants.detect(&:purchasable?) || product_variants.first
  end

  def in_stock?
    product_variants.any?(&:purchasable?)
  end

  def update_review_stats!
    stats = reviews.pick(Arel.sql("COUNT(*)"), Arel.sql("AVG(rating)"))
    count, avg = stats
    update_columns(reviews_count: count, average_rating: avg&.round(2) || 0)
  end

  private

  def generate_slug
    self.slug = name.parameterize if slug.blank? && name.present?
  end
end
