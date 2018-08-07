defmodule Interp.Functions do


    defmacro is_iterable(value) do
        quote do: is_map(unquote(value)) or is_list(unquote(value))
    end

    @doc """
    Checks whether the given value is 'single', which means that it is
    either an integer/float/string. Since the only types allowed by 05AB1E are the following:

     - integer
     - float
     - string
     - iterable (enum/stream)

    We only need to check whether the given value is not iterable.
    """
    defmacro is_single?(value) do
        quote do: not (is_map(unquote(value)) or is_list(unquote(value)))
    end

    # ----------------
    # Value conversion
    # ----------------
    def to_number(value) do
        value = cond do
            is_iterable(value) -> value
            Regex.match?(~r/^\.\d+/, to_string(value)) -> "0" <> to_string(value)
            true -> value
        end

        case value do
            true -> 1
            false -> 0
            _ when is_integer(value) or is_float(value) ->
                value
            _ when is_iterable(value) ->
                value |> Stream.map(&to_number/1)
            _ ->
                try do
                    {value, remaining} = Integer.parse(value)
                    if Regex.match?(~r/\.\d*/, remaining) do
                        {float_value, _} = Float.parse("0" <> remaining)
                        if float_value == 0.0 do
                            value
                        else
                            value + float_value
                        end
                    else
                        value
                    end
                rescue
                    _ -> value
                end
        end
    end

    def to_non_number(value) do
        case value do
            _ when is_integer(value) ->
                Integer.to_string(value)
            _ when is_float(value) ->
                Float.to_string(value)
            _ when is_iterable(value) ->
                value |> Stream.map(&to_non_number/1)
            _ -> 
                value
        end
    end

    def to_str(value) do
        case value do
            true -> "1"
            false -> "0"
            _ when is_integer(value) -> to_string(value)
            _ when is_map(value) -> Enum.map(value, &to_str/1)
            _ -> value
        end
    end

    def to_list(value) do
        cond do
            is_iterable(value) -> value
            true -> String.graphemes(to_string(value))
        end
    end

    def stream(value) do
        cond do
            is_list(value) -> value |> Stream.map(fn x -> x end)
            is_map(value) -> value
            is_integer(value) -> stream(to_string(value))
            true -> String.graphemes(value)
        end
    end

    def normalize_to(value, initial) when is_iterable(value) and not is_iterable(initial), do: value |> Stream.map(fn x -> Enum.join(x) end)
    def normalize_to(value, initial), do: value

    def normalize_inner(value, initial) when is_iterable(value) and not is_iterable(initial), do: value |> Stream.map(fn x -> x |> Stream.map(fn y -> Enum.join(y, "") end) end)
    def normalize_inner(value, initial), do: value

    # --------------------------------
    # Force evaluation on lazy objects
    # --------------------------------
    def eval(value) when is_iterable(value) do
        Enum.to_list(value)
        Enum.map(value, &eval/1)
    end

    def eval(value) do
        value
    end


    # --------------------
    # Unary method calling
    # --------------------
    def call_unary(func, a) do 
        call_unary(func, a, false)
    end

    def call_unary(func, a, false) when is_iterable(a) do
        a |> Stream.map(fn x -> call_unary(func, x, false) end)
    end

    def call_unary(func, a, _) do
        func.(a)
    end

    
    # ---------------------
    # Binary method calling
    # ---------------------
    def call_binary(func, a, b) do
        call_binary(func, a, b, false, false)
    end

    def call_binary(func, a, b, false, false) when is_iterable(a) and is_iterable(b) do
        Stream.zip([a, b]) |> Stream.map(fn {x, y} -> call_binary(func, x, y, false, false) end)
    end

    def call_binary(func, a, b, _, false) when is_iterable(b) do
        b |> Stream.map(fn x -> call_binary(func, a, x, true, false) end)
    end

    def call_binary(func, a, b, false, _) when is_iterable(a) do
        a |> Stream.map(fn x -> call_binary(func, x, b, false, true) end)
    end

    def call_binary(func, a, b, _, _) do
        func.(a, b)
    end


    # ----------------------
    # Ternary method calling
    # ----------------------
    def call_ternary(func, a, b, c) do
        call_ternary(func, a, b, c, false, false, false)
    end

    def call_ternary(func, a, b, c, false, false, false) when is_iterable(a) and is_iterable(b) and is_iterable(c) do
        Stream.zip([a, b, c]) |> Stream.map(fn {x, y, z} -> call_ternary(func, x, y, z, false, false, false) end)
    end

    def call_ternary(func, a, b, c, _, false, false) when is_iterable(b) and is_iterable(c) do
        Stream.zip([b, c]) |> Stream.map(fn {y, z} -> call_ternary(func, a, y, z, true, false, false) end)
    end

    def call_ternary(func, a, b, c, false, _, false) when is_iterable(a) and is_iterable(c) do
        Stream.zip([a, c]) |> Stream.map(fn {x, z} -> call_ternary(func, x, b, z, false, true, false) end)
    end

    def call_ternary(func, a, b, c, false, false, _) when is_iterable(a) and is_iterable(b) do
        Stream.zip([a, b]) |> Stream.map(fn {x, y} -> call_ternary(func, x, y, c, false, false, true) end)
    end

    def call_ternary(func, a, b, c, _, _, false) when is_iterable(c) do
        c |> Stream.map(fn z -> call_ternary(func, a, b, z, true, true, false) end)
    end

    def call_ternary(func, a, b, c, _, false, _) when is_iterable(b) do
        b |> Stream.map(fn y -> call_ternary(func, a, y, c, true, false, true) end)
    end

    def call_ternary(func, a, b, c, false, _, _) when is_iterable(a) do
        a |> Stream.map(fn x -> call_ternary(func, x, b, c, false, true, true) end)
    end
    
    def call_ternary(func, a, b, c, _, _, _) do
        func.(a, b, c)
    end
end