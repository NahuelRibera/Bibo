class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product_variant

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :product_variant_id, uniqueness: { scope: :cart_id }
  validate :quantity_within_stock

  def line_subtotal_cents
    product_variant.price_cents * quantity
  end

  private

  def quantity_within_stock
    return unless product_variant && quantity

    errors.add(:quantity, "exceeds available stock") if quantity.to_i > product_variant.stock
  end
end
