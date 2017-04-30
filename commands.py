import collections
import math
import fractions
from functools import reduce
from encoding import *

letters = list("abcdefghijklmnopqrstuvwxyz")
numbers = list("0123456789")

def is_digit_value(value):
    value = str(value)
    try:
        for X in value:
            if X in numbers:
                continue
            else:
                return 0
        return 1
    except:
        return 0


def flatten(x):
    if isinstance(x, collections.Iterable):
        return [a for i in x for a in flatten(i)]
    else:
        return [x]


def deep_flatten(S):
    if S == []:
        return S
    if isinstance(S[0], list):
        return deep_flatten(S[0]) + deep_flatten(S[1:])
    return S[:1] + deep_flatten(S[1:])


def is_alpha_value(value):
    value = str(value)
    try:
        for X in value:
            if str(X).lower() in letters:
                continue
            else:
                return 0
        return 1
    except:
        return 0


def convert_to_base(n, base):
    """convert positive decimal integer n to equivalent in another base (2-36)"""

    digits = "\u0030\u0031\u0032\u0033\u0034\u0035\u0036\u0037\u0038\u0039\u0041\u0042\u0043\u0044\u0045\u0046" \
             "\u0047\u0048\u0049\u004A\u004B\u004C\u004D\u004E\u004F\u0050\u0051\u0052\u0053\u0054\u0055\u0056" \
             "\u0057\u0058\u0059\u005A\u0061\u0062\u0063\u0064\u0065\u0066\u0067\u0068\u0069\u006A\u006B\u006C" \
             "\u006D\u006E\u006F\u0070\u0071\u0072\u0073\u0074\u0075\u0076\u0077\u0078\u0079\u007A\u01DD\u0292" \
             "\u03B1\u03B2\u03B3\u03B4\u03B5\u03B6\u03B7\u03B8\u0432\u0438\u043C\u043D\u0442\u000A\u0393\u0394" \
             "\u0398\u03B9\u03A3\u03A9\u2260\u220A\u220D\u221E\u2081\u2082\u2083\u2084\u2085\u2086\u0020\u0021" \
             "\u0022\u0023\u0024\u0025\u0026\u0027\u0028\u0029\u002A\u002B\u002C\u002D\u002E\u002F\u003A\u003B" \
             "\u003C\u003D\u003E\u003F\u0040\u005B\u005C\u005D\u005E\u005F\u0060\u007B\u007C\u007D\u007E\u01B5" \
             "\u20AC\u039B\u201A\u0192\u201E\u2026\u2020\u2021\u02C6\u2030\u0160\u2039\u0152\u0106\u017D\u01B6" \
             "\u0100\u2018\u2019\u201C\u201D\u2013\u2014\u02DC\u2122\u0161\u203A\u0153\u0107\u017E\u0178\u0101" \
             "\u00A1\u00A2\u00A3\u00A4\u00A5\u00A6\u00A7\u00A8\u00A9\u00AA\u00AB\u00AC\u03BB\u00AE\u00AF\u00B0" \
             "\u00B1\u00B2\u00B3\u00B4\u00B5\u00B6\u00B7\u00B8\u00B9\u00BA\u00BB\u00BC\u00BD\u00BE\u00BF\u00C0" \
             "\u00C1\u00C2\u00C3\u00C4\u00C5\u00C6\u00C7\u00C8\u00C9\u00CA\u00CB\u00CC\u00CD\u00CE\u00CF\u00D0" \
             "\u00D1\u00D2\u00D3\u00D4\u00D5\u00D6\u00D7\u00D8\u00D9\u00DA\u00DB\u00DC\u00DD\u00DE\u00DF\u00E0" \
             "\u00E1\u00E2\u00E3\u00E4\u00E5\u00E6\u00E7\u00E8\u00E9\u00EA\u00EB\u00EC\u00ED\u00EE\u00EF\u00F0" \
             "\u00F1\u00F2\u00F3\u00F4\u00F5\u00F6\u00F7\u00F8\u00F9\u00FA\u00FB\u00FC\u00FD\u00FE\u00FF"

    if int(n) == 0:
        return "0"

    try:
        n = int(n)
        base = int(base)
    except:
        return ""

    if n < 0 or base < 2 or base > 255:
        if n > 0 and base == 1:
            return "0" * n
        return ""

    s = ""
    while 1:
        r = n % base
        s = digits[int(r)] + s
        n = n // base
        if n == 0:
            break

    try:
        while s[0] == "0":
            s = s[1:]
    except:
        0

    return s


def convert_to_base_arbitrary(n, base):

    if int(n) == 0:
        return [0]

    try:
        n = int(n)
        base = int(base)
    except:
        return ""

    if n > 0 and base == 1:
        return "0" * n

    s = []
    if base > 0:
        while 1:
            r = n % base
            s = [int(r)] + s
            n = n // base
            if n == 0:
                break
    else:
        while True:
            n, remainder = divmod(n, base)

            if remainder < 0:
                n, remainder = n + 1, remainder - base

            s = [remainder] + s
            if n == 0:
                break

    try:
        while s[0] == "0":
            s = s[1:]
    except:
        pass

    return s


def convert_from_base(n, base):

    digits = "\u0030\u0031\u0032\u0033\u0034\u0035\u0036\u0037\u0038\u0039\u0041\u0042\u0043\u0044\u0045\u0046" \
             "\u0047\u0048\u0049\u004A\u004B\u004C\u004D\u004E\u004F\u0050\u0051\u0052\u0053\u0054\u0055\u0056" \
             "\u0057\u0058\u0059\u005A\u0061\u0062\u0063\u0064\u0065\u0066\u0067\u0068\u0069\u006A\u006B\u006C" \
             "\u006D\u006E\u006F\u0070\u0071\u0072\u0073\u0074\u0075\u0076\u0077\u0078\u0079\u007A\u01DD\u0292" \
             "\u03B1\u03B2\u03B3\u03B4\u03B5\u03B6\u03B7\u03B8\u0432\u0438\u043C\u043D\u0442\u000A\u0393\u0394" \
             "\u0398\u03B9\u03A3\u03A9\u2260\u220A\u220D\u221E\u2081\u2082\u2083\u2084\u2085\u2086\u0020\u0021" \
             "\u0022\u0023\u0024\u0025\u0026\u0027\u0028\u0029\u002A\u002B\u002C\u002D\u002E\u002F\u003A\u003B" \
             "\u003C\u003D\u003E\u003F\u0040\u005B\u005C\u005D\u005E\u005F\u0060\u007B\u007C\u007D\u007E\u01B5" \
             "\u20AC\u039B\u201A\u0192\u201E\u2026\u2020\u2021\u02C6\u2030\u0160\u2039\u0152\u0106\u017D\u01B6" \
             "\u0100\u2018\u2019\u201C\u201D\u2013\u2014\u02DC\u2122\u0161\u203A\u0153\u0107\u017E\u0178\u0101" \
             "\u00A1\u00A2\u00A3\u00A4\u00A5\u00A6\u00A7\u00A8\u00A9\u00AA\u00AB\u00AC\u03BB\u00AE\u00AF\u00B0" \
             "\u00B1\u00B2\u00B3\u00B4\u00B5\u00B6\u00B7\u00B8\u00B9\u00BA\u00BB\u00BC\u00BD\u00BE\u00BF\u00C0" \
             "\u00C1\u00C2\u00C3\u00C4\u00C5\u00C6\u00C7\u00C8\u00C9\u00CA\u00CB\u00CC\u00CD\u00CE\u00CF\u00D0" \
             "\u00D1\u00D2\u00D3\u00D4\u00D5\u00D6\u00D7\u00D8\u00D9\u00DA\u00DB\u00DC\u00DD\u00DE\u00DF\u00E0" \
             "\u00E1\u00E2\u00E3\u00E4\u00E5\u00E6\u00E7\u00E8\u00E9\u00EA\u00EB\u00EC\u00ED\u00EE\u00EF\u00F0" \
             "\u00F1\u00F2\u00F3\u00F4\u00F5\u00F6\u00F7\u00F8\u00F9\u00FA\u00FB\u00FC\u00FD\u00FE\u00FF"

    n = str(n)[::-1]
    r = 0
    range_v = 0

    for Q in n:
        r += digits.index(Q) * base ** range_v
        range_v += 1

    return r


def is_prime(n):
    if n == 2 or n == 3:
        return 1
    if n < 2 or n % 2 == 0 or n % 3 == 0:
        return 0
    if n < 9:
        return 1
    r = int(n ** 0.5)
    f = 5
    while f <= r:
        if n % f == 0:
            return 0
        if n % (f + 2) == 0:
            return 0
        f += 6

    return 1


def combinations(n, r):
    n = int(n)
    r = int(r)
    if r > n:
        return 0
    return int(math.factorial(n) // (math.factorial(r) * math.factorial(n - r)))


def permutations(n, r):
    n = int(n)
    r = int(r)
    if r > n:
        return 0
    return int(math.factorial(n) // math.factorial(n - r))


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


def get_letter(n):
    n = int(n)
    if n in range(1, 27):
        return chr(64 + n)
    return None


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
                        n = int(int(n) // int(Q))
                if n == 1: break

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
                        n = int(int(n) // int(Q))
                    list_of_factors.append(value)

    try:
        while list_of_factors[len(list_of_factors) - 1] == 0:
            list_of_factors.pop()
    except:0

    return list_of_factors


def get_nth_prime(n):
    n = int(n) + 1
    current_prime = 2
    while n > 0:
        if is_prime(current_prime):
            n -= 1
            if n > 0:
                current_prime += 1
        else:
            current_prime += 1
    return current_prime


def get_all_substrings(input_string):
  length = len(input_string)
  return [input_string[i:j+1] for i in range(length) for j in range(i, length)]


def command_gcd(numbers):
    if 0 in numbers:
        return 0
    try:
        return reduce(fractions.gcd, numbers)
    except:
        return 1


def command_lcm(numbers):
    if 0 in numbers:
        return 0
    try:
        return reduce(lcm, numbers)
    except:
        return 1


def lcm(a, b):
    if a == 0 or b == 0:
        return 0
    return abs(a) * abs(b) // command_gcd([a, b])


def floatify(string):
    a = str(string)
    is_neg = False

    if a[0] == "-":
        is_neg = True
        a = a[1:]

    if not str(a).__contains__("."):
         a += "."
    while a[0] == "0":
         a = a[1:]
    while a[-1] == "0":
         a = a[0:-1]
    if a[0] == ".":
         a = "0" + a
    if a[-1] == ".":
         a += "0"

    if is_neg:
         a = "-" + a

    return a


def trim_float(string):
    if str(string)[-2:] == ".0":
        return int(string)
    else:
        return floatify(string)


def is_float_value(string):
    number_of_dots = str(string).count(".")
    string = str(string).replace(".", "")

    if is_digit_value(string) and number_of_dots < 2:
        return 1
    else:
        return 0


def euler_totient(n):
    amount = 0

    if is_prime(n):
        return n - 1

    for k in range(1, n + 1):
        if fractions.gcd(n, k) == 1:
            amount += 1

    return amount


def chunk_divide(seq, num):

    if type(seq) is int:
        seq = str(seq)

    seq = seq[::-1]

    avg = len(seq) / float(num)
    out = []
    last = 0.0

    while last < len(seq):
        out.append(seq[int(last):int(last + avg)][::-1])
        last += avg

    return out[::-1]


def minimum_edit_distance(s1, s2):
    s1 = str(s1)
    s2 = str(s2)
    if len(s1) > len(s2):
        s1, s2 = s2, s1

    distances = range(len(s1) + 1)
    for index2,char2 in enumerate(s2):
        newDistances = [index2 + 1]
        for index1, char1 in enumerate(s1):
            if char1 == char2:
                newDistances.append(distances[index1])
            else:
                newDistances.append(1 + min((distances[index1],
                                             distances[index1 + 1],
                                             newDistances[-1])))
        distances = newDistances
    return distances[-1]


def infinite_replace(object1, object2, object3):

    if type(object1) is list:
        object1 = [str(x) for x in object1]

    if type(object2) is list:
        object2 = [str(x) for x in object2]

    if type(object3) is list:
        object3 = [str(x) for x in object3]

    if type(object1) is int:
        object1 = str(object1)

    if type(object2) is int:
        object2 = str(object2)

    if type(object3) is int:
        object3 = str(object3)

    # [String String String]
    if type(object1) is str and type(object2) is str and type(object3) is str:
        while object1.replace(object2, object3) != object1:
            object1 = object1.replace(object2, object3)
        return object1

    # [String List String]
    elif type(object1) is str and type(object2) is list and type(object3) is str:
        previous_object = ""
        while previous_object != object1:
            previous_object = object1
            for element in object2:
                while object1.replace(element, object3) != object1:
                    object1 = object1.replace(element, object3)
        return object1

    # [String List List]
    elif type(object1) is str and type(object2) is list and type(object3) is list:
        previous_object = ""
        while previous_object != object1:
            previous_object = object1
            for index in range(0, len(object2)):
                while object1.replace(object2[index], object3[index]) != object1:
                    object1 = object1.replace(object2[index], object3[index])
        return object1

    # [List String String]
    elif type(object1) is list and type(object2) is str and type(object3) is str:
        result_list = []
        for sub_element in object1:
            while sub_element.replace(object2, object3) != sub_element:
                sub_element = sub_element.replace(object2, object3)

            result_list.append(sub_element)
        return result_list

    # [List List String]
    elif type(object1) is list and type(object2) is list and type(object3) is str:
        result_list = []
        for sub_element in object1:
            previous_object = ""
            while previous_object != sub_element:
                previous_object = sub_element
                for sub_start in object2:
                    while sub_element.replace(sub_start, object3) != sub_element:
                        sub_element = sub_element.replace(sub_start, object3)
            result_list.append(sub_element)
        return result_list

    # [List List List]
    elif type(object1) is list and type(object2) is list and type(object3) is list:
        result_list = []
        for sub_element in object1:
            previous_object = ""
            while previous_object != sub_element:
                previous_object = sub_element
                for sub_index in range(0, len(object2)):
                    while sub_element.replace(object2[sub_index], object3[sub_index]) != sub_element:
                        sub_element = sub_element.replace(object2[sub_index], object3[sub_index])
            result_list.append(sub_element)
        return result_list

    raise Exception
