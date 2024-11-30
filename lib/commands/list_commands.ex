defmodule Commands.ListCommands do
    alias Interp.Functions
    alias Interp.Interpreter
    alias Commands.IntCommands
    alias Commands.GeneralCommands
    alias Commands.MatrixCommands
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
                Stream.scan(Stream.cycle([a]), fn (_, y) -> y + 1 end)
            true ->
                a..b
        end
    end

    def rangify(a) do
        case Stream.take(a, 1) |> Enum.to_list |> List.first do
            nil -> []
            _ -> 
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
            Functions.is_iterable(value) -> value |> Stream.flat_map(&split_individual/1) |> Stream.map(fn x -> x end)
            true -> String.graphemes(value)
        end
    end

    def permute_by_function([], _, _), do: [[]]
    def permute_by_function([head | remaining], commands, environment) do
        for sub <- permute_by_function(remaining, commands, environment), curr <- [head, Interpreter.flat_interp(commands, [head], environment)] do
            [curr] ++ sub
        end
    end

    def take_first(value, count) do
        cond do
            count == 0 and Functions.is_iterable(value) -> []
            count == 0 -> ""
            is_number(value) -> take_first(to_string(value), count)
            Functions.is_iterable(count) -> take_split(value, count)
            Functions.is_iterable(value) and count < 0 -> Stream.take(value, length(Enum.to_list(value)) + count) |> Stream.map(fn x -> x end)
            Functions.is_iterable(value) -> Stream.take(value, Functions.to_number(count)) |> Stream.map(fn x -> x end)
            true -> String.slice(to_string(value), 0..count - 1//1)
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
            true -> deltas(String.graphemes(to_string(value)))
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

    def join(value, _) when not Functions.is_iterable(value), do: to_string(value)
    def join(value, joiner) do
        cond do
            Enum.take(value, 1) == [] -> ""
            value |> Enum.any?(fn x -> Functions.is_iterable(x) end) -> value |> Stream.map(fn x -> x |> join(joiner) end)
            true -> value |> Enum.to_list |> Enum.map(&Functions.flat_string/1) |> Enum.join(joiner)
        end
    end
    
    def grid_join(list) do
        list |> Stream.map(fn x -> 
            if Functions.is_iterable(x) do 
                x |> Enum.to_list |> Enum.map(&Functions.flat_string/1) |> Enum.join(" ") 
            else 
                x 
            end 
        end) |> Enum.to_list |> Enum.join("\n")
    end

    def contains(value, element) do
        cond do
            Functions.is_iterable(value) -> Enum.find(value, fn x -> GeneralCommands.equals(x, element) end) != nil
            true -> String.contains?(to_string(value), to_string(element))
        end
    end

    def take_last(value, count) when Functions.is_iterable(value), do: value |> Stream.take(-count) |> Stream.map(fn x -> x end)
    def take_last(value, count), do: Enum.join(take_last(String.graphemes(to_string(value)), count), "")

    def drop_from(value, count) when Functions.is_iterable(value), do: value |> Stream.drop(count)
    def drop_from(value, count), do: Enum.join(drop_from(String.graphemes(to_string(value)), count), "")

    def surround(value, element) when Functions.is_iterable(value) and Functions.is_iterable(element), do: Stream.concat([element, value, element]) |> Stream.map(fn x -> x end)
    def surround(value, element) when Functions.is_iterable(value), do: Stream.concat([[element], value, [element]]) |> Stream.map(fn x -> x end)
    def surround(value, element) when Functions.is_iterable(element), do: Stream.concat([element, String.graphemes(to_string(value)), element]) |> Stream.map(fn x -> x end)
    def surround(value, element), do: to_string(element) <> to_string(value) <> to_string(element)

    def undelta(value) when Functions.is_iterable(value), do: Stream.concat([[0], value]) |> Stream.scan(fn (x, acc) -> Functions.to_number(x) + acc end)
    def undelta(value), do: undelta(String.graphemes(to_string(value)))

    def remove_from(value, filter_elements) do
        cond do
            Functions.is_iterable(value) and Functions.is_iterable(filter_elements) -> value |> Stream.filter(fn x -> !contains(filter_elements, x) end)
            Functions.is_iterable(value) -> value |> Stream.filter(fn x -> !GeneralCommands.equals(filter_elements, x) end)
            Functions.is_iterable(filter_elements) -> Enum.reduce(filter_elements, to_string(value), fn (x, acc) -> String.replace(acc, to_string(x), "") end)
            true -> remove_from(value, [filter_elements])
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

    def flat_index_in_list(list, element) when not Functions.is_iterable(element), do: flat_index_in_list(list, String.graphemes(to_string(element)))
    def flat_index_in_list(list, element) when not Functions.is_iterable(list), do: flat_index_in_list(String.graphemes(to_string(list)), element)
    def flat_index_in_list(list, element), do: flat_index_in_list(list, Enum.to_list(element), 0)
    defp flat_index_in_list(list, element, index) do
        curr_head = Stream.take(list, length(element)) |> Enum.to_list
        cond do
            length(curr_head) < length(element) -> -1
            GeneralCommands.equals(curr_head, element) -> index
            true -> flat_index_in_list(Stream.drop(list, 1), element, index + 1)
        end
    end

    def list_multiply(value, len) do
        cond do
            Functions.is_iterable(value) -> value |> Stream.cycle |> Stream.take(length(Enum.to_list(value)) * len)
            true -> Stream.cycle([value]) |> Stream.take(len)
        end
    end

    def closest_to(value, element) when Functions.is_iterable(value), do: closest_to(Functions.to_number(value), Functions.to_number(element), nil, nil)
    def closest_to(value, element), do: closest_to(Functions.to_number(String.graphemes(to_string(value))), Functions.to_number(element), nil, nil)
    def closest_to(value, element, acc, min_distance) do
        head = Enum.take(value, 1) |> Enum.to_list |> List.first
        cond do
            head == nil and acc == nil -> []
            head == nil -> acc
            abs(element - head) < min_distance -> closest_to(Enum.drop(value, 1), element, head, abs(element - head))
            true -> closest_to(Enum.drop(value, 1), element, acc, min_distance)
        end
    end

    def extract_every(value, n) do
        cond do
            Functions.is_iterable(value) -> 0..n - 1 |> Stream.map(fn x -> value |> Stream.drop(x) |> Stream.take_every(n) end)
            true -> extract_every(String.graphemes(to_string(value)), n) |> Stream.map(fn x -> Enum.join(Enum.to_list(x), "") end)
        end
    end

    def uniques(value) do
        cond do
            Functions.is_iterable(value) -> value |> Stream.transform([], fn (x, acc) -> if contains(acc, x) do {[], acc} else {[x], [x | acc]} end end) |> Stream.map(fn x -> x end)
            true -> Enum.join(uniques(String.graphemes(to_string(value))))
        end
    end

    def filter_to_front(value, filter_chars) do
        cond do
            Functions.is_iterable(value) and Functions.is_iterable(filter_chars) -> value |> Enum.sort_by(fn x -> not contains(filter_chars, x) end)
            Functions.is_iterable(value) -> value |> Enum.sort_by(fn x -> not GeneralCommands.equals(x, filter_chars) end)
            true -> filter_to_front(String.graphemes(to_string(value)), filter_chars) |> Enum.join("")
        end
    end

    def keep_truthy_indices(value, indices) when is_bitstring(value), do: Enum.join(keep_truthy_indices(String.graphemes(to_string(value)), indices))
    def keep_truthy_indices(value, indices) when is_bitstring(indices), do: keep_truthy_indices(value, String.graphemes(to_string(indices)))
    def keep_truthy_indices(value, indices) do
        Stream.zip(value, indices) |> Stream.filter(fn {_, index} -> GeneralCommands.equals(index, 1) end) |> Stream.map(fn {element, _} -> element end)
    end

    def deduplicate(string) when is_bitstring(string) or is_number(string), do: Enum.join(deduplicate(String.graphemes(to_string(string))), "")
    def deduplicate(list) do
        list |> Stream.transform(nil, fn (x, acc) -> if GeneralCommands.equals(x, acc) do {[], acc} else {[x], x} end end) |> Stream.map(fn x -> x end)
    end

    def index_in(value, element) when Functions.is_single?(value) do
        case String.split(to_string(value), to_string(element), parts: 2) do
            [left, _] -> String.length(left)
            [_] -> -1
        end
    end
    def index_in(value, element) when Functions.is_iterable(value) do
        case first_where(value |> Stream.with_index, fn {x, _} -> GeneralCommands.equals(x, element) end) do
            nil -> -1
            {_, index} -> index
        end
    end

    def first_where(stream, function) do
        stream |> Stream.filter(function) |> Stream.take(1) |> Enum.to_list |> List.first
    end

    def index_in_stream(stream, element) do
        case stream |> Stream.with_index |> Stream.filter(fn {x, _} -> GeneralCommands.equals(x, element) end) |> Stream.take(1) |> Enum.to_list |> List.first do
            nil -> -1
            {_, index} -> index
        end
    end

    def lift(value) do
        cond do
            Functions.is_iterable(value) -> value |> Stream.with_index(1) |> Stream.map(fn {x, index} -> Functions.call_binary(fn a, b -> 
                Functions.to_number(a) * Functions.to_number(b) end, x, index) end)
            true -> String.graphemes(to_string(value)) |> Stream.with_index(1) |> Stream.map(fn {x, index} -> String.duplicate(x, index) end)
        end
    end

    def even_split(value, size) when is_number(value) or is_bitstring(value), do: even_split(String.graphemes(to_string(value)), size) |> Stream.map(fn x -> Enum.join(x, "") end)
    def even_split(list, size) do
        list_length = length(Enum.to_list list)
        {final_size, remainder} = {IntCommands.divide(list_length, size), IntCommands.mod(list_length, size)}
        if remainder == 0 do
            split_into(list, final_size)
        else
            take_split(list, Stream.concat(Stream.cycle([final_size + 1]) |> Stream.take(remainder), Stream.cycle([final_size]) |> Stream.take(size - remainder))) 
        end
    end

    def remove_leading(value, element) when is_number(value) or is_bitstring(value), do: Enum.join(remove_leading(String.graphemes(to_string(value)), element), "")
    def remove_leading(value, element) when Functions.is_iterable(element), do: value |> Stream.drop_while(fn x -> contains(element, x) end)
    def remove_leading(value, element), do: value |> Stream.drop_while(fn x -> GeneralCommands.equals(x, element) end)

    def remove_trailing(value, element) when is_number(value) or is_bitstring(value), do: Enum.join(remove_trailing(String.graphemes(to_string(value)), element), "")
    def remove_trailing(value, element), do: value |> Enum.to_list |> Enum.reverse |> remove_leading(element) |> Enum.reverse

    @doc """
    Rotate the given value to the left or to the right depending on the given shift.
    If the shift is larger than 0, the value is shifted that many times to the left.
    If the shift is smaller than 0, the value is shifted by abs(shift) many times to the right.

    ## Parameters

     - value:   The value that will be shifted
     - shift:   The number of times the value will be shifted.

    ## Returns

    The shifted result from the value.

    """
    def rotate(value, shift) when shift == 0, do: value
    def rotate(value, shift) when not Functions.is_iterable(value), do: Enum.join(rotate(String.graphemes(to_string(value)), shift), "")
    def rotate(value, shift) when shift > 0 do
        case Enum.count value do
            0 -> []
            x -> 
                shift = rem(shift, x)
                Stream.concat(value |> Stream.drop(shift), value |> Stream.take(shift)) |> Enum.to_list
        end
    end
    def rotate(value, shift) when shift < 0 do
        case Enum.count value do
            0 -> []
            x ->
                shift = rem(shift, x)
                Stream.concat(value |> Stream.take(shift), value |> Stream.drop(shift)) |> Enum.to_list
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

    @doc """
    Zip with filler for a single list. Zipping is done internally within the first given argument and
    fills the remaining spaces with the given filler character. Since Elixir does not have a zip with filler
    function, this is done using a resource generator for a new stream, repeatedly taking the first element of
    the given list of lists and dropping one element for the next iteration. It checks each iteration whether
    at least one element of the intermediate results is not equal to [] and replaces any occurrence of [] with
    the filler element. If all elements of the intermediate result equals [], it halts the stream generation.

    ## Parameters

     - a:       The element that will be zipped. Assuming that this element is a list of lists.
     - filler:  The filler character, which can be of any type.

    ## Returns

    Returns the resulting zipped list as a stream.

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
            fn _ -> nil end)
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
            fn _ -> nil end)
            |> Stream.map(fn x -> x end)
    end

    def deep_flatten(list) do
        list |> Stream.flat_map(fn x -> if Functions.is_iterable(x) do deep_flatten(x) else [x] end end)
             |> Stream.map(fn x -> x end)
    end

    def substrings(list) do
        list |> suffixes |> Enum.reverse |> Stream.flat_map(fn y -> prefixes(y) end) |> Stream.map(fn x -> x end)
    end

    def reverse(list) when Functions.is_iterable(list), do: list |> Enum.to_list |> Enum.reverse
    def reverse(string), do: String.reverse(to_string(string))

    def group_equal(list) do
        cond do
            Functions.is_iterable(list) -> Stream.chunk_while(list, {[], nil}, 
                                            fn (x, {acc, last}) -> if last == nil or GeneralCommands.equals(x, last) do {:cont, {[x | acc], x}} else {:cont, acc, {[x], x}} end end,
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

    def permutations([]), do: [[]]
    def permutations(list) do
        list = Enum.to_list list
        for element <- list, remaining <- permutations(list -- [element]), do: [element | remaining]
    end
    
    # Powerset example: [1, 2, 3, 4] → [[], [1], [2], [1, 2], [3], [1, 3], [2, 3], [1, 2, 3], [4], [1, 4], [2, 4], ...]
    def powerset(list) do
        Stream.concat([[]], Stream.transform(list, [[]], fn (x, acc) ->
            current_result = Enum.map(acc, fn n -> n ++ [x] end)
            {current_result, acc ++ current_result}
        end))
            |> Stream.map(fn x -> x end)
    end

    def shape_like(a, b) when Functions.is_iterable(a) and Functions.is_iterable(b), do: a |> Stream.cycle |> Stream.take(length(Enum.to_list b)) |> Enum.to_list
    def shape_like(a, b) when Functions.is_iterable(a), do: a |> Stream.cycle |> Stream.take(if Functions.is_number?(b) do Functions.to_integer(b) else String.length(to_string(b)) end) |> Enum.to_list
    def shape_like(a, b), do: Enum.join(shape_like(Functions.to_list(a), b), "")

    def cartesian(a, b) do
        cond do
            Functions.is_iterable(a) and Functions.is_iterable(b) -> Stream.flat_map(a, fn x -> b |> Stream.map(fn y -> [x, y] end) end) |> Stream.map(fn x -> x end)
            Functions.is_iterable(a) -> cartesian(a, String.graphemes(to_string(b)))
            Functions.is_iterable(b) -> cartesian(String.graphemes(to_string(a)), b)
            true -> cartesian(String.graphemes(to_string(a)), String.graphemes(to_string(b))) |> Stream.map(fn x -> Enum.to_list(x) |> Enum.join("") end)
        end
    end
    
    def cartesian_repeat(_, 0), do: [[]]
    def cartesian_repeat(value, n) do
        cond do
            Functions.is_iterable(value) -> cartesian_repeat(value, n - 1) |> Stream.flat_map(fn x -> value |> Stream.map(fn y -> x ++ [y] end) end) |> Stream.map(fn x -> x end)
            true -> cartesian_repeat(String.graphemes(to_string(value)), n) |> Stream.map(fn x -> Enum.join(Enum.to_list(x), "") end)
        end
    end

    def enumerate_inner(list) when Functions.is_iterable(list), do: list |> Stream.with_index |> Stream.map(fn {element, index} -> [element, index] end)
    def enumerate_inner(value), do: enumerate_inner(String.graphemes(to_string(value)))

    def divide_into(list, n) when is_number(n), do: divide_into(list, [List.duplicate([], n)])
    def divide_into([], containers), do: containers
    def divide_into(_, []), do: []
    def divide_into([head | remaining], acc) do
        acc |> Enum.flat_map(fn x -> divide_into(remaining, insert_anywhere([head], x)) end)
    end

    defp insert_anywhere(element, containers), do: insert_anywhere(element, containers, [])
    defp insert_anywhere(_, [], _), do: [] 
    defp insert_anywhere(element, [head_container | remaining], parsed) do
        [parsed ++ [(head_container ++ element) | remaining] | insert_anywhere(element, remaining, parsed ++ [head_container])]
    end

    def combinations(_, 0), do: [[]]
    def combinations([], _), do: []
    def combinations(list, n) when length(list) == n, do: [list]
    def combinations(list, n) when length(list) < n, do: []
    def combinations([head | remaining], n), do: (for element <- combinations(remaining, n - 1), do: [head | element]) ++ combinations(remaining, n)

    def partitions(list), do: partitions(list, [])
    defp partitions([], acc), do: [acc |> Enum.reverse]
    defp partitions([head | remaining], []), do: partitions(remaining, [[head]])
    defp partitions([head | remaining], [head_acc | remaining_acc]) do
        partitions(remaining, [[head]] ++ [head_acc | remaining_acc]) ++ partitions(remaining, [head_acc ++ [head] | remaining_acc])
    end

    def integer_partitions(number), do: integer_partitions(number, [], 1)
    defp integer_partitions(0, acc, _), do: [acc |> Enum.reverse]
    defp integer_partitions(x, _, _) when x < 0, do: []
    defp integer_partitions(x, _, min_index) when min_index > x, do: []
    defp integer_partitions(number, acc, min_index), do: min_index..number |> Enum.flat_map(fn index -> integer_partitions(number - index, [index | acc], index) end)

    def increasing_contains([], _), do: false
    def increasing_contains(list, value, certainty \\ 5), do: increasing_contains(list, value, certainty, certainty)
    def increasing_contains(_, _, _, 0), do: false
    def increasing_contains(list, value, certainty, allowance) do
        head = Functions.to_number GeneralCommands.head(list)
        cond do
            head == nil -> false
            head < value -> increasing_contains(list |> Stream.drop(1), value, certainty, certainty)
            head == value -> true
            head > value -> increasing_contains(list |> Stream.drop(1), value, certainty, allowance - 1)
        end
    end

    def unfold_up_to(start, function, limit) do
        Stream.unfold(start, 
            fn index -> 
                result = function.(index)
                cond do 
                    result > limit -> nil
                    true -> {result, index + 1}
                end 
            end) |> Stream.map(fn x -> x end)
    end

    def generate_n(start, function, n) do
        Stream.unfold({start, n},
            fn 
                {_, 0} -> nil
                {acc, size} -> 
                    result = function.(acc)
                    {acc, {result, size - 1}}
            end) |> Stream.map(fn x -> x end)
    end

    def list_subtraction(left, []), do: left
    def list_subtraction(left, [curr | remaining]) do
        case left |> Enum.find_index(fn x -> GeneralCommands.equals(x, curr) end) do
            nil -> left |> list_subtraction(remaining)
            index -> ((left |> Enum.take(index)) ++ (left |> Enum.drop(index + 1))) |> list_subtraction(remaining)
        end
    end

    def interleave(left, right) do
        Stream.unfold({left, right}, fn
            {left, right} -> 
                case Stream.take(left, 1) |> Enum.to_list do
                    [] ->
                        case Stream.take(right, 1) |> Enum.to_list do
                            [] -> nil
                            [element] -> {element, right |> Stream.drop(1)}
                        end
                    [element] -> {element, {right, left |> Stream.drop(1)}}
                end
            acc ->
                case Stream.take(acc, 1) |> Enum.to_list do
                    [] -> nil
                    [element] -> {element, acc |> Stream.drop(1)}
                end
            end) |> Stream.map(fn x -> x end)
    end
    
    def continue(list), do: Stream.concat(list, Stream.cycle([List.last(Enum.to_list(list))])) |> Functions.as_stream

    def deck_shuffle(list) do
        [left, right] = list |> even_split(2) |> Enum.to_list
        interleave(left, right)
    end

    def deck_unshuffle(list) do
        list |> split_into(2) |> MatrixCommands.columns_of |> Stream.concat |> Functions.as_stream
    end

    def permutation_index(range, index) when Functions.is_single?(range), do: permutation_index(1..Functions.to_integer(range), index)
    def permutation_index(range, index), do: permutation_index(Enum.to_list(range), index, [])
    defp permutation_index([], _, parsed), do: parsed |> Enum.reverse
    defp permutation_index(range, index, parsed) do
        curr_index = Enum.at(range, div(index, IntCommands.factorial(length(range) - 1)))
        permutation_index(range -- [curr_index], rem(index, IntCommands.factorial(length(range) - 1)), [curr_index | parsed])
    end

    def middle_of(string) when Functions.is_single?(string) do
        case middle_of(Functions.to_list(string)) do
            [left, right] -> left <> right
            middle -> middle
        end
    end
    def middle_of(list) do
        list = Enum.to_list(list)
        len = length(list)
        mid = div(len, 2)
        cond do
            len == 0 -> []
            rem(len, 2) == 0 -> [Enum.at(list, mid - 1), Enum.at(list, mid)]
            true -> Enum.at(list, mid)
        end
    end

    def split_on_truthy_indices(a, b) do
        Stream.zip(a, Stream.concat(b, Stream.cycle([0]))) |> Stream.chunk_while(
            [],
            fn {item, index}, acc ->
                if GeneralCommands.equals(index, 1) do
                    {:cont, Enum.reverse(acc), [item]}
                else
                    {:cont, [item | acc]}
                end
            end,
            fn
                [] -> {:cont, []}
                acc -> {:cont, Enum.reverse(acc), []}
            end
        ) |> Stream.map(fn x -> x end)
    end

    def non_vectorizing_index_in(a, b) do
        case Functions.to_list(a) |> Stream.with_index |> first_where(fn {x, _} -> GeneralCommands.equals(x, b) end) do
            nil -> -1
            {_, index} -> index
        end
    end
end