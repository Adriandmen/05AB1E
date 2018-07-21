defmodule Commands.StrCommands do
    alias Interp.Functions

    def insert_at(a, b, c) when is_map(a) and is_map(b) and is_map(c) do
        pairs = Enum.to_list Stream.zip([b, c])
        Enum.each(pairs, fn {element, location} -> Stream.concat([Stream.take(a, Functions.to_number(location)), [element], Stream.drop(a, Functions.to_number(location) + 1)]) end)
        a
    end

    def insert_at(a, b, c) when is_map(a) and is_map(c) do
        args = Enum.to_list(c)
        Enum.each(args, fn location -> Stream.concat([Stream.take(a, Functions.to_number(location)), [b], Stream.drop(a, Functions.to_number(location) + 1)]) end)
        a
    end

    def insert_at(a, b, c) when is_map(a) do
        Stream.concat([Stream.take(a, Functions.to_number(c)), [b], Stream.drop(a, Functions.to_number(c) + 1)])
    end

    def insert_at(a, b, c) when is_map(b) and is_map(c) do
        curr_element = String.to_charlist(a)
        pairs = Enum.to_list Stream.zip([b, c])
        List.to_string Enum.reduce(pairs, curr_element, fn ({element, location}, acc) -> List.replace_at(acc, Functions.to_number(location), Functions.to_non_number(element)) end)
    end

    def insert_at(a, b, c) when is_map(c) do
        args = Enum.to_list(c)
        curr_element = String.to_charlist(a)
        List.to_string Enum.reduce(args, curr_element, fn (location, acc) -> List.replace_at(acc, Functions.to_number(location), Functions.to_non_number(b)) end)
    end

    def insert_at(a, b, c) do
        List.to_string List.replace_at(String.to_charlist(a), Functions.to_number(c), Functions.to_non_number(b))
    end

    def title_case(string), do: title_case(string, "")
    defp title_case("", parsed), do: parsed
    defp title_case(string, parsed) do
        cond do
            Regex.match?(~r/^[a-zA-Z]/, string) ->
                matches = Regex.named_captures(~r/^(?<string>[a-zA-Z]+)(?<remaining>.*)/, string)
                title_case(matches["remaining"], parsed <> String.capitalize(matches["string"]))
            true ->
                matches = Regex.named_captures(~r/^(?<string>[^a-zA-Z]+)(?<remaining>.*)/, string)
                title_case(matches["remaining"], parsed <> matches["string"])
        end
    end

    def switch_case(string), do: switch_case(String.graphemes(string), []) |> Enum.join("")
    defp switch_case([], parsed), do: parsed |> Enum.reverse
    defp switch_case([char | remaining], parsed) do
        cond do
            Regex.match?(~r/^[a-z]$/, char) -> switch_case(remaining, [String.upcase(char) | parsed])
            Regex.match?(~r/^[A-Z]$/, char) -> switch_case(remaining, [String.downcase(char) | parsed])
            true -> switch_case(remaining, [char | parsed])
        end
    end

    def sentence_case(string), do: sentence_case(string, "")
    defp sentence_case("", parsed), do: parsed
    defp sentence_case(string, parsed) do
        cond do
            Regex.match?(~r/^[a-zA-Z]/, string) ->
                matches = Regex.named_captures(~r/^(?<string>[a-zA-Z].+?)(?<remaining>(\.|!|\?|$).*)/, string)
                sentence_case(matches["remaining"], parsed <> String.capitalize(String.slice(matches["string"], 0..0)) <> String.slice(matches["string"], 1..-1))
            true ->
                matches = Regex.named_captures(~r/^(?<string>.)(?<remaining>.*)/, string)
                sentence_case(matches["remaining"], parsed <> matches["string"])
        end
    end

    def keep_letters(string) when is_bitstring(string), do: keep_letters(String.graphemes(string)) |> Enum.join("")
    def keep_letters(list) do
        list |> Stream.filter(fn x -> Regex.match?(~r/^[A-Za-z]+$/, to_string(x)) end)
    end

    def keep_digits(string) when is_bitstring(string), do: keep_digits(String.graphemes(string)) |> Enum.join("")
    def keep_digits(list) do
        list |> Stream.filter(fn x -> Regex.match?(~r/^[0-9]+$/, to_string(x)) end)
    end
end