defmodule Interp.Stack do
    alias Interp.Stack
    alias Commands.GeneralCommands
    alias Reading.InputHandler

    defstruct elements: [],
              last: nil

    def push(stack, element) do
        %{stack | elements: [element | stack.elements]}
    end

    defp handle_input(%Stack{elements: [], last: last}, environment, false), do: {InputHandler.read_input(), %Stack{elements: [], last: last}, environment}
    defp handle_input(%Stack{elements: [], last: last}, environment, true) do
        case InputHandler.read_input() do
            nil ->
                case last do
                    nil -> {nil, %Stack{elements: [], last: nil}, environment}
                    _ -> {last, %Stack{elements: [], last: last}, environment}
                end
            any -> {any, %Stack{elements: []}, environment}
        end
    end

    def pop(stack, environment, access_history? \\ true)
    def pop(%Stack{elements: [], last: last}, environment, access_history?) do
        case environment.recursive_environment do
            nil -> handle_input(%Stack{elements: [], last: last}, environment, access_history?)
            recursive_env -> 
                # When popping on an empty stack in a recursive environment, for a(n) we retrieve a(n - pops - 1).
                # For example, the first and second pops for a(6) are a(5) and a(4) respectively.
                prev_element = environment.range_variable - recursive_env.popped - 1
                new_env = %{environment | recursive_environment: %{recursive_env | popped: recursive_env.popped + 1}}
                result = GeneralCommands.recursive_program(recursive_env.subprogram, recursive_env.base_cases, prev_element)
                {result, %Stack{elements: []}, new_env}
        end
    end

    def pop(%Stack{elements: [head | remaining]}, environment, _) do
        {head, %Stack{elements: remaining, last: head}, environment}
    end
end