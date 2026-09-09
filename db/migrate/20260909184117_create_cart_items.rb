class CreateCartItems < ActiveRecord::Migration[7.1]
  def change
    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: true
      t.references :product_variant, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end

    add_index :cart_items, [:cart_id, :product_variant_id], unique: true

    add_check_constraint :cart_items, "quantity >= 1", name: "cart_items_quantity_at_least_1"
  end
end
