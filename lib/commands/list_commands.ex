defmodule Commands.ListCommands do
    alias Interp.Functions
    require Interp.Functions
    
    def prefixes(a) do
        case a do
            _ when is_map(a) ->
                a |> Stream.scan([], fn (x, y) -> y ++ [x] end) |> Functions.stream
            _ ->
                String.to_charlist(a) |> Stream.scan([], fn (x, y) -> y ++ [x] end) |> Stream.map(fn x -> to_string(x) end)
        end
    end

    def listify(a, b) do
        cond do
            a == :infinity ->
                throw("Invalid head value for list. Value cannot be infinity.")
            b == :infinity ->
                Stream.scan(Stream.cycle([1]), fn (_, y) -> y + 1 end)
            true ->
                a..b
        end
    end

    def split_individual(value) do
        cond do
            is_integer(value) -> split_individual(to_string(value))
            is_map(value) or is_list(value) -> value |> Stream.flat_map(&split_individual/1) |> Stream.map(fn x -> x end)
            true -> String.graphemes(value)
        end
    end

    def take_first(value, count) do
        cond do
            Functions.is_iterable(count) -> take_split(value, count)
            Functions.is_iterable(value) -> Stream.take(value, Functions.to_number(count))
            true -> String.slice(to_string(value), 0..count - 1)
        end
    end


    defp take_split(value, counts) do
        cond do
            Functions.is_iterable(value) -> take_split(value, counts, [])
            true -> take_split(String.to_charlist(value), counts, []) |> Stream.map(fn x -> List.to_string(Enum.to_list(x)) end)
        end
    end

    defp take_split(value, counts, acc) do
        Stream.transform(counts, value, fn (x, acc) -> {[Stream.take(acc, Functions.to_number(x))], Stream.drop(acc, Functions.to_number(x))} end) |> Stream.map(fn x -> x end)
    end

    def enumerate(value) do
        cond do
            Functions.is_iterable(value) -> value |> Stream.with_index(1) |> Stream.map(fn {_, index} -> index end)
            true -> 1..String.length(to_string(value))
        end
    end

    def deltas(value) do
        cond do
            Functions.is_iterable(value) -> Stream.chunk_every(value, 2, 1, :discard) |> Stream.map(fn [x, y] -> Functions.to_number(y) - Functions.to_number(x) end)
            true -> deltas(String.graphemes(value))
        end
    end

    def sum(value) do
        case Enum.take(value, 1) do
            [] -> 0
            x when Functions.is_iterable(hd(x)) -> value |> Stream.map(fn x -> sum(x) end)
            _ -> value |> Enum.reduce(0, fn (x, acc) -> acc + Functions.to_number(x) end)
        end
    end

    def product(value) do
        case Enum.take(value, 1) do
            [] -> 1
            _ when Functions.is_iterable(hd(value)) -> value |> Stream.map(fn x -> product(x) end)
            _ -> value |> Enum.reduce(1, fn (x, acc) -> acc * Functions.to_number(x) end)
        end
    end
end