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
end