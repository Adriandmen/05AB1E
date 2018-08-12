defmodule ConstantsTest do
    use ExUnit.Case
    import TestHelper

    test "infinite pi stream" do
        assert evaluate("žs15£") == [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5, 8, 9, 7, 9]
    end
    
    test "infinite e stream" do
        assert evaluate("žt15£") == [2, 7, 1, 8, 2, 8, 1, 8, 2, 8, 4, 5, 9, 0, 4]
    end

    test "regular constants" do
        assert evaluate("т") == 100
        assert evaluate("A") == "abcdefghijklmnopqrstuvwxyz"
        assert evaluate("T") == 10
        assert evaluate("¶") == "\n"
        assert evaluate("õ") == ""
        assert evaluate("ð") == " "
        assert evaluate("žh") == "0123456789"
        assert evaluate("ži") == "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        assert evaluate("žj") == "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
        assert evaluate("žk") == "zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA"
        assert evaluate("žl") == "zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA9876543210_"
        assert evaluate("žm") == "9876543210"
        assert evaluate("žn") == "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        assert evaluate("žo") == "ZYXWVUTSRQPONMLKJIHGFEDCBAzyxwvutsrqponmlkjihgfedcba"
        assert evaluate("žp") == "ZYXWVUTSRQPONMLKJIHGFEDCBA"
        assert evaluate("žq") == 3.141592653589793
        assert evaluate("žr") == 2.718281828459045
        assert evaluate("žu") == "()<>[]{}"
        assert evaluate("žv") == 16
        assert evaluate("žw") == 32
        assert evaluate("žx") == 64
        assert evaluate("žy") == 128
        assert evaluate("žz") == 256
        assert evaluate("žA") == 512
        assert evaluate("žB") == 1024
        assert evaluate("žC") == 2048
        assert evaluate("žD") == 4096
        assert evaluate("žE") == 8192
        assert evaluate("žF") == 16384
        assert evaluate("žG") == 32768
        assert evaluate("žH") == 65536
        assert evaluate("žI") == 2147483648
        assert evaluate("žJ") == 4294967296
        assert evaluate("žK") == "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        assert evaluate("žL") == "zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA9876543210"
        assert evaluate("žM") == "aeiou"
        assert evaluate("žN") == "bcdfghjklmnpqrstvwxyz"
        assert evaluate("žO") == "aeiouy"
        assert evaluate("žP") == "bcdfghjklmnpqrstvwxz"
        assert evaluate("žQ") == " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
        assert evaluate("žR") == "ABC"
        assert evaluate("žS") == "qwertyuiop"
        assert evaluate("žT") == "asdfghjkl"
        assert evaluate("žU") == "zxcvbnm"
        assert evaluate("žV") == ["qwertyuiop", "asdfghjkl", "zxcvbnm"]
        assert evaluate("žW") == "qwertyuiopasdfghjklzxcvbnm"
    end

    test "time based constants" do
        {{year, month, day}, {hour, minute, second}} = :calendar.local_time()
        assert evaluate("ža") == hour
        assert evaluate("žb") == minute
        assert evaluate("žc") == second
        assert evaluate("že") == day
        assert evaluate("žf") == month
        assert evaluate("žg") == year

        curr_milliseconds = div(rem(:os.system_time(), 100000000), 100)
        assert_in_delta evaluate("žd"), curr_milliseconds, 100
    end
end