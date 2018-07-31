ExUnit.start()

defmodule TestHelper do
    use ExUnit.Case
    alias Parsing.Parser
    alias Reading.Reader
    alias Interp.Interpreter
    alias Interp.Stack
    alias Interp.Environment
    alias Interp.Functions
    alias Interp.Globals
    alias Interp.GlobalEnvironment
    alias Interp.Canvas

    def evaluate(code) do
        parsed_code = Parser.parse(Reader.read(code))
        {stack, _} = Interpreter.interp(parsed_code, %Stack{}, %Environment{})
        {result, _} = Stack.pop(stack)

        assert is_map(result) or is_number(result) or is_bitstring(result) or is_list(result)

        final = Functions.eval(result)
        Globals.set(%GlobalEnvironment{})
        final
    end

    def evaluate_canvas(code) do
        parsed_code = Parser.parse(Reader.read(code))
        Interpreter.interp(parsed_code, %Stack{}, %Environment{})
        
        final = Canvas.canvas_to_string(Globals.get().canvas)
        Globals.set(%GlobalEnvironment{})
        final
    end
end