defmodule Reading.CodePage do
    def code_page, do: String.codepoints("ǝʒαβγδεζηθ\nвимнтΓΔΘιΣΩ≠∊∍∞₁₂₃₄₅₆ !\"#$%&'()*+,-./0123456789" <>
                       ":;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrst" <>
                       "uvwxyz{|}~Ƶ€Λ‚ƒ„…†‡ˆ‰Š‹ŒĆŽƶĀ‘’“”•–—˜™š›œćžŸā¡¢£¤¥¦§¨©ª«¬λ®¯°" <> 
                       "±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëì" <>
                       "íîïðñòóôõö÷øùúûüýþÿ")

    def utf8_to_osabie(code_point) do
        case Enum.at(code_page(), code_point) do
            nil -> IO.puts :stderr, "Unrecognized byte value: #{code_point}"
            val -> val
        end
    end

    def osabie_to_utf8(code_point) do
        cond do
            code_point >= 0 && code_point < 255 ->
                Enum.at(code_page(), code_point)
            true -> 
                IO.puts :stderr, "Invalid osabie byte found: #{code_point}"
                nil
        end
    end
end