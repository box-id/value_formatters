defmodule ValueFormatters.SchemasTest do
  use ExUnit.Case, async: true

  alias ValueFormatters.Schemas.{
    Format,
    DefaultFormats
  }

  describe "Format Schema" do
    test "accepts shorthands" do
      assert {:ok, _} = validate_format("date")
      assert {:ok, _} = validate_format("number")
      assert {:ok, _} = validate_format("string")
      assert {:ok, _} = validate_format("date_relative")
      assert {:ok, _} = validate_format("date_unix")
      assert {:ok, _} = validate_format("date_iso")
      assert {:ok, _} = validate_format("coordinates")
    end

    test "accepts null shorthand" do
      assert {:ok, _} = validate_format(nil)
    end

    test "accepts extended format" do
      assert {:ok, _} = validate_format(%{"format" => "date"})
    end

    test "accepts date options" do
      assert {:ok, _} =
               validate_format(%{
                 "format" => "date",
                 "time_display" => "short",
                 "date_display" => "long"
               })
    end

    test "accepts number options" do
      assert {:ok, _} =
               validate_format(%{
                 "format" => "number",
                 "precision" => 3,
                 "unit" => "°C"
               })
    end

    test "accepts date_unix options" do
      assert {:ok, _} =
               validate_format(%{
                 "format" => "date_unix",
                 "milliseconds" => true
               })
    end

    test "accepts coordinates options" do
      assert {:ok, _} =
               validate_format(%{
                 "format" => "coordinates",
                 "radius_display" => true
               })
    end

    test "doesn't accept invalid format type" do
      assert {:error, _} =
               validate_default_formats(%{
                 "format" => "foo"
               })
    end

    test "doesn't accept invalid date options" do
      assert {:error, _} =
               validate_format(%{
                 "format" => "date",
                 "time_display" => "short",
                 "date_display" => "long",
                 "foo" => "bar"
               })
    end
  end

  describe "DefaultFormats Schema" do
    test "accepts empty object" do
      assert {:ok, _} = validate_default_formats(%{})
    end

    test "accepts null value" do
      assert {:ok, _} = validate_default_formats(%{"number" => nil})
    end

    test "accepts number defaults" do
      assert {:ok, _} =
               validate_default_formats(%{
                 "number" => %{
                   "precision" => 2,
                   "unit" => "kg"
                 }
               })
    end

    test "accepts date_unix defaults" do
      assert {:ok, _} =
               validate_default_formats(%{
                 "date_unix" => %{
                   "milliseconds" => true
                 }
               })
    end

    test "accepts date defaults" do
      assert {:ok, _} =
               validate_default_formats(%{
                 "date" => %{
                   "date_display" => "long",
                   "time_display" => "short"
                 }
               })
    end

    test "accepts coordinate defaults" do
      assert {:ok, _} =
               validate_default_formats(%{
                 "coordinates" => %{
                   "radius_display" => false
                 }
               })
    end

    test "doesn't accept invalid date options" do
      assert {:error, _} =
               validate_default_formats(%{
                 "date" => %{
                   "date_display" => "long",
                   "time_display" => "short",
                   "foo" => "bar"
                 }
               })
    end

    test "doesn't accept invalid format type" do
      assert {:error, _} =
               validate_default_formats(%{
                 "foo" => %{
                   "date_display" => "long",
                   "time_display" => "short"
                 }
               })
    end
  end

  defp validate_format(format) do
    format_schema = JSV.build!(Format)

    JSV.validate(format, format_schema)
  end

  defp validate_default_formats(default_formats) do
    default_formats_schema = JSV.build!(DefaultFormats)

    JSV.validate(default_formats, default_formats_schema)
  end
end
