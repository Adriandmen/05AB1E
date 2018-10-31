defmodule SpecialOpsTest do
    use ExUnit.Case
    import TestHelper

    test "wrap stack into array" do
        assert evaluate("1 2 3)") == ["1", "2", "3"]
    end

    test "reverse stack" do
        assert evaluate("1 2) 3r)ï") == [3, [1, 2]]
    end

    test "copy paste" do
        assert evaluate("1© 2®") == "1"
        assert evaluate("1© 2)") == ["1", "2"]
        assert evaluate("1© 2®)") == ["1", "2", "1"]
    end

    test "for loop [0, N)" do
        assert evaluate("5FN} N)") == [0, 1, 2, 3, 4, 0]
        assert evaluate("3F3FN} N})") == [0, 1, 2, 0, 0, 1, 2, 1, 0, 1, 2, 2]
    end

    test "for loop [1, N]" do
        assert evaluate("5EN})") == [1, 2, 3, 4, 5]
    end

    test "for loop [1, N)" do
        assert evaluate("5GN} N)") == [1, 2, 3, 4, 0]
        assert evaluate("3G3GN} N})") == [1, 2, 1, 1, 2, 2]
        assert evaluate("3G\"abc\"})") == ["abc", "abc"]
    end

    test "for loop [0, N]" do
        assert evaluate("5ƒN} N)") == [0, 1, 2, 3, 4, 5, 0]
        assert evaluate("2ƒ2ƒN} N})") == [0, 1, 2, 0, 0, 1, 2, 1, 0, 1, 2, 2]
        assert evaluate("3ƒ\"abc\"})") == ["abc", "abc", "abc", "abc"]
    end

    test "filter program" do
        assert evaluate("5LʒÈ") == [2, 4]
        assert evaluate("10Lʒ3%>") == [3, 6, 9]
        assert evaluate("∞ʒ3%>}10£") == [3, 6, 9, 12, 15, 18, 21, 24, 27, 30]
        assert evaluate("12345ʒÈ") == "24"
        assert evaluate("12345ïʒÈ") == "24"
    end

    test "for each program" do
        assert evaluate("5LεÈ") == [0, 1, 0, 1, 0]
        assert evaluate("∞εÈ}5£") == [0, 1, 0, 1, 0]
    end

    test "sort by program" do
        assert evaluate("5LΣÈ") == [1, 3, 5, 2, 4]
        assert evaluate("12345 123 123456789) Σg") == ["123", "12345", "123456789"]
        assert evaluate("123Sï Σε132sk") == [1, 3, 2]
    end

    test "run until no change" do
        assert evaluate("3LLLΔO") == 15
    end

    test "run until no change with intermediate results" do
        assert evaluate("5.Γ>12)ß") == [6, 7, 8, 9, 10, 11, 12]
    end

    test "break out of loop" do
        assert evaluate("10FN N3Q#})") == [0, 1, 2, 3]
        assert evaluate("10FN2Q# 10FN N3Q#} 1ï})") == [0, 1, 2, 3, 1, 0, 1, 2, 3, 1]
    end

    test "split on spaces" do
        assert evaluate("\"123 456\"#") == ["123", "456"]
        assert evaluate("\"123 456\"S#ï") == [[1, 2, 3], [4, 5, 6]]
    end

    test "map command for each" do
        assert evaluate("5L€>") == [2, 3, 4, 5, 6]
        assert evaluate("5L€D") == [1, 1, 2, 2, 3, 3, 4, 4, 5, 5]
        assert evaluate("3LL€D") == [[1], [1], [1, 2], [1, 2], [1, 2, 3], [1, 2, 3]]
        assert evaluate("3LL€€D") == [[1, 1], [1, 1, 2, 2], [1, 1, 2, 2, 3, 3]]
        assert evaluate("∞L€€D3£") == [[1, 1], [1, 1, 2, 2], [1, 1, 2, 2, 3, 3]]
    end

    test "2-arity map command for each" do
        assert evaluate("5L3Lδ+") == [[2, 3, 4], [3, 4, 5], [4, 5, 6], [5, 6, 7], [6, 7, 8]]
        assert evaluate("5L3LδN") == [[[0, 0], [1, 0], [2, 0]], [[0, 1], [1, 1], [2, 1]], [[0, 2], [1, 2], [2, 2]], [[0, 3], [1, 3], [2, 3]], [[0, 4], [1, 4], [2, 4]]]
        assert evaluate("5 3δ+") == 8
        assert evaluate("5 3Lδ+") == [6, 7, 8]
        assert evaluate("\"abc\" \"def\"δ«") == "abcdef"
        assert evaluate("3L5Lδ+") == [[2, 3, 4, 5, 6], [3, 4, 5, 6, 7], [4, 5, 6, 7, 8]]
        assert evaluate("3L5LδF>}2+") == [[4, 5, 6, 7, 8], [5, 6, 7, 8, 9], [6, 7, 8, 9, 10]]
        assert evaluate("12S34S56S)'-δý") == ["1-2", "3-4", "5-6"]
    end

    test "pairwise command" do
        assert evaluate("5Lü+") == [3, 5, 7, 9]
        assert evaluate("5LüF>") == [3, 5, 7, 9]
        assert evaluate("5LüF>") == [3, 5, 7, 9]
        assert evaluate("5Lü)") == [[1, 2], [2, 3], [3, 4], [4, 5]]
    end

    test "pairs of length n" do
        assert evaluate("5L ü2") == [[1, 2], [2, 3], [3, 4], [4, 5]]
        assert evaluate("5L ü3") == [[1, 2, 3], [2, 3, 4], [3, 4, 5]]
        assert evaluate("12345 ü3") == ["123", "234", "345"]
    end

    test "for each subprogram" do
        assert evaluate("12345vyï} y N)") == [1, 2, 3, 4, 5, "", 0]
        assert evaluate("5Lvy} y N)") == [1, 2, 3, 4, 5, "", 0]
        assert evaluate("\"ÁßçÐÈ\"vy})") == ["Á", "ß", "ç", "Ð", "È"]
    end

    test "compressed string with interpolation" do
        assert evaluate("\"test\"’Ÿ™ ÿ") == "hello test"
        assert evaluate("\"test\"“Ÿ™ ÿ") == "hello test"
        assert evaluate("\"test\"”Ÿ™ ÿ") == "Hello test"
        assert evaluate("\"test\"‘Ÿ™ ÿ") == "HELLO test"
    end

    test "infinite loop" do
        assert evaluate("[NO N5Q#") == 15
    end

    test "if/else statements" do
        assert evaluate("1i5} 3O") == 8
        assert evaluate("0i5} 3O") == 3
        assert evaluate("00001i5} 3O") == 8
        assert evaluate("00001i5ë10} 3O") == 8
        assert evaluate("4i5ë10} 3O") == 13
    end
    
    test "max of stack" do
        assert evaluate("1 2 3 2 1M") == 3
        assert evaluate("1 2 3 2 1M)ï") == [1, 2, 3, 2, 1, 3]
        assert evaluate("1 232S101S‚ 1M)ï") == [1, [[2, 3, 2], [1, 0, 1]], 1, 3]
    end

    test "counter variable" do
        assert evaluate("¾") == 0
        assert evaluate("¼¼¼¾") == 3
        assert evaluate("1½1½0½¾") == 2
    end

    test "counter loop" do
        assert evaluate("6µND2Öi¼}") == 12
        assert evaluate("6µND2Ö½") == 12
        assert evaluate("6µND2Ö") == 12
    end

    test "reset counter variable" do
        assert evaluate(".µ¾") == 0
        assert evaluate("¼¼¼¼.µ¾") == 0
        assert evaluate("¼¼¼¼.µ¼¼¾") == 2
    end

    test "quit program" do
        assert evaluate("1 2q4 5") == "2"
        assert evaluate("1 [2 q4 5") == "2"
        assert evaluate("1 [2 3 5F 2 i 45 ë 7 [ q 4 5") == "7"
    end

    test "shift stack one to the left" do
        assert evaluate("1 2 3.À)ï") == [2, 3, 1]
    end

    test "shift stack one to the right" do
        assert evaluate("1 2 3.Á)ï") == [3, 1, 2]
    end

    test "length of stack" do
        assert evaluate("1 2 3.g)ï") == [1, 2, 3, 3]
        assert evaluate("1 2 3 2 1.g)ï") == [1, 2, 3, 2, 1, 5]
    end

    test "evaluate 05AB1E code" do
        assert evaluate("\"2 3+\".V") == 5
        assert evaluate("2'ÿ\"1ÿ3\".V") == "123"
    end

    test "global array" do
        assert evaluate("2ˆ)") == []
        assert evaluate("2ˆ¯ï") == [2]
        assert evaluate("2ˆ3ˆ5ˆ¯ï") == [2, 3, 5]
        assert evaluate("2ˆ3ˆ5ˆ´¯") == []
        assert evaluate("2ˆ3ˆ5ˆ´7ˆ¯ï") == [7]
        assert evaluate("42 17 43 43)ï`ˆ)") == [42, 17, 43]
    end

    test "constants" do
        assert evaluate("₁") == 256
        assert evaluate("₂") == 26
        assert evaluate("₃") == 95
        assert evaluate("₄") == 1000
        assert evaluate("₅") == 255
        assert evaluate("₆") == 36
    end

    test "recursive list generation" do
        assert evaluate("1λ+}5£") == [1, 1, 2, 3, 5]
        assert evaluate("11Sλ+}5£") == [1, 1, 2, 3, 5]
        assert evaluate("358Sλ₂₃+}5£") == [3, 5, 8, 8, 13]
        assert evaluate("0λ₅₅Nα}10000è") == 6823
        assert evaluate("1λ1₆2₆+}5£") == [1, 1, 2, 3, 5]
    end

    test "recursive list with contains flag" do
        assert evaluate("34 1λj+") == 1
        assert evaluate("37 1λj+") == 0
    end

    test "group by function" do
        assert evaluate("5L.γ4‹") == [[1, 2, 3], [4, 5]]
        assert evaluate("12345.γ4‹") == ["123", "45"]
        assert evaluate("∞.γ4÷}3£") == [[1, 2, 3], [4, 5, 6, 7], [8, 9, 10, 11]]
    end

    test "split with function" do
        assert evaluate("5L.¡È") == [[1, 3, 5], [2, 4]]
        assert evaluate("10L.¡3%") == [[1, 4, 7, 10], [2, 5, 8], [3, 6, 9]]
        assert evaluate("∞.¡3%}0è4£") == [1, 4, 7, 10]
    end

    test "find first" do
        assert evaluate("10L.Δ4›") == 5
        assert evaluate("∞.Δ50›") == 51
    end

    test "find first index" do
        assert evaluate("\"a b c d ab cd ef\"#ÅΔg2Q") == 4
        assert evaluate("∞ÅΔg2Q") == 9
    end

    test "left reduce" do
        assert evaluate("1234S.»-") == -8
        assert evaluate("1234.»-") == -8
    end

    test "right reduce" do
        assert evaluate("1234S.«-") == -2
        assert evaluate("1234.«-") == -2
    end

    test "permute by function" do
        assert evaluate("123Sï.æ>") == [[1, 2, 3], [2, 2, 3], [1, 3, 3], [2, 3, 3], [1, 2, 4], [2, 2, 4], [1, 3, 4], [2, 3, 4]]
        assert evaluate("123.æ>}ï") == [[1, 2, 3], [2, 2, 3], [1, 3, 3], [2, 3, 3], [1, 2, 4], [2, 2, 4], [1, 3, 4], [2, 3, 4]]
    end

    test "cumulative reduce left" do
        assert evaluate("5LÅ»+") == [1, 3, 6, 10, 15]
        assert evaluate("5LÅ»-") == [1, -1, -4, -8, -13]
    end

    test "cumulative reduce right" do
        assert evaluate("5LÅ«+") == [15, 14, 12, 9, 5]
        assert evaluate("5LÅ«-") == [3, -2, 4, -1, 5]
    end

    test "map every nth element" do
        assert evaluate("6L2Å€2+") == [3, 2, 5, 4, 7, 6]
        assert evaluate("10L21SÅ€0}ï") == [0, 0, 3, 0, 0, 6, 0, 0, 9, 0]
        assert evaluate("10L320SÅ€0}ï") == [0, 2, 0, 4, 5, 6, 7, 8, 9, 10]
    end

    test "split on function" do
        assert evaluate("5L.¬+5Q") == [[1, 2], [3, 4, 5]]
        assert evaluate("10L.¬3Ö") == [[1, 2], [3, 4, 5], [6, 7, 8], [9, 10]]
        assert evaluate("\"codegolfballoon\".¬@}J") == ["co", "dego", "l", "f", "b", "al", "lo", "o", "n"]
    end
end
