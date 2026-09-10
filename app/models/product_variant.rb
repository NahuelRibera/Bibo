class ProductVariant < ApplicationRecord
  belongs_to :product
  has_many :cart_items, dependent: :restrict_with_error
  # order_items intentionally has no `dependent:` option: the database
  # foreign key (on_delete: :nullify) already detaches historical order
  # snapshots from a deleted variant without destroying them.
  has_many :order_items

  validates :sku, presence: true, uniqueness: true
  validates :price_cents, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validate :option_combination_uniqueness

  scope :active, -> { where(active: true) }
  scope :purchasable, -> { active.where("stock > 0") }

  # Variants are generically labelled from whichever option fields are
  # present, so no product-specific logic is needed to render a selector.
  def label
    parts = [option_label, colour].compact_blank
    parts.any? ? parts.join(", ") : "Standard"
  end

  def purchasable?
    active? && stock > 0
  end

  private

  def option_combination_uniqueness
    return unless product

    scope = product.product_variants.where(colour: colour, option_label: option_label)
    scope = scope.where.not(id: id) if persisted?
    errors.add(:base, "a variant with this colour/option combination already exists for this product") if scope.exists?
  end
end
