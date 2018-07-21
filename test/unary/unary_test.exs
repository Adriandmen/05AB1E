defmodule UnaryTest do
    use ExUnit.Case
    alias Reading.Reader
    alias Parsing.Parser
    alias Interp.Interpreter
    alias Interp.Stack
    alias Interp.Environment
    alias Interp.Functions

    def evaluate(code) do
        parsed_code = Parser.parse(Reader.read(code))
        {stack, environment} = Interpreter.interp(parsed_code, %Stack{}, %Environment{})
        {result, _, _} = Stack.pop(stack, environment)

        assert is_map(result) or is_number(result) or is_bitstring(result) or is_list(result)

        Functions.eval(result)
    end

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
    end

    test "lift" do
        assert evaluate("3Lƶ") == [1, 4, 9]
        assert evaluate("123ƶ") == [1, 4, 9]
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
        assert evaluate("\"aBc\"š") == "AbC"
        assert evaluate("\"aBc Def 123\"š") == "AbC dEF 123"
        assert evaluate("\"aBc Def\" \"a12\")š") == ["AbC dEF", "A12"]
    end

    test "deep flatten" do
        assert evaluate("1 2 3 4)ï˜") == [1, 2, 3, 4]
        assert evaluate("1 2 3 4))ï˜") == [1, 2, 3, 4]
        assert evaluate("3LLL˜") == [1, 1, 1, 2, 1, 1, 2, 1, 2, 3]
    end

    test "sentence case" do
        assert evaluate("\"abc\"ª") == "Abc"
        assert evaluate("\"abc. def? ghi! jkl mnop.\"ª") == "Abc. Def? Ghi! Jkl mnop."
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
        assert evaluate("11223344γ") == ["11", "22", "33", "44"]
        assert evaluate("11223344Sïγ") == [[1, 1], [2, 2], [3, 3], [4, 4]]
        assert evaluate("∞€Dγ4£") == [[1, 1], [2, 2], [3, 3], [4, 4]]
    end
end