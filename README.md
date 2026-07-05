# DiscountDsl

A small, compile-time DSL in Elixir for defining and applying discount rules.

> Instead of hardcoding pricing logic, you declare discounts with macros and run them through a deterministic rule pipeline.

## Features

- **Compile-time DSL**: discounts are registered when the using module is compiled.
- **Simple rule model**: each discount has required product fields, a condition, and an action.
- **Deterministic application order**: discounts are applied in the order they are registered.
- **Safe validation**: a discount is skipped if the product is missing required fields.

## Installation

This project is a Mix library.

```elixir
# mix.exs

defp deps do
  [
    {:discount_dsl, "~> 0.1.0"}
  ]
end
```

Then:

```bash
mix deps.get
```

## Usage

### 1) Define discounts

Create a module that `use`s `DiscountDsl` and declares discounts with the `discount/4` macro.

```elixir
defmodule Discounts do
  use DiscountDsl

  discount(:over_100, [:price], :is_over_100?, :apply_10_percent_discount)
  def is_over_100?(product), do: product.price > 100
  def apply_10_percent_discount(product), do: Map.update!(product, :price, &(&1 * 0.9))

  discount(:electronics, [:price, :category], :is_electronics?, :apply_5_percent_discount)
  def is_electronics?(product), do: product.category == "Electronics"
  def apply_5_percent_discount(product), do: Map.update!(product, :price, &(&1 * 0.95))
end
```

### 2) Apply discounts to a product

```elixir
product = %{price: 200, category: "Electronics"}
result  = Discounts.apply_discount(product)
```

`apply_discount/1` returns the updated product after running all matching discounts.

## DSL Reference

### `discount/4`

```elixir
discount(name, required_fields, condition_function, action_function)
```

- `name`: an atom identifying the discount.
- `required_fields`: list of keys that must exist in the product map.
- `condition_function`: function name (atom) that receives the product and returns a boolean.
- `action_function`: function name (atom) that receives the product and returns the updated product.

A discount is applied when:
1. all `required_fields` are present in the product, and
2. `condition_function(product)` returns `true`.

## How it works (high level)

- When a module does `use DiscountDsl`, the DSL macro registers a list of discounts.
- When compilation finishes, `apply_discount/1` is generated.
- At runtime, `apply_discount/1` iterates through registered discounts and:
  - validates required fields,
  - evaluates the condition,
  - applies the action if the condition passes.

## Testing

Run the project tests with:

```bash
mix test
```

## License

MIT

