defmodule TernaryTest do
    use ExUnit.Case
    alias Reading.Reader
    alias Parsing.Parser
    alias Interp.Interpreter
    alias Interp.Stack
    alias Interp.Environment
    alias Interp.Functions

    def evaluate(code) do
        code = Parser.parse(Reader.read(code))
        {stack, environment} = Interpreter.interp(code, %Stack{}, %Environment{})
        {result, _, _} = Stack.pop(stack, environment)

        assert is_map(result) or is_number(result) or is_bitstring(result) or is_list(result)

        Functions.eval(result)
    end

    test "three swap" do
        assert evaluate("1 2 3Š)") == ["3", "1", "2"]
    end
end