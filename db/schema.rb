# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_09_10_082025) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cart_items", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.bigint "product_variant_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id", "product_variant_id"], name: "index_cart_items_on_cart_id_and_product_variant_id", unique: true
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["product_variant_id"], name: "index_cart_items_on_product_variant_id"
    t.check_constraint "quantity >= 1", name: "cart_items_quantity_at_least_1"
  end

  create_table "carts", force: :cascade do |t|
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_carts_on_token", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "product_variant_id"
    t.string "product_name", null: false
    t.string "product_slug", null: false
    t.string "variant_label"
    t.string "sku", null: false
    t.integer "unit_price_cents", null: false
    t.integer "quantity", null: false
    t.integer "line_total_cents", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_variant_id"], name: "index_order_items_on_product_variant_id"
    t.check_constraint "line_total_cents = (unit_price_cents * quantity)", name: "order_items_line_total_matches_unit_price_and_quantity"
    t.check_constraint "line_total_cents >= 0", name: "order_items_line_total_cents_non_negative"
    t.check_constraint "quantity >= 1", name: "order_items_quantity_at_least_1"
    t.check_constraint "unit_price_cents >= 0", name: "order_items_unit_price_cents_non_negative"
  end

  create_table "orders", force: :cascade do |t|
    t.string "token", null: false
    t.string "status", default: "pending", null: false
    t.integer "subtotal_cents", default: 0, null: false
    t.integer "shipping_cents", default: 0, null: false
    t.integer "total_cents", default: 0, null: false
    t.string "currency", default: "eur", null: false
    t.string "stripe_checkout_session_id"
    t.string "stripe_payment_intent_id"
    t.string "customer_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_orders_on_status"
    t.index ["stripe_checkout_session_id"], name: "index_orders_on_stripe_checkout_session_id", unique: true
    t.index ["stripe_payment_intent_id"], name: "index_orders_on_stripe_payment_intent_id", unique: true
    t.index ["token"], name: "index_orders_on_token", unique: true
    t.check_constraint "shipping_cents >= 0", name: "orders_shipping_cents_non_negative"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying, 'paid'::character varying, 'cancelled'::character varying]::text[])", name: "orders_status_allowed"
    t.check_constraint "subtotal_cents >= 0", name: "orders_subtotal_cents_non_negative"
    t.check_constraint "total_cents = (subtotal_cents + shipping_cents)", name: "orders_total_equals_subtotal_plus_shipping"
    t.check_constraint "total_cents >= 0", name: "orders_total_cents_non_negative"
  end

  create_table "product_images", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.string "image_path", null: false
    t.string "alt_text"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "position"], name: "index_product_images_on_product_id_and_position"
    t.index ["product_id"], name: "index_product_images_on_product_id"
  end

  create_table "product_variants", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.string "sku", null: false
    t.string "colour"
    t.string "option_label"
    t.integer "price_cents", null: false
    t.integer "stock", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "product_id, COALESCE(colour, ''::character varying), COALESCE(option_label, ''::character varying)", name: "index_product_variants_on_product_and_options", unique: true
    t.index ["product_id"], name: "index_product_variants_on_product_id"
    t.index ["sku"], name: "index_product_variants_on_sku", unique: true
    t.check_constraint "price_cents >= 0", name: "product_variants_price_cents_non_negative"
    t.check_constraint "stock >= 0", name: "product_variants_stock_non_negative"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.string "short_description", null: false
    t.text "description", null: false
    t.text "details"
    t.text "shipping_returns_text"
    t.integer "base_price_cents", null: false
    t.boolean "featured", default: false, null: false
    t.boolean "trending", default: false, null: false
    t.boolean "active", default: true, null: false
    t.integer "reviews_count", default: 0, null: false
    t.decimal "average_rating", precision: 3, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active", "featured"], name: "index_products_on_active_and_featured"
    t.index ["active", "trending"], name: "index_products_on_active_and_trending"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["slug"], name: "index_products_on_slug", unique: true
    t.check_constraint "base_price_cents >= 0", name: "products_base_price_cents_non_negative"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.string "reviewer_name", null: false
    t.string "title", null: false
    t.text "body", null: false
    t.integer "rating", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "created_at"], name: "index_reviews_on_product_id_and_created_at"
    t.index ["product_id"], name: "index_reviews_on_product_id"
    t.check_constraint "rating >= 1 AND rating <= 5", name: "reviews_rating_between_1_and_5"
  end

  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "product_variants"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "product_variants", on_delete: :nullify
  add_foreign_key "product_images", "products"
  add_foreign_key "product_variants", "products"
  add_foreign_key "products", "categories"
  add_foreign_key "reviews", "products"
end
