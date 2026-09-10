require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  test "index lists active products" do
    product = create_product(name: "Visible Product")
    create_variant(product: product)
    inactive = create_product(name: "Hidden Product")
    inactive.update!(active: false)

    get products_path

    assert_response :success
    assert_match "Visible Product", response.body
    assert_no_match "Hidden Product", response.body
  end

  test "show renders a visible colour selector when a product has multiple variants" do
    product = create_product(name: "Multi Variant Product")
    create_variant(product: product, sku: "M1", colour: "Natural", stock: 5)
    create_variant(product: product, sku: "M2", colour: "Walnut", stock: 5)

    get product_path(product)

    assert_response :success
    assert_select "fieldset.option-group:not([hidden]) input[name=?]", "colour_option", 2
    assert_select "input[type=hidden][name=?]", "product_variant_id"
  end

  test "show hides the option selectors when a product has a single variant" do
    product = create_product(name: "Single Variant Product")
    create_variant(product: product, sku: "S1", stock: 5)

    get product_path(product)

    assert_response :success
    assert_select "fieldset.option-group[hidden]", 2
  end
end
