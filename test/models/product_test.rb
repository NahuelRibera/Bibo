require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "requires a category, name, descriptions and price" do
    product = Product.new
    assert_not product.valid?
    assert_includes product.errors[:category], "must exist"
    assert_includes product.errors[:name], "can't be blank"
    assert_includes product.errors[:short_description], "can't be blank"
    assert_includes product.errors[:description], "can't be blank"
  end

  test "generates a slug from the name when not provided" do
    product = create_product(name: "Oak Cutting Board")
    assert_equal "oak-cutting-board", product.slug
  end

  test "slug must be unique" do
    create_product(name: "Oak Cutting Board")
    duplicate = Product.new(
      category: create_category,
      name: "Another board",
      slug: "oak-cutting-board",
      short_description: "x",
      description: "x",
      base_price_cents: 1000
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  test "rejects a negative base price" do
    product = Product.new(
      category: create_category,
      name: "Broken",
      short_description: "x",
      description: "x",
      base_price_cents: -100
    )

    assert_not product.valid?
    assert_includes product.errors[:base_price_cents], "must be greater than or equal to 0"
  end

  test "the database also rejects a negative base price" do
    product = create_product

    assert_raises(ActiveRecord::StatementInvalid) do
      product.update_column(:base_price_cents, -500)
    end
  end

  test "default_variant prefers a purchasable variant over an out-of-stock one" do
    product = create_product
    create_variant(product: product, sku: "OUT", colour: "Natural", stock: 0)
    in_stock = create_variant(product: product, sku: "IN", colour: "Walnut", stock: 5)

    assert_equal in_stock, product.default_variant
  end

  test "update_review_stats! reflects the average rating and count" do
    product = create_product
    Review.create!(product: product, reviewer_name: "A", title: "Good", body: "Nice.", rating: 5)
    Review.create!(product: product, reviewer_name: "B", title: "Fine", body: "Okay.", rating: 3)

    product.reload
    assert_equal 2, product.reviews_count
    assert_equal 4.0, product.average_rating.to_f
  end

  test "variant_axes hides both axes for a single-configuration product" do
    product = create_product
    create_variant(product: product, colour: nil, option_label: nil)

    axes = product.variant_axes

    assert_not axes[:show_sizes]
    assert_not axes[:show_colours]
  end

  test "variant_axes shows only the colour axis when only colour varies" do
    product = create_product
    create_variant(product: product, sku: "A", colour: "Cream")
    create_variant(product: product, sku: "B", colour: "Olive")

    axes = product.variant_axes

    assert_not axes[:show_sizes]
    assert axes[:show_colours]
    assert_equal ["Cream", "Olive"], axes[:colours]
  end

  test "variant_axes shows both axes for a full size/colour matrix" do
    product = create_product
    create_variant(product: product, sku: "A", option_label: "Set of 2", colour: "Natural")
    create_variant(product: product, sku: "B", option_label: "Set of 3", colour: "Natural")
    create_variant(product: product, sku: "C", option_label: "Set of 2", colour: "Walnut")

    axes = product.variant_axes

    assert axes[:show_sizes]
    assert axes[:show_colours]
    assert_equal 3, axes[:variants].size
    assert_equal({ size: "Set of 2", colour: "Natural" }, axes[:variants].first.slice(:size, :colour))
  end
end
