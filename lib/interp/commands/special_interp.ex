defmodule Interp.SpecialInterp do
    alias Interp.Stack
    alias Interp.Globals
    alias Interp.Interpreter
    alias Commands.ListCommands
    alias Commands.IntCommands
    alias Commands.GeneralCommands
    alias Reading.InputHandler
    alias Reading.Reader
    alias Parsing.Parser
    import Interp.Functions
    use Bitwise
    
    def interp_step(op, stack, environment) do
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
            ".|" -> {Stack.push(stack, InputHandler.read_until_eof()), environment}
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
                    {_a, stack, environment} = Stack.pop(stack, environment)
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
                    {Stack.push(stack, call_binary(fn x, y -> IntCommands.gcd_of(to_number(x), to_number(y)) end, a, b)), environment}
                end
            ".¿" ->
                {b, stack, environment} = Stack.pop(stack, environment)
                if is_iterable(b) do
                    {Stack.push(stack, Enum.reduce(to_number(b), &IntCommands.lcm_of/2)), environment}
                else
                    {a, stack, environment} = Stack.pop(stack, environment)
                    {Stack.push(stack, call_binary(fn x, y -> IntCommands.lcm_of(to_number(x), to_number(y)) end, a, b)), environment}
                end
            ".V" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                a = to_string(a)
                if String.contains?(a, "ÿ") and not String.starts_with?(a, "\"") do
                    Interpreter.interp(Parser.parse(Reader.read("\"" <> to_string(a) <> "\"")), stack, environment)
                else
                    Interpreter.interp(Parser.parse(Reader.read(to_string(a))), stack, environment) 
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
end
