require "test_helper"

class ProductQueryTest < ActiveSupport::TestCase
  test "search matches by product name" do
    match = create_product(name: "Glass Storage Jars")
    other = create_product(name: "Oak Cutting Board")

    results = Product.search("storage jars")

    assert_includes results, match
    assert_not_includes results, other
  end

  test "search is case-insensitive" do
    match = create_product(name: "Ribbed Glass Mugs")

    assert_includes Product.search("RIBBED glass"), match
  end

  test "search matches by short description and category name" do
    category = create_category(name: "Kitchen")
    by_description = create_product(category: category, name: "Alpha")
    by_description.update!(short_description: "Perfect for morning coffee rituals")
    by_category = create_product(category: category, name: "Beta")

    assert_includes Product.search("coffee rituals"), by_description
    assert_includes Product.search("kitchen"), by_category
  end

  test "search returns nothing for an unmatched term" do
    create_product(name: "Wave Catchall Bowl")

    assert_empty Product.search("zzznonexistentzzz")
  end

  test "a blank search does not filter anything out" do
    a = create_product
    b = create_product

    results = Product.search("")

    assert_includes results, a
    assert_includes results, b
  end

  test "in_category filters by category slug" do
    kitchen = create_category(name: "Kitchen")
    bathroom = create_category(name: "Bathroom")
    in_kitchen = create_product(category: kitchen)
    in_bathroom = create_product(category: bathroom)

    results = Product.in_category(kitchen.slug)

    assert_includes results, in_kitchen
    assert_not_includes results, in_bathroom
  end

  test "sorted by price_asc orders cheapest first" do
    expensive = create_product(base_price_cents: 5000)
    cheap = create_product(base_price_cents: 1000)

    results = Product.where(id: [expensive.id, cheap.id]).sorted("price_asc")

    assert_equal [cheap, expensive], results.to_a
  end

  test "sorted by price_desc orders most expensive first" do
    expensive = create_product(base_price_cents: 5000)
    cheap = create_product(base_price_cents: 1000)

    results = Product.where(id: [expensive.id, cheap.id]).sorted("price_desc")

    assert_equal [expensive, cheap], results.to_a
  end

  test "sorted by rating orders highest-rated first" do
    low_rated = create_product
    low_rated.update_columns(average_rating: 3.0, reviews_count: 2)
    high_rated = create_product
    high_rated.update_columns(average_rating: 4.8, reviews_count: 5)

    results = Product.where(id: [low_rated.id, high_rated.id]).sorted("rating")

    assert_equal [high_rated, low_rated], results.to_a
  end

  test "sorted falls back to featured ordering for an unknown key" do
    assert_nothing_raised { Product.sorted("not_a_real_sort").to_a }
  end
end
