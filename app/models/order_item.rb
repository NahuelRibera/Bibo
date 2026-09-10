class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product_variant, optional: true

  validates :product_name, :product_slug, :sku, presence: true
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :unit_price_cents, :line_total_cents,
    presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validate :line_total_matches_unit_price_and_quantity

  # The name/options as bought, independent of any later catalogue changes.
  def display_name
    variant_label.present? ? "#{product_name} (#{variant_label})" : product_name
  end

  private

  def line_total_matches_unit_price_and_quantity
    return if unit_price_cents.nil? || quantity.nil? || line_total_cents.nil?

    if line_total_cents != unit_price_cents * quantity
      errors.add(:line_total_cents, "must equal unit price times quantity")
    end
  end
end
