defmodule Reading.Reader do

    alias Reading.CodePage
    alias Reading.Dictionary
    alias Commands.IntCommands

    def remaining, do: "(?<remaining>.*)"
    
    defp regexify(map) when is_map(map) do
        map |> Map.to_list |> Enum.map(fn {open, close} -> ~r/^((?<delimiter>#{Regex.escape(open)})(?<string>.*?)(#{Regex.escape(close)}|\z)#{remaining()})/s end)
    end
    defp regexify(list) when is_list(list), do: "(" <> Enum.join(Enum.map(list, fn x -> Regex.escape(x) end), "|") <> ")"
    
    def nullary_ops, do: regexify ["∞", "т", "₁", "₂", "₃", "₄", "A", "®", "N", "y", ".Z", "¶", "õ", "X", "Y", 
                                   "¼", "¾", "q", "ð", ".À", ".Á", ".g", "¯", "´", "T", ".µ", ".¼"]

    def unary_ops, do: regexify ["γ", "η", "θ", "н", "Θ", "Ω", "≠", "∊", "∞", "!", "(", ",", ";", "<", ">", 
                                 "?", "C", "D", "H", "J", "L", "R", "S", "U", "V", "_", "`", "a", "b", "Å\\",
                                 "d", "f", "g", "h", "l", "n", "o", "p", "t", "u", "x", "z", "{", "ˆ", "Œ", 
                                 "Ć", "ƶ", "Ā", "–", "—", "˜", "™", ".š", "œ", "ć", "¥", "¦", "§", "¨", ".ª", 
                                 "°", "±", "·", "¸", "À", "Á", "Â", "Ä", "Æ", "Ç", "È", "É", "Ë", "Ì", "Í", 
                                 "Ñ", "Ò", "Ó", "Ô", "Õ", "Ø", "Ù", "Ý", "Þ", "á", "æ", "ç", "é", "ê", 
                                 "í", "î", "ï", "ò", "ó", "û", "þ", ".€", ".ä", ".A", ".b", ".B", ".c", ".C", 
                                 ".e", ".E", ".j", ".J", ".l", ".M", ".m", ".N", ".p", ".R", ".r", ".s", ".u", 
                                 ".w", ".W", ".²", ".ï", ".ˆ", ".^", "Å¼", "Å½", "Å¾", ".∞", ".¥", ".ǝ", ".∊", 
                                 ".Ø", "\\", "ā", "¤", "¥", "¬", "O", "P", "Z", "W", "»", "½", "=", "Ð", "ß", 
                                 "à", "º", ".ā", ".º", ".œ", ".Ó", ".±", "Å/", "Åu", "Ål", "Å!", "Å0", "Å1",
                                 "Å2", "Å3", "Å4", "Å5", "Å6", "Å7", "Å8", "Å9", "ÅA", "ÅF", "ÅG", "ÅP", "ÅT",
                                 "Åf", "Åg", "Åp", "Å²", "ÅÈ", "ÅÉ", "Å|", ".X", ".v", "Åœ", ".Þ", "ÅN", "ÅM",
                                 "Ån", "Åγ", "Å=", "Å≠", "Åm", "Ås"]

    def binary_ops, do: regexify ["α", "β", "в", "и", "м", "∍", "%", "&", "*", "+", "-", "/", "B", "K",
                                  "Q", "^", "c", "e", "k", "m", "s", "~", "‚", "†", "‰", "‹", "›", "¡", "¢",
                                  "£", "«", "Ã", "Ê", "Ï", "Ö", "×", "Û", "Ü", "Ý", "â", "ä", "å", "è", "@",
                                  "ì", "ô", "ö", "÷", "ù", "ú", "ý", ".å", ".D", ".h", ".H", ".S", ".ø", ".o",
                                  ".£", ".n", ".x", ".L", ".ý", ".Q", ".ò", "j", ".$", ".Œ", "._", ".i", ".k",
                                  "ÅL", "ÅU", "Åβ", "Åв", ".м", ".ι", "ª", "š", ".¢", "ÅΓ", "Å?", "Å¿", ".I",
                                  ".Ï", "Å¡", ".K", "Ú"]
    
    def ternary_ops, do: regexify ["ǝ", "Š", "‡", ":", "Λ", ".Λ", ".:", ".;"]

    def special_ops, do: regexify [")", "r", "©", "¹", "²", "³", "I", "$", "Î", "#", "Ÿ", "ø", "ζ", "ι", "¿", 
                                   "ã", "M", ".¿", ".V", "₅", "₆", "|", ".|", ".Æ"]
    
    def subprogram_ops, do: regexify ["ʒ", "ε", "Δ", "Σ", "F", "G", "v", "ƒ", "µ", "[", "i", "λ", ".γ", ".¡", ".Δ",
                                      "ÅΔ", "E", ".æ", ".Γ", "Å»", "Å«", "Å€", ".¬", "ÅÏ"]
    
    def subcommand_ops, do: regexify ["δ", "€", "ü", ".«", ".»"]
    
    def closing_brackets, do: regexify ["}", "]"]
    
    def string_delimiters, do: regexify ["\"", "•", "‘", "’", "“", "”"]

    def two_char_strings, do: regexify %{".•" => "•"}

    def char_indicators, do: regexify ["'", "„", "…", "Ƶ", "Ž"]
    
    def compressed_chars, do: regexify ["€", "‚", "ƒ", "„", "…", "†", "‡", "ˆ", "‰", "Š", "‹", "Œ", "Ž", "í", "î", "•", "–", "—", 
                                        "ï", "™", "š", "›", "œ", "ž", "Ÿ", "¡", "¢", "£", "¤", "¥", "¦", "§", "¨", "©", "ª", "«", 
                                        "¬", "®", "¯", "°", "±", "²", "³", "´", "µ", "¶", "·", "¸", "¹", "º", "»", "¼", "½", "¾", 
                                        "¿", "À", "Á", "Â", "Ã", "Ä", "Å", "Æ", "Ç", "È", "É", "Ê", "Ë", "Ì", "Í", "Î", "Ï", "Ð", 
                                        "Ñ", "Ò", "Ó", "Ô", "Õ", "Ö", "×", "Ø", "Ù", "Ú", "Û", "Ü", "Ý", "Þ", "ß", "à", "á", "â", 
                                        "ã", "ä", "å", "æ", "ç", "è", "é", "ê", "ë", "ì"]
    
    def any_osabie_char, do: regexify String.graphemes(CodePage.code_page)
    
    def read_file(file_path, encoding) do
        case encoding do
            :utf_8 -> 
                String.graphemes(File.read!(file_path))
            :osabie -> 
                {_, file} = :file.open(file_path, [:read, :binary])
                IO.binread(file, :all) |> :binary.bin_to_list |> Enum.map(fn x -> CodePage.osabie_to_utf8(x) end)
        end
    end

    @doc """
    Reads a number of characters of compressed words from the given string.

    ## Parameters

     - string:  The string from which the characters/compressed words will be read.
     - count:   The number of characters that will be read from the string.

    ## Returns

    Returns a tuple {:string, parsed, remaining}, with the following variables:

     - parsed:      The completely parsed word where possible compressed words are decompressed.
     - remaining:   The leftover string of code/commands that still needs to be parsed.

    """
    def read_chars(string, count), do: read_chars(string, count, "")
    defp read_chars(string, 0, parsed) do
        {:string, Dictionary.decompress(parsed, :normal), string}
    end
    defp read_chars(string, count, parsed) do
        matches = Regex.named_captures(~r/((?<compressed>#{compressed_chars()}{2})|(?<char>(#{any_osabie_char()}|.)))#{remaining()}/s, string)
        case matches["compressed"] do
            "" -> read_chars(matches["remaining"], count - 1, parsed <> matches["char"])
            x -> read_chars(matches["remaining"], count - 1, parsed <> x)
        end
    end

    def read_step(raw_code) do

        cond do
            # Numbers
            Regex.match?(~r/^(\d*\.\d+|\d+)(.*)/s, raw_code) ->
                matches = Regex.named_captures(~r/^(?<number>(\d*\.\d+|\d+))#{remaining()}/s, raw_code)
                {:number, matches["number"], matches["remaining"]}

            # Strings and equivalent values
            Regex.match?(~r/^#{string_delimiters()}(.*?)(\1|\z)/s, raw_code) ->
                matches = Regex.named_captures(~r/^(?<delimiter>#{string_delimiters()})(?<string>.*?)(\1|\z)#{remaining()}/s, raw_code)
                case matches["delimiter"] do
                    # Compressed numbers
                    "•" -> {:number, IntCommands.string_from_base(matches["string"], 255), matches["remaining"]}

                    # Strings
                    "\"" -> {:string, matches["string"], matches["remaining"]}

                    # Compressed strings
                    "‘" -> {:string, Dictionary.decompress(matches["string"], :upper), matches["remaining"]}
                    "’" -> {:string, Dictionary.decompress(matches["string"], :no_space), matches["remaining"]}
                    "“" -> {:string, Dictionary.decompress(matches["string"], :normal), matches["remaining"]}
                    "”" -> {:string, Dictionary.decompress(matches["string"], :title), matches["remaining"]}
                end

            Enum.any?(two_char_strings(), fn regex -> Regex.match?(regex, raw_code) end) ->
                regex = Enum.find(two_char_strings(), fn regex -> Regex.match?(regex, raw_code) end)
                matches = Regex.named_captures(regex, raw_code)
                case matches["delimiter"] do
                    ".•" -> {:string, IntCommands.to_base_arbitrary(IntCommands.string_from_base(matches["string"], 255), 27) 
                                        |> Enum.map(fn x -> if x > 0 do <<x + 96>> else " " end end) |> Enum.join(""), matches["remaining"]}
                end
            
            # If/else statements
            Regex.match?(~r/^(i|ë)/, raw_code) ->
                matches = Regex.named_captures(~r/^(?<if_else>(i|ë))#{remaining()}/s, raw_code)
                case matches["if_else"] do
                    "i" -> {:if_statement, "i", matches["remaining"]}
                    "ë" -> {:else_statement, "ë", matches["remaining"]}
                end
            
            # Chars or normal compressed words/numbers
            Regex.match?(~r/^#{char_indicators()}/s, raw_code) ->
                matches = Regex.named_captures(~r/(?<indicator>#{char_indicators()})#{remaining()}/s, raw_code)
                case matches["indicator"] do
                    "'" -> read_chars(matches["remaining"], 1)
                    "„" -> read_chars(matches["remaining"], 2)
                    "…" -> read_chars(matches["remaining"], 3)
                    "Ƶ" -> 
                        new_matches = Regex.named_captures(~r/(?<char>#{any_osabie_char()})#{remaining()}/s, matches["remaining"])
                        {:number, IntCommands.string_from_base(new_matches["char"], 255) + 101, new_matches["remaining"]}
                    "Ž" ->
                        new_matches = Regex.named_captures(~r/(?<chars>#{any_osabie_char()}{2})#{remaining()}/s, matches["remaining"])
                        {:number, IntCommands.string_from_base(new_matches["chars"], 255), new_matches["remaining"]}
                end

            # Nullary functions
            Regex.match?(~r/^#{nullary_ops()}/s, raw_code) ->
                matches = Regex.named_captures(~r/^(?<nullary_op>#{nullary_ops()})#{remaining()}/s, raw_code)
                {:nullary_op, matches["nullary_op"], matches["remaining"]}

            # Constants as nullary functions
            Regex.match?(~r/^ž#{any_osabie_char()}/s, raw_code) ->
                matches = Regex.named_captures(~r/^(?<nullary_op>ž#{any_osabie_char()})#{remaining()}/s, raw_code)
                {:nullary_op, matches["nullary_op"], matches["remaining"]}
        
            # Unary functions
            Regex.match?(~r/^#{unary_ops()}/s, raw_code) ->
                matches = Regex.named_captures(~r/^(?<unary_op>#{unary_ops()})#{remaining()}/s, raw_code)
                {:unary_op, matches["unary_op"], matches["remaining"]}
            
            # Binary functions
            Regex.match?(~r/^#{binary_ops()}/s, raw_code) ->
                matches = Regex.named_captures(~r/^(?<binary_op>#{binary_ops()})#{remaining()}/s, raw_code)
                {:binary_op, matches["binary_op"], matches["remaining"]}
            
            # Ternary functions
            Regex.match?(~r/^#{ternary_ops()}/s, raw_code) ->
                matches = Regex.named_captures(~r/^(?<ternary_op>#{ternary_ops()})#{remaining()}/s, raw_code)
                {:ternary_op, matches["ternary_op"], matches["remaining"]}
            
            # Special functions
            Regex.match?(~r/^#{special_ops()}/s, raw_code) ->
                matches = Regex.named_captures(~r/^(?<special_op>#{special_ops()})#{remaining()}/s, raw_code)
                {:special_op, matches["special_op"], matches["remaining"]}
            
            # Subprograms
            Regex.match?(~r/^#{subprogram_ops()}/s, raw_code) ->
                matches = Regex.named_captures(~r/^(?<subprogram>#{subprogram_ops()})#{remaining()}/s, raw_code)
                {:subprogram, matches["subprogram"], matches["remaining"]}
            
            # Subcommands
            Regex.match?(~r/^#{subcommand_ops()}/s, raw_code) ->
                matches = Regex.named_captures(~r/^(?<subcommand>#{subcommand_ops()})#{remaining()}/s, raw_code)
                {:subcommand, matches["subcommand"], matches["remaining"]}
            
            # Closing brackets
            Regex.match?(~r/^#{closing_brackets()}/s, raw_code) ->
                matches = Regex.named_captures(~r/^(?<bracket>#{closing_brackets()})#{remaining()}/s, raw_code)
                case matches["bracket"] do
                    "}" -> {:end, "}", matches["remaining"]}
                    "]" -> {:end_all, "]", matches["remaining"]}
                end
            
            # No-ops
            Regex.match?(~r/^(.).*/s, raw_code) ->
                matches = Regex.named_captures(~r/^(?<no_op>.)#{remaining()}/s, raw_code)
                {:no_op, matches["no_op"], matches["remaining"]}
            
            # EOF
            true ->
                {:eof, nil, nil}
        end
    end

    def read(raw_code) do
        case read_step(raw_code) do
            {:eof, val, _} -> [[:eof, val]]
            {type, val, remaining} -> [[type, val]] ++ read(remaining)
        end
    end
end