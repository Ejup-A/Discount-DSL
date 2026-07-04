defmodule DiscountExt do
  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)

      def apply_discounts(product) do
        IO.puts("Applying discounts...")
        case product do
           product when product.price > 100 -> Map.update!(product, :price, &(&1 * 0.9))
           _ -> product

        end
      end
    end
  end
end

defmodule Product do
  use DiscountExt
end
