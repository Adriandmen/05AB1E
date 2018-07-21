defmodule Reading.Dictionary do

    def compressed_chars, do: ["€", "‚", "ƒ", "„", "…", "†", "‡", "ˆ", "‰", "Š", "‹", "Œ", "Ž", "í", "î", "•", "–", "—", 
                               "ï", "™", "š", "›", "œ", "ž", "Ÿ", "¡", "¢", "£", "¤", "¥", "¦", "§", "¨", "©", "ª", "«", 
                               "¬", "®", "¯", "°", "±", "²", "³", "´", "µ", "¶", "·", "¸", "¹", "º", "»", "¼", "½", "¾", 
                               "¿", "À", "Á", "Â", "Ã", "Ä", "Å", "Æ", "Ç", "È", "É", "Ê", "Ë", "Ì", "Í", "Î", "Ï", "Ð", 
                               "Ñ", "Ò", "Ó", "Ô", "Õ", "Ö", "×", "Ø", "Ù", "Ú", "Û", "Ü", "Ý", "Þ", "ß", "à", "á", "â", 
                               "ã", "ä", "å", "æ", "ç", "è", "é", "ê", "ë", "ì"]
    
    defp dictionary do
        case File.read("lib/reading/dictionary/words") do
            {:ok, body} -> String.split(body, "\n") |> Enum.map(&String.trim/1)
        end
    end
    
    # --------------------------------
    # Uncompressing dictionary strings
    # --------------------------------
    def uncompress(compressed_string, mode) when is_binary(compressed_string), do: uncompress(String.graphemes(compressed_string), mode, "")
    defp uncompress([first, second | remaining], mode, uncompressed_string) do
        if first in compressed_chars() and second in compressed_chars() do

            # Find the index of the compressed string and retrieve the dictionary word.
            first_index = compressed_chars() |> Enum.find_index(fn x -> x == first end)
            second_index = compressed_chars() |> Enum.find_index(fn x -> x == second end)
            index = 100 * first_index + second_index
            word = Enum.at(dictionary(), index - 1)
            
            # Adjust to the given mode.
            word = case mode do
                :upper -> (if uncompressed_string == "" do "" else " " end) <> String.upcase(word)
                :no_space -> word
                :normal -> (if uncompressed_string == "" do "" else " " end) <> word
                :title -> (if uncompressed_string == "" do "" else " " end) <> String.capitalize(word)
            end

            uncompress(remaining, mode, uncompressed_string <> word)
        else
            uncompress([second | remaining], mode, uncompressed_string <> first)
        end
    end

    defp uncompress([char | remaining], mode, uncompressed_string), do: uncompress(remaining, mode, uncompressed_string <> char)
    defp uncompress([], _, uncompressed_string), do: uncompressed_string
end