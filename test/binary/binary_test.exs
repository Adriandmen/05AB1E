defmodule BinaryTest do
    use ExUnit.Case
    import TestHelper

    test "element at" do
        assert evaluate("123§ 0è") == "1"
        assert evaluate("123ï 0è") == "1"
        assert evaluate("5L 0è") == 1
        
        assert evaluate("123§ 5è") == "3"
        assert evaluate("123ï 5è") == "3"
        assert evaluate("5L 6è") == 2

        assert evaluate("∞L 6è") == [1, 2, 3, 4, 5, 6, 7]
    end

    test "addition" do
        assert evaluate("4 5+") == 9
        assert evaluate("4ï 5ï+") == 9
        assert evaluate("4§ 5ï+") == 9
        assert evaluate("4ï 5§+") == 9
        assert evaluate("1.2 1.2+") == 2.4
        assert evaluate("4L 5+") == [6, 7, 8, 9]
        assert evaluate("4 5L+") == [5, 6, 7, 8, 9]
        assert evaluate("5L 5L+") == [2, 4, 6, 8, 10]
        assert evaluate("5L 3L+") == [2, 4, 6]
        assert evaluate("∞ 3L+") == [2, 4, 6]
        assert evaluate("3LL 3+") == [[4], [4, 5], [4, 5, 6]]
    end

    test "convert to base" do
        assert evaluate("55 2B") == "110111"
        assert evaluate("5545646 47B") == "16JMM"
    end

    test "string subtraction" do
        assert evaluate("123 2м") == "13"
        assert evaluate("123 32м") == "1"
        assert evaluate("3L 2м") == ["1", "", "3"]
        assert evaluate("12345 2L>м") == "145"
        assert evaluate("5L 2L>м") == ["1", "", "", "4", "5"]
    end

    test "convert from base arbitrary" do
        assert evaluate("1 1 0 1 1 1) 2 β") == 55
        assert evaluate("1 6 19 22 22) 47 β") == 5545646
        assert evaluate("1 6 6 7 2 1 3 3 6) 8( β") == 5545646
    end

    test "bitwise xor" do
        assert evaluate("7 8^") == 15
        assert evaluate("7 8(^") == -1
        assert evaluate("8 8()7^") == [15, -1]
    end

    test "bitwise and" do
        assert evaluate("756 822 &") == 564
        assert evaluate("7( 822 &") == 816
        assert evaluate("7( 756)822 &") == [816, 564]
    end

    test "divmod" do
        assert evaluate("8 4‰") == [2, 0]
        assert evaluate("45 7‰") == [6, 3]
        assert evaluate("45 75S‰") == [[6, 3], [9, 0]]
        assert evaluate("45S 75S‰") == [[0, 4], [1, 0]]
    end

    test "smaller than" do
        assert evaluate("4 8‹") == 1
        assert evaluate("8 8‹") == 0
        assert evaluate("9 8‹") == 0
        assert evaluate("4 8 9) 8‹") == [1, 0, 0]
    end

    test "greater than" do
        assert evaluate("4 8›") == 0
        assert evaluate("8 8›") == 0
        assert evaluate("9 8›") == 1
        assert evaluate("4 8 9) 8›") == [0, 0, 1]
    end

    test "swap top two" do
        assert evaluate("8 4s)") == ["4", "8"]
        assert evaluate("1 2 3 4s)") == ["1", "2", "4", "3"]
    end

    test "power function" do
        assert evaluate("2 5m") == 32
        assert evaluate("4 2(m") == 0.0625
        assert evaluate("4( 2m") == 16
        assert evaluate("1 2 3)2m") == [1, 4, 9]
    end

    test "take first" do
        assert evaluate("12345 3£") == "123"
        assert evaluate("5L 3£") == [1, 2, 3]
        assert evaluate("∞z 2£") == [1, 0.5]
        assert evaluate("123456 23S£") == ["12", "345"]
        assert evaluate("\"\" 23S£") == ["", ""]
        assert evaluate("123456 123S£") == ["1", "23", "456"]
        assert evaluate("123456 1234S£") == ["1", "23", "456", ""]
        assert evaluate("123456 1224S£") == ["1", "23", "45", "6"]
        assert evaluate("∞ 1234S£") == [[1], [2, 3], [4, 5, 6], [7, 8, 9, 10]]
        assert evaluate("∞∞£4£") == [[1], [2, 3], [4, 5, 6], [7, 8, 9, 10]]
    end

    test "modulo" do
        assert evaluate("5 3%") == 2
        assert evaluate("5( 3%") == 1
        assert evaluate("6( 2%") == 0
        assert evaluate("5 3(%") == -1
        assert evaluate("55( 13(%") == -3
        assert evaluate("\"5.5\"2%") == 1.5
        assert Float.round(evaluate("\"5.5\"\"2.5\"%"), 10) == 0.5
        assert Float.round(evaluate("\"5.5\"\"2.5\"(%"), 10) == -2.0
        assert Float.round(evaluate("\"5.5\"(\"2.5\"%"), 10) == 2.0
        assert Float.round(evaluate("\"5.5\"(\"2.5\"(%"), 10) == -0.5
    end

    test "equals to" do
        assert evaluate("3 3Q") == 1
        assert evaluate("3 3ïQ") == 1
        assert evaluate("3ï 3ïQ") == 1
        assert evaluate("3 4Q") == 0
        assert evaluate("3 4ïQ") == 0
        assert evaluate("3ï 4ïQ") == 0
        assert evaluate("3L 3Q") == [0, 0, 1]
        assert evaluate("3L 3ïQ") == [0, 0, 1]
        assert evaluate("3 3LQ") == [0, 0, 1]
        assert evaluate("3ï 3LQ") == [0, 0, 1]
    end

    test "remove from" do
        assert evaluate("123456 45K") == "1236"
        assert evaluate("12344556 45K") == "123456"
        assert evaluate("12344556ï 45ïK") == "123456"
        assert evaluate("1245344556ï 45ïK") == "123456"
        assert evaluate("5L 3K") == [1, 2, 4, 5]
    end

    test "contains" do
        assert evaluate("123456 34å") == 1
        assert evaluate("123456 43å") == 0
        assert evaluate("123456 7Lå") == [1, 1, 1, 1, 1, 1, 0]
        assert evaluate("123456ï 7Lå") == [1, 1, 1, 1, 1, 1, 0]
        assert evaluate("12 34 56) 3å") == 0
        assert evaluate("12 34 56) 34å") == 1
        assert evaluate("1 3 4) 4Lå") == [1, 0, 1, 1]
    end

    test "wrap two" do
        assert evaluate("1 2‚ï") == [1, 2]
        assert evaluate("1L 2L‚") == [[1], [1, 2]]
    end

    test "split a into pieces of length b" do
        assert evaluate("5L2ô") == [[1, 2], [3, 4], [5]]
        assert evaluate("123456 2ô") == ["12", "34", "56"]
        assert evaluate("5L23Sô") == [[[1, 2], [3, 4], [5]], [[1, 2, 3], [4, 5]]]
        assert evaluate("∞2ôO3£") == [3, 7, 11]
    end

    test "a nCr b" do
        assert evaluate("5 2c") == 10
        assert evaluate("120 30c") == 16974538760797408909460074096
        assert evaluate("10L 3c") == [0, 0, 1, 4, 10, 20, 35, 56, 84, 120]
        assert evaluate("10 6Lc") == [10, 45, 120, 210, 252, 210]
        assert evaluate("6L6+6Lc") == [7, 28, 84, 210, 462, 924]
    end

    test "a nPr b" do
        assert evaluate("5 2e") == 20
        assert evaluate("5 2e") == 20
        assert evaluate("5 8e") == 0
        assert evaluate("5 5Le") == [5, 20, 60, 120, 120]
        assert evaluate("5L3e") == [0, 0, 6, 24, 60]
        assert evaluate("6L6+6Le") == [7, 56, 504, 5040, 55440, 665280]
    end

    test "not equals" do
        assert evaluate("1 1Ê") == 0
        assert evaluate("1 1ïÊ") == 0
        assert evaluate("1 2Ê") == 1
        assert evaluate("1 2ïÊ") == 1
        assert evaluate("1ï 2ïÊ") == 1
        assert evaluate("3L2Ê") == [1, 0, 1]
    end

    test "rangify" do
        assert evaluate("1 5Ÿ") == [1, 2, 3, 4, 5]
        assert evaluate("1( 5Ÿ") == [-1, 0, 1, 2, 3, 4, 5]
        assert evaluate("5 1Ÿ") == [5, 4, 3, 2, 1]
        assert evaluate("5 1(Ÿ") == [5, 4, 3, 2, 1, 0, -1]
        assert evaluate("1 3 5)Ÿ") == [1, 2, 3, 4, 5]
        assert evaluate("1 3 5()Ÿ") == [1, 2, 3, 2, 1, 0, -1, -2, -3, -4, -5]
        assert evaluate("1 3 1ï 3)Ÿ") == [1, 2, 3, 2, 1, 2, 3]
        assert evaluate("1 3 1 1 1 3)Ÿ") == [1, 2, 3, 2, 1, 1, 1, 2, 3]
    end

    test "concat" do
        assert evaluate("123 456«") == "123456"
        assert evaluate("3L 456«") == ["1456", "2456", "3456"]
        assert evaluate("123 456S«") == ["1234", "1235", "1236"]
        assert evaluate("3L 3L«") == [1, 2, 3, 1, 2, 3]
    end

    test "prepend" do
        assert evaluate("\"abc\"\"def\"ì") == "defabc"
        assert evaluate("\"abc\"\"def\"Sì") == ["dabc", "eabc", "fabc"]
        assert evaluate("\"abc\"S\"def\"ì") == ["defa", "defb", "defc"]
        assert evaluate("\"abc\"S\"def\"Sì") == ["d", "e", "f", "a", "b", "c"]
    end

    test "join with" do
        assert evaluate("1 2 3 0ý") == "10203"
        assert evaluate("1 2 3) 0ý") == "10203"
    end

    test "dividable by" do
        assert evaluate("4 2Ö") == 1
        assert evaluate("4 3Ö") == 0
        assert evaluate("3 4Ö") == 0
        assert evaluate("45 456SÖ") == [0, 1, 0]
    end

    test "normal zip" do
        assert evaluate("3L 3L3+)ø") == [[1, 4], [2, 5], [3, 6]]
        assert evaluate("123 456ø") == ["14", "25", "36"]
        assert evaluate("123S 456øï") == [[1, 4], [2, 5], [3, 6]]
        assert evaluate("123 456Søï") == [[1, 4], [2, 5], [3, 6]]
        assert evaluate("∞ 3Lø") == [[1, 1], [2, 2], [3, 3]]
        assert evaluate("3L ∞ø") == [[1, 1], [2, 2], [3, 3]]
        assert evaluate("∞ ∞ø3£") == [[1, 1], [2, 2], [3, 3]]
    end

    test "zip with filler" do
        # if c is list of lists: zip(c) with space filler
        assert evaluate("3L 3L3+)ζ") == [[1, 4], [2, 5], [3, 6]]
        assert evaluate("4L 3L3+)ζ") == [[1, 4], [2, 5], [3, 6], [4, " "]]
        assert evaluate("3L 4L3+)ζ") == [[1, 4], [2, 5], [3, 6], [" ", 7]]

        # else if c is list: zip(b, c) with space filler
        assert evaluate("3L 3L3+ζ") == [[1, 4], [2, 5], [3, 6]]
        assert evaluate("3L 4L3+ζ") == [[1, 4], [2, 5], [3, 6], [" ", 7]]
        assert evaluate("4L 3L3+ζ") == [[1, 4], [2, 5], [3, 6], [4, " "]]

        # else if b is list of lists: zip(b) with c filler
        assert evaluate("3L 3L3+)10ïζ") == [[1, 4], [2, 5], [3, 6]]
        assert evaluate("4L 3L3+)10ïζ") == [[1, 4], [2, 5], [3, 6], [4, 10]]
        assert evaluate("3L 4L3+)10ïζ") == [[1, 4], [2, 5], [3, 6], [10, 7]]

        # else zip(a, b) with c filler
        assert evaluate("123 456 0ζ") == ["14", "25", "36"]
        assert evaluate("123 4567 0ζ") == ["14", "25", "36", "07"]
        assert evaluate("1234 456 0ζ") == ["14", "25", "36", "40"]
        assert evaluate("123 4567S 0ζï") == [[1, 4], [2, 5], [3, 6], [0, 7]]
        assert evaluate("1234S 456 0ζï") == [[1, 4], [2, 5], [3, 6], [4, 0]]
        assert evaluate("123S 456S 0ζï") == [[1, 4], [2, 5], [3, 6]]
        assert evaluate("123S 4567S 0ζï") == [[1, 4], [2, 5], [3, 6], [0, 7]]
        assert evaluate("1234S 456S 0ζï") == [[1, 4], [2, 5], [3, 6], [4, 0]]
    end

    test "keep with length" do
        assert evaluate("1 2 3 12 23 123) 2ù") == ["12", "23"]
        assert evaluate("1 2 3 12 23 123) 23Sù") == [["12", "23"], ["123"]]
    end

    test "split on" do
        assert evaluate("12345 3¡") == ["12", "45"]
        assert evaluate("12345367 3¡") == ["12", "45", "67"]
        assert evaluate("12345367ï 3¡") == ["12", "45", "67"]
        assert evaluate("12345367 3ï¡") == ["12", "45", "67"]
        assert evaluate("7L 3¡ï") == [[1, 2], [4, 5, 6, 7]]
        assert evaluate("7L 3ï¡ï") == [[1, 2], [4, 5, 6, 7]]
        assert evaluate("123456378Sï 3ï¡ï") == [[1, 2], [4, 5, 6], [7, 8]]
        assert evaluate("12345678 36S¡") == ["12", "45", "78"]
        assert evaluate("12345678ï 36Sï¡") == ["12", "45", "78"]
        assert evaluate("12345678Sï 36Sï¡") == [[1, 2], [4, 5], [7, 8]]
    end

    test "index in" do
        assert evaluate("1234 1k") == 0
        assert evaluate("1234 4k") == 3
        assert evaluate("1234 14Sk") == [0, 3]
        assert evaluate("1234Sï 14Sïk") == [0, 3]
        assert evaluate("1234S 14Sïk") == [0, 3]
        assert evaluate("1234Sï 14Sk") == [0, 3]
        assert evaluate("1234S 14Sk") == [0, 3]
        assert evaluate("1234S 5k") == -1
        assert evaluate("1234S 54Sk") == [-1, 3]
        assert evaluate("∞ 5k") == 4
    end

    test "list multiply" do
        assert evaluate("123ï 3и") == [123, 123, 123]
        assert evaluate("3L 3и") == [1, 2, 3, 1, 2, 3, 1, 2, 3]
        assert evaluate("3L 0и") == []
        assert evaluate("3L 123Sи") == [[1, 2, 3], [1, 2, 3, 1, 2, 3], [1, 2, 3, 1, 2, 3, 1, 2, 3]]
    end

    test "extract each nth" do
        assert evaluate("6L2ι") == [[1, 3, 5], [2, 4, 6]]
        assert evaluate("6Lι") == [[1, 3, 5], [2, 4, 6]]
        assert evaluate("123456 2ι") == ["135", "246"]
    end

    test "filter to front" do
        assert evaluate("1122332211 1†") == "1111223322"
        assert evaluate("1122332211 2†") == "2222113311"
        assert evaluate("1122332211 23S†") == "2233221111"
        assert evaluate("1122332211Sï 23S†") == [2, 2, 3, 3, 2, 2, 1, 1, 1, 1]
    end

    test "gcd of" do
        assert evaluate("4 8¿") == 4
        assert evaluate("4.5 3¿") == 1.5
        assert evaluate("4.5( 3(¿") == -1.5
        assert evaluate("4.5( 3¿") == 1.5
        assert evaluate("4.5 3(¿") == 1.5
        assert evaluate("8 16 48)¿") == 8
        assert evaluate("8 16 36)¿") == 4
        assert evaluate("1024 32 64 128 8 256 512 24 36)¿") == 4
        assert evaluate("1475.5 615.5¿") == 0.5
    end

    test "cartesian product" do
        assert evaluate("3L 3L3+ â") == [[1, 4], [1, 5], [1, 6], [2, 4], [2, 5], [2, 6], [3, 4], [3, 5], [3, 6]]
        assert evaluate("3L 456 âï") == [[1, 4], [1, 5], [1, 6], [2, 4], [2, 5], [2, 6], [3, 4], [3, 5], [3, 6]]
        assert evaluate("123 456 âï") == [14, 15, 16, 24, 25, 26, 34, 35, 36]
    end

    test "cartesian repeat" do
        assert evaluate("2L 3ã") == [[1, 1, 1], [1, 1, 2], [1, 2, 1], [1, 2, 2], [2, 1, 1], [2, 1, 2], [2, 2, 1], [2, 2, 2]]
        assert evaluate("3L 2ã") == [[1, 1], [1, 2], [1, 3], [2, 1], [2, 2], [2, 3], [3, 1], [3, 2], [3, 3]]
        assert evaluate("3Lã") == [[1, 1], [1, 2], [1, 3], [2, 1], [2, 2], [2, 3], [3, 1], [3, 2], [3, 3]]
        assert evaluate("∞ã5£") == [[1, 1], [1, 2], [1, 3], [1, 4], [1, 5]]
        assert evaluate("123 2ã") == ["11", "12", "13", "21", "22", "23", "31", "32", "33"]
    end

    test "count occurrences" do
        assert evaluate("1233213 3¢") == 3
        assert evaluate("1233213 2¢") == 2
        assert evaluate("1233213Sï 2¢") == 2
        assert evaluate("1233213S 2¢") == 2
        assert evaluate("1233213S 23S¢") == [2, 3]
    end

    test "to base arbitrary" do
        assert evaluate("15 2в") == [1, 1, 1, 1]
        assert evaluate("38 2в") == [1, 0, 0, 1, 1, 0]
        assert evaluate("38( 2в") == [-1, 0, 0, -1, -1, 0]
        assert evaluate("12345 786в") == [15, 555]
        assert evaluate("12345( 7в") == [-5, 0, -6, -6, -4]
        assert evaluate("146 3(в") == [2, 1, 1, 0, 2]
        assert evaluate("12345 7(в") == [6, 6, 0, 1, 4]
        assert evaluate("15 38 12345) 7в") == [[2, 1], [5, 3], [5, 0, 6, 6, 4]]
    end
    
    test "keep chars" do
        assert evaluate("12345 43Ã") == "34"
        assert evaluate("12345S 43SÃ") == ["3", "4"]
        assert evaluate("12 34 34 45 34 12 43) 34Ãï") == [34, 34, 34]
        assert evaluate("12 34 34 45 34 12 43) 34 45‚Ãï") == [34, 34, 45, 34]
    end

    test "keep truthy indices" do
        assert evaluate("5L 10010SÏï") == [1, 4]
        assert evaluate("5L 10010Ïï") == [1, 4]
        assert evaluate("12345 10010SÏ") == "14"
        assert evaluate("12345 10010Ï") == "14"
        assert evaluate("∞ 10010Ïï") == [1, 4]
        assert evaluate("5L ∞ÈÏï") == [2, 4]
    end

    test "string multiplication" do
        assert evaluate("5 3×") == "555"
        assert evaluate("5 3L×") == ["5", "55", "555"]
        assert evaluate("5L 3×") == ["111", "222", "333", "444", "555"]
        assert evaluate("5L 3L×") == ["1", "22", "333"]
    end

    test "remove leading" do
        assert evaluate("112233 1Û") == "2233"
        assert evaluate("112233Sï 1Û") == [2, 2, 3, 3]
    end

    test "remove trailing" do
        assert evaluate("112233 3Ü") == "1122"
        assert evaluate("1122334 3Ü") == "1122334"
        assert evaluate("112233Sï 3Ü") == [1, 1, 2, 2]
    end

    test "convert from base" do
        assert evaluate("12342 5ö") == 972
        assert evaluate("\"m+\" 255ö") == 12345
        assert evaluate("\"m+\" 255ö") == 12345
    end

    test "integer division" do
        assert evaluate("5 2÷") == 2
        assert evaluate("10 2÷") == 5
        assert evaluate("9.5 2÷") == 4
        assert evaluate("9.5 2.5÷") == 3
    end

    test "prepend spaces" do
        assert evaluate("123 2ú") == "  123"
        assert evaluate("3L 2ú") == ["  1", "  2", "  3"]
    end

    test "split evenly" do
        assert evaluate("5L 3ä") == [[1, 2], [3, 4], [5]]
        assert evaluate("6L 3ä") == [[1, 2], [3, 4], [5, 6]]
        assert evaluate("123456 3ä") == ["12", "34", "56"]
        assert evaluate("12345 3ä") == ["12", "34", "5"]
    end

    test "sign function" do
        assert evaluate("5 2.S") == 1
        assert evaluate("2 5.S") == -1
        assert evaluate("5 5.S") == 0
        assert evaluate("543S 4.S") == [1, 0, -1]
    end
    
    test "surround with" do
        assert evaluate("456 1.ø") == "14561"
        assert evaluate("456 12.ø") == "1245612"
        assert evaluate("456Sï 12ï.ø") == [12, 4, 5, 6, 12]
        assert evaluate("456Sï 12Sï.ø") == [1, 2, 4, 5, 6, 1, 2]
    end

    test "overlap" do
        assert evaluate("12345 135.o") == "1 3 5"
        assert evaluate("12345 1365.o") == "1 3  65"
        assert evaluate("12345 1346.o") == "1 34 6"
    end

    test "take last" do
        assert evaluate("12345 2.£") == "45"
        assert evaluate("5L 2.£") == [4, 5]
    end

    test "log" do
        assert evaluate("8 2.n") == 3
        assert evaluate("16 2.n") == 4
        assert evaluate("100 10.n") == 2
    end

    test "lcm of" do
        assert evaluate("1 2.¿ 3.¿ 4.¿ 5.¿ 6.¿ 7.¿ 8.¿ 9.¿ 10.¿") == 2520
        assert evaluate("10L.¿") == 2520
    end

    test "n-plicate" do
        assert evaluate("5ï 3.D)") == [5, 5, 5]
        assert evaluate("5ï \"abc\".D)") == [5, 5, 5]
    end

    test "closest to" do
        assert evaluate("5L 2.8.x") == 3
        assert evaluate("5L 3.x") == 3
        assert evaluate("5L 23S.x") == [2, 3]
        assert evaluate(") 2.x") == []
    end
end
