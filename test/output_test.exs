defmodule OutputTest do
    use ExUnit.Case
    import ExUnit.CaptureIO
    import TestHelper

    test "print with a newline" do
        assert capture_io(fn -> evaluate("123,") end) == "123\n"
    end

    test "print without a newline" do
        assert capture_io(fn -> evaluate("123?") end) == "123"
    end

    test "print list" do
        assert capture_io(fn -> evaluate("3L,") end) == "[1, 2, 3]\n"
        assert capture_io(fn -> evaluate("3LL,") end) == "[[1], [1, 2], [1, 2, 3]]\n"
    end

    test "print string inside of list" do
        assert capture_io(fn -> evaluate("\"a\" \"bc\" \"def\"),") end) == "[\"a\", \"bc\", \"def\"]\n"
    end

    test "print with popping" do
        assert capture_io(fn -> evaluate("123ï 456ï,),") end) == "456\n[123]\n"
    end
    
    test "print without popping" do
        assert capture_io(fn -> evaluate("123ï 456ï=),") end) == "456\n[123, 456]\n"
    end

    test "print N when truthy" do
        assert capture_io(fn -> evaluate("7FNÈ–") end) == "0\n2\n4\n6\n"
    end

    test "print y when truthy" do
        assert capture_io(fn -> evaluate("7LvyÈ—") end) == "2\n4\n6\n"
    end
end