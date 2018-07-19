defmodule Parsing.Parser do
    
    def parse(commands), do: parse_program(commands, [])

    defp parse_program([curr_command | remaining], parsed) do
        case curr_command do
            [:subprogram, op] ->
                {remaining, subcommands, _} = parse_subprogram(remaining)
                parse_program(remaining, parsed ++ [{:subprogram, op, subcommands}])
            [:no_op, _] -> parse_program(remaining, parsed)
            [:eof, _] -> parsed
            [op_type, op] -> parse_program(remaining, parsed ++ [{op_type, op}])
        end
    end
    
    defp parse_program([], parsed) do
        parsed
    end

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
                    :end -> parse_subprogram(remaining, parsed ++ [{:subprogram, op, subcommands}])
                end
            [:no_op, _] -> parse_subprogram(remaining, parsed)
            [op_type, op] -> parse_subprogram(remaining, parsed ++ [{op_type, op}])
        end
    end

    defp parse_subprogram([], parsed) do
        {[], parsed, :end_all}
    end
end