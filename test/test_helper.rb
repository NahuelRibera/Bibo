ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Small builders shared across model/integration tests. The domain has
    # enough required associations (product -> category, variant -> product)
    # that hand-rolling these in every test would be repetitive.
    def create_category(name: "Category #{SecureRandom.hex(4)}")
      Category.create!(name: name)
    end

    def create_product(category: create_category, name: "Sample Product #{SecureRandom.hex(4)}", base_price_cents: 1000)
      Product.create!(
        category: category,
        name: name,
        short_description: "Short description.",
        description: "Full description.",
        base_price_cents: base_price_cents
      )
    end

    def create_variant(product: create_product, sku: nil, colour: nil, option_label: nil, price_cents: 1000, stock: 10, active: true)
      ProductVariant.create!(
        product: product,
        sku: sku || "SKU-#{SecureRandom.hex(4)}",
        colour: colour,
        option_label: option_label,
        price_cents: price_cents,
        stock: stock,
        active: active
      )
    end
  end
end
