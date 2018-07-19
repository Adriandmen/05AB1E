defmodule SpecialOpsTest do
    use ExUnit.Case
    alias Reading.Reader
    alias Interp.Interpreter
    alias Interp.Stack
    alias Interp.Environment
    alias Interp.Functions

    def evaluate(code) do
        code = Reader.read(code)
        {stack, environment} = Interpreter.interp(code, %Stack{}, %Environment{})
        {result, _, _} = Stack.pop(stack, environment)

        assert is_map(result) or is_number(result) or is_bitstring(result) or is_list(result)

        Functions.eval(result)
    end

    test "wrap stack into array" do
        assert evaluate("1 2 3)") == ["1", "2", "3"]
    end

    test "reverse stack" do
        assert evaluate("1 2) 3r)ï") == [3, [1, 2]]
    end

    test "copy paste" do
        assert evaluate("1© 2®") == "1"
        assert evaluate("1© 2)") == ["1", "2"]
        assert evaluate("1© 2®)") == ["1", "2", "1"]
    end
end