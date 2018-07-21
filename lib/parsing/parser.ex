defmodule Parsing.Parser do
    
    # -------------------
    # Normal code parsing
    # -------------------
    def parse(commands), do: parse_program(commands, [])

    defp parse_program([curr_command | remaining], parsed) do
        case curr_command do
            [:subprogram, op] ->
                {remaining, subcommands, _} = parse_subprogram(remaining)
                parse_program(remaining, parsed ++ [{:subprogram, op, subcommands}])
            [:subcommand, op] ->
                {new_remaining, subcommand} = parse_subcommand(remaining)
                parse_program(new_remaining, parsed ++ [{:subprogram, op, subcommand}])
            [:no_op, _] -> parse_program(remaining, parsed)
            [:eof, _] -> parsed
            [op_type, op] -> parse_program(remaining, parsed ++ [{op_type, op}])
        end
    end
    
    defp parse_program([], parsed) do
        parsed
    end

    # ------------------------------------------------------------
    # Sub program parsing (i.e. commands like 'F', 'G', 'v', etc.)
    # ------------------------------------------------------------
    defp parse_subprogram(commands), do: parse_subprogram(commands, [])
    defp parse_subprogram([curr_command | remaining], parsed) do
        case curr_command do
            [:end, _] -> {remaining, parsed, :end}
            [:end_all, _] -> {remaining, parsed, :end_all}
            [:eof, _] -> {remaining, parsed, :eof}
            [:subprogram, op] ->
                {remaining, subcommands, end_op} = parse_subprogram(remaining)
                case end_op do
                    :end_all -> {remaining, parsed ++ [{:subprogram, op, subcommands}], :end_all}
                    :eof -> {remaining, parsed ++ [{:subprogram, op, subcommands}], :end_all}
                    :end -> parse_subprogram(remaining, parsed ++ [{:subprogram, op, subcommands}])
                end
            [:subcommand, op] ->
                {new_remaining, subcommand} = parse_subcommand(remaining)
                parse_subprogram(new_remaining, parsed ++ [{:subprogram, op, subcommand}])
            [:no_op, _] -> parse_subprogram(remaining, parsed)
            [op_type, op] -> parse_subprogram(remaining, parsed ++ [{op_type, op}])
        end
    end

    defp parse_subprogram([], parsed) do
        {[], parsed, :end_all}
    end

    # ------------------------------------------------------------
    # Sub command parsing (i.e. commands like '€', 'ü', 'δ', etc.)
    # ------------------------------------------------------------
    defp parse_subcommand(commands), do: parse_subcommand(commands, [])
    defp parse_subcommand([curr_command | remaining], parsed) do
        case curr_command do
            [:end, _] -> {remaining, parsed}
            [:end_all, _] -> {remaining, parsed}
            [:eof, _] -> {remaining, parsed}
            [:subprogram, op] ->
                {new_remaining, subcommands, _} = parse_subprogram(remaining)
                {new_remaining, parsed ++ [{:subprogram, op, subcommands}]}
            [:subcommand, op] ->
                {new_remaining, subcommand} = parse_subcommand(remaining)
                {new_remaining, parsed ++ [{:subprogram, op, subcommand}]}
            [:no_op, _] -> parse_subcommand(remaining, parsed)
            [op_type, op] -> {remaining, parsed ++ [{op_type, op}]}
        end
    end
end