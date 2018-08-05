defmodule ConstantsTest do
    use ExUnit.Case
    import TestHelper

    test "infinite pi stream" do
        assert evaluate("žs15£") == [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5, 8, 9, 7, 9]
    end
    
    test "infinite e stream" do
        assert evaluate("žt15£") == [2, 7, 1, 8, 2, 8, 1, 8, 2, 8, 4, 5, 9, 0, 4]
    end
end