class Cart < ApplicationRecord
  FREE_SHIPPING_THRESHOLD_CENTS = 4000
  SHIPPING_CENTS = 499

  has_many :cart_items, dependent: :destroy
  has_many :product_variants, through: :cart_items

  before_validation :generate_token, on: :create

  validates :token, presence: true, uniqueness: true

  # Adds a variant to the cart, merging into an existing line rather than
  # creating a duplicate row, and clamping quantity to available stock.
  def add_variant(variant, quantity = 1)
    quantity = quantity.to_i
    raise ArgumentError, "quantity must be positive" if quantity < 1
    raise ArgumentError, "variant is not purchasable" unless variant.purchasable?

    item = cart_items.find_or_initialize_by(product_variant: variant)
    requested = item.new_record? ? quantity : item.quantity + quantity
    item.quantity = [requested, variant.stock].min
    item.save!
    item
  end

  # Shared with CheckoutsController, which computes its own subtotal from
  # order line snapshots rather than a live cart, so the two never drift.
  def self.shipping_cents_for(subtotal_cents)
    subtotal_cents >= FREE_SHIPPING_THRESHOLD_CENTS ? 0 : SHIPPING_CENTS
  end

  def subtotal_cents
    cart_items.includes(:product_variant).sum(&:line_subtotal_cents)
  end

  def shipping_cents
    return 0 if cart_items.empty?
    self.class.shipping_cents_for(subtotal_cents)
  end

  def total_cents
    subtotal_cents + shipping_cents
  end

  private

  def generate_token
    self.token ||= SecureRandom.uuid
  end
end
