class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.references :category, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.string :short_description, null: false
      t.text :description, null: false
      t.text :details
      t.text :shipping_returns_text
      t.integer :base_price_cents, null: false
      t.boolean :featured, null: false, default: false
      t.boolean :trending, null: false, default: false
      t.boolean :active, null: false, default: true
      t.integer :reviews_count, null: false, default: 0
      t.decimal :average_rating, precision: 3, scale: 2, null: false, default: "0.0"

      t.timestamps
    end

    add_index :products, :slug, unique: true
    add_index :products, [:active, :featured]
    add_index :products, [:active, :trending]

    add_check_constraint :products, "base_price_cents >= 0", name: "products_base_price_cents_non_negative"
  end
end
