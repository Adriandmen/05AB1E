import collections

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
    if n == 2:
        return True
    for N in range(2, n):
        if n % N == 0:
            return False
    return True