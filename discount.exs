defmodule Discount do
  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :discounts, accumulate: true)

      def apply_discount do
        IO.puts "Applying the discounts (#{inspect @discounts})"
      end

    end
  end

  defmacro discount(name, condition, action) do
    quote do
      @discounts {unquote(name), unquote(condition), unquote(action)}
    end
  end
end

defmodule Discounts do
  use Discount

  discount :over_100, :is_over_100?, :apply_10_percent_discount

  def is_over_100?(product), do: product.price > 100
  def apply_10_percent_discount(product), do: Map.update!(product, :price, &(&1 * 0.9))
end
