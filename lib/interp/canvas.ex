defmodule Interp.Canvas do

    alias Interp.Functions
    alias Interp.Canvas
    alias Commands.ListCommands
    require Interp.Functions

    defstruct canvas: %{},
              cursor: [0, 0]

    def is_single_direction_list?(directions) do
        case directions do
            [] -> true
            [[[_, _] | _] | _] -> false
            _ -> true
        end
    end

    defp parse_directions(list) when Functions.is_iterable(list), do: list |> Enum.map(fn x -> parse_directions(x) end)
    defp parse_directions(string), do: parse_directions(string, [])
    defp parse_directions("", parsed), do: parsed
    defp parse_directions(string, parsed) do

        cond do
            Regex.match?(~r/^[0-7]/, string) ->
                captures = Regex.named_captures(~r/^(?<direction>[0-7])(?<remaining>.*)/, string)
                case captures["direction"] do
                    "0" -> parse_directions(captures["remaining"], parsed ++ [[:direction, :up]])
                    "1" -> parse_directions(captures["remaining"], parsed ++ [[:direction, :up_right]])
                    "2" -> parse_directions(captures["remaining"], parsed ++ [[:direction, :right]])
                    "3" -> parse_directions(captures["remaining"], parsed ++ [[:direction, :down_right]])
                    "4" -> parse_directions(captures["remaining"], parsed ++ [[:direction, :down]])
                    "5" -> parse_directions(captures["remaining"], parsed ++ [[:direction, :down_left]])
                    "6" -> parse_directions(captures["remaining"], parsed ++ [[:direction, :left]])
                    "7" -> parse_directions(captures["remaining"], parsed ++ [[:direction, :up_left]])
                end
            true -> parsed
        end
    end
    
    def write(canvas, len, characters, direction) do
        directions = parse_directions(direction)
        {new_canvas, _, _} = write_canvas(canvas, len, characters, directions)
        new_canvas
    end

    defp write_canvas(canvas, 0, characters, directions), do: {canvas, characters, directions}
    defp write_canvas(canvas, 1, characters, directions) do
        new_canvas = cond do
            Functions.is_iterable(characters) -> write_char(canvas, List.first Enum.to_list(characters))
            String.length(characters) > 1 -> write_char(canvas, List.first String.graphemes(characters))
            true -> write_char(canvas, characters)
        end

        {new_canvas, characters, directions}
    end
    defp write_canvas(canvas, len, characters, direction) do
        cond do
            # var - var - var
            Functions.is_single?(len) and Functions.is_single?(characters) and String.length(characters) == 1 and is_single_direction_list?(direction) and length(direction) == 1 ->
                write_canvas(move_cursor(write_char(canvas, characters), List.first direction), len - 1, characters, [List.first direction])

            # var - var - vars
            Functions.is_single?(len) and Functions.is_single?(characters) and String.length(characters) == 1 and is_single_direction_list?(direction) ->
                direction |> Enum.reduce({canvas, nil, nil}, fn (dir, {canvas_acc, _, _}) -> write_canvas(canvas_acc, len, characters, [dir]) end)

            # var - vars - var
            Functions.is_single?(len) and Functions.is_single?(characters) and is_single_direction_list?(direction) and length(direction) == 1 ->
                write_canvas(canvas, len, String.graphemes(characters), direction)

            # var - vars - vars
            Functions.is_single?(len) and Functions.is_single?(characters) and is_single_direction_list?(direction) ->
                direction |> Enum.reduce({canvas, characters, nil}, fn (dir, {canvas_acc, chars, _}) -> write_canvas(canvas_acc, len, chars, [dir]) end)

            # var - var - list
            Functions.is_single?(len) and Functions.is_single?(characters) and String.length(characters) == 1 and not is_single_direction_list?(direction) ->
                direction |> Enum.reduce({canvas, nil, nil}, fn (dir, {canvas_acc, _, _}) -> write_canvas(canvas_acc, len, characters, dir) end)

            # var - vars - list
            Functions.is_single?(len) and Functions.is_single?(characters) and not is_single_direction_list?(direction) ->
                direction |> Enum.reduce({canvas, String.graphemes(characters), nil}, fn (dir, {canvas_acc, chars, _}) -> write_canvas(canvas_acc, len, chars, dir) end)

            # var - list - var
            Functions.is_single?(len) and Functions.is_iterable(characters) and is_single_direction_list?(direction) and length(direction) == 1 ->
                [head | remaining] = Enum.to_list characters
                write_canvas(move_cursor(write_char(canvas, head), List.first direction), len - 1, remaining ++ [head], [List.first direction])
        end
    end

    defp write_to_canvas(canvas, 0, _, _), do: canvas
    defp write_to_canvas(canvas, 1, characters, _) do
        cond do
            Functions.is_iterable(characters) -> write_char(canvas, List.first Enum.to_list(characters))
            String.length(characters) > 1 -> write_char(canvas, List.first String.graphemes(characters))
            true -> write_char(canvas, characters)
        end
    end

    # var - list - any
    defp write_to_canvas(canvas, len, characters, direction) when Functions.is_single?(len) and Functions.is_iterable(characters) do
        [head | tail] = Enum.to_list characters
        cond do
            length(direction) > 1 -> 
                {new_canvas, _} = direction |> Enum.reduce({canvas, characters}, fn (dir, {acc, chars}) -> {write_to_canvas(acc, len, chars, [dir]), ListCommands.rotate(chars, len - 1)} end)
                new_canvas
            true -> write_to_canvas(move_cursor(write_char(canvas, head), List.first direction), len - 1, tail ++ [head], [List.first direction])
        end
    end

    # var - var - any
    defp write_to_canvas(canvas, len, characters, direction) when Functions.is_single?(len) and Functions.is_single?(characters) do

        cond do
            String.length(characters) > 1 -> write_to_canvas(canvas, len, String.graphemes(characters), direction)
            length(direction) > 1 -> direction |> Enum.reduce(canvas, fn (dir, acc) -> write_to_canvas(acc, len, characters, [dir]) end)
            true -> write_to_canvas(move_cursor(write_char(canvas, characters), List.first direction), len - 1, characters, [List.first direction])
        end
    end

    defp at(list, x, y), do: Enum.at(Enum.at(list, y), x)

    def canvas_to_string(canvas) do
        keys = Map.keys(canvas.canvas)

        if keys == [] do
            ""
        else
            min_x = Enum.reduce(keys, at(keys, 0, 0), fn ([x, _], acc) -> min(x, acc) end)
            max_x = Enum.reduce(keys, at(keys, 0, 0), fn ([x, _], acc) -> max(x, acc) end)
            min_y = Enum.reduce(keys, at(keys, 1, 0), fn ([_, y], acc) -> min(y, acc) end)
            max_y = Enum.reduce(keys, at(keys, 1, 0), fn ([_, y], acc) -> max(y, acc) end)

            canvas_array = List.duplicate(List.duplicate(" ", max_x - min_x + 1), max_y - min_y + 1)
            
            Enum.reduce(keys, canvas_array, fn (key, acc) ->
                
                # Get the position of the current key where [0, 0] represents the [min_x, max_y] coordinate.
                x = Enum.at(key, 0) - min_x
                y = Enum.at(key, 1) - min_y

                inner_list = List.replace_at(Enum.at(acc, y), x, Map.get(canvas.canvas, key));
                List.replace_at(acc, y, inner_list)
            end)
             |> Enum.reverse
             |> Enum.map(fn x -> Enum.join(x, "") end) |> Enum.join("\n")
        end
    end

    defp move_cursor(canvas, [:direction, direction]) do
        x = Enum.at(canvas.cursor, 0)
        y = Enum.at(canvas.cursor, 1)
        
        # Directions:
        #  7 0 1
        #   \|/
        #  6-x-2
        #   /|\
        #  5 4 3
        new_cursor = case direction do
            :up         -> [x, y + 1]
            :up_right   -> [x + 1, y + 1]
            :right      -> [x + 1, y]
            :down_right -> [x + 1, y - 1]
            :down       -> [x, y - 1]
            :down_left  -> [x - 1, y - 1]
            :left       -> [x - 1, y]
            :up_left    -> [x - 1, y + 1]
            _           -> [x, y]
        end

        %{canvas | cursor: new_cursor}
    end

    defp write_char(canvas, char) do
        %{canvas | canvas: Map.put(canvas.canvas, canvas.cursor, char)}
    end
end