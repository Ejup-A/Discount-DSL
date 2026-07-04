defmodule DiscountDslTest do
  use ExUnit.Case

  test "Ensure the Module Loads" do
    assert Code.ensure_loaded!(DiscountDsl)
  end

  #1. Apply a discount to a product if the condition is met.
  test "single discount is applied correctly" do
    product = %{price: 60, category: "Toys"}
    discounted_product = Discounts.apply_discount(product)

    assert(discounted_product.free_shipping)
    assert discounted_product.price == 60
    assert discounted_product.category == "Toys"
  end

  #2. Apply multiple discounts in sequence if multiple conditionsare met.
  test "multiple discounts are applied in order" do
    product = %{price: 200, category: "Electronics"}
    discounted_product = Discounts.apply_discount(product)

    assert(discounted_product.free_shipping)
    assert discounted_product.price == 171
    assert discounted_product.category == "Electronics"
  end

  #3. Ensure discounts are not applied if conditions are not met.
  test "No Discounts applied if conditions are not met" do
    product = %{price: 40, category: "Toys"}
    discounted_product = Discounts.apply_discount(product)

    assert discounted_product == product
  end

  #4. Handle edge cases, if a product is $100.
  test "Checking edge case to make sure no discount is applied if product is 100$" do
  product = %{price: 100, category: "Toys"}
  discounted_product = Discounts.apply_discount(product)

  assert discounted_product.price == 100
  assert(discounted_product.free_shipping)
  assert discounted_product.category == "Toys"

  end
  #5. Invalid inputs are handled gracefully.
  test "invalid product: missing price" do
  product = %{category: "Toys"}
  discounted_product = Discounts.apply_discount(product)

  assert discounted_product == product
  end
end
