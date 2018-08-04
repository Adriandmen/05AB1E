defmodule Interp.Stack do
    alias Interp.Stack
    alias Commands.GeneralCommands
    alias Reading.InputHandler

    defstruct elements: []

    def push(stack, element) do
        %{stack | elements: [element | stack.elements]}
    end

    def pop(%Stack{elements: []}, environment) do
        case environment.recursive_environment do
            nil -> {InputHandler.read_input(), %Stack{elements: []}, environment}
            recursive_env -> 
                # When popping on an empty stack in a recursive environment, for a(n) we retrieve a(n - pops - 1).
                # For example, the first and second pops for a(6) are a(5) and a(4) respectively.
                prev_element = environment.range_variable - recursive_env.popped - 1
                new_env = %{environment | recursive_environment: %{recursive_env | popped: recursive_env.popped + 1}}
                result = GeneralCommands.recursive_program(recursive_env.subprogram, recursive_env.base_cases, prev_element)
                {result, %Stack{elements: []}, new_env}
        end
    end

    def pop(%Stack{elements: [head | remaining]}, environment) do
        {head, %Stack{elements: remaining}, environment}
    end
end