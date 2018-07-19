defmodule Commands.StrCommands do
    alias Interp.Functions

    def insert_at(a, b, c) when is_map(a) and is_map(b) and is_map(c) do
        pairs = Enum.to_list Stream.zip([b, c])
        Enum.each(pairs, fn {element, location} -> a = Stream.concat([Stream.take(a, Functions.to_number(location)), [element], Stream.drop(a, Functions.to_number(location) + 1)]) end)
        a
    end

    def insert_at(a, b, c) when is_map(a) and is_map(c) do
        args = Enum.to_list(c)
        Enum.each(args, fn location -> a = Stream.concat([Stream.take(a, Functions.to_number(location)), [b], Stream.drop(a, Functions.to_number(location) + 1)]) end)
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
end