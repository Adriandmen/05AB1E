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
            debug: false,
            osabie_encoded: false,
            safe_mode: false
end


defmodule Osabie.CLI do
  alias Reading.Reader
  alias Interp.Interpreter
  alias Interp.Stack
  alias Interp.Environment
  alias Interp.Functions

  def main(args) do
    arguments = parse_args(args)
    encoding = if arguments.osabie_encoded do :osabie else :utf_8 end
    commands = Reader.read(Enum.join(Reader.read_file(arguments.path, encoding), ""))
    {stack, environment} = Interpreter.interp(commands, %Stack{}, %Environment{})
    {last, stack, environment} = Stack.pop(stack, environment)

    last = Functions.eval(last)
    cond do
      is_map(last) or is_list(last) -> IO.inspect last, charlists: false
      true -> IO.puts last
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
        parse_args(remaining, %{options | debug: true})
      
      # Safe mode flag
      [arg | remaining] when arg in ["-s", "--safe"] ->
        parse_args(remaining, %{options | safe_mode: true})
      
      # If anything else, assume that this is the file path
      [arg | remaining] ->
        parse_args(remaining, %{options | path: arg})
    end
  end
end