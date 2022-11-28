defmodule Interp.UnaryInterp do
    alias Interp.Stack
    alias Interp.Globals
    alias Interp.Output
    alias Commands.ListCommands
    alias Commands.StrCommands
    alias Commands.IntCommands
    alias Commands.GeneralCommands
    alias Commands.MatrixCommands
    import Interp.Functions
    use Bitwise

    def interp_step(op, stack, environment) do
        {a, stack, environment} = Stack.pop(stack, environment)
        try_default(fn -> interp_step(op, stack, environment, a) end, fn _ -> {Stack.push(stack, a), environment} end)
    end

    def interp_step(op, stack, environment, a) do
        new_stack = case op do
            ">" -> Stack.push(stack, call_unary(fn x -> to_number(x) + 1 end, a))
            "<" -> Stack.push(stack, call_unary(fn x -> to_number(x) - 1 end, a))
            "L" -> Stack.push(stack, call_unary(fn x -> ListCommands.listify(1, to_integer!(x)) end, a))
            "Ý" -> Stack.push(stack, call_unary(fn x -> ListCommands.listify(0, to_integer!(x)) end, a))
            "!" -> Stack.push(stack, call_unary(fn x -> IntCommands.factorial(to_number(x)) end, a))
            "η" -> Stack.push(stack, call_unary(fn x -> ListCommands.prefixes(x) end, a, true))
            "н" -> Stack.push(stack, call_unary(fn x -> GeneralCommands.head(x) end, a, true))
            "θ" -> Stack.push(stack, call_unary(fn x -> GeneralCommands.tail(x) end, a, true))
            "Θ" -> Stack.push(stack, call_unary(fn x -> to_number(to_number(x) == 1) end, a))
            "≠" -> Stack.push(stack, call_unary(fn x -> to_number(to_number(x) != 1) end, a))
            "_" -> Stack.push(stack, call_unary(fn x -> to_number(to_number(x) == 0) end, a))
            "(" -> Stack.push(stack, call_unary(fn x -> to_number(x) * -1 end, a))
            "a" -> Stack.push(stack, call_unary(fn x -> to_number(Regex.match?(~r/^[a-zA-Z]+$/, to_string(x))) end, a))
            "d" -> Stack.push(stack, call_unary(fn x -> to_number(is_number(to_number(x)) and to_number(x) >= 0) end, a))
            "b" -> Stack.push(stack, call_unary(fn x -> IntCommands.to_base(to_integer!(x), 2) end, a))
            "h" -> Stack.push(stack, call_unary(fn x -> IntCommands.to_base(to_integer!(x), 16) end, a))
            "p" -> Stack.push(stack, call_unary(fn x -> to_number(IntCommands.is_prime?(to_number(x))) end, a))
            "z" -> Stack.push(stack, call_unary(fn x -> 1 / to_number(x) end, a))
            "t" -> Stack.push(stack, call_unary(fn x -> :math.sqrt(to_number(x)) end, a))
            "C" -> Stack.push(stack, call_unary(fn x -> IntCommands.string_from_base(to_non_number(x), 2) end, a))
            "S" -> Stack.push(stack, call_unary(fn x -> ListCommands.split_individual(x) end, a, true))
            "H" -> Stack.push(stack, call_unary(fn x -> IntCommands.string_from_base(String.upcase(to_non_number(x)), 16) end, a))
            "R" -> Stack.push(stack, call_unary(fn x -> x |> ListCommands.reverse end, a, true))
            "o" -> Stack.push(stack, call_unary(fn x -> IntCommands.pow(2, to_number(x)) end, a))
            "n" -> Stack.push(stack, call_unary(fn x -> IntCommands.pow(to_number(x), 2) end, a))
            "u" -> Stack.push(stack, call_unary(fn x -> String.upcase(to_string(x)) end, a))
            "l" -> Stack.push(stack, call_unary(fn x -> String.downcase(to_string(x)) end, a))
            "g" -> Stack.push(stack, call_unary(fn x -> cond do (is_iterable(x) -> length(Enum.to_list(x)); true -> String.length(to_string(x))) end end, a, true))
            ";" -> Stack.push(stack, call_unary(fn x -> to_number(x) / 2 end, a))
            "ï" -> Stack.push(stack, call_unary(fn x -> to_integer(x) end, a))
            "§" -> Stack.push(stack, call_unary(fn x -> to_non_number(x) end, a))
            "±" -> Stack.push(stack, call_unary(fn x -> ~~~to_integer!(x) end, a))
            "Ā" -> Stack.push(stack, call_unary(fn x -> to_number(not(to_number(x) == 0 or x == "")) end, a))
            "Ć" -> Stack.push(stack, call_unary(fn x -> GeneralCommands.enclose(x) end, a, true))
            "Ì" -> Stack.push(stack, call_unary(fn x -> to_number(x) + 2 end, a))
            "Í" -> Stack.push(stack, call_unary(fn x -> to_number(x) - 2 end, a))
            "·" -> Stack.push(stack, call_unary(fn x -> to_number(x) * 2 end, a))
            "Ä" -> Stack.push(stack, call_unary(fn x -> abs(to_number(x)) end, a))
            "î" -> Stack.push(stack, call_unary(fn x -> if is_integer(to_number(x)) do to_number(x) else Float.ceil(to_number(x)) end end, a))
            "ò" -> Stack.push(stack, call_unary(fn x -> round(to_number(x)) end, a))
            "™" -> Stack.push(stack, call_unary(fn x -> StrCommands.title_case(to_string(x)) end, a))
            "È" -> Stack.push(stack, call_unary(fn x -> to_number(IntCommands.mod(to_number(x), 2) == 0) end, a))
            "É" -> Stack.push(stack, call_unary(fn x -> to_number(IntCommands.mod(to_number(x), 2) == 1) end, a))
            "°" -> Stack.push(stack, call_unary(fn x -> IntCommands.pow(10, to_number(x)) end, a))
            "Ç" -> Stack.push(stack, call_unary(fn x -> StrCommands.to_codepoints(x) end, a, true))
            "ç" -> Stack.push(stack, call_unary(fn x -> List.to_string [to_integer!(x)] end, a))
            "f" -> Stack.push(stack, call_unary(fn x -> IntCommands.prime_factors(to_integer!(x)) |> Stream.dedup end, a))
            "Ò" -> Stack.push(stack, call_unary(fn x -> IntCommands.prime_factors(to_integer!(x)) end, a))
            "Ó" -> Stack.push(stack, call_unary(fn x -> IntCommands.prime_exponents(to_integer!(x)) end, a))
            "Ñ" -> Stack.push(stack, call_unary(fn x -> IntCommands.divisors(to_integer!(x)) end, a))
            "Õ" -> Stack.push(stack, call_unary(fn x -> IntCommands.euler_totient(to_integer!(x)) end, a))
            "Ø" -> Stack.push(stack, call_unary(fn x -> IntCommands.nth_prime(to_integer!(x)) end, a))
           ".š" -> Stack.push(stack, call_unary(fn x -> StrCommands.switch_case(to_string(x)) end, a))
           ".ª" -> Stack.push(stack, call_unary(fn x -> StrCommands.sentence_case(to_string(x)) end, a))
           ".b" -> Stack.push(stack, call_unary(fn x -> <<rem(to_integer!(x) - 1, 26) + 65>> end, a))
           ".l" -> Stack.push(stack, call_unary(fn x -> to_number Regex.match?(~r/^[a-z]+$/, to_string(x)) end, a))
           ".u" -> Stack.push(stack, call_unary(fn x -> to_number Regex.match?(~r/^[A-Z]+$/, to_string(x)) end, a))
           ".p" -> Stack.push(stack, call_unary(fn x -> ListCommands.prefixes(x) end, a, true))
           ".ï" -> Stack.push(stack, call_unary(fn x -> to_number(is_integer?(x)) end, a))
           ".²" -> Stack.push(stack, call_unary(fn x -> :math.log2(to_number(x)) end, a))
           ".E" -> Stack.push(stack, call_unary(fn x -> {result, _} = Code.eval_string(to_string(x)); result end, a))
           ".Ø" -> Stack.push(stack, call_unary(fn x -> IntCommands.get_prime_index(to_number(x)) end, a))
           ".±" -> Stack.push(stack, call_unary(fn x -> cond do to_number(x) > 0 -> 1; to_number(x) < 0 -> -1; true -> 0 end end, a))
           ".X" -> Stack.push(stack, call_unary(fn x -> IntCommands.to_roman_numeral(to_integer!(x)) end, a))
           ".v" -> Stack.push(stack, call_unary(fn x -> IntCommands.from_roman_numeral(to_string(x)) end, a))
           ".Þ" -> Stack.push(stack, call_unary(fn x -> ListCommands.continue(to_list(x)) end, a, true))
           ".w" -> Stack.push(stack, call_unary(fn x -> GeneralCommands.get_url(to_string(x)) end, a))
           ".B" -> Stack.push(stack, if is_iterable(a) do StrCommands.squarify(a) else StrCommands.squarify(String.split(to_string(a), "\n")) end)
           ".c" -> Stack.push(stack, if is_iterable(a) do StrCommands.align_center(a, :left) else StrCommands.align_center(String.split(to_string(a), "\n"), :left) end)
           ".C" -> Stack.push(stack, if is_iterable(a) do StrCommands.align_center(a, :right) else StrCommands.align_center(String.split(to_string(a), "\n"), :right) end)
           ".R" -> Stack.push(stack, if is_iterable(a) do Enum.random(Enum.to_list(a)) else Enum.random(String.graphemes(to_string(a))) end)
           ".r" -> Stack.push(stack, if is_iterable(a) do Enum.shuffle(Enum.to_list(a)) else Enum.join(Enum.shuffle(String.graphemes(to_string(a))), "") end)
           ".œ" -> Stack.push(stack, if is_iterable(a) do ListCommands.partitions(Enum.to_list(a)) else ListCommands.partitions(to_list(a)) |> Enum.map(fn x -> x |> Enum.map(fn y -> y |> Enum.join("") end) end) end)
           ".¥" -> Stack.push(stack, ListCommands.undelta(a))
           ".∊" -> Stack.push(stack, StrCommands.vertical_intersected_mirror(a))
            "é" -> Stack.push(stack, a |> Enum.sort_by(fn x -> GeneralCommands.length_of(x) end))
            "º" -> Stack.push(stack, StrCommands.mirror(a))
            "í" -> Stack.push(stack, a |> Stream.map(fn x -> if is_iterable(x) do Enum.to_list(x) |> Enum.reverse else String.reverse(to_string(x)) end end))
            "Ω" -> Stack.push(stack, if is_iterable(a) do Enum.random(Enum.to_list(a)) else Enum.random(String.graphemes(to_string(a))) end)
            "æ" -> Stack.push(stack, if is_iterable(a) do ListCommands.powerset(a) else ListCommands.powerset(String.graphemes(to_string(a))) |> Enum.map(fn x -> Enum.join(x, "") end) end)
            "œ" -> Stack.push(stack, if is_iterable(a) do ListCommands.permutations(a) else ListCommands.permutations(String.graphemes(to_string(a))) |> Enum.map(fn x -> Enum.join(x, "") end) end)
            "Þ" -> Stack.push(stack, to_list(a) |> Stream.cycle |> Stream.map(fn x -> x end))
            "À" -> Stack.push(stack, ListCommands.rotate(a, 1))
            "Á" -> Stack.push(stack, ListCommands.rotate(a, -1))
            "Ù" -> Stack.push(stack, ListCommands.uniques(a))
            "Œ" -> Stack.push(stack, ListCommands.substrings(a))
            "γ" -> Stack.push(stack, ListCommands.group_equal(a))
           ".s" -> Stack.push(stack, ListCommands.suffixes(a))
           ".ā" -> Stack.push(stack, ListCommands.enumerate_inner(a))
           ".º" -> Stack.push(stack, StrCommands.intersected_mirror(a))
           ".Ó" -> Stack.push(stack, IntCommands.number_from_prime_exponents(to_number(to_list(a))))
            "á" -> Stack.push(stack, StrCommands.keep_letters(to_non_number(a)))
            "þ" -> Stack.push(stack, StrCommands.keep_digits(to_non_number(a)))
            "Ô" -> Stack.push(stack, ListCommands.deduplicate(a))
            "∊" -> Stack.push(stack, StrCommands.vertical_mirror(a))
            "˜" -> Stack.push(stack, ListCommands.deep_flatten(a))
            "¸" -> Stack.push(stack, [a])
            "Ë" -> Stack.push(stack, to_number(GeneralCommands.all_equal(a)))
            "ƶ" -> Stack.push(stack, ListCommands.lift(a))
            "¦" -> Stack.push(stack, GeneralCommands.dehead(a))
            "¨" -> Stack.push(stack, GeneralCommands.detail(a))
            "¥" -> Stack.push(stack, ListCommands.deltas(a))
            "ß" -> Stack.push(stack, if is_iterable(a) do IntCommands.min_of(a) else IntCommands.min_of(String.graphemes(to_string(a))) end)
            "à" -> Stack.push(stack, if is_iterable(a) do IntCommands.max_of(a) else IntCommands.max_of(String.graphemes(to_string(a))) end)
            "û" -> Stack.push(stack, normalize_to(Stream.concat(to_list(a), to_list(a) |> Enum.reverse |> Enum.drop(1)) |> Enum.to_list, a))
            "W" -> Stack.push(Stack.push(stack, a), IntCommands.min_of(a))
            "Z" -> Stack.push(Stack.push(stack, a), IntCommands.max_of(a))
            "x" -> Stack.push(Stack.push(stack, a), call_unary(fn x -> 2 * to_number(x) end, a))
            "¤" -> Stack.push(Stack.push(stack, a), GeneralCommands.tail(a))
            "¬" -> Stack.push(Stack.push(stack, a), GeneralCommands.head(a))
            "D" -> Stack.push(Stack.push(stack, a), a)
            "ā" -> Stack.push(Stack.push(stack, a), ListCommands.enumerate(a))
            "Ð" -> Stack.push(Stack.push(Stack.push(stack, a), a), a)
            "ć" -> Stack.push(Stack.push(stack, GeneralCommands.dehead(a)), GeneralCommands.head(a))
            "Â" -> Stack.push(Stack.push(stack, a), if is_iterable(a) do a |> Enum.reverse else to_string(a) |> String.reverse end)
            "ê" -> Stack.push(stack, if is_iterable(a) do Enum.sort(Enum.to_list(a)) |> ListCommands.uniques else Enum.join(Enum.sort(String.graphemes(to_string(a))) |> ListCommands.uniques, "") end)
            "{" -> Stack.push(stack, if is_iterable(a) do Enum.sort(eval(a)) else Enum.join(Enum.sort(String.graphemes(to_string(a)))) end)
            "`" -> %Stack{elements: Enum.reverse(if is_iterable(a) do Enum.to_list(a) else String.graphemes(to_string(a)) end) ++ stack.elements}
            "O" -> if is_iterable(a) do Stack.push(stack, ListCommands.sum(a)) else Stack.push(%Stack{}, ListCommands.sum(Stack.push(stack, a).elements)) end
            "Æ" -> if is_iterable(a) do Stack.push(stack, ListCommands.reduce_subtraction(a)) else Stack.push(%Stack{}, ListCommands.reduce_subtraction(Stack.push(stack, a).elements |> Enum.reverse)) end
            "P" -> if is_iterable(a) do Stack.push(stack, ListCommands.product(a)) else Stack.push(%Stack{}, ListCommands.product(Stack.push(stack, a).elements)) end
            "J" -> if is_iterable(a) do Stack.push(stack, ListCommands.join(a, "")) else Stack.push(%Stack{}, ListCommands.join(Enum.reverse(Stack.push(stack, to_string(a)).elements), "")) end
            "»" -> if is_iterable(a) do Stack.push(stack, ListCommands.grid_join(a)) else Stack.push(%Stack{}, ListCommands.grid_join(Enum.reverse(Stack.push(stack, to_string(a)).elements))) end
            "U" -> Globals.set(%{Globals.get() | x: a}); stack
            "V" -> Globals.set(%{Globals.get() | y: a}); stack
            "ˆ" -> global_env = Globals.get(); Globals.set(%{global_env | array: global_env.array ++ [a]}); stack
            "½" -> if GeneralCommands.equals(a, 1) do global_env = Globals.get(); Globals.set(%{global_env | counter_variable: global_env.counter_variable + 1}) end; stack
            "," -> Output.print(a); stack
            "=" -> Output.print(a); Stack.push(stack, a)
            "?" -> Output.print(a, false); stack
            "–" -> if GeneralCommands.equals(a, 1) do Output.print(environment.range_variable) end; stack
            "—" -> if GeneralCommands.equals(a, 1) do Output.print(environment.range_element) end; stack
           ".M" -> a = to_list(a); Stack.push(stack, Enum.max_by(a, fn x -> Enum.count(a, fn y -> GeneralCommands.equals(x, y) end) end))
           ".m" -> a = to_list(a); Stack.push(stack, Enum.min_by(a, fn x -> Enum.count(a, fn y -> GeneralCommands.equals(x, y) end) end))
           ".W" -> :timer.sleep(to_integer(a)); stack
           "\\" -> stack

           # Extended commands
           "ÅA" -> Stack.push(stack, call_unary(fn x -> IntCommands.arithmetic_mean(to_list(x)) end, a, true))
           "Å!" -> Stack.push(stack, call_unary(fn x -> ListCommands.unfold_up_to(0, &IntCommands.factorial/1, to_integer(x)) end, a))
           "ÅF" -> Stack.push(stack, call_unary(fn x -> ListCommands.unfold_up_to(0, &IntCommands.fibonacci/1, to_integer(x)) end, a))
           "ÅG" -> Stack.push(stack, call_unary(fn x -> ListCommands.unfold_up_to(0, &IntCommands.lucas/1, to_integer(x)) end, a))
           "ÅP" -> Stack.push(stack, call_unary(fn x -> ListCommands.unfold_up_to(0, &IntCommands.nth_prime/1, to_integer(x)) end, a))
           "ÅT" -> Stack.push(stack, call_unary(fn x -> ListCommands.unfold_up_to(0, fn n -> div(n * (n + 1), 2) end, to_integer(x)) end, a))
           "Åp" -> Stack.push(stack, call_unary(fn x -> ListCommands.generate_n(2, &IntCommands.next_prime/1, to_integer(x)) end, a))
           "ÅÈ" -> Stack.push(stack, call_unary(fn x -> ListCommands.unfold_up_to(0, fn n -> 2 * n end, to_integer(x)) end, a))
           "ÅÉ" -> Stack.push(stack, call_unary(fn x -> ListCommands.unfold_up_to(0, fn n -> 2 * n + 1 end, to_integer(x)) end, a))
           "Å|" -> Stack.push(stack, call_unary(fn x -> MatrixCommands.columns_of(x) end, a, true))
           "Å0" -> Stack.push(stack, call_unary(fn x -> List.duplicate(0, to_integer!(x)) end, a))
           "Å1" -> Stack.push(stack, call_unary(fn x -> List.duplicate(1, to_integer!(x)) end, a))
           "Å2" -> Stack.push(stack, call_unary(fn x -> List.duplicate(2, to_integer!(x)) end, a))
           "Å3" -> Stack.push(stack, call_unary(fn x -> List.duplicate(3, to_integer!(x)) end, a))
           "Å4" -> Stack.push(stack, call_unary(fn x -> List.duplicate(4, to_integer!(x)) end, a))
           "Å5" -> Stack.push(stack, call_unary(fn x -> List.duplicate(5, to_integer!(x)) end, a))
           "Å6" -> Stack.push(stack, call_unary(fn x -> List.duplicate(6, to_integer!(x)) end, a))
           "Å7" -> Stack.push(stack, call_unary(fn x -> List.duplicate(7, to_integer!(x)) end, a))
           "Å8" -> Stack.push(stack, call_unary(fn x -> List.duplicate(8, to_integer!(x)) end, a))
           "Å9" -> Stack.push(stack, call_unary(fn x -> List.duplicate(9, to_integer!(x)) end, a))
           "Åœ" -> Stack.push(stack, call_unary(fn x -> ListCommands.integer_partitions(to_integer!(x)) end, a))
           "Åf" -> Stack.push(stack, call_unary(fn x -> IntCommands.fibonacci(to_number!(x)) end, a))
           "Åg" -> Stack.push(stack, call_unary(fn x -> IntCommands.lucas(to_number!(x)) end, a))
           "Å²" -> Stack.push(stack, call_unary(fn x -> to_number!(IntCommands.is_square?(to_number!(x))) end, a))
           "ÅM" -> Stack.push(stack, call_unary(fn x -> IntCommands.prev_prime_from_arbitrary(to_number!(x)) end, a))
           "ÅN" -> Stack.push(stack, call_unary(fn x -> IntCommands.next_prime_from_arbitrary(to_number!(x)) end, a))
           "Ån" -> Stack.push(stack, call_unary(fn x -> IntCommands.nearest_prime_from_arbitrary(to_number(x)) end, a))
           "Å=" -> Stack.push(stack, call_unary(fn x -> ListCommands.deck_shuffle(to_list(x)) end, a, true))
           "Å≠" -> Stack.push(stack, call_unary(fn x -> ListCommands.deck_unshuffle(to_list(x)) end, a, true))
           "Åm" -> Stack.push(stack, call_unary(fn x -> IntCommands.median(Enum.to_list(to_number(to_list(x)))) end, a, true))
           "Ås" -> Stack.push(stack, call_unary(fn x -> ListCommands.middle_of(x) end, a, true))
           "Å¼" -> Stack.push(stack, call_unary(fn x -> :math.tan(to_number(x)) end, a))
           "Å½" -> Stack.push(stack, call_unary(fn x -> :math.sin(to_number(x)) end, a))
           "Å¾" -> Stack.push(stack, call_unary(fn x -> :math.cos(to_number(x)) end, a))
          "Å\\" -> Stack.push(stack, MatrixCommands.left_diagonal(a))
           "Å/" -> Stack.push(stack, MatrixCommands.right_diagonal(a))
           "Åu" -> Stack.push(stack, MatrixCommands.upper_triangular_matrix(a))
           "Ål" -> Stack.push(stack, MatrixCommands.lower_triangular_matrix(a))
           "Åγ" -> {elements, lengths} = call_unary(fn x -> StrCommands.run_length_encode(x) end, a, true); Stack.push(Stack.push(stack, elements), lengths)
        end

        {new_stack, environment}
    end
end
