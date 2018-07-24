defmodule Commands.ListCommands do
    alias Interp.Functions
    alias Commands.GeneralCommands
    require Interp.Functions
    
    def prefixes(a) do
        case a do
            _ when Functions.is_iterable(a) ->
                a |> Stream.scan([], fn (x, y) -> y ++ [x] end) |> Functions.stream
            _ ->
                String.to_charlist(to_string(a)) |> Stream.scan([], fn (x, y) -> y ++ [x] end) |> Stream.map(fn x -> to_string(x) end)
        end
    end

    def suffixes(a) do
        cond do
            Functions.is_iterable(a) -> a |> Enum.reverse |> prefixes |> Stream.map(fn x -> x |> Enum.reverse end)
            true -> String.graphemes(to_string(a)) |> Enum.reverse |> prefixes |> Stream.map(fn x -> x |> Enum.reverse |> Enum.join("") end)
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

    def rangify(a) do
        case Stream.take(a, 1) |> Enum.to_list |> List.first do
            nil -> []
            first -> 
                a |> Stream.transform(nil, fn (element, acc) -> 
                    case acc do
                        nil -> {[element], element}
                        x when element == x -> {[element], element}
                        x when element > x -> {acc + 1..element, element}
                        x when element < x -> {acc - 1..element, element}
                    end
                end)
                  |> Stream.map(fn x -> x end)
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
            Functions.is_iterable(value) -> Stream.transform(counts, value, fn (x, acc) -> {[Stream.take(acc, Functions.to_number(x))], Stream.drop(acc, Functions.to_number(x))} end) 
                                            |> Stream.map(fn x -> x end)
            true -> take_split(String.to_charlist(value), counts) |> Stream.map(fn x -> List.to_string(Enum.to_list(x)) end)
        end
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

    def reduce_subtraction(value) do
        case Enum.take(value, 1) do
            [] -> 0
            x when Functions.is_iterable(hd(x)) -> value |> Stream.map(fn x -> reduce_subtraction(x) end)
            _ -> value |> Functions.to_number |> Enum.reduce(fn (x, acc) -> acc - x end)
        end
    end

    def product(value) do
        case Enum.take(value, 1) do
            [] -> 1
            x when Functions.is_iterable(hd(x)) -> value |> Stream.map(fn x -> product(x) end)
            _ -> value |> Enum.reduce(1, fn (x, acc) -> acc * Functions.to_number(x) end)
        end
    end

    def join(value, joiner) do
        case Enum.take(value, 1) do
            [] -> ""
            x when Functions.is_iterable(hd(x)) -> value |> Stream.map(fn x -> join(x, joiner) end)
            _ -> Enum.to_list(value) |> Enum.join(joiner)
        end
    end

    def contains(value, element) do
        cond do
            Functions.is_iterable(value) -> Enum.find(value, fn x -> GeneralCommands.equals(x, element) end) != nil
            true -> String.contains?(to_string(value), to_string(element))
        end
    end

    def remove_from(value, filter_elements, inner) do
        cond do
            Functions.is_iterable(value) and Functions.is_iterable(filter_elements) -> value |> Stream.filter(fn x -> contains(filter_elements, x) end)
            inner == true -> Enum.reduce(Functions.to_non_number(value), fn (x, acc) -> Enum.replace(acc, Functions.to_non_number(x), "") end)
            Functions.is_iterable(filter_elements) -> remove_from(value, filter_elements, true)
            Functions.is_iterable(value) -> filter_elements |> Stream.filter(fn x -> contains(filter_elements, x) end)
            true -> String.replace(to_string(value), to_string(filter_elements), "")
        end
    end

    def split_into(value, size) do
        cond do
            Functions.is_iterable(value) -> value |> Stream.chunk_every(size)
            true -> to_charlist(to_string(value)) |> Stream.chunk_every(size) |> Stream.map(&to_string/1)
        end
    end

    def split_on(value, split) do
        split_chars = cond do
            Functions.is_iterable(split) -> Enum.to_list split
            true -> [to_string(split)]
        end

        cond do
            Functions.is_iterable(value) ->
                value |> Stream.chunk_while([],
                    fn (x, acc) -> if contains(split_chars, x) do {:cont, Enum.reverse(acc), []} else {:cont, [x | acc]} end end,
                    fn [] -> {:cont, []}; acc -> {:cont, Enum.reverse(acc), []} end)
            true ->
                String.split(to_string(value), split_chars)
        end
    end

    def index_in(value, element) do
        cond do
            Functions.is_iterable(value) -> 
                case value |> Enum.to_list |> Enum.find_index(fn x -> GeneralCommands.equals(x, element) end) do
                    nil -> -1
                    x -> x
                end
            true -> index_in(String.graphemes(to_string(value)), element)
        end
    end

    def lift(value) do
        cond do
            Functions.is_iterable(value) -> value |> Stream.with_index(1) |> Stream.map(fn {x, index} -> Functions.call_binary(fn a, b -> 
                Functions.to_number(a) * Functions.to_number(b) end, x, index) end)
            true -> lift(String.graphemes(to_string(value)))
        end
    end

    def zip(a) do
        Stream.zip(a) |> Stream.map(fn x -> Tuple.to_list x end)
    end

    def zip(a, b) do
        cond do
            Functions.is_iterable(a) and Functions.is_iterable(b) -> Stream.zip(a, b) |> Stream.map(fn x -> Tuple.to_list x end)
            Functions.is_iterable(a) -> Stream.zip(a, String.graphemes(to_string(b))) |> Stream.map(fn x -> Tuple.to_list x end)
            Functions.is_iterable(b) -> Stream.zip(String.graphemes(to_string(a)), b) |> Stream.map(fn x -> Tuple.to_list x end)
            true -> Stream.zip(String.graphemes(to_string(a)), String.graphemes(to_string(b))) |> Stream.map(fn x -> Enum.join(Tuple.to_list(x), "") end)
        end
    end

    @docs """
    Zip with filler for a single list. Zipping is done internally within the first given argument and
    fills the remaining spaces with the given filler character. Since Elixir does not have a zip with filler
    function, this is done using a resource generator for a new stream, repeatedly taking the first element of
    the given list of lists and dropping one element for the next iteration. It checks each iteration whether
    at least one element of the intermediate results is not equal to [] and replaces any occurence of [] with
    the filler element. If all elements of the intermediate result equals [], it halts the stream generation.

    ## Parameters

     - a:       The element that will be zipped. Assuming that this element is a list of lists.
     - filler:  The filler character, which can be of any type.

    """
    def zip_with_filler(a, filler) do
        Stream.resource(
            # Initialize the accumulator with the given list of lists.
            fn -> a end,

            # With the intermediate accumulator as a parameter..
            fn acc ->

                # Take the first element of each sublist.
                elements = acc |> Stream.map(fn n -> n |> Stream.take(1) |> Enum.to_list end)

                # Check if there exists at least one element that does not equal []. If all elements equal [], 
                # we would now know that the zipping is done.
                if Enum.any?(elements, fn n -> n != [] end) do
                    {[elements |> Stream.flat_map(fn n -> if n == [] do [filler] else n end end) |> Stream.map(fn x -> x end)], acc |> Stream.map(fn n -> n |> Stream.drop(1) end)}
                else
                    {:halt, nil}
                end
            end,
            fn acc -> nil end)
            |> Stream.map(fn x -> x end)
    end

    def zip_with_filler(a, b, filler) do
        a = cond do
            Functions.is_iterable(a) -> a
            true -> String.graphemes(to_string(a))
        end

        b = cond do
            Functions.is_iterable(b) -> b
            true -> String.graphemes(to_string(b))
        end

        Stream.resource(
            # Initialize the accumulator with the given list of lists.
            fn -> {a, b} end,

            # With the intermediate accumulator as a parameter..
            fn {left, right} ->

                # Take the first element of each sublist.
                elements = [left |> Stream.take(1) |> Enum.to_list, right |> Stream.take(1) |> Enum.to_list]

                # Check if there exists at least one element that does not equal []. If all elements equal [], 
                # we would now know that the zipping is done.
                if Enum.any?(elements, fn n -> n != [] end) do
                    {[elements |> Stream.flat_map(fn n -> if n == [] do [filler] else n end end) |> Stream.map(fn x -> x end)], {left |> Stream.drop(1), right |> Stream.drop(1)}}
                else
                    {:halt, nil}
                end
            end,
            fn acc -> nil end)
            |> Stream.map(fn x -> x end)
    end

    def deep_flatten(list) do
        list |> Stream.flat_map(fn x -> if Functions.is_iterable(x) do deep_flatten(x) else [x] end end)
             |> Stream.map(fn x -> x end)
    end

    def substrings(list) do
        list |> suffixes |> Enum.reverse |> Stream.flat_map(fn y -> prefixes(y) end) |> Stream.map(fn x -> x end)
    end

    def group_equal(list) do
        cond do
            Functions.is_iterable(list) -> Stream.chunk_while(list, {[], nil}, 
                                            fn (x, {acc, last}) -> if GeneralCommands.equals(x, last) do {:cont, [x | acc], {[], nil}} else {:cont, {[x | acc], x}} end end,
                                            fn ({acc, _}) -> case acc do [] -> {:cont, []}; acc -> {:cont, acc, []} end end)
            true -> String.graphemes(to_string(list)) |> group_equal |> Stream.map(fn x -> x |> Enum.join("") end)
        end
    end

    def keep_with_length(list, length) do
        cond do
            Functions.is_iterable(list) -> list |> Stream.filter(fn x -> GeneralCommands.length_of(x) == length end)
            true -> []
        end
    end
end