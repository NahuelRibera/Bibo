require "test_helper"

class WishlistFlowTest < ActionDispatch::IntegrationTest
  test "adding a product to the wishlist makes it appear on the wishlist page" do
    product = create_product(name: "Wave Catchall Bowl")

    post wishlist_items_path, params: { product_id: product.id }
    assert_redirected_to product_path(product)

    get wishlist_path
    assert_response :success
    assert_match "Wave Catchall Bowl", response.body
  end

  test "adding the same product twice does not duplicate it" do
    product = create_product

    post wishlist_items_path, params: { product_id: product.id }
    post wishlist_items_path, params: { product_id: product.id }

    assert_equal [product.id], session[:wishlist_product_ids]
  end

  test "removing a product takes it off the wishlist" do
    product = create_product(name: "Stone Incense Holder")
    post wishlist_items_path, params: { product_id: product.id }

    delete wishlist_item_path(product)
    assert_redirected_to wishlist_path

    get wishlist_path
    # The flash notice legitimately mentions the product by name, so assert
    # on the empty state rather than the product name being absent from
    # the whole page.
    assert_match "Your wishlist is empty", response.body
  end

  test "wishlist page shows an empty state with nothing added" do
    get wishlist_path

    assert_response :success
    assert_match "Your wishlist is empty", response.body
  end
end
