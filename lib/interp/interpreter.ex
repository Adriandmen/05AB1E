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
    alias Interp.Globals
    alias Interp.Output
    alias Commands.GeneralCommands

    alias Interp.NullaryInterp
    alias Interp.UnaryInterp
    alias Interp.BinaryInterp
    alias Interp.TernaryInterp
    alias Interp.SpecialInterp
    alias Interp.SubprogramInterp
    
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

        {elements, stack, environment} = Enum.reduce(Enum.slice(dissected_string, 0..-2//1), {[], stack, environment}, 
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
                string = Enum.zip(Enum.slice(dissected_string, 0..-2//1), Stream.cycle(elements)) ++ [{hd(Enum.slice(dissected_string, -1..-1//1)), ""}]
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
                    {:nullary_op, op} -> NullaryInterp.interp_step(op, stack, environment)
                    {:unary_op, op} -> UnaryInterp.interp_step(op, stack, environment)
                    {:binary_op, op} -> BinaryInterp.interp_step(op, stack, environment)
                    {:ternary_op, op} -> TernaryInterp.interp_step(op, stack, environment)
                    {:special_op, op} -> SpecialInterp.interp_step(op, stack, environment)
                    {:subprogram, op, subcommands} -> SubprogramInterp.interp_step(op, subcommands, stack, environment)
                    {:if_statement, if_statement, else_statement} -> interp_if_statement(if_statement, else_statement, stack, environment)
                    {:no_op, _} -> {stack, environment}
                    {:eof, _} -> {stack, environment}
                    _ -> {stack, environment}
                end
                interp(remaining, new_stack, new_env)
            :break -> {stack, environment}
            :quit -> {stack, environment}
        end
    end
end
