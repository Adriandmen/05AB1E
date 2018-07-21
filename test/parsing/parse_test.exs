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
            {:subprogram, "F", [
                number: "3", 
                number: "4", 
                binary_op: "+"
            ]},
            {:number, "4"}
        ]
    end

    test "parse subprogram within subprogram" do
        assert Parser.parse(Reader.read("5F3 4F 6F 8 7 -} 7 + } 2")) == [
            {:number, "5"},
            {:subprogram, "F", [
                {:number, "3"},
                {:number, "4"},
                {:subprogram, "F", [
                    {:number, "6"},
                    {:subprogram, "F", [
                        number: "8", 
                        number: "7", 
                        binary_op: "-"]},
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
            {:subprogram, "F", [
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
            {:subprogram, "F", [
                {:number, "3"},
                {:subprogram, "F", [
                    {:number, "2"},
                    {:subprogram, "F", [
                        number: "4", 
                        number: "6", 
                        binary_op: "+"
                    ]}
                ]}
            ]}
        ]
    end

    test "parse multiple subprograms with break" do
        assert Parser.parse(Reader.read("10FN2Q# 10FN N3Q#} 1ï})")) == [
            {:number, "10"},
            {:subprogram, "F", [
                {:nullary_op, "N"},
                {:number, "2"},
                {:binary_op, "Q"},
                {:special_op, "#"},
                {:number, "10"},
                {:subprogram, "F", [
                    nullary_op: "N",
                    nullary_op: "N",
                    number: "3",
                    binary_op: "Q",
                    special_op: "#"
                ]},
                {:number, "1"},
                {:unary_op, "ï"}
            ]},
            {:special_op, ")"}
        ]
    end

    test "parse normal subcommand" do
        assert Parser.parse(Reader.read("5L€>")) == [
            {:number, "5"},
            {:unary_op, "L"},
            {:subprogram, "€", [
                unary_op: ">"
            ]}
        ]
    end

    test "parse normal subcommand with subcommand" do
        assert Parser.parse(Reader.read("5LLLL€€€€D")) == [
            {:number, "5"},
            {:unary_op, "L"},
            {:unary_op, "L"},
            {:unary_op, "L"},
            {:unary_op, "L"},
            {:subprogram, "€", [
                {:subprogram, "€", [
                    {:subprogram, "€", [
                        {:subprogram, "€", [
                            unary_op: "D"
                        ]}
                    ]}
                ]}
            ]}
        ]
    end

    test "parse normal subcommand with subprogram" do
        assert Parser.parse(Reader.read("5L€FN>}5+")) == [
            {:number, "5"},
            {:unary_op, "L"},
            {:subprogram, "€", [
                {:subprogram, "F", [
                    nullary_op: "N", unary_op: ">"
                ]}
            ]},
            {:number, "5"},
            {:binary_op, "+"}
        ]
    end

    test "parse normal subprogram with subcommand" do
        assert Parser.parse(Reader.read("5F3L€D4+}2")) == [
            {:number, "5"},
            {:subprogram, "F", [
                {:number, "3"},
                {:unary_op, "L"},
                {:subprogram, "€", [
                    unary_op: "D"
                ]},
                {:number, "4"},
                {:binary_op, "+"}
            ]},
            {:number, "2"}
        ]
    end

    test "parse normal subcommand with subcommands and subprograms" do
        assert Parser.parse(Reader.read("5LLL€€vyD}5+")) == [
            {:number, "5"},
            {:unary_op, "L"},
            {:unary_op, "L"},
            {:unary_op, "L"},
            {:subprogram, "€", [
                {:subprogram, "€", [
                    {:subprogram, "v", [
                        nullary_op: "y", 
                        unary_op: "D"
                    ]}
                ]}
            ]},
            {:number, "5"},
            {:binary_op, "+"}
        ]
    end

    test "parse normal subcommand with subprogram without closing bracket" do
        assert Parser.parse(Reader.read("3L5LδF>")) == [
            {:number, "3"},
            {:unary_op, "L"},
            {:number, "5"},
            {:unary_op, "L"},
            {:subprogram, "δ", [
                {:subprogram, "F", [
                    unary_op: ">"
                ]}
            ]}
        ]
    end

    test "parse normal for each subprogram" do
        assert Parser.parse(Reader.read("12345vyï})")) == [
            {:number, "12345"},
            {:subprogram, "v", [
                nullary_op: "y", 
                unary_op: "ï"
            ]},
            {:special_op, ")"}
        ]
    end
end