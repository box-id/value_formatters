defmodule ValueFormattersTest do
  use ExUnit.Case, async: true

  alias ValueFormatters

  describe "empty inputs" do
    test "outputs empty string for nil input" do
      assert {:ok, ""} == ValueFormatters.to_string(nil, %{})
    end

    test "outputs empty string for empty string input" do
      assert {:ok, ""} == ValueFormatters.to_string("", %{})
    end
  end

  describe "numbers" do
    test "format float with units and precision" do
      format_definition = %{
        "format" => "number",
        "precision" => 2,
        "unit" => "kg"
      }

      assert ValueFormatters.to_string(1.234, format_definition) == {:ok, "1.23 kg"}

      assert ValueFormatters.to_string(12.345678912345679983731293, format_definition) ==
               {:ok, "12.35 kg"}
    end

    test "format float with precision" do
      format_definition = %{
        "format" => "number",
        "precision" => 2
      }

      assert ValueFormatters.to_string(1.234, format_definition) == {:ok, "1.23"}
    end

    test "format float with units" do
      format_definition = %{
        "format" => "number",
        "unit" => "kg"
      }

      assert ValueFormatters.to_string(1.234, format_definition) == {:ok, "1.234 kg"}
    end

    test "format float without units and precision" do
      format_definition = %{
        "format" => "number"
      }

      assert ValueFormatters.to_string(1.234, format_definition) == {:ok, "1.234"}
    end

    test "format float using default options" do
      assert ValueFormatters.to_string(1.234, "number",
               defaults: %{"number" => %{"precision" => 2, "unit" => "kg"}, "date" => %{}}
             ) == {:ok, "1.23 kg"}
    end

    test "format float with format definition and default options" do
      format_definition = %{
        "format" => "number",
        "precision" => 2
      }

      assert ValueFormatters.to_string(1.234, format_definition,
               defaults: %{"number" => %{"precision" => 3, "unit" => "kg"}, "date" => %{}}
             ) == {:ok, "1.23 kg"}
    end

    test "format float with format definition over default options" do
      format_definition = %{
        "format" => "number",
        "precision" => 2,
        "unit" => "kg"
      }

      assert ValueFormatters.to_string(1.234, format_definition,
               defaults: %{"number" => %{"precision" => 3, "unit" => "l"}, "date" => %{}}
             ) == {:ok, "1.23 kg"}
    end

    test "format float given as a string" do
      format_definition = %{
        "format" => "number",
        "precision" => 2,
        "unit" => "kg"
      }

      assert ValueFormatters.to_string("1.234", format_definition) == {:ok, "1.23 kg"}
    end

    test "no changes to float" do
      assert ValueFormatters.to_string(1.234, nil) == {:ok, "1.234"}
    end

    # Locale en
    test "format float using locale" do
      assert ValueFormatters.to_string(1_000.234, nil) == {:ok, "1,000.234"}
    end

    test "unchanged float inferred as a string" do
      assert ValueFormatters.to_string("1000.234", nil) == {:ok, "1000.234"}
    end

    test "format float with options and locale" do
      assert ValueFormatters.to_string("1000.234", %{"format" => "number"},
               defaults: %{"number" => %{"precision" => 2}}
             ) == {:ok, "1,000.23"}
    end

    test "format integer with units" do
      format_definition = %{
        "format" => "number",
        "unit" => "kg"
      }

      assert ValueFormatters.to_string(1, format_definition) == {:ok, "1 kg"}
    end
  end

  describe "strings" do
    test "string with no format definition" do
      assert ValueFormatters.to_string("Hello", nil) == {:ok, "Hello"}
    end

    test "string with a shorthand" do
      assert ValueFormatters.to_string("Hello", "string") == {:ok, "Hello"}
    end

    test "number string" do
      assert ValueFormatters.to_string("12.34", %{"format" => "string"}) == {:ok, "12.34"}
    end
  end

  describe "dates" do
    test "date only (short)" do
      date_definition = %{
        "format" => "date",
        "date_display" => "short",
        "time_display" => "none"
      }

      assert ValueFormatters.to_string(~U[2016-10-24 13:26:08.003Z], date_definition, []) ==
               {:ok, "10/24/16"}
    end

    test "date only (medium)" do
      date_definition = %{
        "format" => "date",
        "date_display" => "medium",
        "time_display" => "none"
      }

      assert ValueFormatters.to_string(~U[2016-10-24 13:26:08.003Z], date_definition, []) ==
               {:ok, "Oct 24, 2016"}

      date_definition = %{
        "format" => "date",
        # Use default!
        # "date_display" => "medium",
        "time_display" => "none"
      }

      assert ValueFormatters.to_string(~U[2016-10-24 13:26:08.003Z], date_definition, []) ==
               {:ok, "Oct 24, 2016"}
    end

    test "date only (long)" do
      date_definition = %{
        "format" => "date",
        "date_display" => "long",
        "time_display" => "none"
      }

      assert ValueFormatters.to_string(~U[2016-10-24 13:26:08.003Z], date_definition, []) ==
               {:ok, "October 24, 2016"}
    end

    test "date only (full)" do
      date_definition = %{
        "format" => "date",
        "date_display" => "full",
        "time_display" => "none"
      }

      assert ValueFormatters.to_string(~U[2016-10-24 13:26:08.003Z], date_definition, []) ==
               {:ok, "Monday, October 24, 2016"}
    end

    test "time only (short)" do
      date_definition = %{
        "format" => "date",
        "date_display" => "none",
        "time_display" => "short"
      }

      assert ValueFormatters.to_string(~U[2016-10-24 13:26:08.003Z], date_definition, []) ==
               {:ok, "1:26 PM"}
    end

    test "time only (medium)" do
      date_definition = %{
        "format" => "date",
        "date_display" => "none",
        "time_display" => "medium"
      }

      assert ValueFormatters.to_string(~U[2016-10-24 13:26:08.003Z], date_definition, []) ==
               {:ok, "1:26:08 PM"}

      date_definition = %{
        "format" => "date",
        "date_display" => "none"
        # Use default!
        # "time_display" => "medium"
      }

      assert ValueFormatters.to_string(~U[2016-10-24 13:26:08.003Z], date_definition, []) ==
               {:ok, "1:26:08 PM"}
    end

    test "time only (long)" do
      date_definition = %{
        "format" => "date",
        "date_display" => "none",
        "time_display" => "long"
      }

      assert ValueFormatters.to_string(~U[2016-10-24 13:26:08.003Z], date_definition, []) ==
               {:ok, "1:26:08 PM UTC"}
    end

    test "time only (full)" do
      date_definition = %{
        "format" => "date",
        "date_display" => "none",
        "time_display" => "full"
      }

      assert ValueFormatters.to_string(~U[2016-10-24 13:26:08.003Z], date_definition, []) ==
               {:ok, "1:26:08 PM GMT"}
    end

    test "date and time (medium)" do
      date_definition = %{
        "format" => "date",
        "date_display" => "medium",
        "time_display" => "medium"
      }

      assert ValueFormatters.to_string(~U[2016-10-24 13:26:08.003Z], date_definition, []) ==
               {:ok, "Oct 24, 2016, 1:26:08 PM"}

      date_definition = %{
        "format" => "date"
        # Use default!
        # "date_display" => "medium",
        # "time_display" => "medium"
      }

      assert ValueFormatters.to_string(~U[2016-10-24 13:26:08.003Z], date_definition, []) ==
               {:ok, "Oct 24, 2016, 1:26:08 PM"}
    end

    test "date short date" do
      date_definition = %{
        "format" => "date",
        "date_display" => "short",
        "time_display" => "short"
      }

      assert ValueFormatters.to_string(~D[2016-10-24], date_definition, []) == {:ok, "10/24/16"}
    end

    test "date from iso8601" do
      date_definition = %{
        "format" => "date",
        "date_display" => "medium",
        "time_display" => "none"
      }

      assert ValueFormatters.to_string("2016-10-24T15:22:24Z", date_definition, []) ==
               {:ok, "Oct 24, 2016"}

      # Assert that date-only string is accepted
      assert ValueFormatters.to_string("2016-10-24", date_definition, []) ==
               {:ok, "Oct 24, 2016"}
    end

    test "time from iso8601" do
      date_definition = %{
        "format" => "date",
        "date_display" => "none",
        "time_display" => "medium"
      }

      assert ValueFormatters.to_string(
               "2016-08-24T15:22:24Z",
               date_definition,
               time_zone: "Europe/Berlin"
             ) ==
               {:ok, "5:22:24 PM"}

      # Assert that time-only string is accepted. Note that it is not shifted to any timezone as
      # this isn't possible with wall clock time.
      assert ValueFormatters.to_string("15:22:24", date_definition, time_zone: "Europe/Berlin") ==
               {:ok, "3:22:24 PM"}
    end

    test "datetime from iso8601" do
      date_definition = %{
        "format" => "date",
        "date_display" => "medium",
        "time_display" => "medium"
      }

      assert ValueFormatters.to_string("2016-10-24T15:22:24Z", date_definition, []) ==
               {:ok, "Oct 24, 2016, 3:22:24 PM"}
    end

    test "datetime from unix timestamp" do
      date_definition = %{
        "format" => "date",
        "date_display" => "medium",
        "time_display" => "medium"
      }

      assert ValueFormatters.to_string(1_477_323_744, date_definition, []) ==
               {:ok, "Oct 24, 2016, 3:42:24 PM"}
    end

    test "no defined format" do
      date_definition = %{
        "date_display" => "medium"
      }

      assert ValueFormatters.to_string(~D[2016-10-24], date_definition, []) ==
               {:ok, "Oct 24, 2016"}
    end

    # medium is the default
    test "date shorthand" do
      assert ValueFormatters.to_string(~D[2016-10-24], "date") == {:ok, "Oct 24, 2016"}
    end

    test "datetime shorthand" do
      assert ValueFormatters.to_string(~U[2016-10-24 13:26:08.003Z], "date") ==
               {:ok, "Oct 24, 2016, 1:26:08 PM"}
    end

    test "time shorthand" do
      assert ValueFormatters.to_string(~T[13:26:08.003], "date") == {:ok, "1:26:08 PM"}
    end
  end

  # TODO How do I test relative dates?
  describe "date_relative" do
    test "works with shorthand description" do
      assert ValueFormatters.to_string(DateTime.utc_now(), "date_relative") == {:ok, "now"}
    end

    test "yesterday" do
      {:ok, now} = DateTime.now("UTC")
      yesterday = Timex.shift(now, hours: -24)

      assert ValueFormatters.to_string(yesterday, "date_relative") == {:ok, "yesterday"}
    end

    test "tomorrow" do
      {:ok, now} = DateTime.now("UTC")
      tomorrow = Timex.shift(now, hours: 24)

      assert ValueFormatters.to_string(tomorrow, "date_relative") == {:ok, "tomorrow"}
    end

    test "5 days ago" do
      {:ok, now} = DateTime.now("UTC")
      past = Timex.shift(now, hours: -5 * 24)

      assert ValueFormatters.to_string(past, "date_relative") == {:ok, "5 days ago"}
    end

    test "in 5 days" do
      {:ok, now} = DateTime.now("UTC")
      future = Timex.shift(now, hours: 5 * 24)

      assert ValueFormatters.to_string(future, "date_relative") == {:ok, "in 5 days"}
    end

    test "12 months ago" do
      {:ok, now} = DateTime.now("UTC")
      past = Timex.shift(now, days: -364)

      assert ValueFormatters.to_string(past, "date_relative") == {:ok, "12 months ago"}
    end

    test "last year" do
      {:ok, now} = DateTime.now("UTC")
      past = Timex.shift(now, years: -1, months: -2)

      assert ValueFormatters.to_string(past, "date_relative") == {:ok, "last year"}
    end

    test "last week" do
      {:ok, now} = DateTime.now("UTC")
      past = Timex.shift(now, weeks: -1, days: -2)

      assert ValueFormatters.to_string(past, "date_relative") == {:ok, "last week"}
    end

    test "5 years ago" do
      {:ok, now} = DateTime.now("UTC")
      past = Timex.shift(now, years: -5, months: -2, days: -1)

      assert ValueFormatters.to_string(past, "date_relative") == {:ok, "5 years ago"}
    end

    test "from unix timestamp" do
      {:ok, now} = DateTime.now("UTC")
      past = Timex.shift(now, years: -5, months: -2, days: -1)

      assert ValueFormatters.to_string(past, "date_relative") == {:ok, "5 years ago"}
    end

    test "date in iso8601" do
      {:ok, now} = DateTime.now("UTC")
      past = Timex.shift(now, years: -5, months: -2, days: -1)
      date_iso = DateTime.to_iso8601(past)

      assert ValueFormatters.to_string(date_iso, "date_relative") == {:ok, "5 years ago"}
    end

    test "time object not supported" do
      {:ok, time} = Time.new(1, 10, 30)

      assert ValueFormatters.to_string(time, "date_relative") ==
               {:error, "Date part is required for relative date formatting."}
    end
  end

  describe "coordinates" do
    test "full coordinates" do
      assert ValueFormatters.to_string([123.1345, 34.123, 2], %{"format" => "coordinates"}, []) ==
               {:ok, "123.1345°, 34.123°, 2 m"}
    end

    test "inference object with radius" do
      assert ValueFormatters.to_string(
               %{"lat" => 43.1298, "lng" => 54.1234, "radius" => 1},
               %{},
               []
             ) ==
               {:ok, "43.1298°, 54.1234°, 1 m"}
    end

    test "inference object no radius" do
      assert ValueFormatters.to_string(%{"lat" => 43.1298, "lng" => 54.1234}, %{}, []) ==
               {:ok, "43.1298°, 54.1234°"}
    end

    test "inference list with radius" do
      assert ValueFormatters.to_string([123.1345, 34.123, 2], %{}, []) ==
               {:ok, "123.1345°, 34.123°, 2 m"}
    end

    test "inference list no radius" do
      assert ValueFormatters.to_string([123.1345, 34.123], %{}, []) ==
               {:ok, "123.1345°, 34.123°"}
    end

    test "with radius show radius" do
      assert ValueFormatters.to_string(
               %{"lat" => 123.134567, "lng" => 34.12345, "radius" => 2},
               %{"format" => "coordinates"},
               []
             ) ==
               {:ok, "123.13457°, 34.12345°, 2 m"}
    end

    test "no radius show radius" do
      assert ValueFormatters.to_string(
               %{"lat" => 123.134567, "lng" => 34.12345},
               %{"format" => "coordinates", "radius_display" => true},
               []
             ) ==
               {:ok, "123.13457°, 34.12345°"}
    end

    test "with radius hide radius" do
      assert ValueFormatters.to_string(
               %{"lat" => 123.134567, "lng" => 34.12345, "radius" => 2},
               %{"format" => "coordinates", "radius_display" => false},
               []
             ) ==
               {:ok, "123.13457°, 34.12345°"}
    end
  end

  test "call with empty object format desription" do
    assert ValueFormatters.to_string(3.14244453, %{"precision" => 2}) == {:ok, "3.14"}
  end

  describe "render" do
    test "render unit html" do
      assert ValueFormatters.to_string("123", %{"format" => "number", "unit" => "kg"},
               render_unit: fn unit -> "<span class=\"text-gray-500\">#{unit}</span>" end
             ) == {:ok, "123.0 <span class=\"text-gray-500\">kg</span>"}
    end
  end
end
