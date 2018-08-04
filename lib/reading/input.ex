defmodule Reading.InputHandler do
    alias Interp.Environment
    alias Interp.Globals

    def read_input do
        input = IO.read(:stdio, :line)

        input = cond do
            input == :eof -> input
            String.ends_with?(input, "\n") -> String.slice(input, 0..-2)
            true -> input
        end

        cond do
            input == :eof and Globals.get().inputs == [] -> nil
            input == :eof -> 
                [head | _] = Globals.get().inputs
                head
            Regex.match?(~r/^\[.+\]/, input) ->
                {result, _} = Code.eval_string(to_string(input)) 
                result = result |> Stream.map(fn x -> x end)
                global_env = Globals.get()
                Globals.set(%{global_env | inputs: global_env.inputs ++ [result]})
                result
            true ->
                result = to_string(input)
                global_env = Globals.get()
                Globals.set(%{global_env | inputs: global_env.inputs ++ [result]})
                result
        end
    end
end