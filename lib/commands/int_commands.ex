defmodule Commands.IntCommands do

    use Memoize
    alias Interp.Functions
    alias Commands.GeneralCommands
    require Interp.Functions

    # All characters available from the 05AB1E code page, where the
    # alphanumeric digits come first and the remaining characters
    # ranging from 0x00 to 0xff that do not occur yet in the list are appended.
    def digits, do: digits = String.to_charlist(
                             "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmno" <>
                             "pqrstuvwxyzǝʒαβγδεζηθвимнт\nΓΔΘιΣΩ≠∊∍∞₁₂₃₄₅₆ !\"#$%" <>
                             "&'()*+,-./:;<=>?@[\\]^_`{|}~Ƶ€Λ‚ƒ„…†‡ˆ‰Š‹ŒĆŽƶĀ‘’“”–" <>
                             "—˜™š›œćžŸā¡¢£¤¥¦§¨©ª«¬λ®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉ" <>
                             "ÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ")
    
    @doc """
    TODO: negative numbers and decimal.

    Computes the factorial of the given number.

    ## Parameters

     - value: The value from which the factorial will be calculated
    
    ## Returns

    The factorial of the given number.
    """
    def factorial(0), do: 1
    def factorial(value), do: factorial(value, 1)
    defp factorial(1, acc), do: acc
    defp factorial(value, acc), do: factorial(value - 1, acc * value)

    @doc """
    Power function that also works for negative numbers and decimal numbers.

    ## Parameters

     - n: The number that will be raised to the power k
     - k: The exponent of the power function.

    ## Returns

    The result of n ** k.
    """
    def pow(n, k) do
        cond do
            k < 0 -> 1 / pow(n, -k, 1)
            true -> pow(n, k, 1)
        end 
    end
    defp pow(_, 0, acc), do: acc
    defp pow(n, k, acc) when k > 0 and k < 1, do: acc * :math.pow(n, k)
    defp pow(n, k, acc), do: pow(n, k - 1, n * acc)

    # Modulo operator:
    @doc """
    Modulo operator, which also works for negative and decimal numbers.
    Using the following set of rules, we are able to include these numbers:

       -x.(f|i) % -y.(f|i)     -->  -(x.(f|i) % y.(f|i))
       -x.f % y.f              -->  (y.f - (x.f % y.f)) % y.f
       x.f % -y.f              -->  -(-x.f % y.f)
       x.(f|i) % y.(f|i)       -->  ((x / y) % 1) * y.(f|i)
       -x.i % -y.i             -->  -(x.i % y.i) 
       -x.i % y.i              -->  (y.i - (x.i % y.i)) % y.i 
       x.i % -y.i              -->  -(-x.i % y.i)
       x.i % y.i               -->  rem(x.i, y.i)

    ## Parameters

     - dividend:    The dividend of the modulo function.
     - divisor:     The divisor of the modulo function.

    ## Returns

    Returns the result of dividend % divisor.
    """
    def mod(dividend, divisor) when dividend < 0 and divisor < 0, do: -mod(-dividend, -divisor)
    def mod(dividend, divisor) when is_float(divisor) do
        cond do
            dividend < 0 and divisor > 0 ->
                case mod(-dividend, divisor) do
                    0 -> 0
                    x -> divisor - x
                end
            dividend > 0 and divisor < 0 -> -mod(-dividend, -divisor)
            true -> mod(dividend / divisor, 1) * divisor
        end
    end
    def mod(dividend, divisor) when is_float(dividend) and is_integer(divisor) do
        int_part = trunc(dividend)
        float_part = dividend - int_part
        mod(int_part, divisor) + float_part
    end
    def mod(dividend, divisor) when is_integer(dividend) and is_integer(divisor) do
        cond do
            dividend < 0 and divisor > 0 ->
                case mod(-dividend, divisor) do
                    0 -> 0
                    x -> divisor - x
                end
            dividend > 0 and divisor < 0 -> -mod(-dividend, -divisor)
            true -> rem(dividend, divisor)
        end
    end

    @doc """
    Integer division method that uses integer division when applicable or else the
    trunc-function in order to floor the result.
    """
    def divide(dividend, divisor) when is_float(dividend) or is_float(divisor), do: trunc(dividend / divisor)
    def divide(dividend, divisor), do: div(dividend, divisor)

    @doc """
    Converts the given number to the given base and returns it as a string using the characters
    from the 05AB1E code page, except for '•', which is used to decompress base-255 strings.
    """
    def to_base(value, base) do
        Integer.digits(value, base) |> Enum.map(fn x -> Enum.at(digits(), x) end) |> List.to_string
    end

    @doc """
    Converts the given number as a number from the given base and converts it to decimal.
    """
    def string_from_base(value, base) do
        list = to_charlist(value) |> Enum.map(fn x -> Enum.find_index(digits(), fn y -> x == y end) end)
        list_from_base(list, base)
    end

    def list_from_base(value, base) do
        value = Enum.to_list(value)
        {result, _} = Enum.reduce(value, {0, length(value) - 1}, fn (x, {acc, index}) -> {acc + pow(base, index) * x, index - 1} end)
        result
    end

    def to_base_arbitrary(value, base) when base > 0, do: Integer.digits(value, base)
    def to_base_arbitrary(value, base) when base < 0, do: to_negative_base_arbitrary(value, base, [])
    defp to_negative_base_arbitrary(0, _, acc), do: acc
    defp to_negative_base_arbitrary(value, base, acc) do
        remainder = rem(value, base)
        cond do
            remainder >= 0 -> to_negative_base_arbitrary(div(value, base), base, [remainder | acc])

            # If the remainder is negative, we subtract the base from the remainder, resulting in a positive remainder.
            # Since we are subtracting the base from the remainder, we must also add 1 to the divided result.
            remainder < 0 -> to_negative_base_arbitrary(div(value, base) + 1, base, [(remainder - base) | acc])
        end    
    end 

    @doc """
    Checks whether the given number is a prime number.
    """
    def is_prime?(value) when value in [2, 3, 5, 7], do: true
    def is_prime?(value) when value < 2 or rem(value, 2) == 0 or rem(value, 3) == 0, do: false
    def is_prime?(value), do: is_prime?(value, :math.sqrt(value) |> Float.floor |> round, 5)
    def is_prime?(value, current_prime, upper_bound) when current_prime > upper_bound, do: true
    def is_prime?(value, current_prime, upper_bound) do
        cond do
            rem(value, current_prime) == 0 -> false
            rem(value, current_prime + 2) == 0 -> false
            true -> is_prime?(value, current_prime + 6, upper_bound)
        end
    end

    @doc """
    Computes the next prime from the given value.
    """
    def next_prime(2), do: 3
    def next_prime(value) when value < 2, do: 2
    def next_prime(value) do
        next = value + 2
        cond do
            is_prime?(next) -> next
            true -> next_prime(value + 2)
        end
    end

    @doc """
    Retrieves the index of the nearest prime number to the given value that is smaller than
    the given value. The returned index is 0-indexed. 
    """
    def get_prime_index(value) when value < 2, do: -1
    def get_prime_index(value), do: get_prime_index(value, 2, 0)
    def get_prime_index(value, current_prime, index) when value < current_prime, do: index - 1
    def get_prime_index(value, current_prime, index) when value == current_prime, do: index
    def get_prime_index(value, current_prime, index), do: get_prime_index(value, next_prime(current_prime), index + 1)

    @doc """
    Computes the prime factorization of the given value as a list of
    prime factors with duplicates. Example, 60 → [2, 2, 3, 5]
    """
    def prime_factors(value), do: prime_factors(value, [], 2)
    def prime_factors(value, acc, _) when value < 2, do: Enum.reverse acc
    def prime_factors(value, acc, index) when rem(value, index) == 0, do: prime_factors(div(value, index), [index | acc], index)
    def prime_factors(value, acc, index), do: prime_factors(value, acc, next_prime(index))

    @doc """
    Computes the prime exponents of the given value as a list of exponents.
    For example, given the factorization of n, which equals [2 ** a, 3 ** b, 5 ** c, 7 ** d, ...],
    this method returns the list [a, b, c, d, ...] with trailing zeroes removed.
    """
    def prime_exponents(value), do: prime_exponents(value, [], 2, 0)
    def prime_exponents(value, acc, _, 0) when value < 2, do: Enum.reverse acc
    def prime_exponents(value, acc, _, count) when value < 2, do: Enum.reverse [count | acc]
    def prime_exponents(value, acc, index, count) when rem(value, index) == 0, do: prime_exponents(div(value, index), acc, index, count + 1)
    def prime_exponents(value, acc, index, count), do: prime_exponents(value, [count | acc], next_prime(index), 0)

    def number_from_prime_exponents(value) do
        {result, _} = Enum.reduce(value, {1, 2}, fn (element, {product, prime}) -> {product * pow(prime, element), next_prime(prime)} end)
        result
    end

    @doc """
    Computes and retrieves the nth prime where n is the given parameter.
    Uses the defmemo in order to memoize the sequence.
    """
    defmemo nth_prime(0), do: 2
    defmemo nth_prime(n) when n < 0, do: 0
    defmemo nth_prime(n) when n > 0, do: nth_prime(n, 2)
    defmemo nth_prime(0, last_prime), do: last_prime
    defmemo nth_prime(n, last_prime), do: nth_prime(n - 1, next_prime(last_prime))

    def divisors(value), do: divisors(abs(value), [], trunc(:math.sqrt(abs(value))))
    defp divisors(_, acc, 0), do: acc
    defp divisors(value, acc, index) when rem(value, index) == 0 do
        if div(value, index) == index do
            divisors(value, [index], index - 1)
        else
            divisors(value, [index] ++ acc ++ [div(value, index)], index - 1)
        end
    end
    defp divisors(value, acc, index), do: divisors(value, acc, index - 1)

    def n_choose_k(n, k) when k > n, do: 0
    def n_choose_k(n, k), do: div(factorial(n), factorial(k) * factorial(n - k))

    def n_permute_k(n, k) when k > n, do: 0
    def n_permute_k(n, k), do: div(factorial(n), factorial(n - k))

    @doc """
    Is square method. Checks whether the given number is a square.
    Handles arbitrary position.
    """
    def is_square?(0), do: true
    def is_square?(1), do: true
    def is_square?(value) when not is_integer(value), do: false
    def is_square?(value) do
        if not is_integer(value) do
            false
        else
            x = div(value, 2)
            is_square?(value, MapSet.new([x]), x)
        end
    end
    defp is_square?(value, _, x) when x * x == value, do: true
    defp is_square?(value, history, x) do
        x = div(x + div(value, x), 2)
        cond do
            MapSet.member?(history, x) -> false
            true -> is_square?(value, MapSet.put(history, x), x)
        end
    end

    def max_of(list) do
        cond do
            Functions.is_iterable(list) -> max_of(Enum.to_list(list), nil)
            true -> max_of(String.graphemes(to_string(list)), nil)
        end
    end
    def max_of([], value), do: value
    def max_of(list, value) do
        head = List.first Enum.take(list, 1)
        cond do
            Functions.is_iterable(head) and value == nil -> max_of(Enum.drop(list, 1), max_of(head))
            Functions.is_iterable(head) -> max_of(Enum.drop(list, 1), max(max_of(head), value))
            value == nil -> max_of(Enum.drop(list, 1), Functions.to_number(head))
            Functions.to_number(head) > value and is_number(Functions.to_number(head)) -> max_of(Enum.drop(list, 1), Functions.to_number(head))
            true -> max_of(Enum.drop(list, 1), value)
        end
    end

    def min_of(list) do
        cond do
            Functions.is_iterable(list) -> min_of(Enum.to_list(list), nil)
            true -> min_of(String.graphemes(to_string(list)), nil)
        end
    end
    def min_of([], value), do: value
    def min_of(list, value) do
        head = List.first Enum.take(list, 1)
        cond do
            Functions.is_iterable(head) and value == nil -> min_of(Enum.drop(list, 1), min_of(head))
            Functions.is_iterable(head) -> min_of(Enum.drop(list, 1), min(min_of(head), value))
            value == nil -> min_of(Enum.drop(list, 1), Functions.to_number(head))
            Functions.to_number(head) < value and is_number(Functions.to_number(head)) -> min_of(Enum.drop(list, 1), Functions.to_number(head))
            true -> min_of(Enum.drop(list, 1), value)
        end
    end

    # GCD that also supports decimal numbers.
    def gcd_of(a, a), do: a
    def gcd_of(a, 0), do: a
    def gcd_of(0, b), do: b
    def gcd_of(a, b) when is_integer(a) and is_integer(b), do: Integer.gcd(a, b)
    def gcd_of(a, b) when a < 0 and b < 0, do: -gcd_of(-a, -b)
    def gcd_of(a, b) when a < 0, do: gcd_of(-a, b)
    def gcd_of(a, b) when b < 0, do: gcd_of(a, -b)
    def gcd_of(a, b) when a > b, do: gcd_of(a - b, b)
    def gcd_of(a, b) when a < b, do: gcd_of(a, b - a)

    # LCM
    def lcm_of(a, b), do: div(abs(a * b), gcd_of(a, b))

    def euler_totient(value), do: euler_totient(value, value, 0)
    def euler_totient(_, 0, acc), do: acc
    def euler_totient(value, index, acc) do
        if gcd_of(value, index) == 1 do
            euler_totient(value, index - 1, acc + 1)
        else
            euler_totient(value, index - 1, acc)
        end
    end

    def continued_fraction(a, b) do
        Stream.resource(
            fn -> {1, a.(0), 1, a.(1) * a.(0) + b.(1), a.(1)} end,
            fn {k, p0, q0, p1, q1} ->
                {current_digit, k_new, p0_new, q0_new, p1_new, q1_new} = next_fraction_digit(a, b, k, p0, q0, p1, q1)
                {[current_digit], {k_new, p0_new, q0_new, p1_new, q1_new}} end,
            fn _ -> nil end)
            |> Stream.map(fn x -> x end)
    end
    
    defp next_fraction_digit(a, b, k, p0, q0, p1, q1) do
        case {{div(p0, q0), mod(p0, q0)}, {div(p1, q1), mod(p1, q1)}} do
            {{x, r0}, {x, r1}} -> {x, k, 10 * r0, q0, 10 * r1, q1}
            _ ->
                k = k + 1
                x = a.(k)
                y = b.(k)
                next_fraction_digit(a, b, k, p1, q1, x * p1 + y * p0, x * q1 + y * q0)
        end
    end

    def arithmetic_mean(list), do: arithmetic_mean(Enum.to_list(list), 0, 0)
    def arithmetic_mean([], sum, index), do: sum / index
    def arithmetic_mean([head | remaining], sum, index) when Functions.is_iterable(head), do: [head | remaining] |> Stream.map(&arithmetic_mean/1)
    def arithmetic_mean([head | remaining], sum, index), do: arithmetic_mean(remaining, sum + Functions.to_number(head), index + 1)
    
    @doc """
    Tail call optimized version of the Fibonacci sequence
    """
    def fibonacci(0), do: 0
    def fibonacci(1), do: 1
    def fibonacci(index) when index > 1, do: fibonacci(index, 0, 1)
    defp fibonacci(0, a, _), do: a
    defp fibonacci(index, a, b), do: fibonacci(index - 1, b, a + b)

    @doc """
    Tail call optimized version of the Lucas sequence.
    """
    def lucas(0), do: 2
    def lucas(1), do: 1
    def lucas(index) when index > 1, do: lucas(index, 2, 1)
    defp lucas(0, a, _), do: a
    defp lucas(index, a, b), do: lucas(index - 1, b, a + b)
end