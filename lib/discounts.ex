defmodule Discounts do
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
