defmodule BinaryTest do
    use ExUnit.Case
    alias Reading.Reader
    alias Parsing.Parser
    alias Interp.Interpreter
    alias Interp.Stack
    alias Interp.Environment
    alias Interp.Functions

    def evaluate(code) do
        code = Parser.parse(Reader.read(code))
        {stack, environment} = Interpreter.interp(code, %Stack{}, %Environment{})
        {result, _, _} = Stack.pop(stack, environment)

        assert is_map(result) or is_number(result) or is_bitstring(result) or is_list(result)

        Functions.eval(result)
    end

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
        # assert evaluate("5L 3K") == [1, 2, 4, 5]
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
end