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
        Globals.initialize()
        Globals.set(%{Globals.get() | debug: %{Globals.get().debug | test: true}})
        
        parsed_code = Parser.parse(Reader.read(code))
        {stack, environment} = Interpreter.interp(parsed_code, %Stack{}, %Environment{})
        {result, _, _} = Stack.pop(stack, environment)

        final = Functions.eval(result)
        Globals.set(%GlobalEnvironment{})
        final
    end

    def evaluate_canvas(code) do
        Globals.initialize()
        Globals.set(%{Globals.get() | debug: %{Globals.get().debug | test: true}})
        
        parsed_code = Parser.parse(Reader.read(code))
        Interpreter.interp(parsed_code, %Stack{}, %Environment{})
        
        final = Canvas.canvas_to_string(Globals.get().canvas)
        Globals.set(%GlobalEnvironment{})
        final
    end

    def temporary_file, do: "test-file.abe"
    def clean_up_file, do: (if File.exists?(temporary_file()) do File.rm(temporary_file()) end)
    def file_test(test_function) do
        try do
            test_function.(temporary_file())
        after
            clean_up_file()
        end
    end
end