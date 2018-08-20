defmodule UnaryTest do
    use ExUnit.Case
    alias HTTPoison
    import TestHelper
    import Mock

    test "add one" do
        assert evaluate("5ï>") == 6
        assert evaluate("5§>") == 6
        assert evaluate("5L>") == [2, 3, 4, 5, 6]
        assert evaluate("3LL>") == [[2], [2, 3], [2, 3, 4]]
    end

    test "subtract one" do
        assert evaluate("5ï<") == 4
        assert evaluate("5§<") == 4
        assert evaluate("5L<") == [0, 1, 2, 3, 4]
    end

    test "construct list" do
        assert evaluate("5ïL") == [1, 2, 3, 4, 5]
        assert evaluate("5§L") == [1, 2, 3, 4, 5]
        assert evaluate("3LL") == [[1], [1, 2], [1, 2, 3]]
    end

    test "prefixes" do
        assert evaluate("12345η") == ["1", "12", "123", "1234", "12345"]
        assert evaluate("12345ïη") == ["1", "12", "123", "1234", "12345"]
        assert evaluate("∞ηн") == [1]
        assert evaluate("12345.p") == ["1", "12", "123", "1234", "12345"]
        assert evaluate("12345ï.p") == ["1", "12", "123", "1234", "12345"]
        assert evaluate("∞.pн") == [1]
    end

    test "head of element" do
        assert evaluate("5Lн") == 1
        assert evaluate("5LLн") == [1]
        assert evaluate("123456н") == "1"
        assert evaluate("545ïн") == "5"
        assert evaluate("∞н") == 1
    end

    test "tail of element" do
        assert evaluate("12345§θ") == "5"
        assert evaluate("12345ïθ") == "5"
        assert evaluate("5Lθ") == 5
        assert evaluate("5LLθ") == [1, 2, 3, 4, 5]
    end

    test "initial number representation" do
        assert evaluate("123") == "123"
        assert evaluate("123") != 123
    end

    test "convert to int" do
        assert evaluate("123ï") == 123
        assert evaluate("5L§ï") == [1, 2, 3, 4, 5]
        assert evaluate("1.5ï") == 1
    end

    test "convert to string" do
        assert evaluate("5§") == "5"
        assert evaluate("5L§") == ["1", "2", "3", "4", "5"]
        assert evaluate("123ï§") == "123"
    end

    test "05AB1E truthify" do
        assert evaluate("5Θ") == 0
        assert evaluate("5ïΘ") == 0
        assert evaluate("1Θ") == 1
        assert evaluate("1ïΘ") == 1
        assert evaluate("001Θ") == 1
        assert evaluate("4L2-Θ") == [0, 0, 1, 0]
    end

    test "05AB1E falsify" do
        assert evaluate("5≠") == 1
        assert evaluate("5ï≠") == 1
        assert evaluate("1≠") == 0
        assert evaluate("1ï≠") == 0
        assert evaluate("001≠") == 0
        assert evaluate("004≠") == 1
        assert evaluate("4L2-≠") == [1, 1, 0, 1]
    end

    test "factorial" do
        assert evaluate("0!") == 1
        assert evaluate("0ï!") == 1
        assert evaluate("4!") == 24
        assert evaluate("4ï!") == 24
        assert evaluate("4L!") == [1, 2, 6, 24]
    end

    test "convert to binary" do
        assert evaluate("0b") == "0"
        assert evaluate("1b") == "1"
        assert evaluate("55b") == "110111"
        assert evaluate("1 55)b") == ["1", "110111"]
    end

    test "convert to hexadecimal" do
        assert evaluate("0h") == "0"
        assert evaluate("12h") == "C"
        assert evaluate("54454h") == "D4B6"
        assert evaluate("12 54454)h") == ["C", "D4B6"]
    end

    test "convert from binary" do
        assert evaluate("101C") == 5
        assert evaluate("0C") == 0
        assert evaluate("1C") == 1
        assert evaluate("0 1 101) 110)C") == [[0, 1, 5], 6]
    end

    test "convert from hexadecimal" do
        assert evaluate("\"A\"H") == 10
        assert evaluate("\"a\"H") == 10
        assert evaluate("\"64\"H") == 100
        assert evaluate("\"C6D8d4\"H") == 13031636
        assert evaluate("\"A\" \"a\" 64) \"C6D8d4\")H") == [[10, 10, 100], 13031636]
    end

    test "split into individual chars" do
        assert evaluate("123S") == ["1", "2", "3"]
        assert evaluate("123ïS") == ["1", "2", "3"]
        assert evaluate("123 456)S") == ["1", "2", "3", "4", "5", "6"]
        assert evaluate("123ï) 456)S") == ["1", "2", "3", "4", "5", "6"]
    end

    test "bitwise not" do
        assert evaluate("123±") == -124
        assert evaluate("123ï±") == -124
        assert evaluate("12 24ï 24()±") == [-13, -25, 23]
    end

    test "truthified" do
        assert evaluate("123Ā") == 1
        assert evaluate("1Ā") == 1
        assert evaluate("0Ā") == 0
        assert evaluate("\"abc\"Ā") == 1
        assert evaluate("\"\"Ā") == 0
        assert evaluate("\"\" 1ï 0) \"abc\")Ā") == [[0, 1, 0], 1]
    end

    test "enclosed" do
        assert evaluate("123Ć") == "1231"
        assert evaluate("123SĆ") == ["1", "2", "3", "1"]
        assert evaluate("123SïĆ") == [1, 2, 3, 1]
    end

    test "two to the power of x" do
        assert evaluate("5o") == 32
        assert evaluate("5(o") == 0.03125
        assert evaluate("0o") == 1
        assert evaluate("\"0.5\"o") == 1.4142135623730951
        assert evaluate("5 5( 0 \"0.5\")o") == [32, 0.03125, 1, 1.4142135623730951]
    end

    test "to uppercase" do
        assert evaluate("\"abcd\"u") == "ABCD"
        assert evaluate("\"aBc123\"u") == "ABC123"
        assert evaluate("\"1a\" \"2b\")u") == ["1A", "2B"]
    end

    test "to lowercase" do
        assert evaluate("\"ABcd\"l") == "abcd"
        assert evaluate("\"1a\"\"B2\")l") == ["1a", "b2"]
    end

    test "x to the power of two" do
        assert evaluate("5n") == 25
        assert evaluate("\"0.5\"n") == 0.25
        assert evaluate("\"0.5\"(n") == 0.25
        assert evaluate("5 2)n") == [25, 4]
    end

    test "length" do
        assert evaluate("123g") == 3
        assert evaluate("\"\"g") == 0
        assert evaluate("123ïg") == 3
        assert evaluate("123Sïg") == 3
        assert evaluate(")g") == 0
    end

    test "reverse" do
        assert evaluate("123R") == "321"
        assert evaluate("123ïR") == "321"
        assert evaluate("5LR") == [5, 4, 3, 2, 1]
    end

    test "delete last" do
        assert evaluate("1 2 3\\ )") == ["1", "2"]
        assert evaluate("3\\ )") == []
    end

    test "negative boolean" do
        assert evaluate("1_") == 0
        assert evaluate("5_") == 0
        assert evaluate("0_") == 1
        assert evaluate("1 5 0)_") == [0, 0, 1]
    end

    test "is alphabetic" do
        assert evaluate("\"abc\"a") == 1
        assert evaluate("\"ab1c\"a") == 0
        assert evaluate("5a") == 0
        assert evaluate("5 \"abc\" \"ab1\")a") == [0, 1, 0]
    end

    test "double without popping" do
        assert evaluate("4ïx)") == [4, 8]
        assert evaluate("3Lx)") == [[1, 2, 3], [2, 4, 6]]
    end

    test "inverse" do
        assert evaluate("5z") == 0.2
        assert evaluate("2 4 8)z") == [0.5, 0.25, 0.125]
    end

    test "enumerate" do
        assert evaluate("12345ā") == [1, 2, 3, 4, 5]
        assert evaluate("12345Sā") == [1, 2, 3, 4, 5]
        assert evaluate("∞ā5è") == 6
    end

    test "last element" do
        assert evaluate("12345¤") == "5"
        assert evaluate("12345ï ¤") == "5"
        assert evaluate("5L ¤") == 5
    end

    test "remove first" do
        assert evaluate("12345¦") == "2345"
        assert evaluate("\"\"¦") == ""
        assert evaluate("12345ï¦") == "2345"
        assert evaluate("5L¦") == [2, 3, 4, 5]
    end

    test "remove last" do
        assert evaluate("12345¨") == "1234"
        assert evaluate("\"\"¨") == ""
        assert evaluate("12345ï¨") == "1234"
        assert evaluate("5L¨") == [1, 2, 3, 4]
    end

    test "deltas" do
        assert evaluate("1234¥") == [1, 1, 1]
        assert evaluate("4150¥") == [-3, 4, -5]
        assert evaluate("∞¥5£") == [1, 1, 1, 1, 1]
    end

    test "first element" do
        assert evaluate("1234¬") == "1"
        assert evaluate("1234¬)") == ["1234", "1"]
        assert evaluate("4L ¬") == 1
    end

    test "add two" do
        assert evaluate("5Ì") == 7
        assert evaluate("1 2 3)Ì") == [3, 4, 5]
    end

    test "subtract two" do
        assert evaluate("5Í") == 3
        assert evaluate("1 2 3)Í") == [-1, 0, 1]
    end

    test "is even" do
        assert evaluate("5È") == 0
        assert evaluate("6È") == 1
        assert evaluate("5(È") == 0
        assert evaluate("6(È") == 1
        assert evaluate("\"4.0\"È") == 1
        assert evaluate("\"5.0\"È") == 0
        assert evaluate("\"4.01\"È") == 0
        assert evaluate("\"4.000\" 2 3)È") == [1, 1, 0]
    end

    test "is odd" do
        assert evaluate("5É") == 1
        assert evaluate("6É") == 0
        assert evaluate("5(É") == 1
        assert evaluate("6(É") == 0
        assert evaluate("\"4.0\"É") == 0
        assert evaluate("\"5.0\"É") == 1
        assert evaluate("\"4.01\"É") == 0
        assert evaluate("\"5.000\" 2 3)É") == [1, 0, 1]
    end

    test "sum up" do
        assert evaluate("1 2 3)O") == 6
        assert evaluate(")O") == 0
        assert evaluate(") 2L)O") == [0, 3]
        assert evaluate("3L 3L)O") == [6, 6]
        assert evaluate("3LL 3L)O") == [[1, 3, 6], 6]
        assert evaluate("1 2 3 4O") == 10
        assert evaluate("∞∞£O3£") == [1, 5, 15]
    end

    test "product" do
        assert evaluate("1 2 3)P") == 6
        assert evaluate(")P") == 1
        assert evaluate(") 2L)P") == [1, 2]
        assert evaluate("3L 3L)P") == [6, 6]
        assert evaluate("3LL 3L)P") == [[1, 2, 6], 6]
        assert evaluate("1 2 3 4P") == 24
        assert evaluate("∞∞£3£P") == [1, 6, 120]
        assert evaluate("∞∞£P3£") == [1, 6, 120]
    end

    test "join to string" do
        assert evaluate("1 2 3)J") == "123"
        assert evaluate("3LJ") == "123"
        assert evaluate("3LLJ") == ["1", "12", "123"]
        assert evaluate("1 2 3J") == "123"
        assert evaluate("1 32ï 3J") == "1323"
        assert evaluate("32 33‚ 34 35‚ 36 37‚)ïJ") == ["3233", "3435", "3637"]
        assert evaluate("33 33‚ 33‚ 34 35‚ 36 37‚)ïJ") == [["3333", "33"], "3435", "3637"]
        assert evaluate("33 34 35‚ 36)ïJ") == ["33", "3435", "36"]
    end

    test "ten to the power of n" do
        assert evaluate("2°") == 100
        assert evaluate("3L°") == [10, 100, 1000]
        assert_in_delta evaluate("\"0.5\"°"), 3.1622776601, 0.0000001
    end

    test "double number" do
        assert evaluate("2·") == 4
        assert evaluate("3L·") == [2, 4, 6]
    end

    test "is prime" do
        assert evaluate("0p") == 0
        assert evaluate("1p") == 0
        assert evaluate("2p") == 1
        assert evaluate("3p") == 1
        assert evaluate("4p") == 0
        assert evaluate("5p") == 1
        assert evaluate("10Lp") == [0, 1, 1, 0, 1, 0, 1, 0, 0, 0]
    end

    test "is numeric" do
        assert evaluate("123d") == 1
        assert evaluate("123ïd") == 1
        assert evaluate("\"123a\"d") == 0
        assert evaluate("\"123a\" 123 004)d") == [0, 1, 1]
        assert evaluate("123(d") == 0
        assert evaluate("123.5d") == 1
        assert evaluate("0.5(d") == 0
        assert evaluate("0.5d") == 1
    end

    test "lift" do
        assert evaluate("3Lƶ") == [1, 4, 9]
        assert evaluate("123ƶ") == ["1", "22", "333"]
        assert evaluate("3LLƶ") == [[1], [2, 4], [3, 6, 9]]
        assert evaluate("∞ƶ5£") == [1, 4, 9, 16, 25]
    end

    test "head extraction" do
        assert evaluate("123ć)") == ["23", "1"]
        assert evaluate("3Lć)") == [[2, 3], 1]
        assert evaluate("∞ć") == 1
    end

    test "wrap single" do
        assert evaluate("123¸") == ["123"]
        assert evaluate("123ï¸") == [123]
        assert evaluate("1 2 3¸)ï") == [1, 2, [3]]
    end

    test "absolute value" do
        assert evaluate("123Ä") == 123
        assert evaluate("123(Ä") == 123
        assert evaluate("4L2-Ä") == [1, 0, 1, 2]
    end

    test "all equal" do
        assert evaluate("111Ë") == 1
        assert evaluate("\"\"Ë") == 1
        assert evaluate("1 1ï 1)Ë") == 1
        assert evaluate("121Ë") == 0
        assert evaluate("1 1ï 2)Ë") == 0
    end

    test "title case" do
        assert evaluate("\"abc\"™") == "Abc"
        assert evaluate("\"abc def\"™") == "Abc Def"
        assert evaluate("\"abc def\" \"ghi\")™") == ["Abc Def", "Ghi"]
    end

    test "switch case" do
        assert evaluate("\"aBc\".š") == "AbC"
        assert evaluate("\"aBc Def 123\".š") == "AbC dEF 123"
        assert evaluate("\"aBc Def\" \"a12\").š") == ["AbC dEF", "A12"]
    end

    test "deep flatten" do
        assert evaluate("1 2 3 4)ï˜") == [1, 2, 3, 4]
        assert evaluate("1 2 3 4))ï˜") == [1, 2, 3, 4]
        assert evaluate("3LLL˜") == [1, 1, 1, 2, 1, 1, 2, 1, 2, 3]
    end

    test "sentence case" do
        assert evaluate("\"abc\".ª") == "Abc"
        assert evaluate("\"abc. def? ghi! jkl mnop.\".ª") == "Abc. Def? Ghi! Jkl mnop."
    end

    test "reduced subtraction" do
        assert evaluate("1 2 3 4)Æ") == -8
        assert evaluate("1 2 3 4Æ") == -8
        assert evaluate("3L 3L3+)Æ") == [-4, -7]
    end

    test "listify 0..n" do
        assert evaluate("4Ý") == [0, 1, 2, 3, 4]
        assert evaluate("4ÝÝ") == [[0], [0, 1], [0, 1, 2], [0, 1, 2, 3], [0, 1, 2, 3, 4]]
    end

    test "keep letters" do
        assert evaluate("\"123abc\"á") == "abc"
        assert evaluate("\"123\"á") == ""
        assert evaluate("12 34 \"5a\" \"bc\" \"cd\")á") == ["bc", "cd"]
    end

    test "keep digits" do
        assert evaluate("\"123abc\"þ") == "123"
        assert evaluate("\"abc\"þ") == ""
        assert evaluate("\"abc\" 123 456 \"ab4\")þ") == ["123", "456"]
    end

    test "suffixes" do
        assert evaluate("5L.s") == [[5], [4, 5], [3, 4, 5], [2, 3, 4, 5], [1, 2, 3, 4, 5]]
        assert evaluate("12345.s") == ["5", "45", "345", "2345", "12345"]
    end

    test "substrings" do
        assert evaluate("4LŒ") == [[1], [1, 2], [1, 2, 3], [1, 2, 3, 4], [2], [2, 3], [2, 3, 4], [3], [3, 4], [4]]
        assert evaluate("1234Œ") == ["1", "12", "123", "1234", "2", "23", "234", "3", "34", "4"]
    end

    test "group equal" do
        assert evaluate("11223344Sïγ") == [[1, 1], [2, 2], [3, 3], [4, 4]]
        assert evaluate("11223344γ") == ["11", "22", "33", "44"]
        assert evaluate("11223344ïγ") == ["11", "22", "33", "44"]
        assert evaluate("0111011000111111Sïγ") == [[0], [1, 1, 1], [0], [1, 1], [0, 0, 0], [1, 1, 1, 1, 1, 1]]
        assert evaluate("∞€Dγ4£") == [[1, 1], [2, 2], [3, 3], [4, 4]]
    end
    
    test "int to char" do
        assert evaluate("33ç") == "!"
        assert evaluate("33 34 35 36)ç") == ["!", "\"", "#", "$"]
    end

    test "char to int" do
        assert evaluate("\"abc\"Ç") == [97, 98, 99]
        assert evaluate("\"abc\"SÇ") == [97, 98, 99]
        assert evaluate("\"abc\"\"def\")Ç") == [[97, 98, 99], [100, 101, 102]]
        assert evaluate("\"abc\"\"def\"\"g\")Ç") == [[97, 98, 99], [100, 101, 102], 103]
    end

    test "bifurcate" do
        assert evaluate("123Â)") == ["123", "321"]
        assert evaluate("123ïÂ)ï") == [123, 321]
        assert evaluate("3LÂ)") == [[1, 2, 3], [3, 2, 1]]
    end

    test "sort" do
        assert evaluate("123321{") == "112233"
        assert evaluate("123321S{") == ["1", "1", "2", "2", "3", "3"]
        assert evaluate("123321Sï{") == [1, 1, 2, 2, 3, 3]
        assert evaluate("1 2 12 2ï 1ï){") == [1, 2, "1", "12", "2"]
        assert evaluate("3L>>3L>3L){") == [[1, 2, 3], [2, 3, 4], [3, 4, 5]]
    end

    test "peel" do
        assert evaluate("1 2 1234S`)ï") == [1, 2, 1, 2, 3, 4]
        assert evaluate("1 2 1234`)ï") == [1, 2, 1, 2, 3, 4]
    end

    test "reverse each" do
        assert evaluate("123 456 789)í") == ["321", "654", "987"]
        assert evaluate("3L 3L3+ 3L6+)í") == [[3, 2, 1], [6, 5, 4], [9, 8, 7]]
    end

    test "random element" do
        assert evaluate("12345Ω 12345SQO") == 1
        assert evaluate("5LΩ 12345SQO") == 1
        assert evaluate("12345.R 12345SQO") == 1
        assert evaluate("5L.R 12345SQO") == 1
    end

    test "max of without popping" do
        assert evaluate("12345Z") == 5
        assert evaluate("12345SZ") == 5
        assert evaluate("5LZ") == 5
        assert evaluate("5L7L)Z") == 7
    end

    test "min of without popping" do
        assert evaluate("12345W") == 1
        assert evaluate("12345SW") == 1
        assert evaluate("5LW") == 1
        assert evaluate("345S 4324S 58S)W") == 2
    end

    test "uniques of list" do
        assert evaluate("123321Ù") == "123"
        assert evaluate("123321SïÙ") == [1, 2, 3]
        assert evaluate("312321SïÙ") == [3, 1, 2]
        assert evaluate("∞€DÙ5£") == [1, 2, 3, 4, 5]
    end

    test "permutations" do
        assert evaluate("3Lœ") == [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
        assert evaluate("123œ") == ["123", "132", "213", "231", "312", "321"]
    end

    test "sort by length" do
        assert evaluate("1 23 456 78 9)ïé") == [1, 9, 23, 78, 456]
        assert evaluate("1S 23S 456S 78S 9S)ïé") == [[1], [9], [2, 3], [7, 8], [4, 5, 6]]
    end

    test "prime factors with duplicates" do
        assert evaluate("56Ò") == [2, 2, 2, 7]
        assert evaluate("2Ò") == [2]
        assert evaluate("1Ò") == []
        assert evaluate("7831135Ò") == [5, 13, 17, 19, 373]
        assert evaluate("56 2 1 7831135)Ò") == [[2, 2, 2, 7], [2], [], [5, 13, 17, 19, 373]]
    end

    test "prime factors without duplicates" do
        assert evaluate("56f") == [2, 7]
        assert evaluate("2f") == [2]
        assert evaluate("1f") == []
        assert evaluate("5(f") == []
        assert evaluate("7831135f") == [5, 13, 17, 19, 373]
        assert evaluate("56 2 1 7831135)f") == [[2, 7], [2], [], [5, 13, 17, 19, 373]]
    end

    test "prime exponents" do
        assert evaluate("768Ó") == [8, 1]
        assert evaluate("92928Ó") == [8, 1, 0, 0, 2]
        assert evaluate("2Ó") == [1]
        assert evaluate("1Ó") == []
        assert evaluate("5(Ó") == []
        assert evaluate("768 92928 2 1)Ó") == [[8, 1], [8, 1, 0, 0, 2], [1], []]
    end

    test "rotate one to the left" do
        assert evaluate("123456À") == "234561"
        assert evaluate("6LÀ") == [2, 3, 4, 5, 6, 1]
        assert evaluate("1ï)À") == [1]
        assert evaluate(")À") == []
    end

    test "rotate one to the right" do
        assert evaluate("123456Á") == "612345"
        assert evaluate("6LÁ") == [6, 1, 2, 3, 4, 5]
        assert evaluate("1ï)Á") == [1]
        assert evaluate(")Á") == []
    end

    test "join by newlines" do
        assert evaluate("5L»") == "1\n2\n3\n4\n5"
        assert evaluate("5LL»") == "1\n1 2\n1 2 3\n1 2 3 4\n1 2 3 4 5"
        assert evaluate("1 2 3 4 5»") == "1\n2\n3\n4\n5"
        assert evaluate("33 33‚ 33‚ 34 35‚ 36 37‚)ï»") == "[33, 33] 33\n34 35\n36 37"
        assert evaluate("33 33‚ 33)ï»") == "33 33\n33"
    end

    test "set x" do
        assert evaluate("5ïUXXX)") == [5, 5, 5]
        assert evaluate("XXX)") == [1, 1, 1]
    end

    test "set y" do
        assert evaluate("5ïVYYY)") == [5, 5, 5]
        assert evaluate("YYY)") == [2, 2, 2]
    end

    test "vertical mirror" do
        assert evaluate("\"/_\\\"∊") == "/_\\\n\\_/"
    end

    test "divisors" do
        assert evaluate("45Ñ") == [1, 3, 5, 9, 15, 45]
        assert evaluate("32(Ñ") == [1, 2, 4, 8, 16, 32]
        assert evaluate("32( 45)Ñ") == [[1, 2, 4, 8, 16, 32], [1, 3, 5, 9, 15, 45]]
        assert evaluate("25Ñ") == [1, 5, 25]
    end

    test "deduplicate" do
        assert evaluate("1122332211Ô") == "12321"
        assert evaluate("1122332211SïÔ") == [1, 2, 3, 2, 1]
        assert evaluate("∞€DÔ5£") == [1, 2, 3, 4, 5]
    end

    test "euler totient" do
        assert evaluate("1Õ") == 1
        assert evaluate("15Õ") == 8
        assert evaluate("45Õ") == 24
    end

    test "round up" do
        assert evaluate("0.5î") == 1
        assert evaluate("0.1î") == 1
        assert evaluate("0.9î") == 1
        assert evaluate("0.0î") == 0
        assert evaluate("1.0î") == 1
    end

    test "round to nearest integer" do
        assert evaluate("0.5ò") == 1
        assert evaluate("0.49ò") == 0
        assert evaluate("0.49 0.51)ò") == [0, 1]
        assert evaluate("0.49 1)ò") == [0, 1]
    end

    test "sort and uniquify" do
        assert evaluate("1223221ê") == "123"
        assert evaluate("1223221Sïê") == [1, 2, 3]
    end

    test "square root" do
        assert evaluate("4t") == 2.0
        assert evaluate("16t") == 4.0
        assert evaluate("6.25t") == 2.5
    end

    test "number to letter" do
        assert evaluate("1.b") == "A"
        assert evaluate("4.b") == "D"
        assert evaluate("24 25 26).b") == ["X", "Y", "Z"]
    end

    test "squarify" do
        assert evaluate("\"ab\"\"def\").B") == ["ab ", "def"]
        assert evaluate("\"ab\ndef\".B") == ["ab ", "def"]
    end

    test "center align left-focused" do
        assert evaluate("\"a\" \"bcd\" \"defg\") .c") == " a\nbcd\ndefg"
        assert evaluate("\"a\nbcd\ndefg\" .c") == " a\nbcd\ndefg"
    end

    test "center align right-focused" do
        assert evaluate("\"a\" \"bcd\" \"defg\") .C") == "  a\n bcd\ndefg"
        assert evaluate("\"a\nbcd\ndefg\" .C") == "  a\n bcd\ndefg"
    end

    test "is lowercase" do
        assert evaluate("\"abc\".l") == 1
        assert evaluate("\"abC\".l") == 0
        assert evaluate("\"ab1\".l") == 0
        assert evaluate("\"ab\" \"bc\" 12).l") == [1, 1, 0]
    end

    test "is uppercase" do
        assert evaluate("\"ABC\".u") == 1
        assert evaluate("\"ABc\".u") == 0
        assert evaluate("\"AB1\".u") == 0
        assert evaluate("\"AB\" \"BC\" 12).u") == [1, 1, 0]
    end

    test "random shuffle" do
        assert evaluate("12345.r {") == "12345"
        assert evaluate("5L.r {") == [1, 2, 3, 4, 5]
    end

    test "tan" do
        assert_in_delta evaluate("3.1415926535.¼"), 0, 0.00000001
    end

    test "sin" do
        assert_in_delta evaluate("3.1415926535.½"), 0, 0.00000001
    end

    test "cos" do
        assert_in_delta evaluate("3.1415926535.¾"), -1, 0.00000001
    end
    
    test "undelta" do
        assert evaluate("5L.¥") == [0, 1, 3, 6, 10, 15]
        assert evaluate("12345.¥") == [0, 1, 3, 6, 10, 15]
    end

    test "is integer" do
        assert evaluate("4.ï") == 1
        assert evaluate("4(.ï") == 1
        assert evaluate("4.5.ï") == 0
        assert evaluate("4.0.ï") == 1
    end
    
    test "log 2" do
        assert evaluate("16.²") == 4
        assert evaluate("32.²") == 5
        assert evaluate("0.5.²") == -1
    end

    test "divide by 2" do
        assert evaluate("5;") == 2.5
        assert evaluate("6;") == 3.0
    end

    test "triplicate" do
        assert evaluate("5ïÐ)") == [5, 5, 5]
    end

    test "eval string" do
        assert evaluate("\"3 + 4\".E") == 7
        assert evaluate("\"3 + 4\" \"8 + 2\").E") == [7, 10]
    end

    test "nth prime" do
        assert evaluate("0Ø") == 2
        assert evaluate("2Ø") == 5
        assert evaluate("5ÝØ") == [2, 3, 5, 7, 11, 13]
    end
    
    test "get minimum" do
        assert evaluate("12345Sß") == 1
        assert evaluate("12345ß") == 1
        assert evaluate("56S21S34S)ß") == 1
    end
    
    test "get maximum" do
        assert evaluate("12345Sà") == 5
        assert evaluate("12345à") == 5
        assert evaluate("34S25S13S)à") == 5
    end

    test "powerset" do
        assert evaluate(")æ") == [[]]
        assert evaluate("1Læ") == [[], [1]]
        assert evaluate("3Læ") == [[], [1], [2], [1, 2], [3], [1, 3], [2, 3], [1, 2, 3]]
        assert evaluate("4Læ") == [[], [1], [2], [1, 2], [3], [1, 3], [2, 3], [1, 2, 3], [4], [1, 4], [2, 4], [1, 2, 4], [3, 4], [1, 3, 4], [2, 3, 4], [1, 2, 3, 4]]
        assert evaluate("∞æ9£") == [[], [1], [2], [1, 2], [3], [1, 3], [2, 3], [1, 2, 3], [4]]
        assert evaluate("123æ") == ["", "1", "2", "12", "3", "13", "23", "123"]
        assert evaluate("\"\"æ") == [""]
    end

    test "mirror" do
        assert evaluate("\"((\"º") == "(())"
        assert evaluate("\"(<[{123}]>)\"º") == "(<[{123}]>)(<[{321}]>)"
        assert evaluate("\"(<\n{[\"º") == "(<>)\n{[]}"
        assert evaluate("\"(< {[\"#º") == ["(<>)", "{[]}"]
    end

    test "enumerate inner" do
        assert evaluate("123.ā") == [["1", 0], ["2", 1], ["3", 2]]
        assert evaluate("3L.ā") == [[1, 0], [2, 1], [3, 2]]
        assert evaluate("∞.ā3£") == [[1, 0], [2, 1], [3, 2]]
    end

    test "most frequent element" do
        assert evaluate("1 2 3 2 3 2 5)ï.M") == 2
        assert evaluate("1 2 3 2ï 3 2 5).M") == "2"
        assert evaluate("32332112111112.M") == "1"
    end

    test "least frequent element" do
        assert evaluate("1 2 3 2 3 2 5 5)ï.m") == 1
        assert evaluate("1 2 3 2 3 2 5 5).m") == "1"
        assert evaluate("433424343443.m") == "2"
    end

    test "intersected mirror" do
        assert evaluate("\"<<((:\".º") == "<<((:))>>"
        assert evaluate("\"<<:\n((:\n:\".º") == "<<:>>\n((:))\n:"
    end

    test "cycle" do
        assert evaluate("3LÞ10£") == [1, 2, 3, 1, 2, 3, 1, 2, 3, 1]
        assert evaluate("123Þï10£") == [1, 2, 3, 1, 2, 3, 1, 2, 3, 1]
    end

    test "partitions" do
        assert evaluate("2L.œ") == [[[1], [2]], [[1, 2]]]
        assert evaluate("3L.œ") == [[[1], [2], [3]], [[1], [2, 3]], [[1, 2], [3]], [[1, 2, 3]]]
        assert evaluate("4L.œ") == [[[1], [2], [3], [4]], [[1], [2], [3, 4]], [[1], [2, 3], [4]], [[1], [2, 3, 4]], [[1, 2], [3], [4]], [[1, 2], [3, 4]], [[1, 2, 3], [4]], [[1, 2, 3, 4]]]
        assert evaluate("123.œ") == [["1", "2", "3"], ["1", "23"], ["12", "3"], ["123"]]
        assert evaluate("1L.œ") == [[[1]]]
        assert evaluate(").œ") == [[]]
    end

    test "get prime index" do
        assert evaluate("0.Ø") == -1
        assert evaluate("5.Ø") == 2
        assert evaluate("5L.Ø") == [-1, 0, 1, 1, 2]
    end

    test "number from prime exponents" do
        assert evaluate("0 0 3).Ó") == 125
        assert evaluate("3L.Ó") == 2250
        assert evaluate(").Ó") == 1
    end

    test "palindromize" do
        assert evaluate("123û") == "12321"
        assert evaluate("3Lû") == [1, 2, 3, 2, 1]
    end

    test "sign of number" do
        assert evaluate("4.±") == 1
        assert evaluate("4(.±") == -1
        assert evaluate("0.±") == 0
        assert evaluate("0 1 2 1( 0.5 0.5().±") == [0, 1, 1, -1, 1, -1]
    end

    test "left diagonal of matrix" do
        assert evaluate("123S456S789S)ïÅ\\") == [1, 5, 9]
        assert evaluate("123S456S789S159S)ïÅ\\") == [1, 5, 9]
        assert evaluate("1234S4567S7890S)ïÅ\\") == [1, 5, 9]
    end

    test "right diagonal of matrix" do
        assert evaluate("123S456S789S)ïÅ/") == [3, 5, 7]
        assert evaluate("123S456S789S012S)ïÅ/") == [3, 5, 7]
        assert evaluate("1234S4567S7890S)ïÅ/") == [4, 6, 8]
    end

    test "upper triangular matrix" do
        assert evaluate("123S456S789S)ïÅu") == [[1, 2, 3], [5, 6], [9]]
        assert evaluate("1234S4567S7890S)ïÅu") == [[1, 2, 3, 4], [5, 6, 7], [9, 0]]
        assert evaluate("123S456S789S012S)ïÅu") == [[1, 2, 3], [5, 6], [9]]
    end

    test "lower triangular matrix" do
        assert evaluate("123S456S789S)ïÅl") == [[1], [4, 5], [7, 8, 9]]
        assert evaluate("1234S4567S7890S)ïÅl") == [[1, 2], [4, 5, 6], [7, 8, 9, 0]]
        assert evaluate("123S456S789S012S)ïÅl") == [[4], [7, 8], [0, 1, 2]]
    end

    test "vertical intersected mirror" do
        assert evaluate("\"/-\\\"\" | \").∊") == "/-\\\n | \n\\-/"
        assert evaluate("\"/-\\\n | \".∊") == "/-\\\n | \n\\-/"
    end

    test "list of factorials" do
        assert evaluate("120Å!") == [1, 1, 2, 6, 24, 120]
        assert evaluate("1Å!") == [1, 1]
        assert evaluate("0Å!") == []
    end

    test "list of numbers" do
        assert evaluate("5Å0") == [0, 0, 0, 0, 0]
        assert evaluate("0Å0") == []
        assert evaluate("4Å1") == [1, 1, 1, 1]
        assert evaluate("4Å2") == [2, 2, 2, 2]
        assert evaluate("4Å3") == [3, 3, 3, 3]
        assert evaluate("4Å4") == [4, 4, 4, 4]
        assert evaluate("4Å5") == [5, 5, 5, 5]
        assert evaluate("4Å6") == [6, 6, 6, 6]
        assert evaluate("4Å7") == [7, 7, 7, 7]
        assert evaluate("4Å8") == [8, 8, 8, 8]
        assert evaluate("4Å9") == [9, 9, 9, 9]
    end

    test "arithmetic mean" do
        assert evaluate("1 2 3 4 5)ÅA") == 3.0
        assert evaluate("1 2 3 4 5 6)ÅA") == 3.5
        assert evaluate("123S456S)ÅA") == [2, 5]
    end

    test "fibonacci numbers" do
        assert evaluate("144ÅF") == [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144]
        assert evaluate("1ÅF") == [0, 1, 1]
        assert evaluate("0ÅF") == [0]
    end

    test "lucas numbers" do
        assert evaluate("18ÅG") == [2, 1, 3, 4, 7, 11, 18]
        assert evaluate("2ÅG") == [2, 1]
        assert evaluate("1ÅG") == []
    end

    test "prime numbers" do
        assert evaluate("15ÅP") == [2, 3, 5, 7, 11, 13]
        assert evaluate("1ÅP") == []
    end

    test "triangle numbers" do
        assert evaluate("15ÅT") == [0, 1, 3, 6, 10, 15]
        assert evaluate("0ÅT") == [0]
    end

    test "get nth fibonacci number" do
        assert evaluate("0Åf") == 0
        assert evaluate("1Åf") == 1
        assert evaluate("2Åf") == 1
        assert evaluate("3Åf") == 2
        assert evaluate("4Åf") == 3
        assert evaluate("5Åf") == 5
        assert evaluate("6Åf") == 8
        assert evaluate("7Åf") == 13
    end

    test "get nth lucas number" do
        assert evaluate("0Åg") == 2
        assert evaluate("1Åg") == 1
        assert evaluate("10Åg") == 123
    end

    test "get n prime numbers" do
        assert evaluate("5Åp") == [2, 3, 5, 7, 11]
        assert evaluate("1Åp") == [2]
        assert evaluate("0Åp") == []
    end
    
    test "is square" do
        assert evaluate("4Å²") == 1
        assert evaluate("16Å²") == 1
        assert evaluate("15Å²") == 0
        assert evaluate("53522106920846801808219431931984825981463774466487129Å²") == 1
        assert evaluate("53522106920846801808219431931984825981463774466487130Å²") == 0
        assert evaluate("53522106920846801808219431931984825981463774466487128Å²") == 0
    end

    test "even numbers" do
        assert evaluate("5ÅÈ") == [0, 2, 4]
        assert evaluate("8ÅÈ") == [0, 2, 4, 6, 8]
    end

    test "odd numbers" do
        assert evaluate("5ÅÉ") == [1, 3, 5]
        assert evaluate("8ÅÉ") == [1, 3, 5, 7]
    end

    test "columns of" do
        assert evaluate("123S456S789S)ïÅ|") == [[1, 4, 7], [2, 5, 8], [3, 6, 9]]
        assert evaluate("123S456S78S)ïÅ|") == [[1, 4, 7], [2, 5, 8], [3, 6]]
        assert evaluate("∞3ôÅ|0è3£") == [1, 4, 7]
    end

    test "to roman numbers" do
        assert evaluate("36.X") == "XXXVI"
        assert evaluate("2012.X") == "MMXII"
        assert evaluate("1996.X") == "MCMXCVI"
    end

    test "from roman numbers" do
        assert evaluate("\"XXXVI\".v") == 36
        assert evaluate("\"MMXII\".v") == 2012
        assert evaluate("\"MCMXCVI\".v") == 1996
    end

    test "integer partitions" do
        assert evaluate("5Åœ") == [[1, 1, 1, 1, 1], [1, 1, 1, 2], [1, 1, 3], [1, 2, 2], [1, 4], [2, 3], [5]]
        assert evaluate("0Åœ") == [[]]
    end

    test "continue list" do
        assert evaluate("3L.Þ10£") == [1, 2, 3, 3, 3, 3, 3, 3, 3, 3]
        assert evaluate("123.Þ10£ï") == [1, 2, 3, 3, 3, 3, 3, 3, 3, 3]
    end

    test "next prime number" do
        assert evaluate("2ÅN") == 3
        assert evaluate("3ÅN") == 5
        assert evaluate("5ÅN") == 7
        assert evaluate("7ÅN") == 11
        assert evaluate("6.8ÅN") == 7
        assert evaluate("5(ÅN") == 2
    end

    test "prev prime number" do
        assert evaluate("19.5ÅM") == 19
        assert evaluate("5ÅM") == 3
        assert evaluate("3ÅM") == 2
    end
    
    test "nearest prime number" do
        assert evaluate("5Ån") == 5
        assert evaluate("6Ån") == 7
        assert evaluate("5.9Ån") == 5
    end

    test "run length encoding" do
        assert evaluate("112233223Åγ)") == [["1", "2", "3", "2", "3"], [2, 2, 2, 2, 1]]
        assert evaluate("112233223ïÅγ)") == [["1", "2", "3", "2", "3"], [2, 2, 2, 2, 1]]
        assert evaluate("112233223SÅγ)") == [["1", "2", "3", "2", "3"], [2, 2, 2, 2, 1]]
        assert evaluate("112233223SïÅγ)") == [[1, 2, 3, 2, 3], [2, 2, 2, 2, 1]]
    end

    test "retrieve web page" do
        with_mock HTTPoison, [get!: fn "https://codegolf.stackexchange.com/" -> %{:body => "<example body>"} end] do
            assert evaluate("\"https://codegolf.stackexchange.com/\".w") == "<example body>"
        end
    end

    test "deck shuffle" do
        assert evaluate("123456SïÅ=") == [1, 4, 2, 5, 3, 6]
        assert evaluate("1234567890SïÅ=") == [1, 6, 2, 7, 3, 8, 4, 9, 5, 0]
        assert evaluate("1234567SïÅ=") == [1, 5, 2, 6, 3, 7, 4]
        assert evaluate("123456Å=ï") == [1, 4, 2, 5, 3, 6]
        assert evaluate("1234567Å=ï") == [1, 5, 2, 6, 3, 7, 4]
    end

    test "deck unshuffle" do
        assert evaluate("142536SïÅ≠") == [1, 2, 3, 4, 5, 6]
        assert evaluate("1627384950SïÅ≠") == [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]
        assert evaluate("1526374SïÅ≠") == [1, 2, 3, 4, 5, 6, 7]
        assert evaluate("142536Å≠ï") == [1, 2, 3, 4, 5, 6]
        assert evaluate("1526374Å≠ï") == [1, 2, 3, 4, 5, 6, 7]
    end
end