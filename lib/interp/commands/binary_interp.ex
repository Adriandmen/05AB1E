defmodule Interp.BinaryInterp do
    alias Interp.Stack
    alias Commands.ListCommands
    alias Commands.StrCommands
    alias Commands.IntCommands
    alias Commands.GeneralCommands
    import Interp.Functions
    import Bitwise

    def interp_step(op, stack, environment) do
        {b, stack, environment} = Stack.pop(stack, environment)
        {a, stack, environment} = Stack.pop(stack, environment)
        try_default(fn -> interp_step(op, stack, environment, a, b) end, fn _ -> {Stack.push(stack, a), environment} end)
    end

    defp interp_step(op, stack, environment, a, b) do
        new_stack = case op do
            "α" -> Stack.push(stack, call_binary(fn x, y -> abs(to_number(x) - to_number(y)) end, a, b))
            "β" -> Stack.push(stack, call_binary(fn x, y -> IntCommands.list_from_base(to_number(x), to_number(y)) end, a, b, true, false))
            "+" -> Stack.push(stack, call_binary(fn x, y -> to_number(x) + to_number(y) end, a, b))
            "-" -> Stack.push(stack, call_binary(fn x, y -> to_number(x) - to_number(y) end, a, b))
            "/" -> Stack.push(stack, call_binary(fn x, y -> to_number(x) / to_number(y) end, a, b))
            "*" -> Stack.push(stack, call_binary(fn x, y -> to_number(x) * to_number(y) end, a, b))
            "%" -> Stack.push(stack, call_binary(fn x, y -> IntCommands.mod(to_number(x), to_number(y)) end, a, b))
            "&" -> Stack.push(stack, call_binary(fn x, y -> to_integer!(x) &&& to_integer!(y) end, a, b))
            "^" -> Stack.push(stack, call_binary(fn x, y -> Bitwise.bxor(to_integer!(x), to_integer!(y)) end, a, b))
            "~" -> Stack.push(stack, call_binary(fn x, y -> to_integer!(x) ||| to_integer!(y) end, a, b))
            "B" -> Stack.push(stack, call_binary(fn x, y -> IntCommands.to_base(to_integer!(x), to_integer!(y)) end, a, b))
            "c" -> Stack.push(stack, call_binary(fn x, y -> IntCommands.n_choose_k(to_integer!(x), to_integer!(y)) end, a, b))
            "e" -> Stack.push(stack, call_binary(fn x, y -> IntCommands.n_permute_k(to_integer!(x), to_integer!(y)) end, a, b))
            "m" -> Stack.push(stack, call_binary(fn x, y -> IntCommands.pow(to_number(x), to_number(y)) end, a, b))
            "K" -> Stack.push(stack, call_binary(fn x, y -> ListCommands.remove_from(x, y) end, a, b, true, true))
            "å" -> Stack.push(stack, call_binary(fn x, y -> to_number(ListCommands.contains(to_non_number(x), y)) end, a, b, true, false))
            "è" -> Stack.push(stack, call_binary(fn x, y -> GeneralCommands.element_at(to_list(x), to_integer!(y)) end, a, b, true, false))
            "£" -> Stack.push(stack, call_binary(fn x, y -> ListCommands.take_first(x, to_integer!(y)) end, a, b, true, true))
            "м" -> Stack.push(stack, call_binary(fn x, y -> GeneralCommands.remove_from(x, y) end, a, b, true, true))
            "‰" -> Stack.push(stack, call_binary(fn x, y -> [IntCommands.divide(to_number(x), to_number(y)), IntCommands.mod(to_number(x), to_number(y))] end, a, b))
            "‹" -> Stack.push(stack, call_binary(fn x, y -> to_number(to_number(x) < to_number(y)) end, a, b))
            "›" -> Stack.push(stack, call_binary(fn x, y -> to_number(to_number(x) > to_number(y)) end, a, b))
            "@" -> Stack.push(stack, call_binary(fn x, y -> to_number!(to_number(x) >= to_number(y)) end, a, b))
            "ô" -> Stack.push(stack, call_binary(fn x, y -> ListCommands.split_into(x, to_integer!(y)) end, a, b, true, false))
            "Ö" -> Stack.push(stack, call_binary(fn x, y -> to_number(IntCommands.mod(to_number(x), to_number(y)) == 0) end, a, b))
            "ù" -> Stack.push(stack, call_binary(fn x, y -> ListCommands.keep_with_length(x, to_integer!(y)) end, a, b, true, false))
            "k" -> Stack.push(stack, call_binary(fn x, y -> ListCommands.index_in(x, y) end, a, b, true, false))
            "и" -> Stack.push(stack, call_binary(fn x, y -> ListCommands.list_multiply(x, to_integer(y)) end, a, b, true, false))
            "¢" -> Stack.push(stack, call_binary(fn x, y -> GeneralCommands.count(x, y) end, a, b, true, false))
            "×" -> Stack.push(stack, call_binary(fn x, y -> String.duplicate(to_string(x), to_integer!(y)) end, a, b))
            "в" -> Stack.push(stack, call_binary(fn x, y -> IntCommands.to_base_arbitrary(to_integer!(x), to_integer!(y)) end, a, b))
            "ö" -> Stack.push(stack, call_binary(fn x, y -> IntCommands.string_from_base(to_string(x), to_integer!(y)) end, a, b))
            "÷" -> Stack.push(stack, call_binary(fn x, y -> IntCommands.divide(to_number(x), to_number(y)) end, a, b))
            "ú" -> Stack.push(stack, call_binary(fn x, y -> String.duplicate(" ", to_integer!(y)) <> to_string(x) end, a, b))
            "ä" -> Stack.push(stack, call_binary(fn x, y -> ListCommands.even_split(x, to_integer!(y)) end, a, b, true, false))
            "j" -> Stack.push(stack, call_binary(fn x, y -> StrCommands.leftpad_with(x, to_integer!(y), " ") end, a, b, true, false))
            "ª" -> Stack.push(stack, call_binary(fn x, y -> Stream.concat(to_list(x), [y]) |> as_stream end, a, b, true, true))
            "š" -> Stack.push(stack, call_binary(fn x, y -> Stream.concat([y], to_list(x)) |> as_stream end, a, b, true, true))
           ".¢" -> Stack.push(stack, call_binary(fn x, y -> GeneralCommands.strict_count(x, y) end, a, b, true, true))
           ".S" -> Stack.push(stack, call_binary(fn x, y -> cond do to_number(x) > to_number(y) -> 1; to_number(x) < to_number(y) -> -1; true -> 0 end end, a, b))
           ".£" -> Stack.push(stack, call_binary(fn x, y -> ListCommands.take_last(x, to_integer!(y)) end, a, b, true, false))
           ".$" -> Stack.push(stack, call_binary(fn x, y -> ListCommands.drop_from(x, to_integer!(y)) end, a, b, true, false))
           ".n" -> Stack.push(stack, call_binary(fn x, y -> :math.log(to_number(x)) / :math.log(to_number(y)) end, a, b))
           ".x" -> Stack.push(stack, call_binary(fn x, y -> ListCommands.closest_to(x, y) end, a, b, true, false))
           ".L" -> Stack.push(stack, call_binary(fn x, y -> StrCommands.levenshtein_distance(to_list(x), to_list(y)) end, a, b))
           ".ò" -> Stack.push(stack, call_binary(fn x, y -> if is_integer?(x) do x else Float.round(to_number(x), to_integer!(y)) end end, a, b))
           ".Œ" -> Stack.push(stack, call_binary(fn x, y -> normalize_inner(ListCommands.divide_into(Enum.to_list(to_list(x)), to_integer!(y)), a) end, a, b, true, false))
           "._" -> Stack.push(stack, call_binary(fn x, y -> normalize_to(ListCommands.rotate(to_list(x), to_integer!(y)), x) end, a, b, true, false))
           "ÅL" -> Stack.push(stack, call_binary(fn x, y -> if to_number!(x) < to_number!(y) do to_number!(x) else to_number!(y) end end, a, b))
           "ÅU" -> Stack.push(stack, call_binary(fn x, y -> (fn n, sides -> div(n * n * (sides - 2) - n * (sides - 4), 2) end).(to_number!(x), to_number!(y)) end, a, b))
           "Åβ" -> Stack.push(stack, call_binary(fn x, y -> IntCommands.from_custom_base(x, y) end, a, b, true, true))
           "Åв" -> Stack.push(stack, call_binary(fn x, y -> IntCommands.to_custom_base(to_integer(x), y) end, a, b, false, true))
           ".м" -> Stack.push(stack, call_binary(fn x, y -> ListCommands.list_subtraction(to_list(x), Enum.to_list(to_list(y))) end, a, b, true, true))
           ".I" -> Stack.push(stack, call_binary(fn x, y -> ListCommands.permutation_index(x, to_integer!(y)) end, a, b, true, false))
           ".i" -> Stack.push(stack, call_binary(fn x, y -> to_number(ListCommands.increasing_contains(to_list(x), to_number(y))) end, a, b, true, false))
           ".Ï" -> Stack.push(stack, call_binary(fn x, y -> StrCommands.exchange_capitalization(x, y) end, a, b))
           ".ι" -> Stack.push(stack, ListCommands.interleave(to_list(a), to_list(b)))
           ".k" -> Stack.push(stack, ListCommands.flat_index_in_list(a, b))
           ".K" -> Stack.push(stack, ListCommands.non_vectorizing_index_in(a, b))
           ".ý" -> Stack.push(stack, to_list(a) |> Stream.intersperse(b) |> Stream.map(fn x -> x end))
           ".o" -> Stack.push(stack, StrCommands.overlap(a, b))
           ".ø" -> Stack.push(stack, ListCommands.surround(a, b))
           ".å" -> Stack.push(stack, to_number(to_list(a) |> Enum.any?(fn x -> GeneralCommands.equals(x, b) end)))
           ".Q" -> Stack.push(stack, to_number(GeneralCommands.equals(a, b)))
            "Û" -> Stack.push(stack, ListCommands.remove_leading(a, b))
            "Ü" -> Stack.push(stack, ListCommands.remove_trailing(a, b))
            "Ú" -> Stack.push(stack, ListCommands.remove_leading(ListCommands.remove_trailing(a, b), b))
            "∍" -> Stack.push(stack, ListCommands.shape_like(a, b))
            "Q" -> Stack.push(stack, to_number(if is_iterable(a) and is_iterable(b) do GeneralCommands.equals(a, b) else GeneralCommands.vectorized_equals(a, b) end))
            "Ê" -> Stack.push(stack, to_number(if is_iterable(a) and is_iterable(b) do GeneralCommands.equals(a, b) == false else call_unary(fn n -> n == false end, GeneralCommands.vectorized_equals(a, b)) end))
            "Ï" -> Stack.push(stack, ListCommands.keep_truthy_indices(to_non_number(a), to_non_number(b)))
            "â" -> Stack.push(stack, ListCommands.cartesian(a, b))
            "†" -> Stack.push(stack, ListCommands.filter_to_front(a, b))
            "Ã" -> Stack.push(stack, StrCommands.keep_chars(to_non_number(a), to_non_number(b)))
            "¡" -> Stack.push(stack, ListCommands.split_on(a, to_non_number(b)))
            "«" -> Stack.push(stack, GeneralCommands.concat(a, b))
            "ì" -> Stack.push(stack, GeneralCommands.concat(b, a))
            "‚" -> Stack.push(stack, [a, b])
            "s" -> Stack.push(Stack.push(stack, b), a)
            "ý" -> if is_iterable(a) do Stack.push(stack, ListCommands.join(a, to_string(b))) else Stack.push(%Stack{}, ListCommands.join(Enum.reverse(Stack.push(stack, a).elements), to_string(b))) end
           ".D" -> if is_number?(b) do %Stack{elements: (Stream.cycle([a]) |> Enum.take(to_integer!(b))) ++ stack.elements} else %Stack{elements: (Stream.cycle([a]) |> Enum.take(GeneralCommands.length_of(b))) ++ stack.elements} end

           # Extended commands
           "ÅΓ" -> Stack.push(stack, call_binary(fn x, y -> StrCommands.run_length_decode(to_list(x), to_integer!(to_list(y))) end, a, b, true, true))
           "Å?" -> Stack.push(stack, call_binary(fn x, y -> to_number(GeneralCommands.starts_with(x, y)) end, a, b, true, true))
           "Å¿" -> Stack.push(stack, call_binary(fn x, y -> to_number(GeneralCommands.ends_with(x, y)) end, a, b, true, true))
           "Å¡" -> Stack.push(stack, ListCommands.split_on_truthy_indices(to_list(a), to_list(b)))
        end

        {new_stack, environment}
    end
end
