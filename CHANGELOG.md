# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `coordinates_plain` format: plain, locale-independent decimals without unit or radius, e.g. `51.9667, 12.0833`.
- `coordinates_dm` format: degrees and decimal minutes, e.g. `51° 58.00' N, 12° 05.00' E`.
- `coordinates_link` format: a map link built from a configurable `url_template` with `{lat}` and `{lng}`
  placeholders; defaults to Google Maps, e.g. `https://www.google.com/maps/search/?api=1&query=51.9667,12.0833`.
- `precision` option for all coordinate formats (decimal places; minutes for `coordinates_dm`).
  Defaults keep the previous output: 5, or 2 for `coordinates_dm`.

### Fixed

- `coordinates` returns an error instead of raising for values that are not coordinates.

## [0.2.2] - 2025-11-15

### Added 
- Added support for custom coordinate separators in coordinate formatting.

## [0.2.1] - 2025-10-28

### Fixed

- Minor documentation fixes and improvements.

## [0.2.0] - 2025-08-13

### Added

- [JSV](https://hexdocs.pm/jsv/JSV.html)-compatible JsonSchema definitions for `format` and `defaults` as
  `ValueFormatter.Schema.Format` and `ValueFormatter.Schema.DefaultFormats`, respectively.

[unreleased]: https://github.com/box-id/value_formatters/compare/0.2.2...HEAD
[0.2.2]: https://github.com/box-id/value_formatters/releases/tag/0.2.2
[0.2.1]: https://github.com/box-id/value_formatters/releases/tag/0.2.1
