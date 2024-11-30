defmodule Interp.Functions do

    alias Interp.Globals


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
    def to_number(true), do: 1
    def to_number(false), do: 0
    def to_number(value) when is_iterable(value), do: value |> Stream.map(&to_number/1)
    def to_number(value) when is_number(value), do: value
    def to_number(value) do
        value = cond do
            Regex.match?(~r/^\.\d+/, to_string(value)) -> "0" <> to_string(value)
            true -> value
        end

        if is_bitstring(value) and String.starts_with?(value, "-") do
            try do
                new_val = String.slice(value, 1..-1//1)
                -to_number(new_val)
            rescue
                _ -> value
            end
        else
            try do
                {int_part, remaining} = Integer.parse(value)
                case remaining do
                    "" -> int_part
                    _ ->
                        {float_part, remaining} = Float.parse("0" <> remaining)
                        cond do
                            remaining != "" -> value
                            float_part == 0.0 -> int_part
                            remaining == "" -> int_part + float_part
                            true -> value
                        end
                end
            rescue
                _ -> value
            end
        end
    end

    def to_number!(value) do
        cond do
            is_iterable(value) -> value |> Stream.map(&to_number!/1)
            true -> case to_number(value) do
                x when is_number(x) -> x
                _ -> raise("Could not convert #{value} to number.")
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
                case Integer.parse(to_string(value)) do
                    :error -> value
                    {int, string} ->
                        cond do
                            string == "" -> int
                            Regex.match?(~r/^\.\d+$/, string) -> int
                            true -> value
                        end
                end
        end
    end

    def to_integer!(value) do
        cond do
            is_iterable(value) -> value |> Stream.map(&to_integer!/1)
            true ->
                case to_integer(value) do
                    x when is_integer(x) -> x
                    _ -> raise("Could not convert #{value} to integer.")
                end
        end
    end

    def is_integer?(value), do: (to_number(value) == to_integer(value) and not(is_bitstring(to_number(value))))
    def is_number?(value), do: (try do is_number(to_number(value)) catch _ -> false end)

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
            _ when is_number(value) -> to_string(value)
            _ when is_iterable(value) -> Enum.map(value, &to_str/1)
            _ -> value
        end
    end

    def flat_string(value) do
        case value do
            true -> "1"
            false -> "0"
            _ when is_number(value) -> to_string(value)
            _ when is_iterable(value) -> "[" <> (value |> Enum.to_list |> Enum.map(&flat_string/1) |> Enum.join(", ")) <> "]"
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

    def as_stream(stream) do
        stream |> Stream.map(fn x -> x end)
    end

    def normalize_to(value, initial) when is_iterable(value) and not is_iterable(initial), do: value |> Enum.to_list |> Enum.join("")
    def normalize_to(value, _), do: value

    def normalize_inner(value, initial) when is_iterable(value) and not is_iterable(initial), do: value |> Stream.map(fn x -> x |> Stream.map(fn y -> Enum.join(y, "") end) end)
    def normalize_inner(value, _), do: value

    # --------------------------------
    # Force evaluation on lazy objects
    # --------------------------------
    def eval(value) when is_iterable(value), do: Enum.map(Enum.to_list(value), &eval/1)
    def eval(value), do: value


    # --------------------
    # Unary method calling
    # --------------------
    def call_unary(func, a), do: call_unary(func, a, false)
    def call_unary(func, a, false) when is_iterable(a), do: a |> Stream.map(fn x -> call_unary(func, x, false) end)
    def call_unary(func, a, _) do
        try_default(fn -> func.(a) end, fn exception -> throw_test_or_return(exception, a) end)
    end


    # ---------------------
    # Binary method calling
    # ---------------------
    def call_binary(func, a, b), do: call_binary(func, a, b, false, false)
    def call_binary(func, a, b, false, false) when is_iterable(a) and is_iterable(b), do: Stream.zip([a, b]) |> Stream.map(fn {x, y} -> call_binary(func, x, y, false, false) end)
    def call_binary(func, a, b, _, false) when is_iterable(b), do: b |> Stream.map(fn x -> call_binary(func, a, x, true, false) end)
    def call_binary(func, a, b, false, _) when is_iterable(a), do: a |> Stream.map(fn x -> call_binary(func, x, b, false, true) end)
    def call_binary(func, a, b, _, _) do
        try_default([
            fn -> func.(a, b) end,
            fn -> func.(b, a) end
        ], fn exception -> throw_test_or_return(exception, a) end)
    end

    def try_default([function], exception_function), do: try_default(function, exception_function)
    def try_default([function | remaining], exception_function), do: (try do function.() rescue _ -> try_default(remaining, exception_function) end)
    def try_default(function, exception_function), do: (try do function.() rescue x -> exception_function.(x) end)

    defp throw_test_or_return(exception, value) do
        case Globals.get().debug.test do
            true -> throw(exception)
            false -> value
        end
    end
end
