require "test_helper"

class OrderItemTest < ActiveSupport::TestCase
  test "requires product_name, product_slug and sku" do
    item = OrderItem.new(order: create_order, quantity: 1, unit_price_cents: 1000, line_total_cents: 1000)

    assert_not item.valid?
    assert_includes item.errors[:product_name], "can't be blank"
    assert_includes item.errors[:product_slug], "can't be blank"
    assert_includes item.errors[:sku], "can't be blank"
  end

  test "requires line_total_cents to equal unit_price_cents times quantity" do
    item = OrderItem.new(
      order: create_order, product_name: "Thing", product_slug: "thing", sku: "SKU-1",
      unit_price_cents: 1000, quantity: 3, line_total_cents: 1
    )

    assert_not item.valid?
    assert_includes item.errors[:line_total_cents], "must equal unit price times quantity"
  end

  test "the database also enforces line_total_cents = unit_price_cents * quantity" do
    item = create_order_item

    assert_raises(ActiveRecord::StatementInvalid) { item.update_column(:line_total_cents, 1) }
  end

  test "the database rejects a quantity below 1" do
    item = create_order_item

    assert_raises(ActiveRecord::StatementInvalid) { item.update_column(:quantity, 0) }
  end

  test "surviving a deleted product_variant keeps the snapshot" do
    variant = create_variant
    item = create_order_item(product_variant: variant)

    variant.destroy!

    item.reload
    assert_nil item.product_variant_id
    assert item.product_name.present?
    assert item.sku.present?
  end

  test "display_name combines product name and variant label when present" do
    variant = create_variant(colour: "Walnut", option_label: "Set of 3")
    item = create_order_item(product_variant: variant)

    assert_equal "#{variant.product.name} (Set of 3, Walnut)", item.display_name
  end

  test "display_name is just the product name for a standard variant" do
    variant = create_variant(colour: nil, option_label: nil)
    item = create_order_item(product_variant: variant)

    assert_equal variant.product.name, item.display_name
  end
end
