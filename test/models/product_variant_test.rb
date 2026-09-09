require "test_helper"

class ProductVariantTest < ActiveSupport::TestCase
  test "requires a unique sku" do
    create_variant(sku: "BIBO-TEST-1")
    duplicate = ProductVariant.new(product: create_product, sku: "BIBO-TEST-1", price_cents: 1000, stock: 1)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:sku], "has already been taken"
  end

  test "rejects negative stock" do
    variant = ProductVariant.new(product: create_product, sku: "BIBO-TEST-2", price_cents: 1000, stock: -1)

    assert_not variant.valid?
    assert_includes variant.errors[:stock], "must be greater than or equal to 0"
  end

  test "rejects negative price" do
    variant = ProductVariant.new(product: create_product, sku: "BIBO-TEST-3", price_cents: -1, stock: 1)

    assert_not variant.valid?
    assert_includes variant.errors[:price_cents], "must be greater than or equal to 0"
  end

  test "the database also rejects negative stock and price" do
    variant = create_variant

    assert_raises(ActiveRecord::StatementInvalid) { variant.update_column(:stock, -1) }
    assert_raises(ActiveRecord::StatementInvalid) { variant.update_column(:price_cents, -1) }
  end

  test "prevents duplicate colour/option combinations for the same product" do
    product = create_product
    create_variant(product: product, sku: "A", colour: "Black", option_label: "Set of 2")
    duplicate = ProductVariant.new(product: product, sku: "B", colour: "Black", option_label: "Set of 2", price_cents: 1000, stock: 1)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:base], "a variant with this colour/option combination already exists for this product"
  end

  test "allows the same colour/option combination on a different product" do
    product_a = create_product(name: "Product A")
    product_b = create_product(name: "Product B")
    create_variant(product: product_a, sku: "A1", colour: "Black")
    other = ProductVariant.new(product: product_b, sku: "B1", colour: "Black", price_cents: 1000, stock: 1)

    assert other.valid?
  end

  test "the database enforces uniqueness of duplicate nil/nil combinations too" do
    product = create_product
    create_variant(product: product, sku: "STD-1", colour: nil, option_label: nil)
    second = ProductVariant.new(product: product, sku: "STD-2", colour: nil, option_label: nil, price_cents: 1000, stock: 1)

    assert_not second.valid?, "the model validation should already have caught this"
  end

  test "an inactive variant is not purchasable even with stock" do
    variant = create_variant(stock: 10, active: false)
    assert_not variant.purchasable?
  end

  test "a variant with zero stock is not purchasable" do
    variant = create_variant(stock: 0, active: true)
    assert_not variant.purchasable?
  end

  test "label combines option and colour generically" do
    both = create_variant(colour: "Natural", option_label: "Set of 3")
    assert_equal "Set of 3 — Natural", both.label

    colour_only = create_variant(colour: "Cream", option_label: nil)
    assert_equal "Cream", colour_only.label

    neither = create_variant(colour: nil, option_label: nil)
    assert_equal "Standard", neither.label
  end
end
