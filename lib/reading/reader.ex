defmodule Reading.Reader do

    def nullary_ops, do: "(" <> Enum.join(Enum.map(
                        ["∞", "т", "₁", "₂", "₃", "₄", "A", "®", "N"], fn x -> Regex.escape(x) end), "|") <> ")"

    def unary_ops, do: "(" <> Enum.join(Enum.map(
                        ["γ", "η", "θ", "н", "Θ", "Ω", "≠", "∊", "∞", "#", "!", "(", ",", ";", "<", ">", 
                        "?", "@", "C", "D", "H", "J", "L", "R", "S", "U", "V", "_", "`", "a", "b", 
                        "d", "f", "g", "h", "j", "l", "n", "o", "p", "t", "u", "x", "z", "{", "ˆ", 
                        "Œ", "Ć", "ƶ", "Ā", "–", "—", "˜", "™", "š", "œ", "ć", "¥", "¦", "§", "¨", 
                        "ª", "°", "±", "·", "¸", "À", "Á", "Â", "Ä", "Æ", "Ç", "È", "É", "Ë", "Ì", 
                        "Í", "Ñ", "Ò", "Ó", "Ô", "Õ", "Ø", "Ù", "Ú", "Ý", "Þ", "á", "æ", "ç", "é", 
                        "ê", "í", "î", "ï", "ò", "ó", "û", "þ", ".€", ".ä", ".A", ".b", ".B", ".c", 
                        ".C", ".e", ".E", ".j", ".J", ".l", ".M", ".m", ".N", ".p", ".R", ".r", ".s", 
                        ".u", ".V", ".w", ".W", ".²", ".ï", ".ˆ", ".^", ".¼", ".½", ".¾", ".∞", ".¥", 
                        ".ǝ", ".∊", ".Ø", "\\", "ā", "¤", "¥", "¬", "O", "P"], fn x -> Regex.escape(x) end), "|") <> ")"

    # TODO: Special ops like Ÿ (multiple arities)?

    def binary_ops, do: "(" <> Enum.join(Enum.map(
                        ["α", "β", "δ", "ζ", "в", "и", "м", "∍", "%", "&", "*", "+", "-", "/", "B", "K",
                         "Q", "^", "c", "e", "k", "m", "s", "~", "‚", "†", "‰", "‹", "›", "Ÿ", "¡", "¢",
                         "£", "«", "¿", "Ã", "Ê", "Ï", "Ö", "×", "Û", "Ü", "Ý", "â", "ã", "ä", "å", "è",
                         "ì", "ô", "ö", "÷", "ø", "ù", "ú", "ý", ".å", ".D", ".h", ".H"], fn x -> Regex.escape(x) end), "|") <> ")"
    
    def ternary_ops, do: "(" <> Enum.join(Enum.map(
                        ["ǝ"], fn x -> Regex.escape(x) end), "|") <> ")"
                        

    def special_ops, do: "(" <> Enum.join(Enum.map(
                        [")", "r", "©", "¹", "²", "³", "I", "$", "Î"], fn x -> Regex.escape(x) end), "|") <> ")"
    
    def subprogram_ops, do: "(" <> Enum.join(Enum.map(
                        ["ʒ", "ε", "Δ", "Σ", "F", "G", "v", "ƒ"], fn x -> Regex.escape(x) end), "|") <> ")"
    
    def closing_brackets, do: "(" <> Enum.join(Enum.map(
                        ["}", "]"], fn x -> Regex.escape(x) end), "|") <> ")"


    alias Reading.CodePage
    
    def read_file(file_path, encoding) do

        case encoding do
            :utf_8 -> 
                String.codepoints(File.read!(file_path))
            :osabie -> 
                {status, file} = :file.open(file_path, [:read, :binary])
                Stream.map(IO.binread(file, :all), fn x -> CodePage.osabie_to_utf8(x) end)
        end
    end

    def read_step(raw_code) do

        cond do
            # Numbers
            Regex.match?(~r/^\d+/, raw_code) ->
                matches = Regex.named_captures(~r/^(?<number>\d+)(?<remaining>.*)/, raw_code)
                {:number, matches["number"], matches["remaining"]}

            # Strings
            Regex.match?(~r/^"(.*?)("|$)/, raw_code) ->
                matches = Regex.named_captures(~r/^"(?<string>.*?)("|$)(?<remaining>.*)/, raw_code)
                {:string, matches["string"], matches["remaining"]}

            # Nullary functions
            Regex.match?(~r/^#{nullary_ops()}/, raw_code) ->
                matches = Regex.named_captures(~r/^(?<nullary_op>#{nullary_ops()})(?<remaining>.*)/, raw_code)
                {:nullary_op, matches["nullary_op"], matches["remaining"]}

            # Constants as nullary functions
            Regex.match?(~r/^ž./, raw_code) ->
                matches = Regex.named_captures(~r/^(?<nullary_op>ž.)(?<remaining>.*)/, raw_code)
                {:nullary_op, matches["nullary_op"], matches["remaining"]}
        
            # Unary functions
            Regex.match?(~r/^#{unary_ops()}/, raw_code) ->
                matches = Regex.named_captures(~r/^(?<unary_op>#{unary_ops()})(?<remaining>.*)/, raw_code)
                {:unary_op, matches["unary_op"], matches["remaining"]}
            
            # Binary functions
            Regex.match?(~r/^#{binary_ops()}/, raw_code) ->
                matches = Regex.named_captures(~r/^(?<binary_op>#{binary_ops()})(?<remaining>.*)/, raw_code)
                {:binary_op, matches["binary_op"], matches["remaining"]}
            
            # Ternary functions
            Regex.match?(~r/^#{ternary_ops()}/, raw_code) ->
                matches = Regex.named_captures(~r/^(?<ternary_op>#{ternary_ops()})(?<remaining>.*)/, raw_code)
                {:ternary_op, matches["ternary_op"], matches["remaining"]}
            
            # Special functions
            Regex.match?(~r/^#{special_ops()}/, raw_code) ->
                matches = Regex.named_captures(~r/^(?<special_op>#{special_ops()})(?<remaining>.*)/, raw_code)
                {:special_op, matches["special_op"], matches["remaining"]}
            
            # Subprograms
            Regex.match?(~r/^#{subprogram_ops()}/, raw_code) ->
                matches = Regex.named_captures(~r/^(?<subprogram>#{subprogram_ops()})(?<remaining>.*)/, raw_code)
                {:subprogram, matches["subprogram"], matches["remaining"]}
            
            # Closing brackets
            Regex.match?(~r/^#{closing_brackets()}/, raw_code) ->
                matches = Regex.named_captures(~r/^(?<bracket>#{closing_brackets()})(?<remaining>.*)/, raw_code)
                case matches["bracket"] do
                    "}" -> {:end, "}", matches["remaining"]}
                    "]" -> {:end_all, "]", matches["remaining"]}
                end
            
            # No-ops
            Regex.match?(~r/^(.).*/, raw_code) ->
                matches = Regex.named_captures(~r/^(?<no_op>.)(?<remaining>.*)/, raw_code)
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