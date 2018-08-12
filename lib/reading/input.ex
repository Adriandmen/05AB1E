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
                List.last Globals.get().inputs
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

    def read_until_newline() do
        result = read_until_newline([]) |> Enum.reverse
        global_env = Globals.get()
        Globals.set(%{global_env | inputs: global_env.inputs ++ [result]})
        result
    end

    defp read_until_newline(acc) do
        input = IO.read(:stdio, :line)
        cond do
            input == :eof -> acc
            input == "\n" -> acc
            true -> read_until_newline([String.trim_trailing(input, "\n") | acc])
        end
    end
end