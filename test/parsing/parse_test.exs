defmodule ParserTest do
    use ExUnit.Case
    alias Parsing.Parser
    alias Reading.Reader

    test "parse normal set of commands" do
        assert Parser.parse(Reader.read("123 5")) == [{:number, "123"}, {:number, "5"}]
    end

    test "parse subprogram" do
        assert Parser.parse(Reader.read("5F3 4+}4")) == [
            {:number, "5"},
            {:subprogram, "F", [number: "3", number: "4", binary_op: "+"]},
            {:number, "4"}
          ]
    end

    test "parse subprogram within subprogram" do
        assert Parser.parse(Reader.read("5F3 4F 6F 8 7 -} 7 + } 2")) == [
            {:number, "5"},
            {:subprogram, "F",
             [
               {:number, "3"},
               {:number, "4"},
               {:subprogram, "F",
                [
                  {:number, "6"},
                  {:subprogram, "F",
                   [number: "8", number: "7", binary_op: "-"]},
                  {:number, "7"},
                  {:binary_op, "+"}
                ]},
               {:number, "2"},
             ]}
          ]
    end

    test "parse subprograms next to each other" do
        assert Parser.parse(Reader.read("5F 3 4F 2}F 7}")) == [
            {:number, "5"},
            {:subprogram, "F",
             [
               {:number, "3"},
               {:number, "4"},
               {:subprogram, "F", [number: "2"]},
               {:subprogram, "F", [number: "7"]}
             ]}
          ]
    end

    test "parse subprogram with infinite end bracket" do
        assert Parser.parse(Reader.read("5 F 3 F 2 F 4 6 +]")) == [
            {:number, "5"},
            {:subprogram, "F",
             [
               {:number, "3"},
               {:subprogram, "F",
                [
                  {:number, "2"},
                  {:subprogram, "F",
                   [number: "4", number: "6", binary_op: "+"]}
                ]}
             ]}
          ]
    end
end