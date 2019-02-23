defmodule OsabieTest do
    use ExUnit.Case
    alias Osabie.CLI

    import ExUnit.CaptureIO
    import TestHelper

    def run_osabie(code, args \\ []) do
        String.trim_trailing(capture_io(fn -> file_test(fn file -> File.write!(file, code); CLI.main([file | args]) end) end), "\n") |> String.split("\n")
    end

    test "run normal program" do
        assert run_osabie("5L") == ["[1, 2, 3, 4, 5]"]
    end

    test "run with debug" do
        assert run_osabie("5L", ["--debug"]) == [
            "----------------------------------",
            "",
            "Current Command: {:number, \"5\"}",
            "----------------------------------",
            "",
            "Current Command: {:unary_op, \"L\"}",
            "[1, 2, 3, 4, 5]"
        ]
    end

    test "run with already printed" do
        assert run_osabie("1,2") == ["1"]
    end

    test "run with canvas" do
        assert run_osabie("5 'a 3Λ") == [
            "a    ",
            " a   ",
            "  a  ",
            "   a ",
            "    a"
        ]
    end

    test "run with canvas on stack" do
        assert run_osabie("5 'a 3.Λ 11£") == [
            "a    ",
            " a   "
        ]
    end

    test "run without no-lazy option" do
        assert run_osabie("\"ab\"εXJDU}=,") == [
            "[\"a1\", \"ba1\"]",
            "[\"aba1\", \"baba1\"]"
        ]
    end

    test "run with lazy option" do
        assert run_osabie("\"ab\"εXJDU}=,", ["--no-lazy"]) == [
            "[\"a1\", \"ba1\"]",
            "[\"a1\", \"ba1\"]"
        ]
    end
end