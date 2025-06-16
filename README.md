# ValueFormatters

## Usage

To use value formatters, the host application needs to set up its own Cldr backend, including the following libraries:

* Cldr.Number,
* Cldr.Calendar,
* Cldr.DateTime,
* Cldr.Time,
* Cldr.Date

Cldr needs to be passed as an option to the `to_string/3` method under `cldr` key.



