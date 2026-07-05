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

      defp apply_discount_rule(product, {name, required_fields, condition_func, action_func}) do
        case validate_and_apply(product, required_fields, condition_func) do
          :apply ->
            apply(__MODULE__, action_func, [product])

          :skip ->
            product
        end
      end

      defp apply_discount_rule(product, _), do: product

      defp validate_and_apply(product, required_fields, condition_func) do
        if validate_product(product, required_fields) and
             apply(__MODULE__, condition_func, [product]) do
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
