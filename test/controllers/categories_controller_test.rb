require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  test "show lists only active products in that category" do
    kitchen = create_category(name: "Kitchen")
    other = create_category(name: "Bathroom")

    in_category = create_product(category: kitchen, name: "Kitchen Item")
    create_variant(product: in_category)

    outside_category = create_product(category: other, name: "Bathroom Item")
    create_variant(product: outside_category)

    get category_path(kitchen)

    assert_response :success
    assert_match "Kitchen Item", response.body
    assert_no_match "Bathroom Item", response.body
  end
end
