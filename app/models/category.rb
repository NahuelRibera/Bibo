class Category < ApplicationRecord
  has_many :products, dependent: :restrict_with_error

  before_validation :generate_slug

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  scope :ordered, -> { order(:name) }

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug = name.parameterize if slug.blank? && name.present?
  end
end
