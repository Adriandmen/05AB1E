defmodule Interp.Environment do
    alias Reading.InputHandler

    defstruct range_variable: 0,
              range_element: ""
end


defmodule Interp.Interpreter do
    alias Interp.Stack
    alias Interp.Environment
    alias Interp.Globals
    alias Interp.Output
    alias Commands.ListCommands
    alias Commands.StrCommands
    alias Commands.IntCommands
    alias Commands.GeneralCommands
    alias Reading.InputHandler
    import Interp.Functions
    use Bitwise

    def interp_nullary(op, stack, environment) do
        new_stack = case op do
            "∞" -> Stack.push(stack, ListCommands.listify(1, :infinity))
            "т" -> Stack.push(stack, 100)
            "₁" -> Stack.push(stack, 256)
            "₂" -> Stack.push(stack, 26)
            "₃" -> Stack.push(stack, 95)
            "₄" -> Stack.push(stack, 1000)
            "A" -> Stack.push(stack, "abcdefghijklmnopqrstuvwxyz")
            "T" -> Stack.push(stack, 10)
            "®" -> Stack.push(stack, Globals.get().c)
            "N" -> Stack.push(stack, environment.range_variable)
            "y" -> Stack.push(stack, environment.range_element)
            "X" -> Stack.push(stack, Globals.get().x)
            "Y" -> Stack.push(stack, Globals.get().y)
            "¾" -> Stack.push(stack, Globals.get().counter_variable)
            "¶" -> Stack.push(stack, "\n")
            "õ" -> Stack.push(stack, "")
            "q" -> Globals.set(%{Globals.get() | status: :quit}); stack
            "¼" -> global_env = Globals.get(); Globals.set(%{global_env | counter_variable: global_env.counter_variable + 1}); stack
            "w" -> :timer.sleep(1000); stack
            "ža" -> {_, {hour, _, _}} = :calendar.local_time(); Stack.push(stack, hour)
            "žb" -> {_, {_, minute, _}} = :calendar.local_time(); Stack.push(stack, minute)
            "žc" -> {_, {_, _, second}} = :calendar.local_time(); Stack.push(stack, second)
            "žd" -> Stack.push(stack, div(rem(:os.system_time(), 100000000), 100))
            "že" -> {{_, _, day}, _} = :calendar.local_time(); Stack.push(stack, day)
            "žf" -> {{_, month, _}, _} = :calendar.local_time(); Stack.push(stack, month)
            "žg" -> {{year, _, _}, _} = :calendar.local_time(); Stack.push(stack, year)
            "žh" -> Stack.push(stack, "0123456789")
            "ži" -> Stack.push(stack, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
            "žj" -> Stack.push(stack, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_")
            "žk" -> Stack.push(stack, "zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA")
            "žl" -> Stack.push(stack, "zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA9876543210_")
            "žm" -> Stack.push(stack, "9876543210")
            "žn" -> Stack.push(stack, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
            "žo" -> Stack.push(stack, "ZYXWVUTSRQPONMLKJIHGFEDCBAzyxwvutsrqponmlkjihgfedcba")
            "žp" -> Stack.push(stack, "ZYXWVUTSRQPONMLKJIHGFEDCBA")
            "žq" -> Stack.push(stack, 3.141592653589793)
            "žr" -> Stack.push(stack, 2.718281828459045)
            "žu" -> Stack.push(stack, "()<>[]{}")
            "žv" -> Stack.push(stack, 16)
            "žw" -> Stack.push(stack, 32)
            "žx" -> Stack.push(stack, 64)
            "žy" -> Stack.push(stack, 128)
            "žz" -> Stack.push(stack, 256)
            "žA" -> Stack.push(stack, 512)
            "žB" -> Stack.push(stack, 1024)
            "žC" -> Stack.push(stack, 2048)
            "žD" -> Stack.push(stack, 4096)
            "žE" -> Stack.push(stack, 8192)
            "žF" -> Stack.push(stack, 16384)
            "žG" -> Stack.push(stack, 32768)
            "žH" -> Stack.push(stack, 65536)
            "žI" -> Stack.push(stack, 2147483648)
            "žJ" -> Stack.push(stack, 4294967296)
            "žK" -> Stack.push(stack, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
            "žL" -> Stack.push(stack, "zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA9876543210")
            "žM" -> Stack.push(stack, "aeiou")
            "žN" -> Stack.push(stack, "bcdfghjklmnpqrstvwxyz")
            "žO" -> Stack.push(stack, "aeiouy")
            "žP" -> Stack.push(stack, "bcdfghjklmnpqrstvwxz")
            "žQ" -> Stack.push(stack, " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~")
            "žR" -> Stack.push(stack, "ABC")
            "žS" -> Stack.push(stack, "qwertyuiop")
            "žT" -> Stack.push(stack, "asdfghjkl")
            "žU" -> Stack.push(stack, "zxcvbnm")
            "žV" -> Stack.push(stack, ["qwertyuiop", "asdfghjkl", "zxcvbnm"])
            "žW" -> Stack.push(stack, "qwertyuiopasdfghjklzxcvbnm")
        end

        {new_stack, environment}
    end

    def interp_unary(op, stack, environment) do
        {a, stack} = Stack.pop(stack)
        new_stack = case op do
            ">" -> Stack.push(stack, call_unary(fn x -> to_number(x) + 1 end, a))
            "<" -> Stack.push(stack, call_unary(fn x -> to_number(x) - 1 end, a))
            "L" -> Stack.push(stack, call_unary(fn x -> ListCommands.listify(1, to_number(x)) end, a))
            "Ý" -> Stack.push(stack, call_unary(fn x -> ListCommands.listify(0, to_number(x)) end, a))
            "!" -> Stack.push(stack, call_unary(fn x -> IntCommands.factorial(to_number(x)) end, a))
            "η" -> Stack.push(stack, call_unary(fn x -> ListCommands.prefixes(x) end, a, true))
            "н" -> Stack.push(stack, call_unary(fn x -> GeneralCommands.head(x) end, a, true))
            "θ" -> Stack.push(stack, call_unary(fn x -> GeneralCommands.tail(x) end, a, true))
            "Θ" -> Stack.push(stack, call_unary(fn x -> to_number(to_number(x) == 1) end, a))
            "≠" -> Stack.push(stack, call_unary(fn x -> to_number(to_number(x) != 1) end, a))
            "_" -> Stack.push(stack, call_unary(fn x -> to_number(to_number(x) == 0) end, a))
            "(" -> Stack.push(stack, call_unary(fn x -> to_number(x) * -1 end, a))
            "a" -> Stack.push(stack, call_unary(fn x -> to_number(Regex.match?(~r/^[a-zA-Z]+$/, to_string(x))) end, a))
            "d" -> Stack.push(stack, call_unary(fn x -> to_number(Regex.match?(~r/^\d+$/, to_string(x))) end, a))
            "b" -> Stack.push(stack, call_unary(fn x -> IntCommands.to_base(to_number(x), 2) end, a))
            "h" -> Stack.push(stack, call_unary(fn x -> IntCommands.to_base(to_number(x), 16) end, a))
            "p" -> Stack.push(stack, call_unary(fn x -> to_number(IntCommands.is_prime?(to_number(x))) end, a))
            "z" -> Stack.push(stack, call_unary(fn x -> 1 / to_number(x) end, a))
            "C" -> Stack.push(stack, call_unary(fn x -> IntCommands.string_from_base(to_non_number(x), 2) end, a))
            "S" -> Stack.push(stack, call_unary(fn x -> ListCommands.split_individual(x) end, a, true))
            "H" -> Stack.push(stack, call_unary(fn x -> IntCommands.string_from_base(String.upcase(to_non_number(x)), 16) end, a))
            "R" -> Stack.push(stack, call_unary(fn x -> cond do (is_iterable(x) -> Enum.reverse(x); true -> String.reverse(to_string(x))) end end, a, true))
            "o" -> Stack.push(stack, call_unary(fn x -> IntCommands.pow(2, to_number(x)) end, a))
            "n" -> Stack.push(stack, call_unary(fn x -> IntCommands.pow(to_number(x), 2) end, a))
            "u" -> Stack.push(stack, call_unary(fn x -> String.upcase(to_string(x)) end, a))
            "l" -> Stack.push(stack, call_unary(fn x -> String.downcase(to_string(x)) end, a))
            "g" -> Stack.push(stack, call_unary(fn x -> cond do (is_iterable(x) -> length(Enum.to_list(x)); true -> String.length(to_string(x))) end end, a, true))
            ";" -> Stack.push(stack, call_unary(fn x -> to_number(x) / 2 end, a))
            "ï" -> Stack.push(stack, call_unary(fn x -> to_number(x) end, a))
            "§" -> Stack.push(stack, call_unary(fn x -> to_non_number(x) end, a))
            "±" -> Stack.push(stack, call_unary(fn x -> ~~~to_number(x) end, a))
            "Ā" -> Stack.push(stack, call_unary(fn x -> to_number(not(to_number(x) == 0 or x == "")) end, a))
            "Ć" -> Stack.push(stack, call_unary(fn x -> GeneralCommands.enclose(x) end, a, true))
            "Ì" -> Stack.push(stack, call_unary(fn x -> to_number(x) + 2 end, a))
            "Í" -> Stack.push(stack, call_unary(fn x -> to_number(x) - 2 end, a))
            "·" -> Stack.push(stack, call_unary(fn x -> to_number(x) * 2 end, a))
            "Ä" -> Stack.push(stack, call_unary(fn x -> abs(to_number(x)) end, a))
            "™" -> Stack.push(stack, call_unary(fn x -> StrCommands.title_case(to_string(x)) end, a))
            "š" -> Stack.push(stack, call_unary(fn x -> StrCommands.switch_case(to_string(x)) end, a))
            "ª" -> Stack.push(stack, call_unary(fn x -> StrCommands.sentence_case(to_string(x)) end, a))
            "È" -> Stack.push(stack, call_unary(fn x -> to_number(is_integer(to_number(x)) and IntCommands.mod(to_number(x), 2) == 0) end, a))
            "É" -> Stack.push(stack, call_unary(fn x -> to_number(is_integer(to_number(x)) and IntCommands.mod(to_number(x), 2) == 1) end, a))
            "°" -> Stack.push(stack, call_unary(fn x -> IntCommands.pow(10, to_number(x)) end, a))
            "Ç" -> Stack.push(stack, call_unary(fn x -> StrCommands.to_codepoints(x) end, a, true))
            "ç" -> Stack.push(stack, call_unary(fn x -> List.to_string [to_number(x)] end, a))
            "f" -> Stack.push(stack, call_unary(fn x -> IntCommands.prime_factors(to_number(x)) |> Stream.dedup end, a))
            "Ò" -> Stack.push(stack, call_unary(fn x -> IntCommands.prime_factors(to_number(x)) end, a))
            "Ó" -> Stack.push(stack, call_unary(fn x -> IntCommands.prime_exponents(to_number(x)) end, a))
            "é" -> Stack.push(stack, a |> Enum.sort_by(fn x -> GeneralCommands.length_of(x) end))
            "í" -> Stack.push(stack, a |> Stream.map(fn x -> if is_iterable(x) do Enum.to_list(x) |> Enum.reverse else String.reverse(to_string(x)) end end))
            "Ω" -> Stack.push(stack, if is_iterable(a) do Enum.random(Enum.to_list(a)) else Enum.random(String.graphemes(to_string(a))) end)
            # "æ" -> Stack.push(stack, if is_iterable(a) do ListCommands.powerset(a |> Enum.to_list) else ListCommands.powerset(String.graphemes(to_string(a))) |> Enum.map(fn x -> Enum.join(x, "") end) end)
            "œ" -> Stack.push(stack, if is_iterable(a) do ListCommands.permutations(a) else ListCommands.permutations(String.graphemes(to_string(a))) |> Enum.map(fn x -> Enum.join(x, "") end) end)
            "À" -> Stack.push(stack, ListCommands.rotate(a, 1))
            "Á" -> Stack.push(stack, ListCommands.rotate(a, -1))
            "Ù" -> Stack.push(stack, ListCommands.uniques(a))
            "Œ" -> Stack.push(stack, ListCommands.substrings(a))
            "γ" -> Stack.push(stack, ListCommands.group_equal(a))
           ".s" -> Stack.push(stack, ListCommands.suffixes(a))
            "á" -> Stack.push(stack, StrCommands.keep_letters(to_non_number(a)))
            "þ" -> Stack.push(stack, StrCommands.keep_digits(to_non_number(a)))
            "∊" -> Stack.push(stack, StrCommands.vertical_mirror(a))
            "˜" -> Stack.push(stack, ListCommands.deep_flatten(a))
            "¸" -> Stack.push(stack, [a])
            "Ë" -> Stack.push(stack, to_number(GeneralCommands.all_equal(a)))
            "ƶ" -> Stack.push(stack, ListCommands.lift(a))
            "¦" -> Stack.push(stack, GeneralCommands.dehead(a))
            "¨" -> Stack.push(stack, GeneralCommands.detail(a))
            "¥" -> Stack.push(stack, ListCommands.deltas(a))
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
            "{" -> Stack.push(stack, if is_iterable(a) do Enum.sort(Enum.to_list(a)) else Enum.join(Enum.sort(String.graphemes(to_string(a)))) end)
            "`" -> %Stack{elements: Enum.reverse(if is_iterable(a) do Enum.to_list(a) else String.graphemes(to_string(a)) end) ++ stack.elements}
            "O" -> if is_iterable(a) do Stack.push(stack, ListCommands.sum(a)) else Stack.push(%Stack{}, ListCommands.sum(Stack.push(stack, a).elements)) end
            "Æ" -> if is_iterable(a) do Stack.push(stack, ListCommands.reduce_subtraction(a)) else Stack.push(%Stack{}, ListCommands.reduce_subtraction(Stack.push(stack, a).elements |> Enum.reverse)) end
            "P" -> if is_iterable(a) do Stack.push(stack, ListCommands.product(a)) else Stack.push(%Stack{}, ListCommands.product(Stack.push(stack, a).elements)) end
            "J" -> if is_iterable(a) do Stack.push(stack, ListCommands.join(a, "")) else Stack.push(%Stack{}, ListCommands.join(Enum.reverse(Stack.push(stack, to_string(a)).elements), "")) end
            "»" -> if is_iterable(a) do Stack.push(stack, ListCommands.grid_join(a)) else Stack.push(%Stack{}, ListCommands.grid_join(Enum.reverse(Stack.push(stack, to_string(a)).elements))) end
            "U" -> Globals.set(%{Globals.get() | x: a}); stack
            "V" -> Globals.set(%{Globals.get() | y: a}); stack
            "½" -> if GeneralCommands.equals(a, 1) do global_env = Globals.get(); Globals.set(%{global_env | counter_variable: global_env.counter_variable + 1}) end; stack
            "," -> Output.print(a); stack
            "=" -> Output.print(a); Stack.push(stack, a)
            "?" -> Output.print(a, false); stack
            "–" -> if GeneralCommands.equals(a, 1) do Output.print(environment.range_variable) end; stack
            "—" -> if GeneralCommands.equals(a, 1) do Output.print(environment.range_element) end; stack
            "\\" -> stack
        end

        {new_stack, environment}
    end

    def interp_binary(op, stack, environment) do
        {b, stack} = Stack.pop(stack)
        {a, stack} = Stack.pop(stack)

        new_stack = case op do
            "α" -> Stack.push(stack, call_binary(fn x, y -> abs(to_number(x) - to_number(y)) end, a, b))
            "β" -> Stack.push(stack, call_binary(fn x, y -> IntCommands.list_from_base(to_number(x), to_number(y)) end, a, b, true, false))
            "+" -> Stack.push(stack, call_binary(fn x, y -> to_number(x) + to_number(y) end, a, b))
            "-" -> Stack.push(stack, call_binary(fn x, y -> to_number(x) - to_number(y) end, a, b))
            "/" -> Stack.push(stack, call_binary(fn x, y -> to_number(x) / to_number(y) end, a, b))
            "*" -> Stack.push(stack, call_binary(fn x, y -> to_number(x) * to_number(y) end, a, b))
            "%" -> Stack.push(stack, call_binary(fn x, y -> IntCommands.mod(to_number(x), to_number(y)) end, a, b))
            "&" -> Stack.push(stack, call_binary(fn x, y -> to_number(x) &&& to_number(y) end, a, b))
            "^" -> Stack.push(stack, call_binary(fn x, y -> to_number(x) ^^^ to_number(y) end, a, b))
            "~" -> Stack.push(stack, call_binary(fn x, y -> to_number(x) ||| to_number(y) end, a, b))
            "B" -> Stack.push(stack, call_binary(fn x, y -> IntCommands.to_base(to_number(x), to_number(y)) end, a, b))
            "c" -> Stack.push(stack, call_binary(fn x, y -> IntCommands.n_choose_k(to_number(x), to_number(y)) end, a, b))
            "e" -> Stack.push(stack, call_binary(fn x, y -> IntCommands.n_permute_k(to_number(x), to_number(y)) end, a, b))
            "m" -> Stack.push(stack, call_binary(fn x, y -> IntCommands.pow(to_number(x), to_number(y)) end, a, b))
            "K" -> Stack.push(stack, call_binary(fn x, y -> ListCommands.remove_from(x, y, false) end, a, b, true, true))
            "å" -> Stack.push(stack, call_binary(fn x, y -> to_number(ListCommands.contains(to_non_number(x), y)) end, a, b, true, false))
            "è" -> Stack.push(stack, call_binary(fn x, y -> GeneralCommands.element_at(x, to_number(y)) end, a, b, true, false))
            "£" -> Stack.push(stack, call_binary(fn x, y -> ListCommands.take_first(x, to_number(y)) end, a, b, true, true))
            "м" -> Stack.push(stack, call_binary(fn x, y -> GeneralCommands.remove_from(x, y) end, a, b, true, true))
            "‰" -> Stack.push(stack, call_binary(fn x, y -> [IntCommands.divide(to_number(x), to_number(y)), IntCommands.mod(to_number(x), to_number(y))] end, a, b))
            "‹" -> Stack.push(stack, call_binary(fn x, y -> to_number(to_number(x) < to_number(y)) end, a, b))
            "›" -> Stack.push(stack, call_binary(fn x, y -> to_number(to_number(x) > to_number(y)) end, a, b))
            "ô" -> Stack.push(stack, call_binary(fn x, y -> ListCommands.split_into(x, to_number(y)) end, a, b, true, false))
            "Ö" -> Stack.push(stack, call_binary(fn x, y -> to_number(IntCommands.mod(to_number(x), to_number(y)) == 0) end, a, b))
            "ù" -> Stack.push(stack, call_binary(fn x, y -> ListCommands.keep_with_length(x, to_number(y)) end, a, b, true, false))
            "k" -> Stack.push(stack, call_binary(fn x, y -> ListCommands.index_in(x, y) end, a, b, true, false))
            "и" -> Stack.push(stack, call_binary(fn x, y -> ListCommands.list_multiply(x, to_number(y)) end, a, b, true, false))
            "¢" -> Stack.push(stack, call_binary(fn x, y -> GeneralCommands.count(x, y) end, a, b, true, false))
            "в" -> Stack.push(stack, call_binary(fn x, y -> IntCommands.to_base_arbitrary(to_number(x), to_number(y)) end, a, b))
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
        end

        {new_stack, environment}
    end

    def interp_ternary(op, stack, environment) do
        {c, stack} = Stack.pop(stack)
        {b, stack} = Stack.pop(stack)
        {a, stack} = Stack.pop(stack)

        new_stack = case op do
            "ǝ" -> Stack.push(stack, call_ternary(fn x, y, z -> StrCommands.insert_at(x, y, z) end, a, b, c, true, true, true))
            "Š" -> Stack.push(Stack.push(Stack.push(stack, c), a), b)
            "‡" -> Stack.push(stack, StrCommands.transliterate(a, b, c))
        end

        {new_stack, environment}
    end

    def interp_special(op, stack, environment) do
        case op do
            ")" -> 
                {%Stack{elements: [stream(Enum.reverse(stack.elements))]}, environment}
            "r" -> 
                {%Stack{elements: stack.elements |> Enum.reverse}, environment}
            "©" ->
                {a, _} = Stack.pop(stack)
                Globals.set(%{Globals.get() | c: a})
                {stack, environment}
            "¹" -> 
                {element, new_env} = Globals.get_input(0)
                {Stack.push(stack, element), new_env}
            "²" -> 
                {element, new_env} = Globals.get_input(1)
                {Stack.push(stack, element), new_env}
            "³" -> 
                {element, new_env} = Globals.get_input(2)
                {Stack.push(stack, element), new_env}
            "I" -> {Stack.push(stack, InputHandler.read_input()), environment}
            "$" -> {Stack.push(Stack.push(stack, 1), InputHandler.read_input()), environment}
            "Î" -> {Stack.push(Stack.push(stack, 0), InputHandler.read_input()), environment}
            "#" ->
                {element, new_stack} = Stack.pop(stack)
                cond do
                    is_iterable(element) or String.contains?(to_string(element), " ") -> {Stack.push(new_stack, ListCommands.split_on(element, " ")), environment}
                    GeneralCommands.equals(to_number(element), 1) ->
                        global_env = Globals.get() 
                        Globals.set(%{global_env | status: :break})
                        {new_stack, environment}
                    true -> {new_stack, environment}
                end
            "M" ->
                if length(stack.elements) == 0 do
                    {a, stack} = Stack.pop(stack)
                    {Stack.push(stack, IntCommands.max_of(stack.elements)), environment}
                else
                    {Stack.push(stack, IntCommands.max_of(stack.elements)), environment}
                end
            "ã" -> 
                {b, stack} = Stack.pop(stack)
                if is_iterable(b) do
                    {Stack.push(stack, ListCommands.cartesian_repeat(b, 2)), environment}
                else
                    {a, stack} = Stack.pop(stack)
                    {Stack.push(stack, call_binary(fn x, y -> ListCommands.cartesian_repeat(x, to_number(y)) end, a, b, true, false)), environment}
                end
            "Ÿ" -> 
                {b, stack} = Stack.pop(stack)
                if is_iterable(b) do 
                    {Stack.push(stack, ListCommands.rangify(to_number(b))), environment} 
                else 
                    {a, stack} = Stack.pop(stack)
                    {Stack.push(stack, to_number(a)..to_number(b)), environment}
                end
            "ø" -> 
                {b, stack} = Stack.pop(stack)
                if is_iterable(b) and is_iterable(List.first(Enum.take(b, 1))) do 
                    {Stack.push(stack, ListCommands.zip(b)), environment}
                else
                    {a, stack} = Stack.pop(stack)
                    {Stack.push(stack, ListCommands.zip(a, b)), environment}
                end
            "ζ" ->
                {c, stack} = Stack.pop(stack)
                if is_iterable(c) and is_iterable(List.first(Enum.take(c, 1))) do
                    {Stack.push(stack, ListCommands.zip_with_filler(c, " ")), environment}
                else
                    {b, stack} = Stack.pop(stack)
                    if is_iterable(c) and is_iterable(b) do
                        {Stack.push(stack, ListCommands.zip_with_filler(b, c, " ")), environment}
                    else 
                        if is_iterable(b) and is_iterable(List.first(Enum.take(b, 1))) do
                            {Stack.push(stack, ListCommands.zip_with_filler(b, c)), environment}
                        else
                            {a, stack} = Stack.pop(stack)
                            result = cond do
                                not is_iterable(a) and not is_iterable(b) -> ListCommands.zip_with_filler(a, b, c) |> Stream.map(fn x -> Enum.join(Enum.to_list(x), "") end)
                                true -> ListCommands.zip_with_filler(a, b, c)
                            end
                            {Stack.push(stack, result), environment}
                        end
                    end
                end
            "ι" ->
                {b, stack} = Stack.pop(stack)
                if is_iterable(b) do
                    {Stack.push(stack, ListCommands.extract_every(b, 2)), environment}
                else
                    {a, stack} = Stack.pop(stack)
                    {Stack.push(stack, ListCommands.extract_every(a, to_number(b))), environment}
                end
            "¿" ->
                {b, stack} = Stack.pop(stack)
                if is_iterable(b) do
                    {Stack.push(stack, Enum.reduce(to_number(b), &IntCommands.gcd_of/2)), environment}
                else
                    {a, stack} = Stack.pop(stack)
                    {Stack.push(stack, IntCommands.gcd_of(to_number(a), to_number(b))), environment}
                end
        end
    end

    def interp_subprogram(op, subcommands, stack, environment) do
        case op do
            # For N in range [0, n)
            "F" ->
                {a, stack} = Stack.pop(stack)
                current_n = environment.range_variable
                {new_stack, new_env} = GeneralCommands.loop(subcommands, stack, environment, 0, to_number(a) - 1)
                {new_stack, %{new_env | range_variable: current_n}}

            # For N in range [1, n)
            "G" ->
                {a, stack} = Stack.pop(stack)
                current_n = environment.range_variable
                {new_stack, new_env} = GeneralCommands.loop(subcommands, stack, environment, 1, to_number(a) - 1)
                {new_stack, %{new_env | range_variable: current_n}}

            # For N in range [0, n]
            "ƒ" ->
                {a, stack} = Stack.pop(stack)
                current_n = environment.range_variable
                {new_stack, new_env} = GeneralCommands.loop(subcommands, stack, environment, 0, to_number(a))
                {new_stack, %{new_env | range_variable: current_n}}

            # Infinite loop
            "[" ->
                current_n = environment.range_variable
                {new_stack, new_env} = GeneralCommands.loop(subcommands, stack, environment, 0, -1)
                {new_stack, %{new_env | range_variable: current_n}}
            
            # Iterate through string
            "v" ->
                {a, stack} = Stack.pop(stack)
                current_n = environment.range_variable
                current_y = environment.range_element
                {new_stack, new_env} = GeneralCommands.loop(subcommands, stack, environment, 0, if is_iterable(a) do a else to_non_number(a) end)
                {new_stack, %{new_env | range_variable: current_n, range_element: current_y}}

            # Filter by
            "ʒ" ->
                {a, stack} = Stack.pop(stack)
                result = a 
                        |> Stream.with_index 
                        |> Stream.transform(environment, fn ({x, index}, curr_env) ->
                            {result_stack, new_env} = interp(subcommands, %Stack{elements: [x]}, %{curr_env | range_variable: index, range_element: x})
                            {result, _} = Stack.pop(result_stack)
                            case to_number(result) do
                                1 -> {[x], new_env}
                                _ -> {[], new_env}
                            end
                        end)
                        |> Stream.map(fn x -> x end)
                {Stack.push(stack, result), environment}
            
            # Map for each
            "ε" ->
                {a, stack} = Stack.pop(stack)
                result = a
                        |> Stream.with_index
                        |> Stream.transform(environment, fn ({x, index}, curr_env) ->
                            {result_stack, new_env} = interp(subcommands, %Stack{elements: [x]}, %{curr_env | range_variable: index, range_element: x})
                            {result, _} = Stack.pop(result_stack)
                            {[result], new_env} end)
                        |> Stream.map(fn x -> x end)
                {Stack.push(stack, result), environment}

            # Sort by (finite lists only)
            "Σ" ->
                {a, stack} = Stack.pop(stack)
                result = a
                        |> Stream.with_index
                        |> Stream.transform(environment, fn ({x, index}, curr_env) ->
                            {result_stack, new_env} = interp(subcommands, %Stack{elements: [x]}, %{curr_env | range_variable: index, range_element: x})
                            {result, _} = Stack.pop(result_stack)
                            {[{result, x}], new_env} end)
                        |> Enum.sort_by(fn {a, _} -> a end)
                        |> Stream.map(fn {_, x} -> x end)
                {Stack.push(stack, result), environment}

            # Run until a doesn't change
            "Δ" ->
                {a, stack} = Stack.pop(stack)
                {result, new_env} = GeneralCommands.run_while(a, subcommands, environment, 0)
                {Stack.push(stack, result), new_env}
            
            # Counter variable loop
            "µ" ->
                {a, stack} = Stack.pop(stack)
                GeneralCommands.counter_loop(subcommands, stack, environment, 0, to_number(a))
            
            # Map for each
            "€" ->
                {a, stack} = Stack.pop(stack)
                result = a
                        |> Stream.with_index
                        |> Stream.transform(environment, fn ({x, index}, curr_env) ->
                            {result_stack, new_env} = interp(subcommands, %Stack{elements: [x]}, %{curr_env | range_variable: index, range_element: x})
                            {result_stack.elements, new_env} end)
                        |> Stream.map(fn x -> x end)
                {Stack.push(stack, result), environment}
            
            # 2-arity map for each
            "δ" ->
                {b, stack} = Stack.pop(stack)
                {a, stack} = Stack.pop(stack)
                result = a |> Stream.map(fn y -> Stream.map(b, fn x ->
                    {result_stack, _} = interp(subcommands, %Stack{elements: [x, y]}, environment)
                    {result_elem, _} = Stack.pop(result_stack)
                    result_elem end)
                end)
                {Stack.push(stack, result), environment}
            
            # Pairwise command
            "ü" ->
                {a, stack} = Stack.pop(stack)
                result = a |> Stream.chunk_every(2, 1, :discard)
                           |> Stream.map(fn [x, y] ->        
                                {result_stack, _} = interp(subcommands, %Stack{elements: [x, y]}, environment)
                                {result_elem, _} = Stack.pop(result_stack)
                                result_elem end)
                {Stack.push(stack, result), environment}
        end
    end
    
    def interp_if_statement(if_statement, else_statement, stack, environment) do
        {a, stack} = Stack.pop(stack)
        if GeneralCommands.equals(a, 1) do
            interp(if_statement, stack, environment)
        else
            interp(else_statement, stack, environment)
        end
    end

    @doc """
    Interprets the given string by checking whether it contains the 'ÿ' interpolation character.
    By replacing each occurrence of 'ÿ' with the popped value from the string, we end up with the
    interpolated string. If a value is tried to be popped from an empty stack, and there is no remaining
    input left anymore, it cycles through the list of all popped values (i.e. [1, 2] → [1, 2, 1, 2, 1, 2, ...]).

    ## Parameters

     - string:      The string from which the 'ÿ' will be replaced with the values on the stack/input.
     - stack:       The current state of the stack.
     - environment: The current state of the environment.
    
    ## Returns

    Returns a tuple in the following format: {stack, environment}

    """
    def interp_string(string, stack, environment) do
        dissected_string = String.split(string, "ÿ")

        {elements, stack, environment} = Enum.reduce(Enum.slice(dissected_string, 0..-2), {[], stack, environment}, 
            fn (_, {acc, curr_stack, curr_env}) ->
                case Stack.pop(curr_stack) do
                    nil -> {acc, curr_stack, curr_env}
                    {x, new_stack} -> {acc ++ [x], new_stack, curr_env}
                end
            end)

        cond do
            elements == [] -> 
                {Stack.push(stack, string), environment}
            true -> 
                string = Enum.zip(Enum.slice(dissected_string, 0..-2), Stream.cycle(elements)) ++ [{hd(Enum.slice(dissected_string, -1..-1)), ""}]
                       |> Enum.reduce("", fn ({a, b}, acc) -> acc <> a <> b end)
                {Stack.push(stack, string), environment}
        end
    end
    
    def interp([], stack, environment), do: {stack, environment}
    def interp(commands, stack, environment) do
        Globals.initialize()
        
        [current_command | remaining] = commands

        case Globals.get().status do
            :ok -> 
                {new_stack, new_env} = case current_command do
                    {:number, value} -> {Stack.push(stack, value), environment}
                    {:string, value} -> interp_string(value, stack, environment)
                    {:nullary_op, op} -> interp_nullary(op, stack, environment)
                    {:unary_op, op} -> interp_unary(op, stack, environment)
                    {:binary_op, op} -> interp_binary(op, stack, environment)
                    {:ternary_op, op} -> interp_ternary(op, stack, environment)
                    {:special_op, op} -> interp_special(op, stack, environment)
                    {:subprogram, op, subcommands} -> interp_subprogram(op, subcommands, stack, environment)
                    {:if_statement, if_statement, else_statement} -> interp_if_statement(if_statement, else_statement, stack, environment)
                    {:no_op, _} -> {stack, environment}
                    {:eof, _} -> {stack, environment}
                    x -> IO.inspect x
                end
                interp(remaining, new_stack, new_env)
            :break -> {stack, environment}
            :quit -> {stack, environment}
        end
    end
end