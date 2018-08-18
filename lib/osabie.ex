defmodule OsabieProgramArguments do
    @moduledoc """
    The argument module that keeps track of all necessary
    arguments that the interpreter will need while running.
    """
    defstruct path: "",
              debug: %{:stack => false, :local_env => false, :global_env => false, :enabled => false, :test => false},
              osabie_encoded: false,
              safe_mode: false,
              timer: false
end


defmodule Osabie.CLI do
    alias Reading.Reader
    alias Parsing.Parser
    alias Interp.Interpreter
    alias Interp.Stack
    alias Interp.Environment
    alias Interp.Functions
    alias Interp.Output
    alias Interp.Globals
    alias Interp.Canvas

    def arg_aliases, do: [
        d: :debug,
        s: :safe,
        c: :osabie,
        t: :time
    ]

    def arg_switches, do: [
        debug: :boolean,
        safe: :boolean,
        osabie: :boolean,
        time: :boolean,
        debug_stack: :boolean,
        debug_local_env: :boolean,
        debug_global_env: :boolean
    ]

    def main(args) do
        {parsed_args, file_name} = OptionParser.parse!(args, aliases: arg_aliases(), switches: arg_switches())
        parsed_args = normalize_args(parsed_args)
        
        encoding = if parsed_args.osabie_encoded do :osabie else :utf_8 end

        Globals.initialize()

        # Set the debug parameters to the global environment
        if parsed_args.debug.enabled do
            Globals.set(%{Globals.get() | debug: parsed_args.debug})            
        end

        # Run the code and retrieve the last element of the stack
        commands = Parser.parse(Reader.read(Enum.join(Reader.read_file(file_name, encoding), "")))
        {stack, environment} = Interpreter.interp(commands, %Stack{}, %Environment{})

        if Globals.get().canvas.canvas != %{} do
            Output.print(Canvas.canvas_to_string(Globals.get().canvas))
        end
        
        {last, _, _} = Stack.pop(stack, environment)
        case Globals.get().printed do
            true -> nil
            false -> Output.print(last)
        end
    end

    def normalize_args(args), do: normalize_args(args, %OsabieProgramArguments{})
    def normalize_args([], parsed), do: parsed
    def normalize_args([{key, _} | remaining], parsed) do
        case key do
            :debug -> normalize_args(remaining, %{parsed | debug: %{parsed.debug | enabled: true}})
            :safe -> normalize_args(remaining, %{parsed | safe_mode: true})
            :osabie -> normalize_args(remaining, %{parsed | osabie_encoded: true})
            :time -> normalize_args(remaining, %{parsed | timer: true})
            :debug_stack -> normalize_args(remaining, %{parsed | debug: %{parsed.debug | enabled: true, stack: true}})
            :debug_local_env -> normalize_args(remaining, %{parsed | debug: %{parsed.debug | enabled: true, local_env: true}})
            :debug_global_env -> normalize_args(remaining, %{parsed | debug: %{parsed.debug | enabled: true, global_env: true}})
        end
    end
end