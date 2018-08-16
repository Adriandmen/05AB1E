defmodule ArgParseTest do
    use ExUnit.Case
    alias Osabie.CLI
    alias OsabieProgramArguments

    def debug_params, do: %{:stack => false, :local_env => false, :global_env => false, :enabled => false, :test => false}

    test "normalize arguments" do
        assert CLI.normalize_args([{:debug, nil}]) == %OsabieProgramArguments{debug: %{debug_params() | enabled: true}}
        assert CLI.normalize_args([{:safe, nil}]) == %OsabieProgramArguments{safe_mode: true}
        assert CLI.normalize_args([{:osabie, nil}]) == %OsabieProgramArguments{osabie_encoded: true}
        assert CLI.normalize_args([{:time, nil}]) == %OsabieProgramArguments{timer: true}
        assert CLI.normalize_args([{:debug_stack, nil}]) == %OsabieProgramArguments{debug: %{debug_params() | enabled: true, stack: true}}
        assert CLI.normalize_args([{:debug_local_env, nil}]) == %OsabieProgramArguments{debug: %{debug_params() | enabled: true, local_env: true}}
        assert CLI.normalize_args([{:debug_global_env, nil}]) == %OsabieProgramArguments{debug: %{debug_params() | enabled: true, global_env: true}}
        assert CLI.normalize_args([{:debug_global_env, nil}, {:safe, nil}]) == %OsabieProgramArguments{safe_mode: true, debug: %{debug_params() | enabled: true, global_env: true}}
    end
end