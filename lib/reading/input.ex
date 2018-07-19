defmodule Reading.InputHandler do
    alias Interp.Environment

    def read_input(%Environment{inputs: list}) do
        input = IO.read(:stdio, :line)

        input = cond do
            input == :eof -> input
            String.ends_with?(input, "\n") -> String.slice(input, 0..-2)
            true -> input
        end

        cond do
            input == :eof -> 
                [head | _] = list
                {head, %Environment{inputs: list}}
            Regex.match?(~r/^\[.+\]/, input) ->
                {result, _} = Code.eval_string(to_string(input)) 
                result = result |> Stream.map(fn x -> x end)
                {result, %Environment{inputs: list ++ [result]}}
            true ->
                result = to_string(input)
                {result, %Environment{inputs: list ++ [result]}}
        end
    end
end