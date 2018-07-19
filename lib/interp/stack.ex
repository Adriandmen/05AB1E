defmodule Interp.Stack do
    alias Interp.Stack
    alias Interp.Environment
    alias Reading.InputHandler

    defstruct elements: []

    def push(stack, element) do
        %{stack | elements: [element | stack.elements]}
    end

    def pop(%Stack{elements: []}, environment) do
        {element, environment} = InputHandler.read_input(environment)
        {element, %Stack{elements: []}, environment}
    end

    def pop(%Stack{elements: [head | remaining]}, environment) do
        {head, %Stack{elements: remaining}, environment}
    end
end