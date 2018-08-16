defmodule Reading.InputHandler do

    alias Interp.Globals
    alias Interp.Functions
    require Interp.Functions

    def parse_string(string, delimiter), do: parse_string(string, delimiter, "")
    defp parse_string([], _, parsed), do: :eof
    defp parse_string(["\\", "\\" | remaining], delimiter, parsed), do: parse_string(remaining, delimiter, parsed <> "\\")
    defp parse_string(["\\", delimiter | remaining], delimiter, parsed), do: parse_string(remaining, delimiter, parsed <> delimiter)
    defp parse_string([delimiter | remaining], delimiter, parsed), do: {parsed, remaining}
    defp parse_string([head | remaining], delimiter, parsed), do: parse_string(remaining, delimiter, parsed <> head)

    def parse_number(chars), do: parse_number(chars, "")
    defp parse_number([num | remaining], parsed) when num in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"], do: parse_number(remaining, parsed <> num)
    defp parse_number(remaining, parsed), do: {Integer.parse(parsed), remaining}

    def parse_separator([" " | remaining]), do: parse_separator(remaining)
    def parse_separator(["," | remaining]), do: {:cont, remaining}
    def parse_separator(["]" | remaining]), do: {:done, remaining}

    def parse_list(["[" | remaining]) do
        {list, _} = parse_list(remaining, [])
        list
    end
    defp parse_list(chars, parsed) do
        case chars do
            {:cont, remaining} -> parse_list(remaining, parsed)
            {:done, remaining} -> {parsed |> Enum.reverse, remaining}
            [delimiter | remaining] when delimiter in ["\"", "'"] ->
                {new, remaining} = parse_string(remaining, delimiter)
                parse_list(parse_separator(remaining), [new | parsed])
            [number | remaining] when number in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"] ->
                {{new, _}, remaining} = parse_number(chars)
                parse_list(parse_separator(remaining), [new | parsed])
            ["[" | remaining] ->
                {new, remaining} = parse_list(remaining, [])
                parse_list(parse_separator(remaining), [new | parsed])
            [" " | remaining] ->
                parse_list(remaining, parsed)
        end
    end

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
                result = parse_list(String.graphemes(input))
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
end