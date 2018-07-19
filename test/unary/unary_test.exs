defmodule UnaryTest do
    use ExUnit.Case
    alias Reading.Reader
    alias Interp.Interpreter
    alias Interp.Stack
    alias Interp.Environment
    alias Interp.Functions

    def evaluate(code) do
        parsed_code = Reader.read(code)
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
        assert evaluate("3L 3L)O") == [6, 6]
        assert evaluate("3LL 3L)O") == [[1, 3, 6], 6]
        assert evaluate("1 2 3 4O") == 10
        # assert evaluate("∞∞£2£") == [1, 3, 6]
    end
end