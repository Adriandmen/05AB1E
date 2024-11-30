defmodule Interp.TernaryInterp do
    alias Interp.Stack
    alias Interp.Globals
    alias Interp.Canvas
    alias Commands.StrCommands
    import Interp.Functions

    def interp_step(op, stack, environment) do
        {c, stack, environment} = Stack.pop(stack, environment)
        {b, stack, environment} = Stack.pop(stack, environment)
        {a, stack, environment} = Stack.pop(stack, environment)
        try_default(fn -> interp_step(op, stack, environment, a, b, c) end, fn _ -> {Stack.push(stack, a), environment} end)
    end
    
    defp interp_step(op, stack, environment, a, b, c) do
        new_stack = case op do
            "ǝ" -> Stack.push(stack, StrCommands.replace_at(a, b, to_integer!(c)))
            "Š" -> Stack.push(Stack.push(Stack.push(stack, c), a), b)
            "‡" -> Stack.push(stack, StrCommands.transliterate(a, b, c))
            ":" -> Stack.push(stack, StrCommands.replace_infinite(a, b, c))
            "Λ" -> global_env = Globals.get(); Globals.set(%{global_env | canvas: Canvas.write(global_env.canvas, to_integer!(a), to_non_number(b), to_non_number(c), environment)}); stack
           ".Λ" -> 
                global_env = Globals.get()
                new_canvas = Canvas.write(global_env.canvas, to_integer!(a), to_non_number(b), to_non_number(c), environment)
                Globals.set(%{global_env | canvas: %{new_canvas | on_stack: true}}); Stack.push(stack, Canvas.canvas_to_string(new_canvas))
           ".:" -> Stack.push(stack, StrCommands.replace_all(a, b, c))
           ".;" -> Stack.push(stack, StrCommands.replace_first(a, b, c))
        end

        {new_stack, environment}
    end
end