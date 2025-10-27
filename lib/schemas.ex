defmodule ValueFormatters.Schemas do
  def number_options do
    %{
      precision: %{
        type: :number,
        description: "Number of decimal places"
      },
      unit: %{
        type: [:string, :null],
        description: "If set, the formatter appends ' ' + unit to the display value"
      }
    }
  end

  def date_options do
    %{
      date_display: %{
        type: :string,
        description: """
        How the formatter should display the date portion:

        - `full`: Wednesday, November 29, 2023

        - `long`: November 29, 2023

        - `medium`: Nov 29, 2023

        - `short`: 11/29/23

        - `none`: Don't display date
        """,
        enum: ["full", "long", "medium", "short", "none"],
        default: "medium"
      },
      time_display: %{
        type: :string,
        description: """
        How the formatter should display the time portion:

        - `full`: 3:44:28 PM GMT

        - `long`: 3:44:28 PM UTC

        - `medium`: 3:44:28 PM

        - `short`: 3:44 PM

        - `none`: Don't display time
        """,
        enum: ["full", "long", "medium", "short", "none"],
        default: "medium"
      }
    }
  end

  def date_unix_options do
    %{
      milliseconds: %{
        type: :boolean,
        default: false,
        description:
          "Whether the formatter should output the values milliseconds (instead of seconds)."
      }
    }
  end

  def coordinates_options do
    %{
      radius_display: %{
        type: :boolean,
        default: true,
        description:
          "Whether the formatter should include the radius/accuracy information (if present)."
      }
    }
  end
end

defmodule ValueFormatters.Schemas.Format do
  import ValueFormatters.Schemas

  def json_schema() do
    %{
      description: "Formats for value formatting",
      oneOf: [
        %{
          type: :null,
          description: "Skip formatting and return raw value."
        },
        %{
          type: :string,
          title: "shorthand",
          description: "A shorthand representation of the format",
          enum: [
            "number",
            "string",
            "date",
            "date_relative",
            "date_iso",
            "date_unix",
            "coordinates"
          ]
        },
        %{
          type: :object,
          title: "string",
          properties: %{
            format: %{
              const: "string",
              description:
                "Use to explicitly disable any kind of formatting that would otherwise take place, but still return a string."
            },
            field: %{
              type: :string,
              description:
                "If the value is an object, the field to extract the formattable entity from."
            }
          },
          required: [:format],
          additionalProperties: false
        },
        %{
          type: :object,
          title: "number",
          properties:
            Map.merge(
              %{
                format: %{
                  const: "number",
                  description:
                    "Use to display numeric values and format them according to the user's locale."
                },
                field: %{
                  type: :string,
                  description:
                    "If the value is an object, the field to extract the formattable entity from."
                }
              },
              number_options()
            ),
          required: [:format],
          additionalProperties: false
        },
        %{
          type: :object,
          title: "date",
          properties:
            Map.merge(
              %{
                format: %{
                  const: "date",
                  description:
                    "Use to display date-time values and format them according to the user's locale."
                },
                field: %{
                  type: :string,
                  description:
                    "If the value is an object, the field to extract the formattable entity from."
                }
              },
              date_options()
            ),
          required: [:format],
          additionalProperties: false
        },
        %{
          type: :object,
          title: "date_relative",
          properties: %{
            format: %{
              const: "date_relative",
              description: """
              Use format: "date_relative" to display a relative date string (e.g. “2 days ago”) by comparing the given value against the current date & time. Only the largest sensible unit is displayed, e.g. the formatter will only display “days” even when other components such as hours, minutes etc. aren't equal to zero.

              The implementation can choose to update the displayed value in appropriate intervals. Also, it can choose to display the absolute date on user interaction, e.g. in a tooltip.

              This format currently doesn't support any options.
              """
            },
            field: %{
              type: :string,
              description:
                "If the value is an object, the field to extract the formattable entity from."
            }
          },
          required: [:format],
          additionalProperties: false
        },
        %{
          type: :object,
          title: "date_iso",
          properties: %{
            format: %{
              const: "date_iso",
              description: "Use to display date-time values in ISO 8601 extended format."
            },
            field: %{
              type: :string,
              description:
                "If the value is an object, the field to extract the formattable entity from."
            }
          },
          required: [:format],
          additionalProperties: false
        },
        %{
          type: :object,
          title: "date_unix",
          properties:
            Map.merge(
              %{
                format: %{
                  const: "date_unix",
                  description: "Use to display date-time values in seconds since unix epoch."
                },
                field: %{
                  type: :string,
                  description:
                    "If the value is an object, the field to extract the formattable entity from."
                }
              },
              date_unix_options()
            ),
          required: [:format],
          additionalProperties: false
        },
        %{
          type: :object,
          title: "coordinates",
          properties:
            Map.merge(
              %{
                format: %{
                  const: "coordinates",
                  description: "Use to display latitude & longitude information."
                },
                field: %{
                  type: :string,
                  description:
                    "If the value is an object, the field to extract the formattable entity from."
                }
              },
              coordinates_options()
            ),
          required: [:format],
          additionalProperties: false
        },
        %{
          type: "object",
          title: "field",
          properties: %{
            field: %{
              type: :string,
              description:
                "If the value is an object, the field to extract the formattable entity from."
            }
          },
          required: [:field],
          additionalProperties: false
        }
      ]
    }
  end
end

defmodule ValueFormatters.Schemas.DefaultFormats do
  import ValueFormatters.Schemas

  def json_schema() do
    %{
      type: :object,
      description: "Default formats for value formatting",
      properties: %{
        number: %{
          type: [:object, :null],
          description:
            "Use to display numeric values and format them according to the user's locale.",
          properties: number_options(),
          additionalProperties: false
        },
        string: %{
          type: [:object, :null],
          description:
            "Use to explicitly disable any kind of formatting that would otherwise take place.",
          properties: %{},
          additionalProperties: false
        },
        date: %{
          type: [:object, :null],
          description:
            "Use to to display date-time values and format them according to the user's locale.",
          properties: date_options(),
          additionalProperties: false
        },
        date_relative: %{
          type: [:object, :null],
          description: """
          Use format: "date_relative" to display a relative date string (e.g. “2 days ago”) by comparing the given value against the current date & time. Only the largest sensible unit is displayed, e.g. the formatter will only display “days” even when other components such as hours, minutes etc. aren't equal to zero.

          The implementation can choose to update the displayed value in appropriate intervals. Also, it can choose to display the absolute date on user interaction, e.g. in a tooltip.

          This format currently doesn't support any options.
          """,
          properties: %{},
          additionalProperties: false
        },
        date_iso: %{
          type: [:object, :null],
          description: "Use to display date-time values in ISO 8601 extended format.",
          properties: %{},
          additionalProperties: false
        },
        date_unix: %{
          type: [:object, :null],
          description: "Use to display date-time values in seconds since unix epoch.",
          properties: date_unix_options(),
          additionalProperties: false
        },
        coordinates: %{
          type: [:object, :null],
          description: "Use to display latitude & longitude information.",
          properties: coordinates_options(),
          additionalProperties: false
        }
      },
      additionalProperties: false
    }
  end
end
