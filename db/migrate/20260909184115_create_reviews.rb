class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews do |t|
      t.references :product, null: false, foreign_key: true
      t.string :reviewer_name, null: false
      t.string :title, null: false
      t.text :body, null: false
      t.integer :rating, null: false

      t.timestamps
    end

    add_index :reviews, [:product_id, :created_at]

    add_check_constraint :reviews, "rating BETWEEN 1 AND 5", name: "reviews_rating_between_1_and_5"
  end
end
