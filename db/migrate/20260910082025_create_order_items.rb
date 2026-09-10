class CreateOrderItems < ActiveRecord::Migration[7.1]
  def change
    create_table :order_items do |t|
      t.bigint :order_id, null: false
      t.bigint :product_variant_id

      # Snapshot of what was actually purchased, independent of later
      # catalogue changes (renamed/re-priced/deleted products or variants).
      t.string :product_name, null: false
      t.string :product_slug, null: false
      t.string :variant_label
      t.string :sku, null: false
      t.integer :unit_price_cents, null: false
      t.integer :quantity, null: false
      t.integer :line_total_cents, null: false

      t.timestamps
    end

    add_index :order_items, :order_id
    add_index :order_items, :product_variant_id

    add_foreign_key :order_items, :orders
    add_foreign_key :order_items, :product_variants, on_delete: :nullify

    add_check_constraint :order_items, "quantity >= 1", name: "order_items_quantity_at_least_1"
    add_check_constraint :order_items, "unit_price_cents >= 0", name: "order_items_unit_price_cents_non_negative"
    add_check_constraint :order_items, "line_total_cents >= 0", name: "order_items_line_total_cents_non_negative"
    add_check_constraint :order_items, "line_total_cents = unit_price_cents * quantity", name: "order_items_line_total_matches_unit_price_and_quantity"
  end
end
