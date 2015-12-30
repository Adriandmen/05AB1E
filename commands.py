import collections
import math

letters = list("abcdefghijklmnopqrstuvwxyz")
numbers = list("0123456789")

def is_digit_value(value):
    value = str(value)
    try:
        for X in value:
            if numbers.__contains__(X):
                continue
            else:
                return False
        return True
    except:
        return False


def flatten(x):
    if isinstance(x, collections.Iterable):
        return [a for i in x for a in flatten(i)]
    else:
        return [x]


def is_alpha_value(value):
    value = str(value)
    try:
        for X in value:
            if letters.__contains__(X.lower()):
                continue
            else:
                return False
        return True
    except:
        return False


def convert_to_base(n, base):
    """convert positive decimal integer n to equivalent in another base (2-36)"""

    digits = "0123456789abcdefghijklmnopqrstuvwxyz"

    if int(n) == 0:
        return "0"

    try:
        n = int(n)
        base = int(base)
    except:
        return ""

    if n < 0 or base < 2 or base > 36:
        return ""

    s = ""
    while 1:
        r = n % base
        s = digits[int(r)] + s
        n = n / base
        if n == 0:
            break

    try:
        while s[0]=="0":
            s = s[1:]
    except:
        0

    return s


def is_prime(n):
    if n < 2:
        return False
    if n == 2:
        return True
    for N in range(2, n):
        if n % N == 0:
            return False
    return True


def combinations(n, r):
    n = int(n)
    r = int(r)
    return int(math.factorial(n) / (math.factorial(r) * math.factorial(n - r)))


def permutations(n, r):
    n = int(n)
    r = int(r)
    return int(math.factorial(n) / math.factorial(n - r))


def prime_factorization(n):
    n = int(n)
    list_of_factors = []

    if n < 2:
        return []
    else:
        if n == 2:
            return [2]
        else:
            for Q in range(2, n + 1):
                if is_prime(Q):
                    if n % Q == 0:
                        list_of_factors.append(Q)
    return list_of_factors


def prime_factorization_duplicates(n):
    n = int(n)
    list_of_factors = []

    if n < 2:
        return []
    else:
        if n == 2:
            return [2]
        else:
            for Q in range(2, n + 1):
                if is_prime(Q):
                    while n % Q == 0:
                        list_of_factors.append(Q)
                        n = int(int(n) / int(Q))

    return list_of_factors


def prime_factorization_powers(n):
    n = int(n)
    list_of_factors = []

    if n < 2:
        return []
    else:
        if n == 2:
            return [1]
        else:
            for Q in range(2, n + 1):
                if is_prime(Q):
                    value = 0
                    while n % Q == 0:
                        value += 1
                        n = int(int(n) / int(Q))
                    list_of_factors.append(value)

    try:
        while list_of_factors[len(list_of_factors) - 1] == 0:
            list_of_factors.pop()
    except:0

    return list_of_factors
