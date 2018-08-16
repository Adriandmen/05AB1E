defmodule ReaderTest do
    use ExUnit.Case
    alias Reading.Reader
    alias Reading.CodePage

    import ExUnit.CaptureIO
    import TestHelper

    test "utf8 to osabie encoding" do
        assert CodePage.utf8_to_osabie("Γ") == 16
        assert CodePage.utf8_to_osabie("λ") == 173
        assert capture_io(:stderr, fn -> CodePage.utf8_to_osabie("物") end) == "Unrecognized byte value: 物\n"
    end

    test "osabie to utf8 encoding" do
        assert CodePage.osabie_to_utf8(16) == "Γ"
        assert CodePage.osabie_to_utf8(173) == "λ"
        assert capture_io(:stderr, fn -> CodePage.osabie_to_utf8(399) end) == "Invalid osabie byte found: 399\n"
    end

    test "read utf8 encoded file" do
        assert file_test(fn file -> File.write!(file, "5L€È3+"); Reader.read_file(file, :utf_8) end) == ["5", "L", "€", "È", "3", "+"]
    end

    test "read osabie encoded file" do
        assert file_test(fn file -> File.write!(file, <<53, 76, 128, 200, 51, 43>>); Reader.read_file(file, :osabie) end) == ["5", "L", "€", "È", "3", "+"]
    end

    test "read number from code" do
        assert Reader.read_step("123abc") == {:number, "123", "abc"}
    end

    test "read number from code with no remaining code" do
        assert Reader.read_step("123") == {:number, "123", ""}
    end

    test "read number from code with leading zeroes" do
        assert Reader.read_step("0123c") == {:number, "0123", "c"}
    end

    test "read decimal number" do
        assert Reader.read_step("1.2a") == {:number, "1.2", "a"}
    end

    test "read decimal number without leading number" do
        assert Reader.read_step(".2a") == {:number, ".2", "a"}
    end

    test "read decimal number with no remaining code" do
        assert Reader.read_step(".2") == {:number, ".2", ""}
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

    test "read normal string with newlines" do
        assert Reader.read_step("\"abc\ndef\"ghi") == {:string, "abc\ndef", "ghi"}
    end

    test "read normal with no remaining code" do
        assert Reader.read_step("\"abc\"") == {:string, "abc", ""}
    end

    test "read string without end delimiter" do
        assert Reader.read_step("\"abc") == {:string, "abc", ""}
    end

    test "read string with newlines without end delimiter" do
        assert Reader.read_step("\"abc\n") == {:string, "abc\n", ""}
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

    test "read compressed string upper" do
        assert Reader.read_step("‘Ÿ™,‚ï!‘") == {:string, "HELLO, WORLD!", ""}
    end

    test "read compressed string one compressed char" do
        assert Reader.read_step("‘Ÿ") == {:string, "Ÿ", ""}
    end

    test "read compressed string title" do
        assert Reader.read_step("”Ÿ™,‚ï!") == {:string, "Hello, World!", ""}
    end

    test "read compressed string title one compressed char" do
        assert Reader.read_step("”Ÿ") == {:string, "Ÿ", ""}
    end

    test "read compressed string normal" do
        assert Reader.read_step("“Ÿ™,‚ï!") == {:string, "hello, world!", ""}
    end

    test "read compressed string normal one compressed char" do
        assert Reader.read_step("“Ÿ") == {:string, "Ÿ", ""}
    end

    test "read compressed string no space" do
        assert Reader.read_step("’Ÿ™,‚ï!") == {:string, "hello,world!", ""}
    end

    test "read compressed string no space one compressed char" do
        assert Reader.read_step("’Ÿ") == {:string, "Ÿ", ""}
    end

    test "read normal 1 char string" do
        assert Reader.read_step("'a1") == {:string, "a", "1"}
    end

    test "read normal 2 char string" do
        assert Reader.read_step("„ab1") == {:string, "ab", "1"}
    end

    test "read normal 3 char string" do
        assert Reader.read_step("…abc1") == {:string, "abc", "1"}
    end

    test "read compressed 1 word string" do
        assert Reader.read_step("'Ÿ™1") == {:string, "hello", "1"}
    end

    test "read compressed 2 word string" do
        assert Reader.read_step("„Ÿ™‚ï1") == {:string, "hello world", "1"}
    end

    test "read compressed 3 word string" do
        assert Reader.read_step("…Ÿ™‚ïŸ™1") == {:string, "hello world hello", "1"}
    end
    
    test "read compressed char 1 char string" do
        assert Reader.read_step("'Ÿ1") == {:string, "Ÿ", "1"}
    end
    
    test "read 2 char string with one word and one char" do
        assert Reader.read_step("„Ÿ™12") == {:string, "hello1", "2"}
        assert Reader.read_step("„1Ÿ™2") == {:string, "1 hello", "2"}
    end
    
    test "read 2 char string with one compressed char and one char" do
        assert Reader.read_step("„1™2") == {:string, "1™", "2"}
    end
    
    test "read 3 char string with one word and two chars" do
        assert Reader.read_step("…Ÿ™abc") == {:string, "helloab", "c"}
    end
    
    test "read 3 char string with one word and one char and one compressed char" do
        assert Reader.read_step("…Ÿ™aŸc") == {:string, "helloaŸ", "c"}
    end

    test "read compressed number char" do
        assert Reader.read_step("Ƶ1abc") == {:number, 102, "abc"}
    end

    test "read compressed number char without remaining code" do
        assert Reader.read_step("Ƶa") == {:number, 137, ""}
    end

    test "read two-char compressed number" do
        assert Reader.read_step("Ž4çabc") == {:number, 1250, "abc"}
    end

    test "read two-char compressed number without remaining code" do
        assert Reader.read_step("Ž4ç") == {:number, 1250, ""}
    end

    test "read compressed alphabetic string" do
        assert Reader.read_step(".•Uÿ/õDÀтÂñ‚Δθñ8=öwÁβPb•") == {:string, "i want this string to be compressed", ""}
    end

    test "read compressed alphabetic string without end delimiter" do
        assert Reader.read_step(".•Uÿ/õDÀтÂñ‚Δθñ8=öwÁβPb") == {:string, "i want this string to be compressed", ""}
    end
end