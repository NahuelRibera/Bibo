class Order < ApplicationRecord
  STATUSES = %w[pending paid cancelled].freeze

  has_many :order_items, dependent: :destroy

  before_validation :generate_token, on: :create

  validates :token, presence: true, uniqueness: true
  validates :status, inclusion: { in: STATUSES }
  validates :currency, presence: true
  validates :subtotal_cents, :shipping_cents, :total_cents,
    presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validate :total_equals_subtotal_plus_shipping

  scope :pending, -> { where(status: "pending") }

  def to_param
    token
  end

  def pending?
    status == "pending"
  end

  def paid?
    status == "paid"
  end

  def cancelled?
    status == "cancelled"
  end

  # Marks the order paid and decrements stock for what was bought, exactly
  # once. Safe to call from both the success-page check and the webhook:
  # the row lock plus the status guard inside the transaction mean a second
  # caller (a retried webhook delivery, or the two racing each other) is a
  # no-op rather than a double stock decrement. A cancelled order is never
  # revived into paid, even by a late webhook. Stock is only ever
  # decremented here, never reserved ahead of time - see README for what
  # that means in practice.
  def confirm_payment!(payment_intent_id:, customer_email: nil)
    return true if paid?
    return false if cancelled?

    transaction do
      locked = lock!
      return true if locked.paid?
      return false if locked.cancelled?

      locked.order_items.includes(:product_variant).each do |item|
        variant = item.product_variant
        next unless variant

        variant.with_lock do
          variant.update!(stock: [variant.stock - item.quantity, 0].max)
        end
      end

      locked.update!(
        status: "paid",
        stripe_payment_intent_id: payment_intent_id,
        customer_email: customer_email.presence || locked.customer_email
      )
    end

    true
  end

  def cancel!
    update!(status: "cancelled") if pending?
  end

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(24)
  end

  def total_equals_subtotal_plus_shipping
    return if subtotal_cents.nil? || shipping_cents.nil? || total_cents.nil?

    errors.add(:total_cents, "must equal subtotal plus shipping") if total_cents != subtotal_cents + shipping_cents
  end
end
