# For test purposes only
defmodule ValueFormatters.Cldr do
  use Cldr,
    otp_app: :value_formatters,
    default_locale: "en",
    data_dir: "./priv/cldr",
    # "fa" (Persian) is here only because its default digits are not Latin (۰-۹, decimal
    # separator ٫). The coordinates_dm tests use it to prove that every digit, including the
    # zero-padding of minutes, goes through Cldr instead of being hardcoded ASCII.
    locales: ["de", "fa"],
    providers: [
      Cldr.Number,
      Cldr.Calendar,
      Cldr.DateTime,
      Cldr.Time,
      Cldr.Date
    ]
end
