defmodule Osabie do
    @moduledoc """
    Documentation for Osabie.
    """

    @doc """
    Hello world.

    ## Examples

        iex> Osabie.hello
        :world

    """
    def hello do
        :world
    end
end

defmodule OsabieProgramArguments do
    @moduledoc """
    The argument module that keeps track of all necessary
    arguments that the interpreter will need while running.
    """
    defstruct path: "",
              debug: %{:stack => false, :local_env => false, :global_env => false, :enabled => false},
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
            debug = Globals.get().debug
            Globals.set(%{Globals.get() | debug: parsed_args.debug})            
        end

        # Run the code and retrieve the last element of the stack
        commands = Parser.parse(Reader.read(Enum.join(Reader.read_file(file_name, encoding), "")))
        {stack, environment} = Interpreter.interp(commands, %Stack{}, %Environment{})
        {last, _, _} = Stack.pop(stack, environment)

        if Globals.get().canvas.canvas != %{} do
            Output.print(Canvas.canvas_to_string(Globals.get().canvas))
        end
        
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


    @doc """
    Parses the arguments and returns the resulting options/flags 
    that are retrieved from the command line arguments list.
    """
    def parse_args(arguments) do
        parse_args(arguments, %OsabieProgramArguments{})
    end
  
    defp parse_args(arguments, options) do

        case arguments do
            # When there are no arguments left to parse, return the resulting options.
            [] -> 
        
            # Make sure that the path has been set.
            if options.path === "" do
                IO.puts "Could not find the code path"
                :error
            else
                options
            end

            # Osabie encoding flag.
            [arg | remaining] when arg in ["-c", "--osabie"] ->
                parse_args(remaining, %{options | osabie_encoded: true})
      
            # Debug flag
            [arg | remaining] when arg in ["-d", "--debug"] ->
                parse_args(remaining, %{options | debug: %{options.debug | enabled: true}})
      
            # Debug show stack
            [arg | remaining] when arg in ["--debug-stack"] ->
                parse_args(remaining, %{options | debug: %{options.debug | enabled: true, stack: true}})
      
            # Debug show local environment
            [arg | remaining] when arg in ["--debug-local-env"] ->
                parse_args(remaining, %{options | debug: %{options.debug | enabled: true, local_env: true}})
      
            # Debug show global environment
            [arg | remaining] when arg in ["--debug-global-env"] ->
                parse_args(remaining, %{options | debug: %{options.debug | enabled: true, global_env: true}})
      
            # Safe mode flag
            [arg | remaining] when arg in ["-s", "--safe"] ->
                parse_args(remaining, %{options | safe_mode: true})
      
            # If anything else, assume that this is the file path
            [arg | remaining] ->
                parse_args(remaining, %{options | path: arg})
        end
    end
end