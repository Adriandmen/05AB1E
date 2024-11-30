defmodule Commands.GeneralCommands do

    use Memoize
    alias Interp.Functions
    alias Interp.Interpreter
    alias Interp.Stack
    alias Interp.Globals
    alias Interp.Environment
    alias Interp.RecursiveEnvironment
    alias HTTPoison
    alias Commands.ListCommands
    alias Commands.IntCommands
    alias Commands.GeneralCommands
    require Interp.Functions
    
    def head(value) do
        cond do
            Functions.is_iterable(value) -> List.first Enum.to_list(Stream.take(value, 1))
            is_integer(value) -> head(Functions.to_non_number(value))
            true -> String.slice(value, 0..0)
        end
    end

    def dehead(value) do
        cond do
            Functions.is_iterable(value) -> Stream.drop(value, 1) |> Stream.map(fn x -> x end)
            true -> String.slice(to_string(value), 1..-1//1)
        end
    end

    def tail(value) do
        cond do
            Functions.is_iterable(value) -> hd(Enum.slice(Enum.to_list(value), -1..-1//1))
            is_integer(value) -> tail(Functions.to_non_number(value))
            true -> String.slice(value, -1..-1//1)
        end
    end

    def detail(value) do
        cond do
            Functions.is_iterable(value) -> 
                value |> Enum.reverse |> tl |> Enum.reverse |> Stream.map(fn x -> x end)
            true -> String.slice(to_string(value), 0..-2//1)
        end
    end

    def element_at(value, index) when index < 0, do: element_at(value, IntCommands.mod(index, length_of(value)))
    def element_at(value, index) do
        case value |> Stream.drop(index) |> Stream.take(1) |> Enum.to_list |> List.first do
            nil -> 
                cond do
                    value |> length_of() == 0 -> value
                    true -> Stream.cycle(value) |> Stream.drop(index) |> Stream.take(1) |> Enum.to_list |> List.first
                end
            head -> head
        end
    end

    def remove_from(value, filter_chars) do
        filter_chars = Functions.to_str Functions.stream(filter_chars)
        value = Functions.to_str(value)

        cond do
            Functions.is_iterable(value) -> value |> Stream.map(fn x -> remove_from(x, filter_chars) end)
            true -> Enum.reduce(Enum.filter(String.graphemes(value), fn x -> not Enum.member?(filter_chars, Functions.to_str x) end), "", fn (element, acc) -> acc <> element end)
        end
    end

    def vectorized_equals(a, b) do
        cond do
            Functions.is_iterable(a) and not Functions.is_iterable(b) -> a |> Stream.map(fn x -> vectorized_equals(x, b) end)
            not Functions.is_iterable(a) and Functions.is_iterable(b) -> b |> Stream.map(fn x -> vectorized_equals(a, x) end)
            Functions.is_iterable(a) and Functions.is_iterable(b) -> Stream.zip(a, b) |> Stream.map(fn {x, y} -> vectorized_equals(x, y) end)
            true -> Functions.to_number(a) == Functions.to_number(b)
        end
    end

    def equals(a, b) do
        cond do
            Functions.is_iterable(a) and not Functions.is_iterable(b) -> false
            not Functions.is_iterable(a) and Functions.is_iterable(b) -> false
            true -> Functions.eval(Functions.to_number(a)) == Functions.eval(Functions.to_number(b))
        end
    end

    def all_equal(value) do
        cond do
            Functions.is_iterable(value) -> 
                case Enum.take(value, 1) do
                    [] -> true
                    element -> Enum.all?(value, fn x -> equals(x, hd(element)) end)
                end
            true ->
                all_equal(String.graphemes(to_string(value)))
        end
    end

    def count(value, element) when Functions.is_iterable(value), do: value |> Enum.count(fn x -> equals(x, element) end)
    def count(value, element), do: count(value, element, 0)
    defp count("", _, count), do: count
    defp count(value, element, count), do: count(value |> String.slice(1..-1//1), element, count + Functions.to_number(value |> String.starts_with?(element)))

    def strict_count(value, element) when not Functions.is_iterable(value) and not Functions.is_iterable(element), do: element |> Stream.map(fn x -> count(value, x) end)
    def strict_count(value, element) when not Functions.is_iterable(value), do: count(value, element)
    def strict_count(value, element) when Functions.is_iterable(value), do: value |> Enum.count(fn x -> equals(x, element) end)

    def enclose(value) do
        cond do
            Functions.is_iterable(value) -> Stream.concat(value, Stream.take(value, 1)) |> Stream.map(fn x -> x end)
            true -> Functions.to_non_number(value) <> head(value)
        end
    end

    def concat(a, b) do
        cond do
            Functions.is_iterable(a) and Functions.is_iterable(b) -> Stream.concat(a, b) |> Stream.map(fn x -> x end)
            Functions.is_iterable(a) and not Functions.is_iterable(b) -> a |> Stream.map(fn x -> concat(x, b) end)
            not Functions.is_iterable(a) and Functions.is_iterable(b) -> b |> Stream.map(fn x -> concat(a, x) end)
            true -> to_string(a) <> to_string(b)
        end
    end

    def length_of(a) do
        cond do
            Functions.is_iterable(a) -> length(Enum.to_list(a))
            true -> String.length(to_string(a))
        end
    end

    @doc """
    Loop method. This method iteratively runs the given commands on the given index and the given range.
    After each iteration of running the code, it also gives the resulting stack and resulting environment.

    ## Parameters

     - commands:    A list of commands that the program will run on.
     - stack:       A Stack object which contains the current state of the stack.
     - environment: The environment in which the program will be run in.
     - index:       The current index of the loop iteration.
     - range:       The range of the loop. If the range is an integer, the loop will run from n <- index..range
                    If the range of the loop is a string or a list, it will iterate over each element in the given range.  
    """
    def loop(commands, stack, environment, index, range) do
        case Globals.get().status do
            :ok -> 
                cond do
                    # If the range is an integer and the index is in bounds, run the commands
                    # and increment the index by 1 on the next iteration.
                    (is_integer(range) and index <= range) or range == :infinity ->
                        {new_stack, new_env} = Interpreter.interp(commands, stack, %{environment | range_variable: index})
                        loop(commands, new_stack, new_env, index + 1, range)
                    
                    # If the range is a list/stream/map, take the first element after 'index' elements
                    # and check if the current index is in bounds (i.e. curr_element != []).
                    Functions.is_iterable(range) ->
                        curr_element = range |> Stream.drop(index) |> Stream.take(1) |> Enum.to_list
                        case curr_element do
                            [] -> {stack, environment}
                            x ->
                                {new_stack, new_env} = Interpreter.interp(commands, stack, %{environment | range_variable: index, range_element: hd(x)})
                                loop(commands, new_stack, new_env, index + 1, range)
                        end
                    
                    # If the range is a string, convert to a list of strings and loop on that.
                    is_bitstring(range) ->
                        loop(commands, stack, environment, index, String.graphemes(range))
                    
                    # If none of the above applies, that means that the index is out of bounds and
                    # we will return the final state of the stack and the environment.
                    true ->
                        {stack, environment}
                end
            :break ->
                Globals.set(%{Globals.get() | status: :ok})
                {stack, environment}
            :quit -> {stack, environment}
        end
    end

    def run_while(prev_result, commands, environment, index, prev_results \\ nil) do
        {result_stack, new_env} = Interpreter.interp(commands, %Stack{elements: [prev_result]}, %{environment | range_variable: index, range_element: prev_result})
        {result, _, new_env} = Stack.pop(result_stack, new_env)
        cond do
            GeneralCommands.equals(prev_result, result) and prev_results == nil -> {result, new_env}
            GeneralCommands.equals(prev_result, result) -> {prev_results |> Enum.reverse, new_env}
            prev_results == nil -> run_while(result, commands, new_env, index + 1)
            true -> run_while(result, commands, new_env, index + 1, [result | prev_results])
        end
    end

    def counter_loop(commands, stack, environment, index, count) do
        case Globals.get().status do
            :ok -> 
                cond do
                    Globals.get().counter_variable >= count -> {stack, environment}
                    true -> 
                        {result_stack, new_env} = Interpreter.interp(commands, stack, %{environment | range_variable: index})
                        counter_loop(commands, result_stack, new_env, index + 1, count)
                end
            :break ->
                Globals.set(%{Globals.get() | status: :ok})
                {stack, environment}
            :quit -> {stack, environment}
        end
    end

    defmemo recursive_program(commands, base_cases, n) do
        cond do
            n < 0 -> 0
            n < length(base_cases) -> Enum.at(base_cases, n)
            true ->
                {stack, new_env} = Interpreter.interp(commands, %Stack{elements: []}, %Environment{range_variable: n, recursive_environment: %RecursiveEnvironment{subprogram: commands, base_cases: base_cases}})
                {head, _, _} = Stack.pop(stack, new_env)
                head
        end
    end

    def map_every(commands, environment, list, nth) do
        cond do
            Functions.is_iterable(nth) -> 
                list
                |> Stream.with_index(nth |> Stream.take(1) |> Enum.to_list |> List.first)
                |> Stream.transform({nth |> Stream.cycle, 0}, fn ({x, index}, {nth, offset}) ->
                    head = nth |> Stream.take(1) |> Enum.to_list |> List.first
                    cond do
                        head == 0 -> {[x], {nth, offset}}
                        index - offset == head -> {[Interpreter.flat_interp(commands, [x], environment)], {nth |> Stream.drop(1), index}}
                        true -> {[x], {nth, offset}}
                    end
                end) |> Stream.map(fn x -> x end)
            true ->
                list |> Stream.map_every(nth, fn x -> Interpreter.flat_interp(commands, [x], environment) end)
        end
    end

    def get_url(url) do
        cond do
            url |> String.starts_with?("http") -> HTTPoison.get!(url).body
            true -> HTTPoison.get!("http://" <> url).body
        end
    end

    def starts_with(left, right) when Functions.is_iterable(left) and Functions.is_iterable(right) do
        cond do
            equals(left |> Stream.take(length(Enum.to_list(right))) |> Enum.to_list, right) -> true
            true -> false
        end
    end
    def starts_with(left, right) when Functions.is_iterable(left), do: left |> Stream.map(fn x -> x |> starts_with(right) end)
    def starts_with(left, right) when Functions.is_iterable(right), do: right |> Stream.map(fn x -> left |> starts_with(x) end)
    def starts_with(left, right), do: String.starts_with?(to_string(left), to_string(right))

    def ends_with(left, right) when Functions.is_iterable(left) and Functions.is_iterable(right), do: starts_with(left |> ListCommands.reverse, right |> ListCommands.reverse)
    def ends_with(left, right) when Functions.is_iterable(left), do: starts_with(left |> Stream.map(&ListCommands.reverse/1), right |> ListCommands.reverse)
    def ends_with(left, right) when Functions.is_iterable(right), do: starts_with(left |> ListCommands.reverse, right |> Stream.map(&ListCommands.reverse/1))
    def ends_with(left, right), do: starts_with(left |> ListCommands.reverse, right |> ListCommands.reverse)
end