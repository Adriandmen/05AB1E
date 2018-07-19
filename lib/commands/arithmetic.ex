defmodule Commands.Arithmetic do
    
    def add(a, b) do
        case {a, b} do
            {:infinity, :infinity} -> :infinity
            {:infinity, :min_infinity} -> 0
            {:min_infinity, :infinity} -> 0
            {:min_infinity, :min_infinity} -> :min_infinity
            {:infinity, _} -> :infinity
            {:min_infinity, _} -> :min_infinity
            {x, y} when y == :infinity or y == :min_infinity -> add(b, a)
            {x, y} -> x + y
        end
    end

    def mult(a, b) do
        case {a, b} do
            {:infinity, :infinity} -> :infinity
            {:min_infinity, :infinity} -> :min_infinity
            {:infinity, :min_infinity} -> :min_infinity
            {:min_infinity, :min_infinity} -> :infinity
            {:infinity, x} when x > 0 -> :infinity
            {:infinity, x} when x < 0 -> :min_infinity
            {:infinity, x} when x == 0 -> 0
            {:min_infinity, x} when x > 0 -> :min_infinity
            {:min_infinity, x} when x < 0 -> :infinity
            {:min_infinity, x} when x == 0 -> 0
            {x, y} when y == :infinity or y == :min_infinity -> mult(y, x)
            {x, y} -> x * y
        end
    end

    def absolute(a) do
        case a do
            :infinity -> :infinity
            :min_infinity -> :min_infinity
            
        end
    end

    # def eq(a, b) do
        
    # end
end