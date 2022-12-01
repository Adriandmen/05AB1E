defmodule Interp.SubprogramInterp do
    alias Interp.Stack
    alias Interp.Interpreter
    alias Interp.Globals
    alias Commands.ListCommands
    alias Commands.GeneralCommands
    import Interp.Functions
    
    def interp_step(op, subcommands, stack, environment) do
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
                            {result_stack, new_env} = Interpreter.interp(subcommands, %Stack{elements: [x]}, %{curr_env | range_variable: index, range_element: x})
                            {result, _, new_env} = Stack.pop(result_stack, new_env)
                            case to_number(result) do
                                1 -> {[x], new_env}
                                _ -> {[], new_env}
                            end
                        end)
                        |> Stream.map(fn x -> x end)
                        |> Globals.lazy_safe

                {Stack.push(stack, normalize_to(result, a)), environment}
            
            # Filter by command
            "w" ->
                interp_step("ʒ", subcommands, stack, environment)
            
            # Map for each
            "ε" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                result = to_list(a)
                        |> Stream.with_index
                        |> Stream.transform(environment, fn ({x, index}, curr_env) ->
                            {result_stack, new_env} = Interpreter.interp(subcommands, %Stack{elements: [x]}, %{curr_env | range_variable: index, range_element: x})
                            {result, _, new_env} = Stack.pop(result_stack, new_env)
                            {[result], new_env} end)
                        |> Stream.map(fn x -> x end)
                        |> Globals.lazy_safe

                {Stack.push(stack, result), environment}

            # Sort by (finite lists only)
            "Σ" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                result = to_list(a)
                        |> Stream.with_index
                        |> Stream.transform(environment, fn ({x, index}, curr_env) ->
                            {result_stack, new_env} = Interpreter.interp(subcommands, %Stack{elements: [x]}, %{curr_env | range_variable: index, range_element: x})
                            {result, _, new_env} = Stack.pop(result_stack, new_env)
                            {[{eval(result), x}], new_env} end)
                        |> Enum.sort_by(fn {a, _} -> a end)
                        |> Stream.map(fn {_, x} -> x end)
                        |> Globals.lazy_safe

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
                result = to_list(a)
                    |> Stream.with_index
                    |> Enum.find(-1, fn {x, index} -> 
                        result = Interpreter.flat_interp(subcommands, [x], %{environment | range_variable: index, range_element: x})
                        GeneralCommands.equals(result, 1) end)

                case result do
                    {res, _} -> {Stack.push(stack, res), environment}
                    _ -> {Stack.push(stack, -1), environment}
                end
            
            # Find first index
            "ÅΔ" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                result = to_list(a)
                    |> Stream.with_index
                    |> Enum.find_index(fn {x, index} -> 
                        result = Interpreter.flat_interp(subcommands, [x], %{environment | range_variable: index, range_element: x})
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
                            {result_stack, new_env} = Interpreter.interp(subcommands, %Stack{elements: [x]}, %{curr_env | range_variable: index, range_element: x})
                            {result_stack.elements, new_env} end)
                        |> Stream.map(fn x -> x end)
                        |> Globals.lazy_safe

                {Stack.push(stack, result), environment}
            
            # 2-arity map for each
            "δ" ->
                {b, stack, environment} = Stack.pop(stack, environment)
                {a, stack, environment} = Stack.pop(stack, environment)

                {a, b} = cond do
                    is_number?(a) and is_number?(b) -> {1..to_integer!(a), 1..to_integer!(b)}
                    true -> {a, b}
                end

                result = cond do
                    is_iterable(a) and is_iterable(b) -> a |> Stream.with_index |> Stream.map(fn {x, x_index} -> Stream.map(b |> Stream.with_index, fn {y, y_index} ->
                        Interpreter.flat_interp(subcommands, [x, y], %{environment | range_variable: [y_index, x_index], range_element: [x, y]}) end) end)
                    is_iterable(a) -> a |> Stream.with_index |> Stream.map(fn {x, x_index} -> Interpreter.flat_interp(subcommands, [x, b], %{environment | range_variable: x_index, range_element: x}) end)
                    is_iterable(b) -> b |> Stream.with_index |> Stream.map(fn {y, y_index} -> Interpreter.flat_interp(subcommands, [a, y], %{environment | range_variable: y_index, range_element: y}) end)
                    true -> Interpreter.flat_interp(subcommands, [a, b], environment)
                end

                {Stack.push(stack, Globals.lazy_safe(result)), environment}
            
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
                                    |> Stream.map(fn [x, y] -> Interpreter.flat_interp(subcommands, [x, y], environment) end)
                end
                {Stack.push(stack, Globals.lazy_safe(result)), environment}
            
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
                    [{_, "£"} | remaining] -> {:first_n, remaining}
                    [{_, "è"} | remaining] -> {:at_n, remaining}
                    _ -> {:normal, subcommands}
                end
                
                result = ListCommands.listify(0, :infinity) |> Stream.map(fn x -> GeneralCommands.recursive_program(subcommands, base_cases, x) end) |> Globals.lazy_safe

                case flag do
                    :normal -> {Stack.push(stack, result), environment}
                    :contains -> 
                        {b, stack, environment} = Stack.pop(stack, environment)
                        {Stack.push(stack, to_number(ListCommands.increasing_contains(result, to_number(b)))), environment}
                    :first_n ->
                        {b, stack, environment} = Stack.pop(stack, environment)
                        {Stack.push(stack, ListCommands.take_first(result, to_integer(b))), environment}
                    :at_n ->
                        {b, stack, environment} = Stack.pop(stack, environment)
                        {Stack.push(stack, GeneralCommands.element_at(result, to_integer(b))), environment}
                end

            # Group by function
            ".γ" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                result = to_list(a) 
                            |> Stream.with_index 
                            |> Stream.chunk_by(
                                fn {x, index} -> 
                                    {result_stack, _} = Interpreter.interp(subcommands, %Stack{elements: [x]}, %{environment | range_variable: index, range_element: x})
                                    {result_elem, _, _} = Stack.pop(result_stack, environment)
                                    to_number(result_elem)
                                end)
                            |> Stream.map(fn x -> x |> Stream.map(fn {element, _} -> element end) end)
                            |> Globals.lazy_safe

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
                                    result_elem = Interpreter.flat_interp(subcommands, [x], %{environment | range_variable: index, range_element: x})
                                    if Enum.any?(acc, fn n -> GeneralCommands.equals(n, result_elem) end) do {[], acc} else {[result_elem], [result_elem | acc]} end
                                end)
                            |> Stream.map(
                                fn outcome -> 
                                    a |> Stream.with_index
                                      |> Stream.filter(fn {element, index} -> GeneralCommands.equals(
                                          Interpreter.flat_interp(subcommands, [element], %{environment | range_variable: index, range_element: element}),
                                          outcome) 
                                        end)
                                      |> Stream.map(fn {element, _} -> element end)
                                    end)
                            |> Globals.lazy_safe

                {Stack.push(stack, result), environment}

            # Left reduce
            ".»" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                result = to_list(a) |> Enum.reduce(fn (x, acc) -> Interpreter.flat_interp(subcommands, [acc, x], environment) end)
                {Stack.push(stack, result), environment}
            
            # Right reduce
            ".«" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                result = to_list(a) |> Enum.reverse |> Enum.reduce(fn (x, acc) -> Interpreter.flat_interp(subcommands, [x, acc], environment) end)
                {Stack.push(stack, result), environment}

            # Cumulative left reduce
            "Å»" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                result = to_list(a) |> Enum.scan(fn (x, acc) -> Interpreter.flat_interp(subcommands, [acc, x], environment) end)
                {Stack.push(stack, result), environment}

            # Cumulative right reduce
            "Å«" ->
                {a, stack, environment} = Stack.pop(stack, environment)
                result = to_list(a) |> Enum.reverse |> Enum.scan(fn (x, acc) -> Interpreter.flat_interp(subcommands, [x, acc], environment) end) |> Enum.reverse
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
                           |> Stream.map(fn {items, index} -> Interpreter.flat_interp(subcommands, items, %{environment | range_variable: index, range_element: items}) end)
                           |> Globals.lazy_safe

                {Stack.push(stack, ListCommands.split_on_truthy_indices(a, Stream.concat([0], result))), environment}

            # Apply function at indices
            "ÅÏ" ->
                {b, stack, environment} = Stack.pop(stack, environment)
                b = Stream.concat(to_list(b), Stream.cycle([0]))

                {a, stack, environment} = Stack.pop(stack, environment)
                a_list = to_list(a)

                result = a_list |> Stream.zip(b)
                                |> Stream.with_index
                                |> Stream.map(
                                    fn {{item, val}, index} ->
                                        if GeneralCommands.equals(val, 1) do 
                                            Interpreter.flat_interp(subcommands, [item], %{environment | range_variable: index, range_element: [item]}) 
                                        else 
                                            item 
                                        end 
                                    end)
                                |> Globals.lazy_safe
                
                {Stack.push(stack, normalize_to(result, a)), environment}
        end
    end
end
