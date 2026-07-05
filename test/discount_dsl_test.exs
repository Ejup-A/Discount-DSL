defmodule DiscountDslTest do
  use ExUnit.Case
  
  defmodule DiscountsTest do
  use DiscountDsl

  discount(:over_100, [:price], :is_over_100?, :apply_10_percent_discount)
  def is_over_100?(product), do: product.price > 100
  def apply_10_percent_discount(product), do: Map.update!(product, :price, &(&1 * 0.9))

  discount(:electronics, [:price, :category], :is_electronics?, :apply_5_percent_discount)
  def is_electronics?(product), do: product.category == "Electronics"
  def apply_5_percent_discount(product), do: Map.update!(product, :price, &(&1 * 0.95))

  discount(:free_shipping, [:price], :is_eligible_for_free_shipping?, :apply_free_shipping)
  def is_eligible_for_free_shipping?(product), do: product.price > 50
  def apply_free_shipping(product), do: Map.put(product, :free_shipping, true)
end

  test "Ensure the Module Loads" do
    assert Code.ensure_loaded!(DiscountDsl)
  end

  #1. Apply a discount to a product if the condition is met.
  test "single discount is applied correctly" do
    product = %{price: 60, category: "Toys"}
    discounted_product = DiscountsTest.apply_discount(product)

    assert(discounted_product.free_shipping)
    assert discounted_product.price == 60
    assert discounted_product.category == "Toys"
  end

  #2. Apply multiple discounts in sequence if multiple conditionsare met.
  test "multiple discounts are applied in order" do
    product = %{price: 200, category: "Electronics"}
    discounted_product = DiscountsTest.apply_discount(product)

    assert(discounted_product.free_shipping)
    assert discounted_product.price == 171
    assert discounted_product.category == "Electronics"
  end

  #3. Ensure discounts are not applied if conditions are not met.
  test "No Discounts applied if conditions are not met" do
    product = %{price: 40, category: "Toys"}
    discounted_product = DiscountsTest.apply_discount(product)

    assert discounted_product == product
  end

  #4. Handle edge cases, if a product is $100.
  test "Checking edge case to make sure no discount is applied if product is 100$" do
  product = %{price: 100, category: "Toys"}
  discounted_product = DiscountsTest.apply_discount(product)

  assert discounted_product.price == 100
  assert(discounted_product.free_shipping)
  assert discounted_product.category == "Toys"

  end

  #5. Invalid inputs are handled gracefully.
  test "invalid product: missing price" do
  product = %{category: "Toys"}
  discounted_product = DiscountsTest.apply_discount(product)

  assert discounted_product == product
  end
end
