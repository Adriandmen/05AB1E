defmodule Interp.Environment do
    alias Reading.InputHandler

    defstruct X: 1,
              Y: 2,
              Z: 3,
              c: -1,
              N: 0,
              y: "",
              canvas: nil,       # TODO: create canvas module
              inputs: []

    def get_input(environment, n) do
        list = environment.inputs
        if length(list) <= n do
            {_, new_env} = InputHandler.read_input(environment)
            get_input(new_env, n)
        else
            {Enum.at(environment.inputs, n), environment}
        end
    end
end


defmodule Interp.Interpreter do
    alias Interp.Stack
    alias Interp.Environment
    alias Commands.ListCommands
    alias Commands.StrCommands
    alias Commands.IntCommands
    alias Commands.GeneralCommands
    alias Reading.InputHandler
    import Interp.Functions
    use Bitwise

    defp interp_nullary(op, stack, environment) do
        new_stack = case op do
            "∞" -> Stack.push(stack, ListCommands.listify(1, :infinity))
            "т" -> Stack.push(stack, 100)
            "₁" -> Stack.push(stack, 256)
            "₂" -> Stack.push(stack, 26)
            "₃" -> Stack.push(stack, 95)
            "₄" -> Stack.push(stack, 1000)
            "A" -> Stack.push(stack, "abcdefghijklmnopqrstuvwxyz")
            "T" -> Stack.push(stack, 10)
            "®" -> Stack.push(stack, environment.c)
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

    defp interp_unary(op, stack, environment) do
        {a, stack, environment} = Stack.pop(stack, environment)
        new_stack = case op do
            ">" -> Stack.push(stack, call_unary(fn x -> to_number(x) + 1 end, a))
            "<" -> Stack.push(stack, call_unary(fn x -> to_number(x) - 1 end, a))
            "L" -> Stack.push(stack, call_unary(fn x -> ListCommands.listify(1, to_number(x)) end, a))
            "!" -> Stack.push(stack, call_unary(fn x -> IntCommands.factorial(to_number(x)) end, a))
            "η" -> Stack.push(stack, call_unary(fn x -> ListCommands.prefixes(to_non_number(x)) end, a, true))
            "н" -> Stack.push(stack, call_unary(fn x -> GeneralCommands.head(x) end, a, true))
            "θ" -> Stack.push(stack, call_unary(fn x -> GeneralCommands.tail(x) end, a, true))
            "Θ" -> Stack.push(stack, call_unary(fn x -> to_number(to_number(x) == 1) end, a))
            "≠" -> Stack.push(stack, call_unary(fn x -> to_number(to_number(x) != 1) end, a))
            "_" -> Stack.push(stack, call_unary(fn x -> to_number(to_number(x) == 0) end, a))
            "(" -> Stack.push(stack, call_unary(fn x -> to_number(x) * -1 end, a))
            "a" -> Stack.push(stack, call_unary(fn x -> to_number(Regex.match?(~r/^[a-zA-Z]+$/, to_string(x))) end, a))
            "b" -> Stack.push(stack, call_unary(fn x -> IntCommands.to_base(to_number(x), 2) end, a))
            "h" -> Stack.push(stack, call_unary(fn x -> IntCommands.to_base(to_number(x), 16) end, a))
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
            "È" -> Stack.push(stack, call_unary(fn x -> to_number(is_integer(to_number(x)) and IntCommands.mod(to_number(x), 2) == 0) end, a))
            "É" -> Stack.push(stack, call_unary(fn x -> to_number(is_integer(to_number(x)) and IntCommands.mod(to_number(x), 2) == 1) end, a))
            "¦" -> Stack.push(stack, GeneralCommands.dehead(a))
            "¨" -> Stack.push(stack, GeneralCommands.detail(a))
            "¥" -> Stack.push(stack, ListCommands.deltas(a))
            "x" -> Stack.push(Stack.push(stack, a), call_unary(fn x -> 2 * to_number(x) end, a))
            "¤" -> Stack.push(Stack.push(stack, a), GeneralCommands.tail(a))
            "¬" -> Stack.push(Stack.push(stack, a), GeneralCommands.head(a))
            "D" -> Stack.push(Stack.push(stack, a), a)
            "ā" -> Stack.push(Stack.push(stack, a), ListCommands.enumerate(a))
            "Ð" -> Stack.push(Stack.push(Stack.push(stack, a), a), a)
            "O" -> cond do (is_iterable(a) -> Stack.push(stack, ListCommands.sum(a)); true -> Stack.push(%Stack{}, ListCommands.sum(Stack.push(stack, a).elements))) end
            "P" -> cond do (is_iterable(a) -> Stack.push(stack, ListCommands.sum(a)); true -> Stack.push(%Stack{}, ListCommands.sum(Stack.push(stack, a).elements))) end
            "\\" -> stack
        end

        {new_stack, environment}
    end

    defp interp_binary(op, stack, environment) do
        {b, stack, environment} = Stack.pop(stack, environment)
        {a, stack, environment} = Stack.pop(stack, environment)

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
            "m" -> Stack.push(stack, call_binary(fn x, y -> IntCommands.pow(to_number(x), to_number(y)) end, a, b))
            "è" -> Stack.push(stack, call_binary(fn x, y -> GeneralCommands.element_at(x, to_number(y)) end, a, b, true, false))
            "£" -> Stack.push(stack, call_binary(fn x, y -> ListCommands.take_first(x, to_number(y)) end, a, b, true, true))
            "м" -> Stack.push(stack, call_binary(fn x, y -> GeneralCommands.remove_from(x, y) end, a, b, true, true))
            "‰" -> Stack.push(stack, call_binary(fn x, y -> [IntCommands.divide(to_number(x), to_number(y)), IntCommands.mod(to_number(x), to_number(y))] end, a, b))
            "‹" -> Stack.push(stack, call_binary(fn x, y -> to_number(to_number(x) < to_number(y)) end, a, b))
            "›" -> Stack.push(stack, call_binary(fn x, y -> to_number(to_number(x) > to_number(y)) end, a, b))
            "s" -> Stack.push(Stack.push(stack, b), a)
        end

        {new_stack, environment}
    end

    defp interp_ternary(op, stack, environment) do
        {c, stack, environment} = Stack.pop(stack, environment)
        {b, stack, environment} = Stack.pop(stack, environment)
        {a, stack, environment} = Stack.pop(stack, environment)

        new_stack = case op do
            "ǝ" -> Stack.push(stack, call_ternary(fn x, y, z -> StrCommands.insert_at(x, y, z) end, a, b, c, true, true, true))
        end

        {new_stack, environment}
    end

    defp interp_special(op, stack, environment) do
        {new_stack, environment} = case op do
            ")" -> 
                {%Stack{elements: [stream(Enum.reverse(stack.elements))]}, environment}
            "r" -> 
                {%Stack{elements: stack.elements |> Enum.reverse}, environment}
            "©" ->
                {a, _, environment} = Stack.pop(stack, environment)
                {stack, %{environment | c: a}}
            "¹" -> 
                {element, new_env} = Environment.get_input(environment, 0)
                {Stack.push(stack, element), new_env}
            "²" -> 
                {element, new_env} = Environment.get_input(environment, 1)
                {Stack.push(stack, element), new_env}
            "³" -> 
                {element, new_env} = Environment.get_input(environment, 2)
                {Stack.push(stack, element), new_env}
        end
    end

    defp interp_string(string, stack, environment) do
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
                       |> Enum.reduce("", fn ({a, b}, acc) -> acc <> a <> b end)
                {Stack.push(stack, string), environment}
        end
    end
    
    def interp(commands, stack, environment) do
        [current_command | remaining] = commands

        {stack, environment} = case current_command do
            [:number, value] -> {Stack.push(stack, value), environment}
            [:string, value] -> interp_string(value, stack, environment)
            [:nullary_op, op] -> interp_nullary(op, stack, environment)
            [:unary_op, op] -> interp_unary(op, stack, environment)
            [:binary_op, op] -> interp_binary(op, stack, environment)
            [:ternary_op, op] -> interp_ternary(op, stack, environment)
            [:special_op, op] -> interp_special(op, stack, environment)
            [:no_op, _] -> {stack, environment}
            [:eof, _] -> {stack, environment}
            x -> IO.inspect x
        end

        if length(remaining) > 0 do
            interp(remaining, stack, environment)
        else
            {stack, environment}
        end
    end
end