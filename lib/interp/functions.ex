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

    def to_integer(value) do
        cond do
            value == true -> 1
            value == false -> 0
            is_integer(value) -> value
            is_float(value) -> round(Float.floor(value))
            is_iterable(value) -> value |> Stream.map(&to_integer/1)
            true ->
                {int, _} = Integer.parse(to_string(value))
                int 
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

    def normalize_to(value, initial) when is_iterable(value) and not is_iterable(initial), do: value |> Enum.join("")
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
        try do
            func.(a, b)
        rescue
            _ -> func.(b, a) 
        end
    end
end