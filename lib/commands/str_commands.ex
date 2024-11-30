defmodule Commands.StrCommands do
    alias Interp.Functions
    alias Commands.ListCommands
    alias Commands.GeneralCommands
    require Interp.Functions
    use Memoize

    @doc """
    Replace at the given index. Replaces the element found in a at index c and replaces it with b.
    """
    def replace_at(a, b, c) when Functions.is_iterable(a) and Functions.is_iterable(b) and Functions.is_iterable(c) do
        Enum.reduce(Enum.to_list(Stream.zip([b, c])), a, 
            fn ({new, index}, acc) -> acc |> Stream.with_index |> Stream.map(fn {element, curr_index} -> if curr_index == index do new else element end end)
        end)
    end
    def replace_at(a, b, c) when Functions.is_iterable(a) and Functions.is_iterable(b), do: a |> Stream.with_index |> Stream.map(fn {element, curr_index} -> if curr_index == c do b else element end end)
    def replace_at(a, b, c) when Functions.is_iterable(a) and Functions.is_iterable(c), do: Enum.reduce(c, a, fn (index, acc) -> replace_at(acc, b, index) end)
    def replace_at(a, b, c) when Functions.is_iterable(a), do: a |> Stream.with_index |> Stream.map(fn {element, curr_index} -> if GeneralCommands.equals(curr_index, c) do b else element end end)
    def replace_at(a, b, c), do: String.graphemes(to_string(a)) |> replace_at(b, c) |> Enum.join("") 

    @doc """
    Infinite replacement method. When the first element ('a') is an iterable, it maps the replace_infinite method over each
    element of 'a'. An alternative non-vectorizing version (although not infinitly replaced) is the transliteration method.

    ## Parameters
    
     - a:   The value in which the replacements will happen.
     - b:   The from value(s) for the replacement pair(s).
     - c:   The to value(s) for the replacement pair(s).

    ## Returns

    Returns the element 'a' where the each replacement pair is infinitly replaced.
    """
    def replace_infinite(a, b, c) when Functions.is_single?(a) and Functions.is_single?(b) and Functions.is_single?(c) do
        a = to_string(a)
        b = to_string(b)
        c = to_string(c)
        replace_infinite(String.replace(a, b, c), b, c, a)
    end
    def replace_infinite(a, b, c) when Functions.is_single?(a) and Functions.is_iterable(b) and Functions.is_iterable(c), do: Enum.reduce(Stream.zip(b, c), a, fn ({from, to}, acc) -> replace_infinite(acc, from, to) end)
    def replace_infinite(a, b, c) when Functions.is_single?(a) and Functions.is_iterable(b) and Functions.is_single?(c) do (case Enum.reduce(b, a, fn (from, acc) -> replace_infinite(acc, from, c) end) do; ^a -> a; x -> replace_infinite(x, b, c) end) end
    def replace_infinite(a, b, c) when Functions.is_single?(a) and Functions.is_single?(b) and Functions.is_iterable(c), do: Enum.reduce(c, a, fn (to, acc) -> replace_infinite(acc, b, to) end)
    def replace_infinite(a, b, c) when Functions.is_iterable(a), do: a |> Stream.map(fn x -> replace_infinite(x, b, c) end)
    
    defp replace_infinite(a, b, c, acc) do (case String.replace(a, b, c) do; ^acc -> acc; x -> replace_infinite(x, b, c, a) end) end

    def replace_all(a, b, c) when Functions.is_single?(a) and Functions.is_single?(b) and Functions.is_single?(c) do
        a = to_string(a)
        b = to_string(b)
        c = to_string(c)
        String.replace(a, b, c)
    end
    def replace_all(a, b, c) when Functions.is_single?(a) and Functions.is_iterable(b) and Functions.is_iterable(c), do: Enum.reduce(Stream.zip(b, c), a, fn ({from, to}, acc) -> replace_all(acc, from, to) end)
    def replace_all(a, b, c) when Functions.is_single?(a) and Functions.is_iterable(b) and Functions.is_single?(c), do: Enum.reduce(b, a, fn (from, acc) -> replace_all(acc, from, c) end)
    def replace_all(a, b, c) when Functions.is_single?(a) and Functions.is_single?(b) and Functions.is_iterable(c), do: Enum.reduce(c, a, fn (to, acc) -> replace_all(acc, b, to) end)
    def replace_all(a, b, c) when Functions.is_iterable(a), do: a |> Stream.map(fn x -> replace_all(x, b, c) end)

    def replace_first(a, b, c) when Functions.is_iterable(a) and Functions.is_single?(b) and Functions.is_single?(c) do
        case a |> ListCommands.index_in(b) do
            -1 -> a
            index -> a |> replace_at(c, index)
        end
    end
    def replace_first(a, b, c) when Functions.is_single?(a) and Functions.is_single?(b) and Functions.is_single?(c) do
        case String.split(to_string(a), to_string(b)) do
            [left, right | remaining] -> left <> to_string(c) <> Enum.join([right | remaining], to_string(b))
            _ -> a
        end
    end
    def replace_first(a, b, c) when Functions.is_iterable(b) and Functions.is_iterable(c), do: Enum.reduce(Stream.zip(b, c), a, fn ({from, to}, acc) -> replace_first(acc, from, to) end)
    def replace_first(a, b, c) when Functions.is_iterable(b) and Functions.is_single?(c), do: Enum.reduce(b, a, fn (from, acc) -> replace_first(acc, from, c) end)
    def replace_first(a, b, c) when Functions.is_single?(b) and Functions.is_iterable(c), do: Enum.reduce(c, a, fn (to, acc) -> replace_first(acc, b, to) end)


    @doc """
    Computes the Levenshtein distance between two lists of characters using the following recursive formula:

    lev([], b) = length(b)
    lev(a, []) = length(a)
    lev(a, b) = min(lev(a - 1, b) + 1, lev(a, b - 1) + 1, lev(a - 1, b - 1) + (a[0] == b[0]))

    """
    defmemo levenshtein_distance([], b), do: length(b)
    defmemo levenshtein_distance(a, []), do: length(a)
    defmemo levenshtein_distance([a | as], [b | bs]) do
        min(levenshtein_distance(as, [b | bs]) + 1, min(levenshtein_distance([a | as], bs) + 1, levenshtein_distance(as, bs) + (if GeneralCommands.equals(a, b) do 0 else 1 end)))
    end


    def squarify(list) do
        list = Enum.to_list(list)
        max_length = list |> Enum.map(fn x -> String.length(to_string(x)) end) |> Enum.max
        list |> Enum.map(fn x -> to_string(x) <> String.duplicate(" ", max_length - String.length(to_string(x))) end)
    end

    def align_center(list, focus) do
        list = Enum.to_list(list)
        max_length = list |> Enum.map(fn x -> String.length(to_string(x)) end) |> Enum.max

        result = case focus do
            :left -> list |> Enum.map(fn x -> String.duplicate(" ", round(Float.floor((max_length - String.length(to_string(x))) / 2))) <> to_string(x) end)
            :right -> list |> Enum.map(fn x -> String.duplicate(" ", round(Float.ceil((max_length - String.length(to_string(x))) / 2))) <> to_string(x) end)
        end

        result |> Enum.join("\n")
    end

    def overlap(left, right) when not Functions.is_iterable(left), do: overlap(String.graphemes(to_string(left)), right)
    def overlap(left, right) when not Functions.is_iterable(right), do: overlap(left, String.graphemes(to_string(right)))
    def overlap(left, right), do: overlap(Enum.to_list(left), Enum.to_list(right), "")
    defp overlap([], [], acc), do: acc
    defp overlap([], right_remaining, acc), do: acc <> Enum.join(right_remaining, "")
    defp overlap([head | left_remaining], [head | right_remaining], acc), do: overlap(left_remaining, right_remaining, acc <> head)
    defp overlap([_ | left_remaining], right_remaining, acc), do: overlap(left_remaining, right_remaining, acc <> " ")
    
    def title_case(string), do: title_case(string, "")
    defp title_case("", parsed), do: parsed
    defp title_case(string, parsed) do
        cond do
            Regex.match?(~r/^[a-zA-Z]/, string) ->
                matches = Regex.named_captures(~r/^(?<string>[a-zA-Z]+)(?<remaining>.*)/s, string)
                title_case(matches["remaining"], parsed <> String.capitalize(matches["string"]))
            true ->
                matches = Regex.named_captures(~r/^(?<string>[^a-zA-Z]+)(?<remaining>.*)/s, string)
                title_case(matches["remaining"], parsed <> matches["string"])
        end
    end

    def switch_case(string), do: switch_case(String.graphemes(string), []) |> Enum.join("")
    defp switch_case([], parsed), do: parsed |> Enum.reverse
    defp switch_case([char | remaining], parsed) do
        cond do
            Regex.match?(~r/^[a-z]$/, char) -> switch_case(remaining, [String.upcase(char) | parsed])
            Regex.match?(~r/^[A-Z]$/, char) -> switch_case(remaining, [String.downcase(char) | parsed])
            true -> switch_case(remaining, [char | parsed])
        end
    end

    def sentence_case(string), do: sentence_case(string, "")
    defp sentence_case("", parsed), do: parsed
    defp sentence_case(string, parsed) do
        cond do
            Regex.match?(~r/^[a-zA-Z]/, string) ->
                matches = Regex.named_captures(~r/^(?<string>[a-zA-Z].+?)(?<remaining>(\.|!|\?|$).*)/s, string)
                sentence_case(matches["remaining"], parsed <> String.capitalize(String.slice(matches["string"], 0..0)) <> String.slice(matches["string"], 1..-1//1))
            true ->
                matches = Regex.named_captures(~r/^(?<string>.)(?<remaining>.*)/s, string)
                sentence_case(matches["remaining"], parsed <> matches["string"])
        end
    end

    def keep_letters(string) when is_bitstring(string), do: keep_letters(String.graphemes(string)) |> Enum.join("")
    def keep_letters(list) do
        list |> Stream.filter(fn x -> Regex.match?(~r/^[A-Za-z]+$/, to_string(x)) end)
    end

    def keep_digits(string) when is_bitstring(string), do: keep_digits(String.graphemes(string)) |> Enum.join("")
    def keep_digits(list) do
        list |> Stream.filter(fn x -> Regex.match?(~r/^[0-9]+$/, to_string(x)) end)
    end

    def keep_chars(string, chars) when is_bitstring(string) and is_bitstring(chars), do: keep_chars(String.graphemes(string), String.graphemes(chars)) |> Enum.join("")
    def keep_chars(string, chars) when is_bitstring(string), do: keep_chars(String.graphemes(string), chars) |> Enum.join("")
    def keep_chars(list, chars) when is_bitstring(chars) do
        list |> Stream.filter(fn x -> GeneralCommands.equals(x, chars) end)
    end
    def keep_chars(list, chars) do
        list |> Stream.filter(fn x -> ListCommands.contains(chars, x) end)
    end

    def to_codepoints(value) when Functions.is_iterable(value), do: value |> Stream.map(
        fn x -> 
            if not Functions.is_iterable(x) and String.length(to_string(x)) == 1 do 
                hd(to_codepoints(to_string(x))) 
            else 
                to_codepoints(to_string(x)) 
            end 
        end)
    def to_codepoints(value), do: String.to_charlist(to_string(value))

    @doc """
    Transliterates the given string with the given transliteration set. For example, transliterating "abcd" with "bdg" → "qrs" would
    transliterate the following in the initial string:

     "b" → "q"
     "d" → "r"
     "g" → "s"

    The first match in the transliteration set is the transliteration that is executed. Therefore "abcd" results in "aqcr" after transliteration.

    ## Parameters

     - string/list:     The string or list that needs to be transliterated.
     - from_chars:      The from characters either as a single element or as a list.
     - to_chars:        The characters to which the initial characters will be mapped to, either as a single element or a list.

    ## Returns

    The transliterated string or list depending on the initial type of the first parameter.
    
    """
    def transliterate(string, from_chars, to_chars) when Functions.is_single?(string), do: Enum.join(transliterate(String.graphemes(to_string(string)), from_chars, to_chars), "")
    def transliterate(list, from_chars, to_chars) when Functions.is_single?(from_chars), do: transliterate(list, String.graphemes(to_string(from_chars)), to_chars)
    def transliterate(list, from_chars, to_chars) when Functions.is_single?(to_chars), do: transliterate(list, from_chars, String.graphemes(to_string(to_chars)))
    def transliterate(list, from_chars, to_chars) do
        transliteration_pairs = Stream.zip(from_chars, to_chars)
        list |> Stream.map(fn x ->
            case ListCommands.first_where(transliteration_pairs, fn {a, _} -> GeneralCommands.equals(a, x) end) do
                nil -> x
                {_, b} -> b
            end
        end)
    end

    def vertical_mirror(string) when is_bitstring(string), do: Enum.join(vertical_mirror(String.split(string, "\n")), "\n")
    def vertical_mirror(list) do
        list ++ (list |> Enum.to_list |> Enum.reverse |> Enum.map(fn x -> x |> transliterate("\\/", "/\\") end))
    end

    def mirror(list) when Functions.is_iterable(list) do
        list |> Stream.map(fn x -> if Functions.is_iterable(x) do x ++ (x |> Enum.to_list |> Enum.reverse |> transliterate("<>{}()[]\\/", "><}{)(][/\\")) else mirror(x) end end)
    end
    def mirror(string) do
        string = to_string(string)
        cond do
            String.contains?(string, "\n") -> Enum.join(mirror(String.split(string, "\n")), "\n")
            true -> string <> (string |> String.reverse |> transliterate("<>{}()[]\\/", "><}{)(][/\\"))
        end
    end

    def intersected_mirror(list) when Functions.is_iterable(list) do
        list |> Stream.map(fn x -> if Functions.is_iterable(x) do x ++ (x |> Enum.to_list |> Enum.drop(1) |> Enum.reverse |> transliterate("<>{}()[]\\/", "><}{)(][/\\")) else intersected_mirror(x) end end)
    end
    def intersected_mirror(string) do
        string = to_string(string)
        cond do
            String.contains?(string, "\n") -> Enum.join(intersected_mirror(String.split(string, "\n")), "\n")
            true -> string <> (string |> String.reverse |> String.slice(1..-1//1) |> transliterate("<>{}()[]\\/", "><}{)(][/\\"))
        end
    end

    def vertical_intersected_mirror(list) when Functions.is_iterable(list) do
        list ++ (list |> Enum.reverse |> Enum.drop(1) |> Enum.map(fn x -> x |> transliterate("/\\", "\\/") end)) |> Enum.join("\n")
    end
    def vertical_intersected_mirror(string), do: vertical_intersected_mirror(String.split(to_string(string), "\n"))

    def leftpad_with(list, length, pad_char) when Functions.is_iterable(list), do: list |> Stream.map(fn x -> leftpad_with(x, length, pad_char) end)
    def leftpad_with(string, length, pad_char) when is_bitstring(string), do: String.duplicate(pad_char, max(length - String.length(string), 0)) <> string
    def leftpad_with(value, length, pad_char), do: leftpad_with(Functions.to_non_number(value), length, pad_char)

    def run_length_encode(string) when not Functions.is_iterable(string), do: run_length_encode(Functions.to_list(string))
    def run_length_encode(list) do
        chars = list |> ListCommands.deduplicate
        lengths = list |> ListCommands.group_equal |> Stream.map(fn x -> length(Enum.to_list(x)) end)
        {chars, lengths}
    end

    def run_length_decode(elements, lengths) do
        Stream.zip(elements, lengths) |> Stream.flat_map(fn {element, len} -> List.duplicate(element, Functions.to_number(len)) end) |> Functions.as_stream
    end

    defp exchange_capitalization(left, [], acc), do: acc <> Enum.join(left, "")
    defp exchange_capitalization([], _, acc), do: acc
    defp exchange_capitalization([a | as], [b | bs], acc) do
        cond do
            Regex.match?(~r/^[A-Z]/, b) -> exchange_capitalization(as, bs, acc <> String.upcase(a))
            Regex.match?(~r/^[a-z]/, b) -> exchange_capitalization(as, bs, acc <> String.downcase(a))
            true -> exchange_capitalization(as, bs, acc <> a)
        end
    end
    def exchange_capitalization(left, right), do: exchange_capitalization(Functions.to_list(left), Functions.to_list(right), "")
end
