defmodule Interp.Canvas do

    alias Interp.Functions
    alias Interp.Interpreter
    alias Reading.Reader
    alias Parsing.Parser
    require Interp.Functions

    defstruct canvas: %{},
              cursor: [0, 0],
              on_stack: false
              

    def is_single_direction_list?(directions) do
        case directions do
            [] -> true
            [[[_, _] | _] | _] -> false
            _ -> true
        end
    end

    defp pattern_templates, do: %{
        "+" => "04402662",
        "×" => "15513773"
    }

    defp special_ops, do: %{
        "8" => :return_to_origin
    }

    defp map_to_regex(map), do: "(" <> (Map.keys(map) |> Enum.map(&Regex.escape/1) |> Enum.join("|")) <> ")"
    defp pattern_regex, do: map_to_regex pattern_templates()
    defp special_regex, do: map_to_regex special_ops()
    
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

            Regex.match?(~r/^#{special_regex()}/, string) ->
                captures = Regex.named_captures(~r/^(?<op>#{special_regex()})(?<remaining>.*)/, string)
                parse_directions(captures["remaining"], parsed ++ [[:special_op, Map.get(special_ops(), captures["op"])]])

            Regex.match?(~r/^#{pattern_regex()}/, string) ->
                captures = Regex.named_captures(~r/^(?<pattern>#{pattern_regex()})(?<remaining>.*)/, string)
                parse_directions(Map.get(pattern_templates(), captures["pattern"]) <> captures["remaining"], parsed) 

            true -> 
                case List.last(parsed) do
                    [:code, prev_op] -> parse_directions(String.slice(string, 1..-1//1), Enum.slice(parsed, 0..-2//1) ++ [[:code, prev_op <> String.first(string)]])
                    _ -> parse_directions(String.slice(string, 1..-1//1), parsed ++ [[:code, String.first(string)]])
                end
        end
    end
    
    def write(canvas, len, characters, direction, environment) do
        directions = parse_directions(direction)
        {new_canvas, _, _} = write_canvas(canvas, len, characters, directions, environment)
        new_canvas
    end

    # Normalizes the length of the given canvas environment. This means that if the returned environment
    # denotes the length as 'nil', it will be reassigned to the given curr_length. Otherwise it will return
    # the given environment untouched.
    defp normalize_length({canvas, characters, nil}, curr_length), do: {canvas, characters, curr_length}
    defp normalize_length({canvas, characters, length}, _), do: {canvas, characters, length}

    # If the head of directions is not a direction, but a code snippet, run the code snippet on a stack
    # which contains the length as an element and reassign the length to the result of running that code snippet.
    defp write_canvas(canvas, len, characters, [[:code, op] | remaining], environment) do
        list = [[:code, op] | remaining]
        code = list |> Enum.take_while(fn [type, _] -> type == :code end) |> Enum.map(fn [_, op] -> op end) |> Enum.join("")
        result = Functions.to_number Interpreter.flat_interp(Parser.parse(Reader.read(code)), [len], environment)
        normalize_length(write_canvas(canvas, result, characters, remaining, environment), result)
    end

    # Interpretation of the special op.
    defp write_canvas(canvas, len, characters, [[:special_op, op] | remaining], environment) do
        case op do
            :return_to_origin -> write_canvas(%{canvas | cursor: [0, 0]}, len, characters, remaining, environment)
        end
    end
    
    # When the rounded version of the length is <= 0 or <= 1. We cannot round the length since we
    # need to keep the unrounded version in memory in case commands will be run against them.
    defp write_canvas(canvas, length, characters, _, _) when length < 0.5, do: {canvas, characters, nil}
    defp write_canvas(canvas, length, characters, _, _) when length < 1.5 do
        new_canvas = cond do
            Functions.is_iterable(characters) -> write_char(canvas, List.first Enum.to_list(characters))
            String.length(characters) > 1 -> write_char(canvas, List.first String.graphemes(characters))
            true -> write_char(canvas, characters)
        end

        {new_canvas, characters, nil}
    end

    # Main case for writing to the canvas.
    defp write_canvas(canvas, len, characters, direction, environment) do
        cond do
            # var - var - var
            Functions.is_single?(len) and Functions.is_single?(characters) and String.length(characters) == 1 and is_single_direction_list?(direction) and length(direction) == 1 ->
                write_canvas(move_cursor(write_char(canvas, characters), List.first direction), len - 1, characters, [List.first direction], environment)

            # var - var - vars
            Functions.is_single?(len) and Functions.is_single?(characters) and String.length(characters) == 1 and is_single_direction_list?(direction) ->
                direction |> Enum.reduce({canvas, nil, len}, fn (dir, {canvas_acc, _, curr_length}) -> 
                    normalize_length(write_canvas(canvas_acc, curr_length, characters, [dir], environment), curr_length) end)

            # var - vars - var
            Functions.is_single?(len) and Functions.is_single?(characters) and is_single_direction_list?(direction) and length(direction) == 1 ->
                normalize_length(write_canvas(canvas, len, String.graphemes(characters), direction, environment), len)

            # var - vars - vars
            Functions.is_single?(len) and Functions.is_single?(characters) and is_single_direction_list?(direction) ->
                direction |> Enum.reduce({canvas, characters, len}, fn (dir, {canvas_acc, chars, curr_length}) -> 
                    normalize_length(write_canvas(canvas_acc, curr_length, chars, [dir], environment), curr_length) end)

            # var - var - list
            Functions.is_single?(len) and Functions.is_single?(characters) and String.length(characters) == 1 and not is_single_direction_list?(direction) ->
                direction |> Enum.reduce({canvas, nil, len}, fn (dir, {canvas_acc, _, curr_length}) -> 
                    normalize_length(write_canvas(canvas_acc, curr_length, characters, dir, environment), curr_length) end)

            # var - vars - list
            Functions.is_single?(len) and Functions.is_single?(characters) and not is_single_direction_list?(direction) ->
                direction |> Enum.reduce({canvas, String.graphemes(characters), len}, fn (dir, {canvas_acc, chars, curr_length}) -> 
                    normalize_length(write_canvas(canvas_acc, curr_length, chars, dir, environment), curr_length) end)

            # var - list - var
            Functions.is_single?(len) and Functions.is_iterable(characters) and is_single_direction_list?(direction) and length(direction) == 1 ->
                [head | remaining] = Enum.to_list characters
                write_canvas(move_cursor(write_char(canvas, head), List.first direction), len - 1, remaining ++ [head], [List.first direction], environment)
            
            # var - list - vars
            Functions.is_single?(len) and Functions.is_iterable(characters) and is_single_direction_list?(direction) ->
                direction |> Enum.reduce({canvas, characters, len}, fn (dir, {canvas_acc, chars, curr_length}) -> 
                    normalize_length(write_canvas(canvas_acc, curr_length, chars, [dir], environment), curr_length) end)

            # var - list - list
            Functions.is_single?(len) and Functions.is_iterable(characters) and not is_single_direction_list?(direction) ->
                direction |> Enum.reduce({canvas, characters, len}, fn (dir, {canvas_acc, chars, curr_length}) -> 
                    normalize_length(write_canvas(canvas_acc, curr_length, chars, dir, environment), curr_length) end)

            # list - var - var(s)
            Functions.is_iterable(len) and Functions.is_single?(characters) and String.length(characters) == 1 and is_single_direction_list?(direction) ->
                len |> Enum.reduce({canvas, characters, nil}, fn (curr_len, {canvas_acc, chars, _}) -> write_canvas(canvas_acc, curr_len, chars, direction, environment) end)

            # list - vars - var(s)
            Functions.is_iterable(len) and Functions.is_single?(characters) and is_single_direction_list?(direction) ->
                len |> Enum.reduce({canvas, String.graphemes(characters), nil}, fn (curr_len, {canvas_acc, chars, _}) -> write_canvas(canvas_acc, curr_len, chars, direction, environment) end)

            # list - var - list
            Functions.is_iterable(len) and Functions.is_single?(characters) and not is_single_direction_list?(direction) ->
                Stream.zip(len, Stream.cycle(direction)) |> Enum.to_list |> Enum.reduce({canvas, characters, nil}, fn ({curr_len, curr_dir}, {canvas_acc, chars, _}) -> write_canvas(canvas_acc, curr_len, chars, curr_dir, environment) end)
            
            # list - list - var(s)
            Functions.is_iterable(len) and Functions.is_iterable(characters) and is_single_direction_list?(direction) ->
                characters |> Enum.reduce({canvas, direction, nil}, fn (curr_char, {canvas_acc, _, _}) -> write_canvas(canvas_acc, len, curr_char, direction, environment) end)
            
            # list - list - list
            Functions.is_iterable(len) and Functions.is_iterable(characters) and not is_single_direction_list?(direction) ->
                Stream.zip([len, characters, Stream.cycle(direction)]) |> Enum.to_list |> Enum.reduce({canvas, characters, nil}, fn ({curr_len, curr_char, curr_dir}, {canvas_acc, _, _}) ->
                    write_canvas(canvas_acc, curr_len, curr_char, curr_dir, environment) end)
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