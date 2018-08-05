defmodule TernaryTest do
    use ExUnit.Case
    import TestHelper

    test "three swap" do
        assert evaluate("1 2 3Š)") == ["3", "1", "2"]
    end

    test "transliterate" do
        assert evaluate("12345 23 78‡") == "17845"
        assert evaluate("12345 23S 78‡") == "17845"
        assert evaluate("12345 23 78S‡") == "17845"
        assert evaluate("12345 23S 78S‡") == "17845"
        assert evaluate("5L 23Sï 78Sï‡") == [1, 7, 8, 4, 5]
        assert evaluate("1 11 45‡") == "4"
        assert evaluate("10 20 30 40 50) ∞ ∞20+‡") == [30, 40, 50, 60, 70]
        assert evaluate("∞ ∞ ∞20+‡5£") == [21, 22, 23, 24, 25]
    end

    test "replace infinite" do
        assert evaluate("\"abc\" \"c\" \"d\":") == "abd"
        assert evaluate("\"abbbc\" \"bb\" \"b\":") == "abc"
        assert evaluate("1232 23S 4:") == "1444"
        assert evaluate("1232 23S 34S:") == "1444"
        assert evaluate("12 32) 2 3:ï") == [13, 33]
        assert evaluate("12 32) 2 3‚ 4 5‚:ï") == [14, 54]
    end

    test "replace at index" do
        assert evaluate("5L 10ï 2ǝ") == [1, 2, 10, 4, 5]
        assert evaluate("5L 10ï 23Sǝ") == [1, 2, 10, 10, 5]
        assert evaluate("10L \"80 90\"#ï 27Sǝ") == [1, 2, 80, 4, 5, 6, 7, 90, 9, 10]
        assert evaluate("∞ \"80 90\"#ï 27Sǝ 10£") == [1, 2, 80, 4, 5, 6, 7, 90, 9, 10]
        assert evaluate("5L 3L 2ǝ") == [1, 2, [1, 2, 3], 4, 5]
        assert evaluate("123456 \"x\" 2ǝ") == "12x456"
        assert evaluate("123456 \"x\" 23Sǝ") == "12xx56"
        assert evaluate("123456 \"xy\"S 23Sǝ") == "12xy56"
    end
end