defmodule ValueFormatters do
  use OK.Pipe
  alias ValueFormatters.Cldr

  @date_display_options [:none, :short, :medium, :long, :full]
  @time_display_options [:none, :short, :medium, :long, :full]

  def to_string(value, format_definition, options \\ [])

  def to_string(nil, _format_definition, _options), do: {:ok, ""}
  def to_string("", _format_definition, _options), do: {:ok, ""}

  # def to_string(true, _format_definition, _options), do: {:ok, Cldr.Message.format("Yes")}
  # def to_string(false, _format_definition, _options), do: {:ok, Cldr.Message.format("No")}

  def to_string(value, format_definition, options) do
    format_definition =
      format_definition
      |> expand_format_definition(value)
      |> merge_with_defaults(options)

    # do the formatting
    case format_definition["format"] do
      "number" -> format_number(value, format_definition, options)
      "string" -> format_string(value, format_definition)
      "date" -> format_date(value, format_definition, options)
      "date_relative" -> format_date_relative(value, format_definition, options)
      "coordinates" -> format_coordinates(value, format_definition)
      _ -> {:error, "Unsupported format #{format_definition["format"]}"}
    end
    |> handle_cldr_error()
  end

  defp expand_format_definition(nil = _format_definition, value) do
    format = determine_value_type(value)
    %{"format" => format}
  end

  # In case of a shorthand formatDefinition, expand it
  defp expand_format_definition(format_definition, _value)
       when format_definition in ["number", "string", "date", "date_relative", "coordinates"] do
    %{"format" => format_definition}
  end

  defp expand_format_definition(format_definition, value) when is_map(format_definition) do
    if Map.has_key?(format_definition, "format") do
      format_definition
    else
      Map.put(format_definition, "format", determine_value_type(value))
    end
  end

  defp determine_value_type(value) when is_number(value), do: "number"
  defp determine_value_type(value) when is_binary(value), do: "string"

  defp determine_value_type(value) do
    case value do
      %Date{} -> "date"
      %DateTime{} -> "date"
      %NaiveDateTime{} -> "date"
      %Time{} -> "date"
      [_lat, _lng, _radius] -> "coordinates"
      [_lat, _lng] -> "coordinates"
      %{"lat" => _lat, "lng" => _lng, "radius" => _radius} -> "coordinates"
      %{"lat" => _lat, "lng" => _lng} -> "coordinates"
      _ -> "The type of value #{inspect(value)} is not supported."
    end
  end

  defp handle_cldr_error({:error, {_module, reason}}), do: {:error, reason}
  defp handle_cldr_error(result), do: result

  defp merge_with_defaults(format_definition, []), do: format_definition

  defp merge_with_defaults(%{"format" => format} = format_definition, options) do
    format_defaults = get_in(options, [:defaults, format])

    if format_defaults != nil do
      Map.merge(format_defaults, format_definition)
    else
      format_definition
    end
  end

  defp format_number(value, number_definition, opts) when is_number(value) do
    precision = Map.get(number_definition, "precision")
    unit = Map.get(number_definition, "unit")

    # Cldr.Number.to_string adds additional 0's in case fractional_digits_cnt < precision
    # To avoid that, precision is set to the smaller value of non-0 fractional_digits_cnt and precision
    # integer
    {rounded_value, precision} =
      if is_float(value) do
        rounded = round_float(value, precision)
        {rounded, min(count_fractional_digits(rounded), precision)}
      else
        {value, precision}
      end

    Cldr.Number.to_string(rounded_value, locale: get_locale(opts), fractional_digits: precision)
    ~> append_unit(unit, opts)
  end

  defp format_number(value, number_definition, opts) do
    with {number, _remainder} <- Float.parse(value) do
      format_number(number, number_definition, opts)
    else
      :error -> {:error, "Can't parse value #{value}"}
    end
  end

  defp count_fractional_digits(number) do
    [_integer_part, fractional_part] =
      number
      |> Float.to_string()
      |> String.split(".")

    String.length(fractional_part)
  end

  defp round_float(value, nil), do: value
  defp round_float(value, precision), do: Float.round(value, precision)

  defp append_unit(value, nil, _), do: value

  defp append_unit(value, unit, opts) do
    unit = to_string(unit)
    separator = if unit == "°", do: "", else: " "

    render_function = Keyword.get(opts, :render_unit, &Function.identity/1)

    value <> separator <> render_function.(unit)
  end

  defp format_string(value, _string_definition), do: {:ok, value}

  defp format_date(value, date_definition, opts) do
    with {:ok, value} <- pre_process_date_value(value, date_definition, opts) do
      date_display =
        Map.get(date_definition, "date_display", "medium") |> String.to_existing_atom()

      time_display =
        Map.get(date_definition, "time_display", "medium") |> String.to_existing_atom()

      cond do
        date_display not in @date_display_options ->
          {:error, "Invalid date_display option #{date_display}"}

        time_display not in @time_display_options ->
          {:error, "Invalid time_display option #{time_display}"}

        date_display == :none and time_display == :none ->
          {:error,
           "date_display and time_display can't both be :none (while formatting #{inspect(value)})"}

        # Value of type Time has to be formatted with Cldr.Time
        date_display == :none or is_time(value) ->
          Cldr.Time.to_string(value, format: time_display, locale: get_locale(opts))

        # Value of type Date has to be formatted with Cldr.Date
        time_display == :none or is_date(value) ->
          Cldr.Date.to_string(value, format: date_display, locale: get_locale(opts))

        # Covers DateTime and NaiveDateTime
        true ->
          Cldr.DateTime.to_string(value,
            date_format: date_display,
            time_format: time_display,
            locale: get_locale(opts)
          )
      end
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp pre_process_date_value(value, date_definition, opts) when is_binary(value) do
    extract_date_from_iso(value, date_definition)
    ~>> pre_process_date_value(date_definition, opts)
  end

  # value is an integer (unix timestamp), in seconds or milliseconds
  defp pre_process_date_value(value, date_definition, opts)
       when is_integer(value) or is_float(value) do
    # Try guessing the precision (millisecond vs second) of the unix timestamp. A unix timestamp
    # of 20_000_000_000 seconds means 2603-10-11T11:33:20, which is fairly unlikely to be a real
    # value.
    {precision, value} =
      if value > 20_000_000_000,
        do: {:millisecond, value},
        else: {:millisecond, round(value * 1000)}

    DateTime.from_unix(value, precision)
    ~>> pre_process_date_value(date_definition, opts)
  end

  defp pre_process_date_value(value, _date_definition, opts) do
    case value do
      %DateTime{} ->
        timezone = get_timezone(opts)
        shift_datetime_to_user_zone(value, timezone)

      %NaiveDateTime{} ->
        timezone = get_timezone(opts, "Etc/UTC")

        # TODO: There are two more return values that might need handling:
        # {:ambiguous, first_datetime :: t(), second_datetime :: t()}
        # {:gap, t(), t()}
        DateTime.from_naive(value, timezone)

      %Date{} ->
        {:ok, value}

      %Time{} ->
        {:ok, value}

      _ ->
        {:error, "Invalid Date/Time value #{value}"}
    end
  end

  defp extract_date_from_iso(value, _date_definition) do
    with {:error, _datetime_error} <- DateTime.from_iso8601(value),
         {:error, _date_error} <- Date.from_iso8601(value),
         {:error, _time_error} <- Time.from_iso8601(value) do
      {:error, "Can't parse value #{value}. The value is not a valid date/time."}
    else
      {:ok, date, _remainder} -> {:ok, date}
      success -> success
    end
  end

  defp is_date(%Date{}), do: true
  defp is_date(_), do: false

  defp is_time(%Time{}), do: true
  defp is_time(_), do: false

  defp shift_datetime_to_user_zone(value, nil), do: {:ok, value}
  defp shift_datetime_to_user_zone(value, zone), do: DateTime.shift_zone(value, zone)

  defp format_date_relative(value, date_definition, opts) do
    with {:ok, value} <- pre_process_date_value(value, date_definition, opts) do
      if not is_time(value) do
        Cldr.DateTime.Relative.to_string(value, locale: get_locale(opts))
      else
        {:error, "Date part is required for relative date formatting."}
      end
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp format_coordinates(value, coordinate_definition) do
    [lat, lng, radius] =
      case value do
        %{"lat" => lat, "lng" => lng, "radius" => radius} -> [lat, lng, radius]
        %{"lat" => lat, "lng" => lng} -> [lat, lng, nil]
        [lat, lng, radius] -> [lat, lng, radius]
        [lat, lng] -> [lat, lng, nil]
      end

    with {:ok, lat_formatted} <-
           format_number(lat, %{"format" => "number", "precision" => 5}, []),
         {:ok, lng_formatted} <- format_number(lng, %{"format" => "number", "precision" => 5}, []) do
      if get_in(coordinate_definition, ["radius_display"]) != false and radius != nil do
        with {:ok, radius_formatted} <-
               format_number(radius, %{"format" => "number", "precision" => 0, "unit" => "m"}, []) do
          {:ok, "#{lat_formatted}\u{00B0}, #{lng_formatted}\u{00B0}, #{radius_formatted}"}
        else
          {:error, reason} -> {:error, reason}
        end
      else
        {:ok, "#{lat_formatted}\u{00B0}, #{lng_formatted}\u{00B0}"}
      end
    else
      {:error, _reason} -> {:error, "Value #{value} cannot be parsed as a coordinate"}
    end
  end

  defp get_locale(opts, default \\ nil) do
    Keyword.get(opts, :locale) ||
      Process.get(:locale) ||
      default
  end

  defp get_timezone(opts, default \\ nil) do
    Keyword.get(opts, :time_zone) ||
      Process.get(:time_zone) ||
      default

    # FIXME: Better default possible by guessing from region?
  end
end
