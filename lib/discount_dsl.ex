defmodule DiscountDsl do
  defmacro __using__(_options) do
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

    defp apply_discount_rule(product, {_name, condition_func, action_func}) do
      if apply(__MODULE__, condition_func, [product]) do
        apply(__MODULE__, action_func, [product])
      else
        product
      end
    end
  end
end

  defmacro discount(name, condition, action) do
    quote bind_quoted: [name: name, condition: condition, action: action] do
      @discounts {name, condition, action}
    end
  end
end
