defmodule Interp.Environment do
    defstruct range_variable: 0,
              range_element: "",
              recursive_environment: nil
end


defmodule Interp.RecursiveEnvironment do
    defstruct subprogram: nil,
              base_cases: nil,
              popped: 0
end


defmodule Interp.Interpreter do
    alias Interp.Stack
    alias Interp.Environment
    alias Interp.Globals
    alias Interp.Output
    alias Interp.Canvas
    alias Commands.ListCommands
    alias Commands.StrCommands
    alias Commands.IntCommands
    alias Commands.GeneralCommands
    alias Commands.MatrixCommands
    alias Reading.InputHandler
    alias Reading.Reader
    alias Parsing.Parser
    import Interp.Functions
    use Bitwise

    def interp_nullary(op, stack, environment) do
        new_stack = case op do
            "∞" -> Stack.push(stack, ListCommands.listify(1, :infinity))
            "т" -> Stack.push(stack, 100)
            "₁" -> Stack.push(stack, if environment.recursive_environment == nil do 256 else GeneralCommands.recursive_program(environment.recursive_environment.subprogram, environment.recursive_environment.base_cases, environment.range_variable - 1) end)
            "₂" -> Stack.push(stack, if environment.recursive_environment == nil do 26 else GeneralCommands.recursive_program(environment.recursive_environment.subprogram, environment.recursive_environment.base_cases, environment.range_variable - 2) end)
            "₃" -> Stack.push(stack, if environment.recursive_environment == nil do 95 else GeneralCommands.recursive_program(environment.recursive_environment.subprogram, environment.recursive_environment.base_cases, environment.range_variable - 3) end)
            "₄" -> Stack.push(stack, if environment.recursive_environment == nil do 1000 else GeneralCommands.recursive_program(environment.recursive_environment.subprogram, environment.recursive_environment.base_cases, environment.range_variable - 4) end)
            "A" -> Stack.push(stack, "abcdefghijklmnopqrstuvwxyz")
            "T" -> Stack.push(stack, 10)
            "®" -> Stack.push(stack, Globals.get().c)
            "N" -> Stack.push(stack, environment.range_variable)
            "y" -> Stack.push(stack, environment.range_element)
            "X" -> Stack.push(stack, Globals.get().x)
            "Y" -> Stack.push(stack, Globals.get().y)
            "¾" -> Stack.push(stack, Globals.get().counter_variable)
            "¯" -> Stack.push(stack, Globals.get().array)
            "¶" -> Stack.push(stack, "\n")
            "õ" -> Stack.push(stack, "")
            "ð" -> Stack.push(stack, " ")
            "λ" -> Stack.push(stack, 0..(environment.range_variable - 1) |> Stream.map(fn x -> GeneralCommands.recursive_program(environment.recursive_environment.subprogram, environment.recursive_environment.base_cases, x) end))
            "´" -> Globals.set(%{Globals.get() | array: []}); stack
            "q" -> Globals.set(%{Globals.get() | status: :quit}); stack
            "¼" -> global_env = Globals.get(); Globals.set(%{global_env | counter_variable: global_env.counter_variable + 1}); stack
            ".Z" -> :timer.sleep(1000); stack
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
            "žs" -> Stack.push(stack, IntCommands.continued_fraction(fn x -> if x == 0 do 0 else 2 * x - 1 end end, fn y -> if y == 1 do 4 else IntCommands.pow(y - 1, 2) end end))
            "žt" -> Stack.push(stack, IntCommands.continued_fraction(fn x -> if x == 0 do 2 else 1 + x end end, fn y -> if y == 0 do 2 else y + 1 end end))
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
            "žX" -> Stack.push(stack, "http://")
            "žY" -> Stack.push(stack, "https://")
            "žZ" -> Stack.push(stack, "http://www.")
            "žƵ" -> Stack.push(stack, "https://www.")
            "žÀ" -> Stack.push(stack, "aeiouAEIOU")
            "žÁ" -> Stack.push(stack, "aeiouyAEIOUY")
            ".À" -> %Stack{elements: ListCommands.rotate(stack.elements, -1) |> Enum.to_list}
            ".Á" -> %Stack{elements: ListCommands.rotate(stack.elements, 1) |> Enum.to_list}
            ".g" -> Stack.push(stack, GeneralCommands.length_of(stack.elements))
        end

        {new_stack, environment}
    end
    
    def interp_unary(op, stack, environment) do
        {a, stack, environment} = Stack.pop(stack, environment)
        try_default(fn -> interp_unary(op, stack, environment, a) end, fn _ -> {Stack.push(stack, a), environment} end)
    end
    defp interp_unary(op, stack, environment, a) do
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
            "È" -> Stack.push(stack, call_unary(fn x -> to_number(is_integer(to_number(x)) and IntCommands.mod(to_number(x), 2) == 0) end, a))
            "É" -> Stack.push(stack, call_unary(fn x -> to_number(is_integer(to_number(x)) and IntCommands.mod(to_number(x), 2) == 1) end, a))
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
           ".¼" -> Stack.push(stack, call_unary(fn x -> :math.tan(to_number(x)) end, a))
           ".½" -> Stack.push(stack, call_unary(fn x -> :math.sin(to_number(x)) end, a))
           ".¾" -> Stack.push(stack, call_unary(fn x -> :math.cos(to_number(x)) end, a))
           ".ï" -> Stack.push(stack, call_unary(fn x -> to_number(is_integer(to_number(x))) end, a))
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
            "{" -> Stack.push(stack, if is_iterable(a) do Enum.sort(Enum.to_list(a)) else Enum.join(Enum.sort(String.graphemes(to_string(a)))) end)
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
           ".W" -> :timer.sleep(to_number(a)); stack
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
          "Å\\" -> Stack.push(stack, MatrixCommands.left_diagonal(a))
           "Å/" -> Stack.push(stack, MatrixCommands.right_diagonal(a))
           "Åu" -> Stack.push(stack, MatrixCommands.upper_triangular_matrix(a))
           "Ål" -> Stack.push(stack, MatrixCommands.lower_triangular_matrix(a))
           "Åγ" -> {elements, lengths} = call_unary(fn x -> StrCommands.run_length_encode(x) end, a, true); Stack.push(Stack.push(stack, elements), lengths)
        end

        {new_stack, environment}
    end

    def interp_binary(op, stack, environment) do
        {b, stack, environment} = Stack.pop(stack, environment)
        {a, stack, environment} = Stack.pop(stack, environment)
        try_default(fn -> interp_binary(op, stack, environment, a, b) end, fn _ -> {Stack.push(stack, a), environment} end)
    end
    defp interp_binary(op, stack, environment, a, b) do
        new_stack = case op do
            "α" -> Stack.push(stack, call_binary(fn x, y -> abs(to_number(x) - to_number(y)) end, a, b))
            "β" -> Stack.push(stack, call_binary(fn x, y -> IntCommands.list_from_base(to_number(x), to_number(y)) end, a, b, true, false))
            "+" -> Stack.push(stack, call_binary(fn x, y -> to_number(x) + to_number(y) end, a, b))
            "-" -> Stack.push(stack, call_binary(fn x, y -> to_number(x) - to_number(y) end, a, b))
            "/" -> Stack.push(stack, call_binary(fn x, y -> to_number(x) / to_number(y) end, a, b))
            "*" -> Stack.push(stack, call_binary(fn x, y -> to_number(x) * to_number(y) end, a, b))
            "%" -> Stack.push(stack, call_binary(fn x, y -> IntCommands.mod(to_number(x), to_number(y)) end, a, b))
            "&" -> Stack.push(stack, call_binary(fn x, y -> to_integer!(x) &&& to_integer!(y) end, a, b))
            "^" -> Stack.push(stack, call_binary(fn x, y -> to_integer!(x) ^^^ to_integer!(y) end, a, b))
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
            "и" -> Stack.push(stack, call_binary(fn x, y -> ListCommands.list_multiply(x, to_number(y)) end, a, b, true, false))
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
           ".ý" -> Stack.push(stack, to_list(a) |> Stream.intersperse(b) |> Stream.map(fn x -> x end))
           ".o" -> Stack.push(stack, StrCommands.overlap(a, b))
           ".ø" -> Stack.push(stack, ListCommands.surround(a, b))
           ".å" -> Stack.push(stack, to_number(to_list(a) |> Enum.any?(fn x -> GeneralCommands.equals(x, b) end)))
           ".Q" -> Stack.push(stack, to_number(GeneralCommands.equals(a, b)))
            "Û" -> Stack.push(stack, ListCommands.remove_leading(a, b))
            "Ü" -> Stack.push(stack, ListCommands.remove_trailing(a, b))
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

    def interp_ternary(op, stack, environment) do
        {c, stack, environment} = Stack.pop(stack, environment)
        {b, stack, environment} = Stack.pop(stack, environment)
        {a, stack, environment} = Stack.pop(stack, environment)
        try_default(fn -> interp_ternary(op, stack, environment, a, b, c) end, fn _ -> {Stack.push(stack, a), environment} end)
    end
    defp interp_ternary(op, stack, environment, a, b, c) do

        new_stack = case op do
            "ǝ" -> Stack.push(stack, StrCommands.replace_at(a, b, to_integer!(c)))
            "Š" -> Stack.push(Stack.push(Stack.push(stack, c), a), b)
            "‡" -> Stack.push(stack, StrCommands.transliterate(a, b, c))
            ":" -> Stack.push(stack, StrCommands.replace_infinite(a, b, c))
            "Λ" -> global_env = Globals.get(); Globals.set(%{global_env | canvas: Canvas.write(global_env.canvas, to_integer!(a), to_non_number(b), to_non_number(c), environment)}); stack
           ".Λ" -> 
                global_env = Globals.get()
                new_canvas = Canvas.write(global_env.canvas, to_integer!(a), to_non_number(b), to_non_number(c), environment)
                Globals.set(%{global_env | canvas: new_canvas}); Stack.push(stack, Canvas.canvas_to_string(new_canvas))
           ".:" -> Stack.push(stack, StrCommands.replace_all(a, b, c))
           ".;" -> Stack.push(stack, StrCommands.replace_first(a, b, c))
        end

        {new_stack, environment}
    end

    def interp_special(op, stack, environment) do
        case op do
            ")" -> 
                {%Stack{elements: [Enum.reverse(stack.elements)]}, environment}
            "r" -> 
                {%Stack{elements: stack.elements |> Enum.reverse}, environment}
            "©" ->
                {a, _, environment} = Stack.pop(stack, environment)
                Globals.set(%{Globals.get() | c: a})
                {stack, environment}
            "¹" -> 
                element = Globals.get_input(0)
                {Stack.push(stack, element), environment}
            "²" -> 
                element = Globals.get_input(1)
                {Stack.push(stack, element), environment}
            "³" -> 
                element = Globals.get_input(2)
                {Stack.push(stack, element), environment}
            "I" -> {Stack.push(stack, InputHandler.read_input()), environment}
            "$" -> {Stack.push(Stack.push(stack, 1), InputHandler.read_input()), environment}
            "Î" -> {Stack.push(Stack.push(stack, 0), InputHandler.read_input()), environment}
            "|" -> {Stack.push(stack, InputHandler.read_until_newline()), environment}
            "#" ->
                {element, new_stack, environment} = Stack.pop(stack, environment)
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
                    {a, stack, environment} = Stack.pop(stack, environment)
                    {Stack.push(stack, IntCommands.max_of(stack.elements)), environment}
                else
                    {Stack.push(stack, IntCommands.max_of(stack.elements)), environment}
                end
            "ã" -> 
                {b, stack, environment} = Stack.pop(stack, environment)
                if is_iterable(b) do
                    {Stack.push(stack, ListCommands.cartesian_repeat(b, 2)), environment}
                else
                    {a, stack, environment} = Stack.pop(stack, environment)
                    {Stack.push(stack, call_binary(fn x, y -> ListCommands.cartesian_repeat(x, to_integer!(y)) end, a, b, true, false)), environment}
                end
            ".Æ" -> 
                {b, stack, environment} = Stack.pop(stack, environment)
                if is_iterable(b) do
                    {Stack.push(stack, ListCommands.combinations(Enum.to_list(to_list(b)), 2)), environment}
                else
                    {a, stack, environment} = Stack.pop(stack, environment)
                    {Stack.push(stack, call_binary(fn x, y -> ListCommands.combinations(Enum.to_list(to_list(x)), to_integer!(y)) end, a, b, true, false)), environment}
                end
            "Ÿ" -> 
                {b, stack, environment} = Stack.pop(stack, environment)
                if is_iterable(b) do 
                    {Stack.push(stack, ListCommands.rangify(to_integer!(b))), environment} 
                else 
                    {a, stack, environment} = Stack.pop(stack, environment)
                    {Stack.push(stack, to_integer!(a)..to_integer!(b)), environment}
                end
            "ø" -> 
                {b, stack, environment} = Stack.pop(stack, environment)
                if is_iterable(b) and is_iterable(List.first(Enum.take(b, 1))) do 
                    {Stack.push(stack, ListCommands.zip(b)), environment}
                else
                    {a, stack, environment} = Stack.pop(stack, environment)
                    {Stack.push(stack, ListCommands.zip(a, b)), environment}
                end
            "ζ" ->
                {c, stack, environment} = Stack.pop(stack, environment)
                if is_iterable(c) and is_iterable(List.first(Enum.take(c, 1))) do
                    {Stack.push(stack, ListCommands.zip_with_filler(c, " ")), environment}
                else
                    {b, stack, environment} = Stack.pop(stack, environment)
                    if is_iterable(c) and is_iterable(b) do
                        {Stack.push(stack, ListCommands.zip_with_filler(b, c, " ")), environment}
                    else 
                        if is_iterable(b) and is_iterable(List.first(Enum.take(b, 1))) do
                            {Stack.push(stack, ListCommands.zip_with_filler(b, c)), environment}
                        else
                            {a, stack, environment} = Stack.pop(stack, environment)
                            result = cond do
                                not is_iterable(a) and not is_iterable(b) -> ListCommands.zip_with_filler(a, b, c) |> Stream.map(fn x -> Enum.join(Enum.to_list(x), "") end)
                                true -> ListCommands.zip_with_filler(a, b, c)
                            end
                            {Stack.push(stack, result), environment}
                        end
                    end
                end
            "ι" ->
                {b, stack, environment} = Stack.pop(stack, environment)
                if is_iterable(b) do
                    {Stack.push(stack, ListCommands.extract_every(b, 2)), environment}
                else
                    {a, stack, environment} = Stack.pop(stack, environment)
                    {Stack.push(stack, ListCommands.extract_every(a, to_integer!(b))), environment}
                end
            "¿" ->
                {b, stack, environment} = Stack.pop(stack, environment)
                if is_iterable(b) do
                    {Stack.push(stack, Enum.reduce(to_number(b), &IntCommands.gcd_of/2)), environment}
                else
                    {a, stack, environment} = Stack.pop(stack, environment)
                    {Stack.push(stack, IntCommands.gcd_of(to_number(a), to_number(b))), environment}
                end
            ".¿" ->
                {b, stack, environment} = Stack.pop(stack, environment)
                if is_iterable(b) do
                    {Stack.push(stack, Enum.reduce(to_number(b), &IntCommands.lcm_of/2)), environment}
                else
                    {a, stack, environment} = Stack.pop(stack, environment)
                    {Stack.push(stack, IntCommands.lcm_of(to_number(a), to_number(b))), environment}
                end
            ".V" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                a = to_string(a)
                if String.contains?(a, "ÿ") and not String.starts_with?(a, "\"") do
                    interp(Parser.parse(Reader.read("\"" <> to_string(a) <> "\"")), stack, environment)
                else
                    interp(Parser.parse(Reader.read(to_string(a))), stack, environment) 
                end
            "₅" ->
                if environment.recursive_environment == nil do
                    {Stack.push(stack, 255), environment}
                else
                    {a, stack, environment} = Stack.pop(stack, environment)
                    result = call_unary(fn x -> GeneralCommands.recursive_program(environment.recursive_environment.subprogram, environment.recursive_environment.base_cases, to_number(x)) end, a)
                    {Stack.push(stack, result), environment}
                end
            "₆" ->
                if environment.recursive_environment == nil do
                    {Stack.push(stack, 36), environment}
                else
                    {a, stack, environment} = Stack.pop(stack, environment)
                    result = call_unary(fn x -> GeneralCommands.recursive_program(environment.recursive_environment.subprogram, environment.recursive_environment.base_cases, environment.range_variable - to_number(x)) end, a)
                    {Stack.push(stack, result), environment}
                end
        end
    end

    def interp_subprogram(op, subcommands, stack, environment) do
        case op do
            # For N in range [0, n)
            "F" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                current_n = environment.range_variable
                {new_stack, new_env} = GeneralCommands.loop(subcommands, stack, environment, 0, to_integer!(a) - 1)
                {new_stack, %{new_env | range_variable: current_n}}

            # For N in range [1, n]
            "E" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                current_n = environment.range_variable
                {new_stack, new_env} = GeneralCommands.loop(subcommands, stack, environment, 1, to_integer!(a))
                {new_stack, %{new_env | range_variable: current_n}}

            # For N in range [1, n)
            "G" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                current_n = environment.range_variable
                {new_stack, new_env} = GeneralCommands.loop(subcommands, stack, environment, 1, to_integer!(a) - 1)
                {new_stack, %{new_env | range_variable: current_n}}

            # For N in range [0, n]
            "ƒ" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                current_n = environment.range_variable
                {new_stack, new_env} = GeneralCommands.loop(subcommands, stack, environment, 0, to_integer!(a))
                {new_stack, %{new_env | range_variable: current_n}}

            # Infinite loop
            "[" ->
                current_n = environment.range_variable
                {new_stack, new_env} = GeneralCommands.loop(subcommands, stack, environment, 0, :infinity)
                {new_stack, %{new_env | range_variable: current_n}}
            
            # Iterate through string
            "v" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                current_n = environment.range_variable
                current_y = environment.range_element
                {new_stack, new_env} = GeneralCommands.loop(subcommands, stack, environment, 0, if is_iterable(a) do a else to_non_number(a) end)
                {new_stack, %{new_env | range_variable: current_n, range_element: current_y}}

            # Filter by
            "ʒ" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                result = to_list(a)
                        |> Stream.with_index 
                        |> Stream.transform(environment, fn ({x, index}, curr_env) ->
                            {result_stack, new_env} = interp(subcommands, %Stack{elements: [x]}, %{curr_env | range_variable: index, range_element: x})
                            {result, _, new_env} = Stack.pop(result_stack, new_env)
                            case to_number(result) do
                                1 -> {[x], new_env}
                                _ -> {[], new_env}
                            end
                        end)
                        |> Stream.map(fn x -> x end)

                {Stack.push(stack, normalize_to(result, a)), environment}
            
            # Filter by command
            "w" ->
                interp_subprogram("ʒ", subcommands, stack, environment)
            
            # Map for each
            "ε" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                result = to_list(a)
                        |> Stream.with_index
                        |> Stream.transform(environment, fn ({x, index}, curr_env) ->
                            {result_stack, new_env} = interp(subcommands, %Stack{elements: [x]}, %{curr_env | range_variable: index, range_element: x})
                            {result, _, new_env} = Stack.pop(result_stack, new_env)
                            {[result], new_env} end)
                        |> Stream.map(fn x -> x end)
                {Stack.push(stack, result), environment}

            # Sort by (finite lists only)
            "Σ" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                result = to_list(a)
                        |> Stream.with_index
                        |> Stream.transform(environment, fn ({x, index}, curr_env) ->
                            {result_stack, new_env} = interp(subcommands, %Stack{elements: [x]}, %{curr_env | range_variable: index, range_element: x})
                            {result, _, new_env} = Stack.pop(result_stack, new_env)
                            {[{eval(result), x}], new_env} end)
                        |> Enum.sort_by(fn {a, _} -> a end)
                        |> Stream.map(fn {_, x} -> x end)
                {Stack.push(stack, normalize_to(result, a)), environment}

            # Run until a doesn't change
            "Δ" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                {result, new_env} = GeneralCommands.run_while(a, subcommands, environment, 0)
                {Stack.push(stack, result), new_env}

            # Run until a doesn't change and return all intermediate results
            ".Γ" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                {result, new_env} = GeneralCommands.run_while(a, subcommands, environment, 0, [])
                {Stack.push(stack, result), new_env}

            # Find first
            ".Δ" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                {result, _} = to_list(a)
                    |> Stream.with_index
                    |> Enum.find(-1, fn {x, index} -> 
                        result = flat_interp(subcommands, [x], %{environment | range_variable: index, range_element: x})
                        GeneralCommands.equals(result, 1) end)
                {Stack.push(stack, result), environment}
            
            # Find first index
            "ÅΔ" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                result = to_list(a)
                    |> Stream.with_index
                    |> Enum.find_index(fn {x, index} -> 
                        result = flat_interp(subcommands, [x], %{environment | range_variable: index, range_element: x})
                        GeneralCommands.equals(result, 1) end)

                result = case result do
                    nil -> -1
                    _ -> result
                end
                {Stack.push(stack, result), environment}
            
            # Counter variable loop
            "µ" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                GeneralCommands.counter_loop(subcommands, stack, environment, 1, to_integer!(a))
            
            # Map for each
            "€" ->
                {a, stack, environment} = Stack.pop(stack, environment)

                result = to_list(a)
                        |> Stream.with_index
                        |> Stream.transform(environment, fn ({x, index}, curr_env) ->
                            {result_stack, new_env} = interp(subcommands, %Stack{elements: [x]}, %{curr_env | range_variable: index, range_element: x})
                            {result_stack.elements, new_env} end)
                        |> Stream.map(fn x -> x end)
                {Stack.push(stack, result), environment}
            
            # 2-arity map for each
            "δ" ->
                {b, stack, environment} = Stack.pop(stack, environment)
                {a, stack, environment} = Stack.pop(stack, environment)

                result = cond do
                    is_iterable(a) and is_iterable(b) -> a |> Stream.with_index |> Stream.map(fn {x, x_index} -> Stream.map(b |> Stream.with_index, fn {y, y_index} ->
                        flat_interp(subcommands, [x, y], %{environment | range_variable: [y_index, x_index], range_element: [x, y]}) end) end)
                    is_iterable(a) -> a |> Stream.with_index |> Stream.map(fn {x, x_index} -> flat_interp(subcommands, [x, b], %{environment | range_variable: x_index, range_element: x}) end)
                    is_iterable(b) -> b |> Stream.with_index |> Stream.map(fn {y, y_index} -> flat_interp(subcommands, [a, y], %{environment | range_variable: y_index, range_element: y}) end)
                    true -> flat_interp(subcommands, [a, b], environment)
                end
                {Stack.push(stack, result), environment}
            
            # Pairwise command
            "ü" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                result = case subcommands do
                    [{:number, number}] -> 
                        cond do
                            is_iterable(a) -> 
                                a |> Stream.chunk_every(to_integer!(number), 1, :discard)
                                  |> Stream.map(fn x -> x end)
                            true -> 
                                String.graphemes(to_string(a)) |> Stream.chunk_every(to_integer!(number), 1, :discard)
                                                               |> Stream.map(fn x -> Enum.join(Enum.to_list(x), "") end)
                        end
                        
                    _ -> to_list(a) |> Stream.chunk_every(2, 1, :discard)
                                    |> Stream.map(fn [x, y] -> flat_interp(subcommands, [x, y], environment) end)
                end
                {Stack.push(stack, result), environment}
            
            # Recursive list generation
            "λ" ->
                {base_cases, stack, environment} = Stack.pop(stack, environment)
                
                # If there are no base cases specified, assume that a(0) = 1
                base_cases = cond do
                    base_cases == [] or base_cases == "" or base_cases == nil -> [1]
                    is_iterable(base_cases) -> Enum.to_list to_number(base_cases)
                    true -> [to_number(base_cases)]
                end

                {flag, subcommands} = case subcommands do
                    [{_, "j"} | remaining] -> {:contains, remaining}
                    _ -> {:normal, subcommands}
                end
                
                result = ListCommands.listify(0, :infinity) |> Stream.map(fn x -> GeneralCommands.recursive_program(subcommands, base_cases, x) end)

                case flag do
                    :normal -> {Stack.push(stack, result), environment}
                    :contains -> 
                        {b, stack, environment} = Stack.pop(stack, environment)
                        {Stack.push(stack, to_number(ListCommands.increasing_contains(result, to_number(b)))), environment}
                end

            # Group by function
            ".γ" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                result = to_list(a) 
                            |> Stream.with_index 
                            |> Stream.chunk_by(
                                fn {x, index} -> 
                                    {result_stack, _} = interp(subcommands, %Stack{elements: [x]}, %{environment | range_variable: index, range_element: x})
                                    {result_elem, _, _} = Stack.pop(result_stack, environment)
                                    to_number(result_elem)
                                end)
                            |> Stream.map(fn x -> x |> Stream.map(fn {element, _} -> element end) end)

                result = cond do
                    is_iterable(a) -> result
                    true -> result |> Stream.map(fn x -> Enum.join(x, "") end)
                end

                {Stack.push(stack, result), environment}

            # Split with
            ".¡" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                a = to_list(a)
                result = a
                            |> Stream.with_index
                            |> Stream.transform([], 
                                fn ({x, index}, acc) -> 
                                    result_elem = flat_interp(subcommands, [x], %{environment | range_variable: index, range_element: x})
                                    if Enum.any?(acc, fn n -> GeneralCommands.equals(n, result_elem) end) do {[], acc} else {[result_elem], [result_elem | acc]} end
                                end)
                            |> Stream.map(
                                fn outcome -> 
                                    a |> Stream.with_index
                                      |> Stream.filter(fn {element, index} -> GeneralCommands.equals(
                                          flat_interp(subcommands, [element], %{environment | range_variable: index, range_element: element}),
                                          outcome) 
                                        end)
                                      |> Stream.map(fn {element, _} -> element end)
                                    end)

                {Stack.push(stack, result), environment}

            # Left reduce
            ".»" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                result = to_list(a) |> Enum.reduce(fn (x, acc) -> flat_interp(subcommands, [acc, x], environment) end)
                {Stack.push(stack, result), environment}
            
            # Right reduce
            ".«" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                result = to_list(a) |> Enum.reverse |> Enum.reduce(fn (x, acc) -> flat_interp(subcommands, [x, acc], environment) end)
                {Stack.push(stack, result), environment}

            # Cumulative left reduce
            "Å»" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                result = to_list(a) |> Enum.scan(fn (x, acc) -> flat_interp(subcommands, [acc, x], environment) end)
                {Stack.push(stack, result), environment}

            # Cumulative right reduce
            "Å«" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                result = to_list(a) |> Enum.reverse |> Enum.scan(fn (x, acc) -> flat_interp(subcommands, [x, acc], environment) end) |> Enum.reverse
                {Stack.push(stack, result), environment}

            # Map function on every nth element
            "Å€" ->
                {b, stack, environment} = Stack.pop(stack, environment)
                {a, stack, environment} = Stack.pop(stack, environment)
                result = GeneralCommands.map_every(subcommands, environment, to_list(a), to_integer(b))
                {Stack.push(stack, result), environment}

            # Permute by function
            ".æ" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                result = ListCommands.permute_by_function(Enum.to_list(to_list(a)), subcommands, environment)
                {Stack.push(stack, result), environment}

            # Split on function
            ".¬" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                a = to_list(a)
                result = a |> Stream.chunk_every(2, 1, :discard)
                           |> Stream.with_index
                           |> Stream.map(fn {items, index} -> flat_interp(subcommands, items, %{environment | range_variable: index, range_element: items}) end)
                {Stack.push(stack, ListCommands.split_on_truthy_indices(a, Stream.concat([0], result))), environment}
        end
    end
    
    def interp_if_statement(if_statement, else_statement, stack, environment) do
        {a, stack, environment} = Stack.pop(stack, environment)
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
    def interp_string("ÿ", stack, environment), do: {Stack.push(stack, "ÿ"), environment}
    def interp_string(string, stack, environment) do
        dissected_string = String.split(string, "ÿ")

        {elements, stack, environment} = Enum.reduce(Enum.slice(dissected_string, 0..-2), {[], stack, environment}, 
            fn (_, {acc, curr_stack, curr_env}) ->
                case Stack.pop(curr_stack, curr_env) do
                    nil -> {acc, curr_stack, curr_env}
                    {x, new_stack, new_env} -> {acc ++ [x], new_stack, new_env}
                end
            end)

        cond do
            elements == [] -> 
                {Stack.push(stack, string), environment}
            true -> 
                string = Enum.zip(Enum.slice(dissected_string, 0..-2), Stream.cycle(elements)) ++ [{hd(Enum.slice(dissected_string, -1..-1)), ""}]
                       |> Enum.reduce("", fn ({a, b}, acc) -> acc <> to_string(a) <> to_string(b) end)
                {Stack.push(stack, string), environment}
        end
    end

    def flat_interp(commands, elements, environment) do
        {result_stack, _} = interp(commands, %Stack{elements: elements |> Enum.reverse}, environment)
        {result_elem, _, _} = Stack.pop(result_stack, environment)
        result_elem
    end
    
    def interp([], stack, environment), do: {stack, environment}
    def interp(commands, stack, environment) do
        Globals.initialize()
        
        [current_command | remaining] = commands

        # Debugging
        if Globals.get().debug.enabled do
            IO.puts "----------------------------------\n"

            IO.write "Current Command: "
            IO.inspect current_command

            if Globals.get().debug.stack do
                IO.write "Current Stack: "
                Output.print(stack.elements |> Enum.reverse) 
                IO.write "\n"
            end

            if Globals.get().debug.local_env do
                IO.write "Local Environment: "
                IO.inspect(environment)
                IO.write "\n"
            end

            if Globals.get().debug.global_env do
                IO.write "Global Environment: "
                IO.inspect(Globals.get())
                IO.write "\n"
            end
        end

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
