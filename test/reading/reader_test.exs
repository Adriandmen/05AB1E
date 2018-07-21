defmodule ReaderTest do
    use ExUnit.Case
    alias Reading.Reader

    test "read number from code" do
        assert Reader.read_step("123abc") == {:number, "123", "abc"}
    end

    test "read number from code with no remaining code" do
        assert Reader.read_step("123") == {:number, "123", ""}
    end

    test "read number from code with leading zeroes" do
        assert Reader.read_step("0123c") == {:number, "0123", "c"}
    end

    test "read nullary function" do
        assert Reader.read_step("∞abc") == {:nullary_op, "∞", "abc"}
    end

    test "read nullary function with no remaining code" do
        assert Reader.read_step("∞") == {:nullary_op, "∞", ""}
    end

    test "read unary function" do
        assert Reader.read_step(">abc") == {:unary_op, ">", "abc"}
    end

    test "read unary function with no remaining code" do
        assert Reader.read_step(">") == {:unary_op, ">", ""}
    end

    test "read binary function" do
        assert Reader.read_step("+abc") == {:binary_op, "+", "abc"}
    end

    test "read binary function with no remaining code" do
        assert Reader.read_step("+") == {:binary_op, "+", ""}
    end

    test "read normal string" do
        assert Reader.read_step("\"abc\"def") == {:string, "abc", "def"}
    end

    test "read normal with no remaining code" do
        assert Reader.read_step("\"abc\"") == {:string, "abc", ""}
    end

    test "read string without end delimiter" do
        assert Reader.read_step("\"abc") == {:string, "abc", ""}
    end

    test "read end of file" do
        assert Reader.read_step("") == {:eof, nil, nil}
    end

    test "read compressed number" do
        assert Reader.read_step("•1æa•") == {:number, 123456, ""}
    end

    test "read compressed number without end delimiter" do
        assert Reader.read_step("•1æa") == {:number, 123456, ""}
    end

    test "read empty compressed number" do
        assert Reader.read_step("••") == {:number, 0, ""}
    end
end