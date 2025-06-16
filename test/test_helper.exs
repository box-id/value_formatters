ExUnit.start()

defmodule CldrBehavior do
  @callback to_string(arg :: any, opts :: any) :: any
end

Mox.defmock(MockedCldr.Number, for: CldrBehavior)
Mox.defmock(MockedCldr.Date, for: CldrBehavior)
Mox.defmock(MockedCldr.Time, for: CldrBehavior)
Mox.defmock(MockedCldr.DateTime, for: CldrBehavior)
Mox.defmock(MockedCldr.DateTime.Relative, for: CldrBehavior)
