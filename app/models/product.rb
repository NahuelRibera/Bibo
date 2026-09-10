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

  scope :in_category, ->(slug) { joins(:category).where(categories: { slug: slug }) if slug.present? }

  scope :with_colour, lambda { |colour|
    next unless colour.present?

    joins(:product_variants).where(product_variants: { colour: colour }).distinct
  }

  scope :search, lambda { |query|
    next unless query.present?

    term = "%#{sanitize_sql_like(query)}%"
    left_joins(:category).where(
      "products.name ILIKE :term OR products.short_description ILIKE :term " \
      "OR products.description ILIKE :term OR categories.name ILIKE :term",
      term: term
    ).distinct
  }

  SORT_OPTIONS = {
    "featured" => -> { order(featured: :desc, created_at: :desc) },
    "newest" => -> { order(created_at: :desc) },
    "price_asc" => -> { order(base_price_cents: :asc) },
    "price_desc" => -> { order(base_price_cents: :desc) },
    "rating" => -> { order(average_rating: :desc, reviews_count: :desc) },
  }.freeze

  scope :sorted, lambda { |key|
    instance_exec(&SORT_OPTIONS.fetch(key) { SORT_OPTIONS["featured"] })
  }

  def to_param
    slug
  end

  # Distinct colours available across a product's active variants, in the
  # order they were created. Used to drive the colour filter and the
  # product-detail colour selector without hardcoding per-product values.
  def self.available_colours
    ProductVariant.active.where.not(colour: nil).distinct.order(:colour).pluck(:colour)
  end

  def default_variant
    product_variants.detect(&:purchasable?) || product_variants.first
  end

  def in_stock?
    product_variants.any?(&:purchasable?)
  end

  # Shapes this product's active variants into whatever selector axes
  # (size, colour) they actually use, for the product-detail Stimulus
  # controller. An axis is only worth showing when it has more than one
  # distinct value — a product with a single configuration, or one that
  # only varies on one axis, gets no pointless selector for the other.
  # Relies on product_variants already being loaded (e.g. via `includes`)
  # to avoid a second query.
  def variant_axes
    variants = product_variants.select(&:active?)
    sizes = variants.map { |v| v.option_label.presence }.uniq
    colours = variants.map { |v| v.colour.presence }.uniq

    {
      sizes: sizes,
      colours: colours,
      show_sizes: sizes.size > 1,
      show_colours: colours.size > 1,
      variants: variants.map { |v|
        {
          id: v.id,
          size: v.option_label.to_s,
          colour: v.colour.to_s,
          price_cents: v.price_cents,
          stock: v.stock,
          purchasable: v.purchasable?,
        }
      },
    }
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
