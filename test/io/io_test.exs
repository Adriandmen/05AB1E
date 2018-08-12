defmodule IOTest do
    use ExUnit.Case
    alias Interp.Globals
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

    test "input number" do
        assert capture_io([input: "5"], fn -> evaluate("I3+?") end) == "8"
    end

    test "implicit input" do
        assert capture_io([input: "5"], fn -> evaluate("3+?") end) == "8"
    end

    test "input string" do
        assert capture_io([input: "abc"], fn -> evaluate("ID«?") end) == "abcabc"
    end

    test "input list" do
        assert capture_io([input: "[1, 2, 3]"], fn -> evaluate("5+?") end) == "[6, 7, 8]"
    end

    test "two inputs" do
        assert capture_io([input: "5\n6"], fn -> evaluate("+?") end) == "11"
    end

    test "binary with one input" do
        assert capture_io([input: "5"], fn -> evaluate("+?") end) == "10"
    end

    test "read until empty newline" do
        assert capture_io([input: "123\n456\n789\n\nabc"], fn -> evaluate("|?") end) == "[\"123\", \"456\", \"789\"]"
    end

    test "read until eof" do
        assert capture_io([input: "123\n456\n789"], fn -> evaluate("|?") end) == "[\"123\", \"456\", \"789\"]"
    end

    test "get nth unprompted input" do
        assert capture_io([input: "123\n456\n789"], fn -> evaluate("¹?") end) == "123"
        assert capture_io([input: "123\n456\n789"], fn -> evaluate("²?") end) == "456"
        assert capture_io([input: "123\n456\n789"], fn -> evaluate("³?") end) == "789"
        assert capture_io([input: "123\n456\n789"], fn -> evaluate("³¹²)ï?") end) == "[789, 123, 456]"
    end

    test "get nth prompted input" do
        assert capture_io([input: "123\n456\n789\nabc"], fn -> evaluate("IIIIð¹?") end) == "123"
        assert capture_io([input: "123\n456\n789\nabc"], fn -> evaluate("IIIIð²?") end) == "456"
        assert capture_io([input: "123\n456\n789\nabc"], fn -> evaluate("IIIIð³?") end) == "789"
    end

    test "get debugging output" do
        Globals.initialize()

        # Enabled debugging
        Globals.set(%{Globals.get | debug: %{:stack => false, :local_env => false, :global_env => false, :enabled => true, :test => false}})
        assert String.contains?(capture_io(fn -> evaluate("2 3+") end), "Current Command")

        # Enabled stack debugging
        Globals.set(%{Globals.get | debug: %{:stack => true, :local_env => false, :global_env => false, :enabled => true, :test => false}})
        assert String.contains?(capture_io(fn -> evaluate("2 3+") end), "Current Stack")

        # Enabled local environment debugging
        Globals.set(%{Globals.get | debug: %{:stack => true, :local_env => true, :global_env => false, :enabled => true, :test => false}})
        assert String.contains?(capture_io(fn -> evaluate("2FN") end), "Local Environment")

        # Enabled global environment debugging
        Globals.set(%{Globals.get | debug: %{:stack => true, :local_env => false, :global_env => true, :enabled => true, :test => false}})
        assert String.contains?(capture_io(fn -> evaluate("2©®+") end), "Global Environment")
    end
end