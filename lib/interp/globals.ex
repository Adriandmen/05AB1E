defmodule Interp.GlobalEnvironment do
    defstruct counter_variable: 0,
              canvas: nil,              # TODO: create canvas module
              x: 1,
              y: 2,
              z: 3,
              c: -1,
              inputs: [],
              status: :ok,
              printed: false
end

defmodule Interp.Globals do

    alias Interp.GlobalEnvironment
    alias Reading.InputHandler

    def initialize do
        receive do
            {:env, global_env} -> send(self(), {:env, global_env})
        after
            0 -> 
                send(self(), {:env, %GlobalEnvironment{}})
        end
    end

    def get do
        receive do
            {:env, global_env} ->
                send(self(), {:env, global_env})
                global_env
        after
            0 -> throw("Could not retrieve global environment.")
        end
    end

    def set(new_env) do
        receive do
            _ -> send(self(), {:env, new_env})
        after
            0 -> throw("Could not retrieve global environment.")
        end
    end

    def get_input(n) do
        list = get().inputs
        if length(list) <= n do
            InputHandler.read_input()
            get_input(n)
        else
            Enum.at(get().inputs, n)
        end
    end
end

defmodule Interp.Output do
    alias Interp.Globals
    alias Interp.Functions
    require Interp.Functions

    def print(element, newline \\ true) do
        Globals.set(%{Globals.get() | printed: true})
        cond do
            element == :separator ->
                IO.write(", ")
            Functions.is_iterable(element) -> 
                IO.write("[")
                element |> Stream.intersperse(:separator) |> Stream.each(fn x -> print(x, false) end) |> Stream.run
                IO.write("]")
            is_number(element) ->
                IO.write(element)
            true ->
                IO.write("\"")
                IO.write(element)
                IO.write("\"")
        end

        if newline, do: IO.write("\n")
    end
end