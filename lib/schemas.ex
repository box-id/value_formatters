defmodule ValueFormatters.Schemas.Format do
  def json_schema() do
    %{
      type: :object,
      description: "Formats for value formatting",
      oneOf: [
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
                "Use to explicitly disable any kind of formatting that would otherwise take place."
            }
          }
        },
        %{
          type: :object,
          title: "number",
          properties: %{
            format: %{
              const: "number",
              description:
                "Use  to display numeric values and format them according to the user's locale."
            },
            precision: %{type: :number, description: "Number of decimal places"},
            unit: %{
              type: :string,
              description: "If set, the formatter appends ' ' + unit to the display value"
            }
          }
        },
        %{
          type: :object,
          title: "date",
          properties: %{
            format: %{
              const: "date",
              description:
                "Use to display date-time values and format them according to the user's locale."
            },
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
            }
          }
        },
        %{
          type: :object,
          title: "date_iso",
          properties: %{
            format: %{
              const: "date_iso",
              description: "Use to display date-time values in ISO 8601 extended format."
            }
          }
        },
        %{
          type: :object,
          title: "date_unix",
          properties: %{
            format: %{
              const: "date_unix",
              description: "Use to display date-time values in seconds since unix epoch."
            },
            milliseconds: %{
              type: :boolean,
              default: false,
              description:
                "Whether the formatter should output the values milliseconds (instead of seconds)."
            }
          }
        },
        %{
          type: :object,
          title: "coordinate",
          properties: %{
            format: %{
              const: "coordinate",
              description: "Use to display latitude & longitude information."
            },
            radius_display: %{
              type: :boolean,
              default: true,
              description:
                "Whether the formatter should include the radius/accuracy information (if present)."
            }
          }
        }
      ]
    }
  end
end

defmodule ValueFormatters.Schemas.DefaultFormats do
  def json_schema() do
    %{
      type: :object,
      description: "Default formats for value formatting",
      properties: %{
        number: %{
          type: :object,
          description:
            "Use  to display numeric values and format them according to the user's locale.",
          properties: %{
            precision: %{type: :number, description: "Number of decimal places"},
            unit: %{
              type: :string,
              description: "If set, the formatter appends ' ' + unit to the display value"
            }
          }
        },
        string: %{
          type: :object,
          description:
            "Use to explicitly disable any kind of formatting that would otherwise take place.",
          properties: %{}
        },
        date: %{
          type: :object,
          description:
            "Use to to display date-time values and format them according to the user's locale.",
          properties: %{
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
        },
        date_relative: %{
          type: :object,
          description: """
          Use format: "date_relative" to display a relative date string (e.g. “2 days ago”) by comparing the given value against the current date & time. Only the largest sensible unit is displayed, e.g. the formatter will only display “days” even when other components such as hours, minutes etc. aren't equal to zero.

          The implementation can choose to update the displayed value in appropriate intervals. Also, it can choose to display the absolute date on user interaction, e.g. in a tooltip.

          This format currently doesn't support any options.
          """,
          properties: %{}
        },
        date_iso: %{
          type: :object,
          description: "Use to display date-time values in ISO 8601 extended format.",
          properties: %{}
        },
        date_unix: %{
          type: :object,
          description: "Use to display date-time values in seconds since unix epoch.",
          properties: %{
            milliseconds: %{
              type: :boolean,
              default: false,
              description:
                "Whether the formatter should output the values milliseconds (instead of seconds)."
            }
          }
        },
        coordinates: %{
          type: :object,
          description: "Use to display latitude & longitude information.",
          properties: %{
            radius_display: %{
              type: :boolean,
              default: true,
              description:
                "Whether the formatter should include the radius/accuracy information (if present)."
            }
          }
        }
      }
    }
  end
end
