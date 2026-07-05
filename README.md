#  DiscountDsl A compile-time domain-specific language (DSL) built in Elixir for defining and executing flexible discount rules using macros. This project demonstrates advanced Elixir metaprogramming: macros, compile-time AST generation, module attributes, functional pipeline execution, rule-based engine design, and ExUnit testing. It behaves like a lightweight pricing engine similar to production rule systems used in e-commerce platforms.

Installation:

def deps do
  [
    {:discount_dsl, "~> 0.1.0"}
  ]
end

mix deps.get

Core concept: instead of imperative logic like:

if product.price > 100 do product.price * 0.9 end

You define:

discount(:over_100, [:price], :is_over_100?, :apply_10_percent_discount)

Which compiles into:

apply_discount(product)

Architecture: DiscountDsl uses __using__/1 to import macros, registers @discounts, attaches @before_compile, stores rules via discount/4, and generates apply_discount/1 using Enum.reduce/3. Each rule validates required fields, evaluates condition functions, and executes action functions in sequence.

Runtime flow: load @discounts → iterate rules → validate fields → run condition → apply action → pass updated product → return final result.

# Implementation:

defmodule DiscountDsl do
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :discounts, accumulate: true)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def apply_discount(product) do
        Enum.reduce(@discounts, product, fn discount, acc ->
          apply_discount_rule(acc, discount)
        end)
      end

      defp apply_discount_rule(product, {_, required_fields, condition_func, action_func}) do
        case validate_and_apply(product, required_fields, condition_func) do
          :apply -> apply(__MODULE__, action_func, [product])
          :skip -> product
        end
      end

      defp apply_discount_rule(product, _), do: product

      defp validate_and_apply(product, required_fields, condition_func) do
        if validate_product(product, required_fields) and apply(__MODULE__, condition_func, [product]) do
          :apply
        else
          :skip
        end
      end

      defp validate_product(product, required_fields) do
        Enum.all?(required_fields, &Map.has_key?(product, &1))
      end
    end
  end

  defmacro discount(name, required_fields, condition, action) do
    quote bind_quoted: [
      name: name,
      required_fields: required_fields,
      condition: condition,
      action: action
    ] do
      @discounts {name, required_fields, condition, action}
    end
  end
end

# Example usage:

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

# Usage:

product = %{price: 200, category: "Electronics"}
Discounts.apply_discount(product)

# Tests:

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

  test "module loads" do
    assert Code.ensure_loaded!(DiscountDsl)
  end

  test "single discount" do
    product = %{price: 60, category: "Toys"}
    assert DiscountsTest.apply_discount(product).free_shipping == true
  end

  test "multiple discounts" do
    product = %{price: 200, category: "Electronics"}
    result = DiscountsTest.apply_discount(product)
    assert result.price == 171
    assert result.free_shipping == true
  end

  test "no discounts" do
    product = %{price: 40, category: "Toys"}
    assert DiscountsTest.apply_discount(product) == product
  end

  test "edge case" do
    product = %{price: 100, category: "Toys"}
    result = DiscountsTest.apply_discount(product)
    assert result.price == 100
    assert result.free_shipping == true
  end

  test "missing fields" do
    product = %{category: "Toys"}
    assert DiscountsTest.apply_discount(product) == product
  end
end