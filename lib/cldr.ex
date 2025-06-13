# For test purposes only
defmodule Formatter.Cldr do
  use Cldr,
    # Available locales are defined in the config files s.t. they can vary by environment.
    otp_app: :value_formatters,
    default_locale: "en",
    data_dir: "./priv/cldr",
    locales: ["de"],
    providers: [
      Cldr.Number,
      Cldr.Calendar,
      Cldr.DateTime,
      Cldr.Time,
      Cldr.Date,
      Cldr.List
    ]
end
