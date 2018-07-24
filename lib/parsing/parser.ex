defmodule Parsing.Parser do
    
    # -------------------
    # Normal code parsing
    # -------------------
    def parse(commands), do: parse_program(commands, [])
    defp parse_program([], parsed), do: parsed
    defp parse_program([curr_command | remaining], parsed) do
        case curr_command do
            [:subprogram, op] ->
                {new_remaining, subcommands, _} = parse_subprogram(remaining)
                parse_program(new_remaining, parsed ++ [{:subprogram, op, subcommands}])
            [:subcommand, op] ->
                {new_remaining, subcommand, _} = parse_subcommand(remaining)
                parse_program(new_remaining, parsed ++ [{:subprogram, op, subcommand}])
            [:if_statement, op] ->
                {new_remaining, if_statement, else_statement, _} = parse_if_statement(remaining)
                parse_program(new_remaining, parsed ++ [{:if_statement, if_statement, else_statement}])
            [:no_op, _] -> parse_program(remaining, parsed)
            [:eof, _] -> parsed
            [op_type, op] -> parse_program(remaining, parsed ++ [{op_type, op}])
        end
    end

    # -------------------------
    # If/else statement parsing
    # -------------------------
    defp parse_if_statement(commands), do: parse_if_statement(commands, [], [])
    defp parse_if_statement([], if_statement, else_statement), do: {[], if_statement, else_statement, :eof}
    defp parse_if_statement([curr_command | remaining], if_statement, else_statement) do
        case curr_command do
            [:end, _] -> {remaining, if_statement, else_statement, :end}
            [:end_all, _] -> {remaining, if_statement, else_statement, :end_all}
            [:eof, _] -> {remaining, if_statement, else_statement, :eof}
            [:else_statement, _] -> parse_else_statement(remaining, if_statement, [])
            [:subprogram, op] ->
                {new_remaining, subcommands, end_op} = parse_subprogram(remaining)
                case end_op do
                    :end -> parse_if_statement(new_remaining, if_statement ++ [{:subprogram, op, subcommands}], else_statement)
                    :else_statement -> parse_else_statement(new_remaining, if_statement ++ [{:subprogram, op, subcommands}], else_statement)
                    x -> {new_remaining, if_statement ++ [{:subprogram, op, subcommands}], else_statement, x}
                end
            [:subcommand, op] ->
                {new_remaining, subcommand, end_op} = parse_subcommand(remaining)
                case end_op do
                    :end -> parse_if_statement(new_remaining, if_statement ++ [{:subprogram, op, subcommand}], else_statement)
                    :else_statement -> parse_else_statement(new_remaining, if_statement ++ [{:subprogram, op, subcommand}], else_statement)
                    x -> {new_remaining, if_statement ++ [{:subprogram, op, subcommand}], else_statement, x}
                end
            [:if_statement, _] ->
                {new_remaining, inner_if, inner_else, end_op} = parse_if_statement(remaining)
                case end_op do
                    :end -> parse_if_statement(new_remaining, if_statement ++ [{:if_statement, inner_if, inner_else}], else_statement)
                    :else_statement -> parse_else_statement(new_remaining, if_statement ++ [{:if_statement, inner_if, inner_else}], else_statement)
                    x -> {new_remaining, if_statement ++ [{:if_statement, inner_if, inner_else}], else_statement, x}
                end
            [:no_op, _] -> parse_if_statement(remaining, if_statement, else_statement)
            [op_type, op] -> parse_if_statement(remaining, if_statement ++ [{op_type, op}], else_statement)
        end
    end

    defp parse_else_statement([], if_statement, else_statement), do: {[], if_statement, else_statement, :eof}
    defp parse_else_statement([curr_command | remaining], if_statement, else_statement) do
        case curr_command do
            [:end, _] -> {remaining, if_statement, else_statement, :end}
            [:end_all, _] -> {remaining, if_statement, else_statement, :end_all}
            [:eof, _] -> {remaining, if_statement, else_statement, :eof}
            [:else_statement, _] -> {remaining, if_statement, else_statement, :else_statement}
            [:subprogram, op] ->
                {new_remaining, subcommands, end_op} = parse_subprogram(remaining)
                case end_op do
                    :end -> parse_else_statement(new_remaining, if_statement, else_statement ++ [{:subprogram, op, subcommands}])
                    x -> {new_remaining, if_statement, else_statement ++ [{:subprogram, op, subcommands}], x}
                end
            [:subcommand, op] ->
                {new_remaining, subcommand, end_op} = parse_subcommand(remaining)
                case end_op do
                    :end -> parse_else_statement(new_remaining, if_statement, else_statement ++ [{:subprogram, op, subcommand}])
                    x -> {new_remaining, if_statement, else_statement ++ [{:subprogram, op, subcommand}], x}
                end
            [:if_statement, op] ->
                {new_remaining, inner_if, inner_else, end_op} = parse_if_statement(remaining)
                case end_op do
                    :end -> parse_else_statement(new_remaining, if_statement, else_statement ++ [{:if_statement, inner_if, inner_else}])
                    x -> {new_remaining, if_statement, else_statement ++ [{:if_statement, inner_if, inner_else}], x}
                end
            [:no_op, _] -> parse_else_statement(remaining, if_statement, else_statement)
            [op_type, op] -> parse_else_statement(remaining, if_statement, else_statement ++ [{op_type, op}])
        end
    end

    # ------------------------------------------------------------
    # Sub program parsing (i.e. commands like 'F', 'G', 'v', etc.)
    # ------------------------------------------------------------
    defp parse_subprogram(commands), do: parse_subprogram(commands, [])
    defp parse_subprogram([], parsed), do: {[], parsed, :eof}
    defp parse_subprogram([curr_command | remaining], parsed) do
        case curr_command do
            [:end, _] -> {remaining, parsed, :end}
            [:end_all, _] -> {remaining, parsed, :end_all}
            [:eof, _] -> {remaining, parsed, :eof}
            [:else_statement, _] -> {remaining, parsed, :else_statement}
            [:subprogram, op] ->
                {new_remaining, subcommands, end_op} = parse_subprogram(remaining)
                case end_op do
                    :end -> parse_subprogram(new_remaining, parsed ++ [{:subprogram, op, subcommands}])
                    x -> {new_remaining, parsed ++ [{:subprogram, op, subcommands}], x}
                end
            [:subcommand, op] ->
                {new_remaining, subcommand, end_op} = parse_subcommand(remaining)
                case end_op do
                    :end -> parse_subprogram(new_remaining, parsed ++ [{:subprogram, op, subcommand}])
                    x -> {new_remaining, parsed ++ [{:subprogram, op, subcommand}], x}
                end
            [:if_statement, op] ->
                {new_remaining, inner_if, inner_else, end_op} = parse_if_statement(remaining)
                case end_op do
                    :end -> parse_subprogram(new_remaining, parsed ++ [{:if_statement, inner_if, inner_else}])
                    x -> {new_remaining, parsed ++ [{:if_statement, inner_if, inner_else}], x}
                end
            [:no_op, _] -> parse_subprogram(remaining, parsed)
            [op_type, op] -> parse_subprogram(remaining, parsed ++ [{op_type, op}])
        end
    end

    # ------------------------------------------------------------
    # Sub command parsing (i.e. commands like '€', 'ü', 'δ', etc.)
    # ------------------------------------------------------------
    defp parse_subcommand(commands), do: parse_subcommand(commands, [])
    defp parse_subcommand([curr_command | remaining], parsed) do
        case curr_command do
            [:end, _] -> {remaining, parsed, :end}
            [:end_all, _] -> {remaining, parsed, :end_all}
            [:eof, _] -> {remaining, parsed, :end_all}
            [:subprogram, op] ->
                {new_remaining, subcommands, end_op} = parse_subprogram(remaining)
                {new_remaining, parsed ++ [{:subprogram, op, subcommands}], end_op}
            [:subcommand, op] ->
                {new_remaining, subcommand, end_op} = parse_subcommand(remaining)
                {new_remaining, parsed ++ [{:subprogram, op, subcommand}], end_op}
            [:no_op, _] -> parse_subcommand(remaining, parsed)
            [op_type, op] -> {remaining, parsed ++ [{op_type, op}], :end}
        end
    end
end