# ValueFormatters

Turns raw values (numbers, strings, dates, coordinates) into display strings, localized with
[Cldr](https://hex.pm/packages/ex_cldr). A *format definition* says how a value is rendered.
Format definitions are plain maps, so they can be stored as JSON, and JSON schemas for them are
included.

## Installation

The library isn't published on Hex. Add it as a git dependency:

```elixir
def deps do
  [
    {:value_formatters, github: "box-id/value_formatters", tag: "0.2.2"}
  ]
end
```

`{:jsv, ...}` is optional; you only need it to use the JSON schemas.

### Cldr backend

The host application sets up its own Cldr backend with these providers:

```elixir
defmodule MyApp.Cldr do
  use Cldr,
    locales: ["en", "de"],
    providers: [Cldr.Number, Cldr.Calendar, Cldr.DateTime, Cldr.Time, Cldr.Date]
end
```

Its dependencies are `ex_cldr_numbers`, `ex_cldr_dates_times` and `ex_cldr_calendars`.

## Usage

```elixir
ValueFormatters.to_string(value, format_definition, opts)
# => {:ok, "formatted"} | {:error, reason}
```

```elixir
ValueFormatters.to_string(1234.5678, nil, cldr: MyApp.Cldr)
# => {:ok, "1,234.5678"}

ValueFormatters.to_string(1234.5678, %{"format" => "number", "precision" => 2, "unit" => "kg"},
  cldr: MyApp.Cldr,
  locale: "de"
)
# => {:ok, "1.234,57 kg"}
```

`nil` and `""` always format to `{:ok, ""}`.

### Format definitions

A format definition can be any of these:

- **`nil`**: the format is inferred from the value.
  - Numbers become `number`.
  - Strings become `string`.
  - `Date`, `Time`, `DateTime` and `NaiveDateTime` become `date`.
  - `[lat, lng]`, `[lat, lng, radius]` and `%{"lat" => ..., "lng" => ...}` become `coordinates`.
- **A string** (shorthand): the name of a format with default options, e.g. `"date_iso"`.
- **A map**: `%{"format" => "number", "precision" => 2}`. If `"format"` is missing, it is inferred
  from the value as for `nil`.

### Options

These are the `opts` keyword list:

| Option         | Description                                                                                  |
|----------------|----------------------------------------------------------------------------------------------|
| `:cldr`        | Your Cldr backend module. Required by every format that uses Cldr.                           |
| `:locale`      | Locale for formatting. Falls back to `Process.get(:locale)`, then Cldr's default locale.     |
| `:time_zone`   | Time zone that dates are shifted to. Falls back to `Process.get(:time_zone)`.                |
| `:defaults`    | Default options per format, e.g. `%{"number" => %{"precision" => 2}}`. Options in the format definition take precedence. |
| `:render_unit` | A function that renders a number's unit, e.g. to wrap it in markup. The default leaves it unchanged. |

### Preset module

With `use ValueFormatters` you get a module that presets the backend and defaults. Defaults passed
when calling `to_string/3` are merged over the preset ones.

```elixir
defmodule MyApp.Formatter do
  use ValueFormatters,
    cldr: MyApp.Cldr,
    defaults: %{"coordinates_link" => %{"url_template" => "geo:{lat},{lng}"}}
end

MyApp.Formatter.to_string([51.96667, 12.08333], "coordinates_link")
# => {:ok, "geo:51.96667,12.08333"}
```

## Formats

The examples call `MyApp.Formatter` from [Preset module](#preset-module), so the Cldr backend is set.
They show only the string inside the `{:ok, string}` result and use the `en` locale unless stated
otherwise.

### `number`

| Option      | Default | Description                                                         |
|-------------|---------|---------------------------------------------------------------------|
| `precision` | –       | Decimal places: a maximum for floats and numeric strings, but a fixed count for integers. Floats may retain a trailing `.0`. |
| `unit`      | –       | Appended after a space. `°` is appended without a space.            |

```elixir
MyApp.Formatter.to_string(1234.5678, "number")                                   # "1,234.5678"
MyApp.Formatter.to_string(1234.5678, %{"format" => "number", "precision" => 2})  # "1,234.57" ("1.234,57" in de)
```

### `string`

This returns the value as a string. Use it to skip any other formatting.

### `date`

The input can be a `Date`, `Time`, `DateTime` or `NaiveDateTime`, an ISO 8601 string, or a Unix
timestamp in seconds or milliseconds.

| Option         | Default  | Values                                         |
|----------------|----------|------------------------------------------------|
| `date_display` | `medium` | `full`, `long`, `medium`, `short`, `none`      |
| `time_display` | `medium` | `full`, `long`, `medium`, `short`, `none`      |

```elixir
MyApp.Formatter.to_string(~U[2023-11-29 15:44:28Z], "date")  # "Nov 29, 2023, 3:44:28 PM"
MyApp.Formatter.to_string(~U[2023-11-29 15:44:28Z],
  %{"format" => "date", "date_display" => "long", "time_display" => "none"})  # "29. November 2023" (de)
```

### `date_relative`

This renders the date relative to now, e.g. `"2 days ago"`. It has no options.

### `date_iso`

This renders ISO 8601, e.g. `"2023-11-29T15:44:28Z"`. It has no options.

### `date_unix`

This renders a Unix timestamp, e.g. `"1701272668"`.

| Option         | Default | Description                       |
|----------------|---------|-----------------------------------|
| `milliseconds` | `false` | Output milliseconds, not seconds. |

### Coordinates

All coordinate formats accept these inputs:

- `[lat, lng]`
- `[lat, lng, radius]`
- `%{"lat" => lat, "lng" => lng}`
- `%{"lat" => lat, "lng" => lng, "radius" => radius}`

Latitude and longitude can be numbers or numeric strings (surrounding whitespace is ignored, any
other trailing characters are not). Latitude must be within -90..90 and longitude within
-180..180. If either can't be parsed or is out of range, formatting returns
`{:error, "Value ... cannot be parsed as a coordinate"}`. The radius is validated only when
it is displayed; an invalid displayed radius returns `{:error, "Can't parse value ..."}`.

| Format              | Example (`[51.96667, 12.08333, 2]`)                                 | Localized | Radius |
|---------------------|---------------------------------------------------------------------|-----------|--------|
| `coordinates`       | `51.96667°, 12.08333°, 2 m`                                         | yes       | yes    |
| `coordinates_plain` | `51.96667, 12.08333`                                                | no        | no     |
| `coordinates_dm`    | `51° 58.00' N, 12° 05.00' E, 2 m`                                   | yes       | yes    |
| `coordinates_link`  | `https://www.google.com/maps/search/?api=1&query=51.96667,12.08333` | no        | no     |

Their options:

| Option           | Formats                                         | Default       | Description |
|------------------|-------------------------------------------------|---------------|-------------|
| `precision`      | all                                             | `5`; `2` for `coordinates_dm` | Maximum decimal places for lat/lng. For `coordinates_dm`, the decimal places of the minutes. An integer from 0 to 15. |
| `separator`      | `coordinates`, `coordinates_plain`, `coordinates_dm` | `", "`   | Placed between the parts. |
| `radius_display` | `coordinates`, `coordinates_dm`                 | `true`        | Show the radius (`2 m`) if present. |
| `url_template`   | `coordinates_link`                              | Google Maps URL | Must contain `{lat}` and `{lng}`. |

Notes:

- **`coordinates_plain`** is machine-readable: always a dot decimal separator, with no unit and
  no scientific notation. Use it for CSV exports.
- **`coordinates_dm`** shows degrees and decimal minutes with hemisphere letters N/S/E/W. The
  letters aren't localized; the numbers are, e.g. `51° 58,00' N` in `de`. Negative values give
  S/W, e.g. `33° 51.41' S, 151° 12.92' W`.
- **`coordinates_link`** fills `url_template` with plain decimals:

  ```elixir
  MyApp.Formatter.to_string([51.96667, 12.08333], %{
    "format" => "coordinates_link",
    "url_template" => "https://www.openstreetmap.org/?mlat={lat}&mlon={lng}",
    "precision" => 3
  })
  # "https://www.openstreetmap.org/?mlat=51.967&mlon=12.083"
  ```

## JSON schemas

The schemas validate format definitions, for example when they're stored in user configuration.
Use them with [JSV](https://hex.pm/packages/jsv):

- **`ValueFormatters.Schemas.Format.json_schema/0`** validates a single format definition: `null`,
  a shorthand string, or an object.
- **`ValueFormatters.Schemas.DefaultFormats.json_schema/0`** validates the `defaults` map, which
  has one key per format.

## Development

```sh
mix deps.get
mix test
mix format --check-formatted
mix compile --warnings-as-errors
```

Tests use the Cldr backend in `test/cldr.ex`, with locale data in `priv/cldr`.
