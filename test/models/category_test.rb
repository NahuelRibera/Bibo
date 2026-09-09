require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "requires a name" do
    category = Category.new(description: "No name")
    assert_not category.valid?
    assert_includes category.errors[:name], "can't be blank"
  end

  test "generates a slug from the name when not provided" do
    category = Category.create!(name: "Storage")
    assert_equal "storage", category.slug
  end

  test "slug must be unique" do
    Category.create!(name: "Kitchen")
    duplicate = Category.new(name: "Kitchen accessories", slug: "kitchen")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  test "database rejects a duplicate slug even bypassing validations" do
    Category.create!(name: "Kitchen")
    duplicate = Category.new(name: "Other", slug: "kitchen")

    assert_raises(ActiveRecord::RecordNotUnique) { duplicate.save!(validate: false) }
  end
end
