class CreateProductVariants < ActiveRecord::Migration[7.1]
  def change
    create_table :product_variants do |t|
      t.references :product, null: false, foreign_key: true
      t.string :sku, null: false
      t.string :colour
      t.string :option_label
      t.integer :price_cents, null: false
      t.integer :stock, null: false, default: 0
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :product_variants, :sku, unique: true

    # NULL colour/option_label values are distinct under a normal unique index in
    # Postgres, so duplicate "no colour / no option" rows would slip through. This
    # expression index collapses NULLs to '' so the same combination is only ever
    # stored once per product, including the single-configuration case.
    reversible do |dir|
      dir.up do
        execute <<~SQL
          CREATE UNIQUE INDEX index_product_variants_on_product_and_options
          ON product_variants (product_id, COALESCE(colour, ''), COALESCE(option_label, ''))
        SQL
      end

      dir.down do
        execute "DROP INDEX index_product_variants_on_product_and_options"
      end
    end

    add_check_constraint :product_variants, "price_cents >= 0", name: "product_variants_price_cents_non_negative"
    add_check_constraint :product_variants, "stock >= 0", name: "product_variants_stock_non_negative"
  end
end
