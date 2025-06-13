defmodule ValueFormattersInstanceTest do
  use ExUnit.Case, async: true

  import Mox

  setup :verify_on_exit!

  defmodule MyValueFormatters do
    use ValueFormatters,
      cldr: MockedCldr,
      defaults: %{
        "number" => %{
          "precision" => 2
        }
      }
  end

  describe "Instantiated ValueFormatters" do
    test "uses instance defaults" do
      MockedCldr.Number
      |> expect(:to_string, fn _value, opts ->
        assert opts[:fractional_digits] == 2

        {:ok, "34.12"}
      end)

      assert MyValueFormatters.to_string("34.12345", %{"format" => "number"}) == {:ok, "34.12"}
    end

    test "merges defaults when provided in call" do
      MockedCldr.Number
      |> expect(:to_string, fn _value, opts ->
        assert opts[:fractional_digits] == 2

        {:ok, "42.00"}
      end)

      assert MyValueFormatters.to_string(42, %{},
               defaults: %{"date" => %{"date_display" => "long"}}
             ) ==
               {:ok, "42.00"}
    end
  end
end
