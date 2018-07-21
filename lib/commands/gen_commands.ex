defmodule Commands.GeneralCommands do

    alias Interp.Functions
    alias Interp.Interpreter
    alias Interp.Stack
    require Interp.Functions
    
    def head(value) do
        cond do
            Functions.is_iterable(value) -> hd(Enum.to_list(Stream.take(value, 1)))
            is_integer(value) -> head(Functions.to_non_number(value))
            true -> String.slice(value, 0..0)
        end
    end

    def dehead(value) do
        cond do
            Functions.is_iterable(value) -> Stream.drop(value, 1)
            true -> String.slice(to_string(value), 1..-1)
        end
    end

    def tail(value) do
        cond do
            Functions.is_iterable(value) -> hd(Enum.slice(Enum.to_list(value), -1..-1))
            is_integer(value) -> tail(Functions.to_non_number(value))
            true -> String.slice(value, -1..-1)
        end
    end

    def detail(value) do
        cond do
            Functions.is_iterable(value) -> Stream.take(value, length(Enum.to_list(value)) - 1)
            true -> String.slice(to_string(value), 0..-2)
        end
    end

    # def slice(value, a, b) do
    #     cond do
    #         is_map(value) -> Stream.cycle(value) |> Stream.drop(a) 
    #     end
    # end

    def element_at(value, index) do
        cond do
            is_map(value) -> Stream.cycle(value) |> Stream.drop(index) |> Stream.take(1) |> Enum.to_list |> hd
            is_integer(value) -> element_at(Functions.to_non_number(value), index)
            true -> String.at(value, rem(index, String.length(value)))
        end
    end

    def remove_from(value, filter_chars) do
        filter_chars = Functions.to_str Functions.stream(filter_chars)
        value = Functions.to_str(value)

        cond do
            is_map(value) or is_list(value) -> value |> Stream.map(fn x -> remove_from(x, filter_chars) end)
            true -> Enum.reduce(Enum.filter(String.graphemes(value), fn x -> not Enum.member?(filter_chars, Functions.to_str x) end), "", fn (element, acc) -> acc <> element end)
        end
    end

    def equals(a, b) do
        cond do
            Functions.is_iterable(a) and not Functions.is_iterable(b) -> a |> Stream.map(fn x -> equals(x, b) end)
            not Functions.is_iterable(a) and Functions.is_iterable(b) -> b |> Stream.map(fn x -> equals(a, x) end)
            true -> Functions.to_number(a) == Functions.to_number(b)
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

    @docs """
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
        case environment.status do
            :ok -> 
                cond do
                    # If the range is an integer and the index is in bounds, run the commands
                    # and increment the index by 1 on the next iteration.
                    is_integer(range) and index <= range ->
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
                {stack, %{environment | status: :ok}}
            :quit -> {stack, environment}
        end
    end

    def run_while(prev_result, commands, environment, index) do
        {result_stack, new_env} = Interpreter.interp(commands, %Stack{elements: [prev_result]}, %{environment | range_variable: index, range_element: prev_result})
        {result, _, new_env} = Stack.pop(result_stack, new_env)
        cond do
            result == prev_result -> {result, new_env}
            true -> run_while(result, commands, new_env, index + 1)
        end
    end
end