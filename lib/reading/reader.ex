defmodule Reading.Reader do

    alias Reading.CodePage
    alias Reading.Dictionary
    alias Commands.IntCommands
    
    defp regexify(list) do
        "(" <> Enum.join(Enum.map(list, fn x -> Regex.escape(x) end), "|") <> ")"
    end
    
    def nullary_ops, do: regexify ["∞", "т", "₁", "₂", "₃", "₄", "A", "®", "N", "y", "w", "¶", "õ"]

    def unary_ops, do: regexify ["γ", "η", "θ", "н", "Θ", "Ω", "≠", "∊", "∞", "!", "(", ",", ";", "<", ">", 
                                 "?", "@", "C", "D", "H", "J", "L", "R", "S", "U", "V", "_", "`", "a", "b", 
                                 "d", "f", "g", "h", "j", "l", "n", "o", "p", "t", "u", "x", "z", "{", "ˆ", 
                                 "Œ", "Ć", "ƶ", "Ā", "–", "—", "˜", "™", "š", "œ", "ć", "¥", "¦", "§", "¨", 
                                 "ª", "°", "±", "·", "¸", "À", "Á", "Â", "Ä", "Æ", "Ç", "È", "É", "Ë", "Ì", 
                                 "Í", "Ñ", "Ò", "Ó", "Ô", "Õ", "Ø", "Ù", "Ú", "Ý", "Þ", "á", "æ", "ç", "é", 
                                 "ê", "í", "î", "ï", "ò", "ó", "û", "þ", ".€", ".ä", ".A", ".b", ".B", ".c", 
                                 ".C", ".e", ".E", ".j", ".J", ".l", ".M", ".m", ".N", ".p", ".R", ".r", ".s", 
                                 ".u", ".V", ".w", ".W", ".²", ".ï", ".ˆ", ".^", ".¼", ".½", ".¾", ".∞", ".¥", 
                                 ".ǝ", ".∊", ".Ø", "\\", "ā", "¤", "¥", "¬", "O", "P"]

    def binary_ops, do: regexify ["α", "β", "в", "и", "м", "∍", "%", "&", "*", "+", "-", "/", "B", "K",
                                  "Q", "^", "c", "e", "k", "m", "s", "~", "‚", "†", "‰", "‹", "›", "¡", "¢",
                                  "£", "«", "¿", "Ã", "Ê", "Ï", "Ö", "×", "Û", "Ü", "Ý", "â", "ã", "ä", "å", "è",
                                  "ì", "ô", "ö", "÷", "ù", "ú", "ý", ".å", ".D", ".h", ".H"]
    
    def ternary_ops, do: regexify ["ǝ", "Š"]

    def special_ops, do: regexify [")", "r", "©", "¹", "²", "³", "I", "$", "Î", "#", "Ÿ", "ø", "ζ"]
    
    def subprogram_ops, do: regexify ["ʒ", "ε", "Δ", "Σ", "F", "G", "v", "ƒ", "µ"]
    
    def subcommand_ops, do: regexify ["δ", "€", "ü", ".«", ".»"]
    
    def closing_brackets, do: regexify ["}", "]"]
    
    def string_delimiters, do: regexify ["\"", "•", "‘", "’", "“", "”"]

    def char_indicators, do: regexify ["'", "„", "…"]
    
    def compressed_chars, do: regexify ["€", "‚", "ƒ", "„", "…", "†", "‡", "ˆ", "‰", "Š", "‹", "Œ", "Ž", "í", "î", "•", "–", "—", 
                                        "ï", "™", "š", "›", "œ", "ž", "Ÿ", "¡", "¢", "£", "¤", "¥", "¦", "§", "¨", "©", "ª", "«", 
                                        "¬", "®", "¯", "°", "±", "²", "³", "´", "µ", "¶", "·", "¸", "¹", "º", "»", "¼", "½", "¾", 
                                        "¿", "À", "Á", "Â", "Ã", "Ä", "Å", "Æ", "Ç", "È", "É", "Ê", "Ë", "Ì", "Í", "Î", "Ï", "Ð", 
                                        "Ñ", "Ò", "Ó", "Ô", "Õ", "Ö", "×", "Ø", "Ù", "Ú", "Û", "Ü", "Ý", "Þ", "ß", "à", "á", "â", 
                                        "ã", "ä", "å", "æ", "ç", "è", "é", "ê", "ë", "ì"]
    
    def any_osabie_char, do: regexify String.graphemes(CodePage.code_page)

    def remaining, do: "(?<remaining>.*)"
    
    def read_file(file_path, encoding) do

        case encoding do
            :utf_8 -> 
                String.codepoints(File.read!(file_path))
            :osabie -> 
                {_, file} = :file.open(file_path, [:read, :binary])
                Stream.map(IO.binread(file, :all), fn x -> CodePage.osabie_to_utf8(x) end)
        end
    end

    def read_chars(string, count), do: read_chars(string, count, "")
    def read_chars(string, 0, parsed) do
        {:string, Dictionary.decompress(parsed, :normal), string}
    end
    def read_chars(string, count, parsed) do
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
            Regex.match?(~r/^#{string_delimiters()}((.|\n)*?)(\1|\z)/, raw_code) ->
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
            
            # Chars or normal compressed words
            Regex.match?(~r/^#{char_indicators()}/s, raw_code) ->
                matches = Regex.named_captures(~r/(?<indicator>#{char_indicators()})#{remaining()}/s, raw_code)
                case matches["indicator"] do
                    "'" -> read_chars(matches["remaining"], 1)
                    "„" -> read_chars(matches["remaining"], 2)
                    "…" -> read_chars(matches["remaining"], 3)
                end

            # Nullary functions
            Regex.match?(~r/^#{nullary_ops()}/s, raw_code) ->
                matches = Regex.named_captures(~r/^(?<nullary_op>#{nullary_ops()})#{remaining()}/s, raw_code)
                {:nullary_op, matches["nullary_op"], matches["remaining"]}

            # Constants as nullary functions
            Regex.match?(~r/^ž./s, raw_code) ->
                matches = Regex.named_captures(~r/^(?<nullary_op>ž.)#{remaining()}/s, raw_code)
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