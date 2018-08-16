defmodule Reading.CodePage do

    def code_page, do: "ǝʒαβγδεζηθ\nвимнтΓΔΘιΣΩ≠∊∍∞₁₂₃₄₅₆ !\"#$%&'()*+,-./0123456789" <>
                       ":;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrst" <>
                       "uvwxyz{|}~Ƶ€Λ‚ƒ„…†‡ˆ‰Š‹ŒĆŽƶĀ‘’“”•–—˜™š›œćžŸā¡¢£¤¥¦§¨©ª«¬λ®¯°" <> 
                       "±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëì" <>
                       "íîïðñòóôõö÷øùúûüýþÿ"

    def code_points, do: String.graphemes(code_page())

    def utf8_to_osabie(code_point) do
        case Enum.find_index(code_points(), fn x -> x == code_point end) do
            nil -> IO.puts :stderr, "Unrecognized byte value: #{code_point}"
            val -> val
        end
    end

    def osabie_to_utf8(code_point) do
        cond do
            code_point >= 0 && code_point < 255 ->
                Enum.at(code_points(), code_point)
            true -> 
                IO.puts :stderr, "Invalid osabie byte found: #{code_point}"
                nil
        end
    end
end