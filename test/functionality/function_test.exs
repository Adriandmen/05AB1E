defmodule FunctionTest do
    use ExUnit.Case
    alias Interp.Functions
    alias Interp.Globals

    test "to number conversion" do
        assert Functions.to_number("4") == 4
        assert Functions.to_number(4) == 4
        assert Functions.to_number(4.5) == 4.5
        assert Functions.to_number("4.5") == 4.5
        assert Functions.to_number("-4.5") == -4.5
        assert Functions.to_number("-0.5") == -0.5
        assert Functions.to_number(".5") == 0.5
        assert Functions.to_number("-.5") == -0.5
        assert Functions.to_number([1, "2", [3, "4.5"]]) |> Functions.eval == [1, 2, [3, 4.5]]
        assert Functions.to_number("a") == "a"
        assert Functions.to_number("4.a") == "4.a"
    end

    test "to non number conversion" do
        assert Functions.to_non_number(-4) == "-4"
        assert Functions.to_non_number(4.5) == "4.5"
        assert Functions.to_non_number([-4, -4.5, [5, 6]]) |> Functions.eval == ["-4", "-4.5", ["5", "6"]]
    end

    test "retrieve non initialized global environment" do
        assert_raise(RuntimeError, fn -> Globals.get() end)
        assert_raise(RuntimeError, fn -> Globals.set(%{}) end)
    end
end