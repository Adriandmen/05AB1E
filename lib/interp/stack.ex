defmodule Interp.Stack do
    alias Interp.Stack
    alias Reading.InputHandler

    defstruct elements: []

    def push(stack, element) do
        %{stack | elements: [element | stack.elements]}
    end

    def pop(%Stack{elements: []}) do
        {InputHandler.read_input(), %Stack{elements: []}}
    end

    def pop(%Stack{elements: [head | remaining]}) do
        {head, %Stack{elements: remaining}}
    end
end