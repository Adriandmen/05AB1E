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
    end

    test "for each program" do
        assert evaluate("5LεÈ") == [0, 1, 0, 1, 0]
        assert evaluate("∞εÈ}5£") == [0, 1, 0, 1, 0]
    end

    test "sort by program" do
        assert evaluate("5LΣÈ") == [1, 3, 5, 2, 4]
        assert evaluate("12345 123 123456789) Σg") == ["123", "12345", "123456789"]
    end

    test "run until no change" do
        assert evaluate("3LLLΔO") == 15
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
        assert evaluate("3L5Lδ+") == [[2, 3, 4, 5, 6], [3, 4, 5, 6, 7], [4, 5, 6, 7, 8]]
        assert evaluate("3L5LδF>}2+") == [[4, 5, 6, 7, 8], [5, 6, 7, 8, 9], [6, 7, 8, 9, 10]]
    end

    test "pairwise command" do
        assert evaluate("5Lü+") == [3, 5, 7, 9]
        assert evaluate("5LüF>") == [3, 5, 7, 9]
        assert evaluate("5LüF>") == [3, 5, 7, 9]
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
        assert evaluate("6µN2Öi¼}") == 10
        assert evaluate("6µN2Ö½") == 10
        assert evaluate("6µN2Ö") == 10
    end

    test "quit program" do
        assert evaluate("1 2q4 5") == "2"
        assert evaluate("1 [2 q4 5") == "2"
        assert evaluate("1 [2 3 5F 2 i 45 ë 7 [ q 4 5") == "7"
    end
end