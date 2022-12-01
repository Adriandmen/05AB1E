defmodule Reading.InputHandler do

    alias Interp.Globals

    defp parse_multiline_string(chars) do
        cond do
            String.ends_with?(chars, "\"\"\"") -> String.slice(chars, 0..-4)
            true -> chars <> "\n" <> parse_multiline_string(String.trim_trailing(IO.read(:stdio, :line), "\n"))
            :eof -> ""
        end
    end

    def read_input() do 
        input = case IO.read(:stdio, :line) do
            :eof -> :eof
            x -> String.trim_trailing(x, "\n")
        end

        cond do
            input == :eof and Globals.get().inputs == [] -> nil
            input == :eof -> 
                List.last Globals.get().inputs
            String.starts_with?(input, "[") and String.ends_with?(input, "]") ->
                {result, _} = Code.eval_string(input)
                global_env = Globals.get()
                Globals.set(%{global_env | inputs: global_env.inputs ++ [result]})
                result
            String.starts_with?(input, "\"\"\"") ->
                result = parse_multiline_string(String.slice(input, 3..-1))
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

    def read_until_eof() do
        result = read_until_eof([]) |> Enum.reverse
        global_env = Globals.get()
        Globals.set(%{global_env | inputs: global_env.inputs ++ [result]})
        result
    end

    defp read_until_eof(acc) do
        input = IO.read(:stdio, :line)
        cond do
            input == :eof -> acc
            input == "\n" -> read_until_eof(["" | acc])
            true -> read_until_eof([String.trim_trailing(input, "\n") | acc])
        end
    end
end
