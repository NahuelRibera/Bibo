require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  test "rating must be between 1 and 5" do
    product = create_product

    assert_not Review.new(product: product, reviewer_name: "A", title: "T", body: "B", rating: 0).valid?
    assert_not Review.new(product: product, reviewer_name: "A", title: "T", body: "B", rating: 6).valid?
    assert Review.new(product: product, reviewer_name: "A", title: "T", body: "B", rating: 3).valid?
  end

  test "the database also rejects an out-of-range rating" do
    product = create_product
    review = Review.create!(product: product, reviewer_name: "A", title: "T", body: "B", rating: 5)

    assert_raises(ActiveRecord::StatementInvalid) { review.update_column(:rating, 7) }
  end

  test "saving a review updates the product's cached rating and count" do
    product = create_product
    assert_equal 0, product.reviews_count

    Review.create!(product: product, reviewer_name: "A", title: "T", body: "B", rating: 4)
    Review.create!(product: product, reviewer_name: "B", title: "T", body: "B", rating: 2)

    product.reload
    assert_equal 2, product.reviews_count
    assert_equal 3.0, product.average_rating.to_f
  end

  test "destroying a review updates the product's cached rating and count" do
    product = create_product
    keep = Review.create!(product: product, reviewer_name: "A", title: "T", body: "B", rating: 5)
    remove = Review.create!(product: product, reviewer_name: "B", title: "T", body: "B", rating: 1)

    remove.destroy!
    product.reload

    assert_equal 1, product.reviews_count
    assert_equal 5.0, product.average_rating.to_f
  end
end
