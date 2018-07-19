defmodule Commands.GeneralCommands do

    alias Interp.Functions
    require Interp.Functions
    
    def head(value) do
        cond do
            Functions.is_iterable(value) -> hd(Enum.to_list(Stream.take(value, 1)))
            is_integer(value) -> head(Functions.to_non_number(value))
            true -> String.slice(value, 0..0)
        end
    end

    def dehead(value) do
        cond do
            Functions.is_iterable(value) -> Stream.drop(value, 1)
            true -> String.slice(to_string(value), 1..-1)
        end
    end

    def tail(value) do
        cond do
            Functions.is_iterable(value) -> hd(Enum.slice(Enum.to_list(value), -1..-1))
            is_integer(value) -> tail(Functions.to_non_number(value))
            true -> String.slice(value, -1..-1)
        end
    end

    def detail(value) do
        cond do
            Functions.is_iterable(value) -> Stream.take(value, length(Enum.to_list(value)) - 1)
            true -> String.slice(to_string(value), 0..-2)
        end
    end

    # def slice(value, a, b) do
    #     cond do
    #         is_map(value) -> Stream.cycle(value) |> Stream.drop(a) 
    #     end
    # end

    def element_at(value, index) do
        cond do
            is_map(value) -> Stream.cycle(value) |> Stream.drop(index) |> Stream.take(1) |> Enum.to_list |> hd
            is_integer(value) -> element_at(Functions.to_non_number(value), index)
            true -> String.at(value, rem(index, String.length(value)))
        end
    end

    def remove_from(value, filter_chars) do
        filter_chars = Functions.to_str Functions.stream(filter_chars)
        value = Functions.to_str(value)

        cond do
            is_map(value) or is_list(value) -> value |> Stream.map(fn x -> remove_from(x, filter_chars) end)
            true -> Enum.reduce(Enum.filter(String.graphemes(value), fn x -> not Enum.member?(filter_chars, Functions.to_str x) end), "", fn (element, acc) -> acc <> element end)
        end
    end

    def enclose(value) do
        cond do
            Functions.is_iterable(value) -> Stream.concat(value, Stream.take(value, 1)) |> Stream.map(fn x -> x end)
            true -> Functions.to_non_number(value) <> head(value)
        end
    end
end