class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.string :token, null: false
      t.string :status, null: false, default: "pending"
      t.integer :subtotal_cents, null: false, default: 0
      t.integer :shipping_cents, null: false, default: 0
      t.integer :total_cents, null: false, default: 0
      t.string :currency, null: false, default: "eur"
      t.string :stripe_checkout_session_id
      t.string :stripe_payment_intent_id
      t.string :customer_email

      t.timestamps
    end

    add_index :orders, :token, unique: true
    add_index :orders, :stripe_checkout_session_id, unique: true
    add_index :orders, :stripe_payment_intent_id, unique: true
    add_index :orders, :status

    add_check_constraint :orders, "status IN ('pending', 'paid', 'cancelled')", name: "orders_status_allowed"
    add_check_constraint :orders, "subtotal_cents >= 0", name: "orders_subtotal_cents_non_negative"
    add_check_constraint :orders, "shipping_cents >= 0", name: "orders_shipping_cents_non_negative"
    add_check_constraint :orders, "total_cents >= 0", name: "orders_total_cents_non_negative"
    add_check_constraint :orders, "total_cents = subtotal_cents + shipping_cents", name: "orders_total_equals_subtotal_plus_shipping"
  end
end
