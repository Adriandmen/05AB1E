defmodule StackTest do
    use ExUnit.Case
    import ExUnit.CaptureIO
    import TestHelper

    test "pop from normal non-empty stack" do
        assert capture_io(fn -> evaluate("2ï 3ï 4ï,") end) == "4\n"
    end

    test "pop from empty stack with history" do
        assert capture_io([input: ""], fn -> evaluate("2ï 3ï,,,") end) == "3\n2\n2\n"
    end

    test "pop from empty stack with input" do
        assert capture_io([input: "1"], fn -> evaluate("2ï 3ï,,,,") end) == "3\n2\n1\n1\n"
    end
end