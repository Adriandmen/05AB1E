defmodule Interp.NullaryInterp do
    alias Interp.Stack
    alias Interp.Globals
    alias Commands.ListCommands
    alias Commands.IntCommands
    alias Commands.GeneralCommands
    alias Reading.CodePage
    
    def interp_step(op, stack, environment) do
        new_stack = case op do
            "∞" -> Stack.push(stack, ListCommands.listify(1, :infinity))
            "т" -> Stack.push(stack, 100)
            "₁" -> Stack.push(stack, if environment.recursive_environment == nil do 256 else GeneralCommands.recursive_program(environment.recursive_environment.subprogram, environment.recursive_environment.base_cases, environment.range_variable - 1) end)
            "₂" -> Stack.push(stack, if environment.recursive_environment == nil do 26 else GeneralCommands.recursive_program(environment.recursive_environment.subprogram, environment.recursive_environment.base_cases, environment.range_variable - 2) end)
            "₃" -> Stack.push(stack, if environment.recursive_environment == nil do 95 else GeneralCommands.recursive_program(environment.recursive_environment.subprogram, environment.recursive_environment.base_cases, environment.range_variable - 3) end)
            "₄" -> Stack.push(stack, if environment.recursive_environment == nil do 1000 else GeneralCommands.recursive_program(environment.recursive_environment.subprogram, environment.recursive_environment.base_cases, environment.range_variable - 4) end)
            "A" -> Stack.push(stack, "abcdefghijklmnopqrstuvwxyz")
            "T" -> Stack.push(stack, 10)
            "®" -> Stack.push(stack, Globals.get().c)
            "N" -> Stack.push(stack, environment.range_variable)
            "y" -> Stack.push(stack, environment.range_element)
            "X" -> Stack.push(stack, Globals.get().x)
            "Y" -> Stack.push(stack, Globals.get().y)
            "¾" -> Stack.push(stack, Globals.get().counter_variable)
            "¯" -> Stack.push(stack, Globals.get().array)
            "¶" -> Stack.push(stack, "\n")
            "õ" -> Stack.push(stack, "")
            "ð" -> Stack.push(stack, " ")
            "λ" -> Stack.push(stack, 0..(environment.range_variable - 1) |> Stream.map(fn x -> GeneralCommands.recursive_program(environment.recursive_environment.subprogram, environment.recursive_environment.base_cases, x) end))
            "´" -> Globals.set(%{Globals.get() | array: []}); stack
            "q" -> Globals.set(%{Globals.get() | status: :quit}); stack
            "¼" -> global_env = Globals.get(); Globals.set(%{global_env | counter_variable: global_env.counter_variable + 1}); stack
            ".Z" -> :timer.sleep(1000); stack
            "ža" -> {_, {hour, _, _}} = :calendar.local_time(); Stack.push(stack, hour)
            "žb" -> {_, {_, minute, _}} = :calendar.local_time(); Stack.push(stack, minute)
            "žc" -> {_, {_, _, second}} = :calendar.local_time(); Stack.push(stack, second)
            "žd" -> Stack.push(stack, div(rem(:os.system_time(), 100000000), 100))
            "že" -> {{_, _, day}, _} = :calendar.local_time(); Stack.push(stack, day)
            "žf" -> {{_, month, _}, _} = :calendar.local_time(); Stack.push(stack, month)
            "žg" -> {{year, _, _}, _} = :calendar.local_time(); Stack.push(stack, year)
            "žh" -> Stack.push(stack, "0123456789")
            "ži" -> Stack.push(stack, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
            "žj" -> Stack.push(stack, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_")
            "žk" -> Stack.push(stack, "zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA")
            "žl" -> Stack.push(stack, "zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA9876543210_")
            "žm" -> Stack.push(stack, "9876543210")
            "žn" -> Stack.push(stack, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
            "žo" -> Stack.push(stack, "ZYXWVUTSRQPONMLKJIHGFEDCBAzyxwvutsrqponmlkjihgfedcba")
            "žp" -> Stack.push(stack, "ZYXWVUTSRQPONMLKJIHGFEDCBA")
            "žq" -> Stack.push(stack, 3.141592653589793)
            "žr" -> Stack.push(stack, 2.718281828459045)
            "žs" -> Stack.push(stack, IntCommands.continued_fraction(fn x -> if x == 0 do 0 else 2 * x - 1 end end, fn y -> if y == 1 do 4 else IntCommands.pow(y - 1, 2) end end))
            "žt" -> Stack.push(stack, IntCommands.continued_fraction(fn x -> if x == 0 do 2 else 1 + x end end, fn y -> if y == 0 do 2 else y + 1 end end))
            "žu" -> Stack.push(stack, "()<>[]{}")
            "žv" -> Stack.push(stack, 16)
            "žw" -> Stack.push(stack, 32)
            "žx" -> Stack.push(stack, 64)
            "žy" -> Stack.push(stack, 128)
            "žz" -> Stack.push(stack, 256)
            "žA" -> Stack.push(stack, 512)
            "žB" -> Stack.push(stack, 1024)
            "žC" -> Stack.push(stack, 2048)
            "žD" -> Stack.push(stack, 4096)
            "žE" -> Stack.push(stack, 8192)
            "žF" -> Stack.push(stack, 16384)
            "žG" -> Stack.push(stack, 32768)
            "žH" -> Stack.push(stack, 65536)
            "žI" -> Stack.push(stack, 2147483648)
            "žJ" -> Stack.push(stack, 4294967296)
            "žK" -> Stack.push(stack, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
            "žL" -> Stack.push(stack, "zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA9876543210")
            "žM" -> Stack.push(stack, "aeiou")
            "žN" -> Stack.push(stack, "bcdfghjklmnpqrstvwxyz")
            "žO" -> Stack.push(stack, "aeiouy")
            "žP" -> Stack.push(stack, "bcdfghjklmnpqrstvwxz")
            "žQ" -> Stack.push(stack, " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~")
            "žR" -> Stack.push(stack, "ABC")
            "žS" -> Stack.push(stack, "qwertyuiop")
            "žT" -> Stack.push(stack, "asdfghjkl")
            "žU" -> Stack.push(stack, "zxcvbnm")
            "žV" -> Stack.push(stack, ["qwertyuiop", "asdfghjkl", "zxcvbnm"])
            "žW" -> Stack.push(stack, "qwertyuiopasdfghjklzxcvbnm")
            "žX" -> Stack.push(stack, "http://")
            "žY" -> Stack.push(stack, "https://")
            "žZ" -> Stack.push(stack, "http://www.")
            "žƵ" -> Stack.push(stack, "https://www.")
            "žÀ" -> Stack.push(stack, "aeiouAEIOU")
            "žÁ" -> Stack.push(stack, "aeiouyAEIOUY")
            "žĆ" -> Stack.push(stack, CodePage.code_page)
            ".À" -> %Stack{elements: ListCommands.rotate(stack.elements, -1) |> Enum.to_list}
            ".Á" -> %Stack{elements: ListCommands.rotate(stack.elements, 1) |> Enum.to_list}
            ".g" -> Stack.push(stack, GeneralCommands.length_of(stack.elements))
            ".µ" -> Globals.set(%{Globals.get() | counter_variable: 0}); stack
            ".¼" -> Globals.set(%{Globals.get() | counter_variable: Globals.get().counter_variable - 1}); stack
        end

        {new_stack, environment}
    end
end