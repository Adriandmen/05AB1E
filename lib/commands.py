import collections
import math
import fractions
import ast
import random
import re
from functools import reduce
from itertools import count
from difflib import SequenceMatcher

letters = "abcdefghijklmnopqrstuvwxyz"
numbers = "0123456789"

def apply_safe(function, *args):
    try:
        return function(*args)
    except:
        return args[0]

def ast_int_eval(number):
    a = str(number)
    try:
        a = ast.literal_eval(a)
    except:
        a = int(a)

    return a

def is_digit_value(value):
    value = str(value)
    try:
        int(value)
        return 1
    except:
        return 0


def flatten(x):
    if type(x) is list:
        return [a for i in x for a in flatten(i)]
    return [x]


def deep_flatten(S):
    if type(S) is not list or not S:
        return S

    buf = []
    for i in S:
        if type(i) is list:
            buf += deep_flatten(i)
        else:
            buf.append(i)

    return buf

def is_alpha_value(value):
    value = str(value)
    
    if len(value) == 0:
        return 0

    try:
        for X in value:
            if not X.lower() in letters:
                return 0
        return 1
    except:
        return 0


def convert_to_base(n, base):
    """
    convert positive decimal integer n to equivalent in another base(1-255)
    """

    digits = "\u0030\u0031\u0032\u0033\u0034\u0035\u0036\u0037\u0038\u0039" \
             "\u0041\u0042\u0043\u0044\u0045\u0046\u0047\u0048\u0049\u004A" \
             "\u004B\u004C\u004D\u004E\u004F\u0050\u0051\u0052\u0053\u0054" \
             "\u0055\u0056\u0057\u0058\u0059\u005A\u0061\u0062\u0063\u0064" \
             "\u0065\u0066\u0067\u0068\u0069\u006A\u006B\u006C\u006D\u006E" \
             "\u006F\u0070\u0071\u0072\u0073\u0074\u0075\u0076\u0077\u0078" \
             "\u0079\u007A\u01DD\u0292\u03B1\u03B2\u03B3\u03B4\u03B5\u03B6" \
             "\u03B7\u03B8\u0432\u0438\u043C\u043D\u0442\u000A\u0393\u0394" \
             "\u0398\u03B9\u03A3\u03A9\u2260\u220A\u220D\u221E\u2081\u2082" \
             "\u2083\u2084\u2085\u2086\u0020\u0021\u0022\u0023\u0024\u0025" \
             "\u0026\u0027\u0028\u0029\u002A\u002B\u002C\u002D\u002E\u002F" \
             "\u003A\u003B\u003C\u003D\u003E\u003F\u0040\u005B\u005C\u005D" \
             "\u005E\u005F\u0060\u007B\u007C\u007D\u007E\u01B5\u20AC\u039B" \
             "\u201A\u0192\u201E\u2026\u2020\u2021\u02C6\u2030\u0160\u2039" \
             "\u0152\u0106\u017D\u01B6\u0100\u2018\u2019\u201C\u201D\u2013" \
             "\u2014\u02DC\u2122\u0161\u203A\u0153\u0107\u017E\u0178\u0101" \
             "\u00A1\u00A2\u00A3\u00A4\u00A5\u00A6\u00A7\u00A8\u00A9\u00AA" \
             "\u00AB\u00AC\u03BB\u00AE\u00AF\u00B0\u00B1\u00B2\u00B3\u00B4" \
             "\u00B5\u00B6\u00B7\u00B8\u00B9\u00BA\u00BB\u00BC\u00BD\u00BE" \
             "\u00BF\u00C0\u00C1\u00C2\u00C3\u00C4\u00C5\u00C6\u00C7\u00C8" \
             "\u00C9\u00CA\u00CB\u00CC\u00CD\u00CE\u00CF\u00D0\u00D1\u00D2" \
             "\u00D3\u00D4\u00D5\u00D6\u00D7\u00D8\u00D9\u00DA\u00DB\u00DC" \
             "\u00DD\u00DE\u00DF\u00E0\u00E1\u00E2\u00E3\u00E4\u00E5\u00E6" \
             "\u00E7\u00E8\u00E9\u00EA\u00EB\u00EC\u00ED\u00EE\u00EF\u00F0" \
             "\u00F1\u00F2\u00F3\u00F4\u00F5\u00F6\u00F7\u00F8\u00F9\u00FA" \
             "\u00FB\u00FC\u00FD\u00FE\u00FF"

    n = int(n)
    base = int(base)

    if n == 0:
        return "0"

    if n < 0 or base < 2 or base > 255:
        if n > 0 and base == 1:
            return "0" * n
        return str(n)

    s = ""
    while True:
        r = n % base
        s = digits[int(r)] + s
        n = n // base
        if n == 0:
            break

    try:
        while s[0] == "0":
            s = s[1:]
    except:
        pass

    return s


def convert_to_base_arbitrary(n, base):
    n = int(n)
    base = int(base)

    if n == 0:
        return [0]

    if n > 0 and base == 1:
        return [0] * n

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
    digits = "\u0030\u0031\u0032\u0033\u0034\u0035\u0036\u0037\u0038\u0039" \
             "\u0041\u0042\u0043\u0044\u0045\u0046\u0047\u0048\u0049\u004A" \
             "\u004B\u004C\u004D\u004E\u004F\u0050\u0051\u0052\u0053\u0054" \
             "\u0055\u0056\u0057\u0058\u0059\u005A\u0061\u0062\u0063\u0064" \
             "\u0065\u0066\u0067\u0068\u0069\u006A\u006B\u006C\u006D\u006E" \
             "\u006F\u0070\u0071\u0072\u0073\u0074\u0075\u0076\u0077\u0078" \
             "\u0079\u007A\u01DD\u0292\u03B1\u03B2\u03B3\u03B4\u03B5\u03B6" \
             "\u03B7\u03B8\u0432\u0438\u043C\u043D\u0442\u000A\u0393\u0394" \
             "\u0398\u03B9\u03A3\u03A9\u2260\u220A\u220D\u221E\u2081\u2082" \
             "\u2083\u2084\u2085\u2086\u0020\u0021\u0022\u0023\u0024\u0025" \
             "\u0026\u0027\u0028\u0029\u002A\u002B\u002C\u002D\u002E\u002F" \
             "\u003A\u003B\u003C\u003D\u003E\u003F\u0040\u005B\u005C\u005D" \
             "\u005E\u005F\u0060\u007B\u007C\u007D\u007E\u01B5\u20AC\u039B" \
             "\u201A\u0192\u201E\u2026\u2020\u2021\u02C6\u2030\u0160\u2039" \
             "\u0152\u0106\u017D\u01B6\u0100\u2018\u2019\u201C\u201D\u2013" \
             "\u2014\u02DC\u2122\u0161\u203A\u0153\u0107\u017E\u0178\u0101" \
             "\u00A1\u00A2\u00A3\u00A4\u00A5\u00A6\u00A7\u00A8\u00A9\u00AA" \
             "\u00AB\u00AC\u03BB\u00AE\u00AF\u00B0\u00B1\u00B2\u00B3\u00B4" \
             "\u00B5\u00B6\u00B7\u00B8\u00B9\u00BA\u00BB\u00BC\u00BD\u00BE" \
             "\u00BF\u00C0\u00C1\u00C2\u00C3\u00C4\u00C5\u00C6\u00C7\u00C8" \
             "\u00C9\u00CA\u00CB\u00CC\u00CD\u00CE\u00CF\u00D0\u00D1\u00D2" \
             "\u00D3\u00D4\u00D5\u00D6\u00D7\u00D8\u00D9\u00DA\u00DB\u00DC" \
             "\u00DD\u00DE\u00DF\u00E0\u00E1\u00E2\u00E3\u00E4\u00E5\u00E6" \
             "\u00E7\u00E8\u00E9\u00EA\u00EB\u00EC\u00ED\u00EE\u00EF\u00F0" \
             "\u00F1\u00F2\u00F3\u00F4\u00F5\u00F6\u00F7\u00F8\u00F9\u00FA" \
             "\u00FB\u00FC\u00FD\u00FE\u00FF"

    n = str(n)[::-1]
    base = int(base)
    r = 0
    range_v = 0

    for Q in n:
        r += digits.index(Q) * base ** range_v
        range_v += 1

    return r


def convert_from_base_arbitrary(n, base):
    if type(n) is not list:
        n = str(n)

    base = int(base)
    
    n = n[::-1]
    r = 0
    range_v = 0

    for Q in n:
        r += int(Q) * base ** range_v
        range_v += 1

    return r


def is_prime(n):
    try:
        n = int(n)
    except:
        return 0

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


def first_n_primes(n):
    prime_list = []
    primes = prime_sieve()
    for x in range(n):
        prime_list.append(next(primes))
    return prime_list

    
def primes_upto_n(n):
    prime_list = []
    primes = prime_sieve()
    while True:
        current_prime = next(primes)
        if current_prime > n:
            break
        prime_list.append(current_prime)
    return prime_list
    

def prime_sieve():
    yield 2
    yield 3
    yield 5
    yield 7
    sieve = {}
    ps = prime_sieve()
    p = next(ps) and next(ps)
    q = p * p
    for c in count(9, 2):
        if c in sieve:
            s = sieve.pop(c)
        elif c < q:
            yield c
            continue
        else:
            s = count(q + 2 * p, 2 * p)
            p = next(ps)
            q = p * p
        for m in s:
            if m not in sieve:
                break
        sieve[m] = s


def combinations(n, r):
    n = int(n)
    r = int(r)
    if r > n:
        return 0
    return int(
        math.factorial(n) // (math.factorial(r) * math.factorial(n - r))
    )


def permutations(n, r):
    n = int(n)
    r = int(r)
    if r > n:
        return 0
    return int(math.factorial(n) // math.factorial(n - r))


def prime_factorization(n):
    n = int(n)

    if n < 2:
        return []
    if n == 2:
        return [2]

    list_of_factors = []
    for Q in range(2, n + 1):
        if is_prime(Q):
            if n % Q == 0:
                list_of_factors.append(Q)
    return list_of_factors


def get_letter(n):
    n = int(n)
    if n in range(1, 27):
        return chr(64 + n)


def prime_factorization_duplicates(n):
    n = int(n)

    if n < 2:
        return []
    if n == 2:
        return [2]
    list_of_factors = []

    for Q in range(2, n + 1):
        if is_prime(Q):
            while n % Q == 0:
                list_of_factors.append(Q)
                n = int(int(n) // int(Q))
        if n == 1:
            break

    return list_of_factors


def prime_factorization_powers(n):
    n = int(n)

    if n < 2:
        return []
    if n == 2:
        return [1]

    list_of_factors = []

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
    except:
        pass

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

def get_index_of_prime(n):
    from itertools import takewhile
    n = int(n)
    g = prime_sieve()
    return len(list(takewhile(lambda x: x <= n, g)))-1

def get_all_substrings(input_string):
    if type(input_string) is not list:
        input_string = str(input_string)
        
    length = len(input_string)
    return [
        input_string[i:j+1] for i in range(length) for j in range(i, length)
    ]

def floatify(string):
    # force an exception if not a number
    ast_int_eval(string)

    a = str(string).lower()
    is_neg = False

    # handling scientific notation
    if "e" in a:
        if "e-" in a:
            dec = re.search("e-([0-9]+)", a)
            a = ("%." + dec.group(1) + "f") % float(a)
        else:
            a = "%f" % float(a)

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
    return floatify(string)


def is_float_value(string):
    number_of_dots = str(string).count(".")
    string = str(string).replace(".", "")

    if is_digit_value(string) and number_of_dots < 2:
        return 1
    return 0


def euler_totient(n):
    n = int(n)
    if is_prime(n):
        return n - 1

    amount = 0

    for k in range(1, n + 1):
        if fractions.gcd(n, k) == 1:
            amount += 1

    return amount


def chunk_divide(seq, num):
    num = ast_int_eval(num)
    avg = len(seq) / float(num)
    is_list = type(seq) is list

    if not is_list:
        seq = str(seq)

    if avg < 1: 
        return seq
    # special case: there are more parts than possible groupings
    elif avg < 2:    
        seq = [[x] for x in seq]

        idx = 0
        while len(seq) > num:
            seq.insert(idx, seq.pop(idx) + seq.pop(idx))
            idx = idx + 1 if idx < len(seq) - 1 else 0

        if not is_list:
            seq = [''.join(x) for x in seq]
        return seq
    else:
        seq = seq[::-1]
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
    for index2, char2 in enumerate(s2):
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
    elif type(object1) is not list:
        object1 = str(object1)

    if type(object2) is list:
        object2 = [str(x) for x in object2]
    elif type(object2) is not list:
        object2 = str(object2)

    if type(object3) is list:
        object3 = [str(x) for x in object3]
    elif type(object3) is not list:
        object3 = str(object3)

    type1 = type(object1)
    type2 = type(object2)
    type3 = type(object3)

    # [String String String]
    if type1 is str and type2 is str and type3 is str:
        while object1.replace(object2, object3) != object1:
            object1 = object1.replace(object2, object3)
        return object1

    # [String List String]
    elif type1 is str and type2 is list and type3 is str:
        previous_object = ""
        while previous_object != object1:
            previous_object = object1
            for element in object2:
                while object1.replace(element, object3) != object1:
                    object1 = object1.replace(element, object3)
        return object1

    # [String List List]
    elif type1 is str and type2 is list and type3 is list:
        previous_object = ""
        while previous_object != object1:
            previous_object = object1
            for index in range(0, len(object2)):
                while object1.replace(object2[index], object3[index])\
                        != object1:
                    object1 = object1.replace(object2[index], object3[index])
        return object1

    # [List String String]
    elif type1 is list and type2 is str and type3 is str:
        result_list = []
        for sub_element in object1:
            while sub_element.replace(object2, object3) != sub_element:
                sub_element = sub_element.replace(object2, object3)

            result_list.append(sub_element)
        return result_list

    # [List List String]
    elif type1 is list and type2 is list and type3 is str:
        result_list = []
        for sub_element in object1:
            previous_object = ""
            while previous_object != sub_element:
                previous_object = sub_element
                for sub_start in object2:
                    while sub_element.replace(sub_start, object3)\
                            != sub_element:
                        sub_element = sub_element.replace(sub_start, object3)
            result_list.append(sub_element)
        return result_list

    # [List List List]
    elif type1 is list and type2 is list and type3 is list:
        result_list = []
        for sub_element in object1:
            previous_object = ""
            while previous_object != sub_element:
                previous_object = sub_element
                for sub_index in range(0, len(object2)):
                    while sub_element.replace(
                            object2[sub_index], object3[sub_index])\
                            != sub_element:
                        sub_element = sub_element.replace(
                            object2[sub_index], object3[sub_index])
            result_list.append(sub_element)
        return result_list

    raise Exception


def single_replace(object1, object2, object3):

    if type(object1) is list:
        object1 = [str(x) for x in object1]
    else:
        object1 = str(object1)

    if type(object2) is list:
        object2 = [str(x) for x in object2]
    else:
        object2 = str(object2)

    if type(object3) is list:
        object3 = [str(x) for x in object3]
    else:
        object3 = str(object3)

    type1 = type(object1)
    type2 = type(object2)
    type3 = type(object3)

    # [String String String]
    if type1 is str and type2 is str and type3 is str:
        object1 = object1.replace(object2, object3)
        return object1

    # [String List String]
    elif type1 is str and type2 is list and type3 is str:
        for element in object2:
            object1 = object1.replace(str(element), object3)
        return object1

    # [String List List]
    elif type1 is str and type2 is list and type3 is list:
        for index in range(0, len(object2)):
            object1 = object1.replace(str(object2[index]), str(object3[index]))
        return object1

    # [List String String]
    elif type1 is list and type2 is str and type3 is str:
        result_list = []
        for sub_element in object1:
            sub_element = sub_element.replace(object2, object3)
            result_list.append(sub_element)
        return result_list

    # [List List String]
    elif type1 is list and type2 is list and type3 is str:
        result_list = []
        for sub_element in object1:
            for old in object2:
                sub_element = sub_element.replace(str(old), str(object3))
            result_list.append(sub_element)
        return result_list

    # [List List List]
    elif type1 is list and type2 is list and type3 is list:
        result_list = []
        for current in object1:
            for index in range(0, len(object2)):
                current = current.replace(object2[index], object3[index])
            result_list.append(current)
        return result_list

    raise Exception


def first_replace(object1, object2, object3):

    if type(object1) is list:
        object1 = [str(x) for x in object1]
    elif type(object1) is not list:
        object1 = str(object1)

    if type(object2) is list:
        object2 = [str(x) for x in object2]
    elif type(object2) is not list:
        object2 = str(object2)

    if type(object3) is list:
        object3 = [str(x) for x in object3]
    elif type(object3) is not list:
        object3 = str(object3)

    type1 = type(object1)
    type2 = type(object2)
    type3 = type(object3)

    # [String String String]
    if type1 is str and type2 is str and type3 is str:
        object1 = object1.replace(object2, object3, 1)
        return object1

    # [String List String]
    elif type1 is str and type2 is list and type3 is str:
        for element in object2:
            object1 = object1.replace(str(element), object3, 1)
        return object1

    # [String List List]
    elif type1 is str and type2 is list and type3 is list:
        for index in range(0, len(object2)):
            object1 = object1.replace(
                str(object2[index]), str(object3[index]), 1)
        return object1

    # [List String String]
    elif type1 is list and type2 is str and type3 is str:
        result_list = []
        for sub_element in object1:
            sub_element = sub_element.replace(object2, object3, 1)
            result_list.append(sub_element)
        return result_list

    # [List List String]
    elif type1 is list and type2 is list and type3 is str:
        result_list = []
        for sub_element in object1:
            for old in object2:
                sub_element = sub_element.replace(str(old), str(object3), 1)
            result_list.append(sub_element)
        return result_list

    # [List List List]
    elif type1 is list and type2 is list and type3 is list:
        result_list = []
        for current in object1:
            for index in range(0, len(object2)):
                current = current.replace(object2[index], object3[index], 1)
            result_list.append(current)
        return result_list

    raise Exception


def divisors_of_number(n):

    temp_list = []
    for N in range(1, int(n) + 1):
        if int(n) % N == 0:
            temp_list.append(N)

    return temp_list


def insert(object1, character, location):
    if type(object1) is not list:
        object1 = str(object1)

    location = int(location)

    if location > len(object1):
        return object1

    if type(object1) is list:
        return object1[0:location] + [character] + object1[location + 1:]

    return object1[0:location] + str(character) + object1[location + 1:]


def mirror(a):
    if type(a) is not list:
        a = str(a).split("\n")

    result = []
    for element in a:
        reversed_element = transliterate(
            element[::-1], "<>{}()[]\\/", "><}{)(][/\\")
        result.append(element + reversed_element)

    return '\n'.join(result)


def vertical_mirror(a):
    if type(a) is not list:
        a = str(a).split("\n")

    result = []
    for element in a:
        result.append(element)

    for element in a[::-1]:
        reversed_element = transliterate(element,  "\\/", "/\\")
        result.append(reversed_element)

    return '\n'.join(result)


def vertical_intersected_mirror(a):
    if type(a) is not list:
        a = str(a).split("\n")

    result = []
    for element in a:
        result.append(element)

    for element in a[::-1][1:]:
        reversed_element = transliterate(element,  "\\/", "/\\")
        result.append(reversed_element)

    return '\n'.join(result)


def intersected_mirror(a):
    if type(a) is not list:
        a = str(a).split("\n")

    result = []
    for element in a:
        reversed_element = transliterate(
            element[::-1], "<>{}()[]\\/", "><}{)(][/\\")
        result.append(element[:-1] + reversed_element)

    return '\n'.join(result)


def transliterate(string: str, prev, next):
    processed = ""

    for character in string:
        has_replaced = False
        for Q in range(min(len(prev), len(next))):
            if character == prev[Q]:
                processed += next[Q]
                has_replaced = True
                break

        if not has_replaced:
            processed += character

    return processed


def string_multiplication(a, b):
    if type(a) is not list and type(b) is not list:
        try:
            try:
                return ast_int_eval(b) * str(a)
            except:
                return ast_int_eval(a) * str(b)
        except:
            result = []
            for x in a:
                temp_list = []
                for y in b:
                    temp_list.append(str(x) + str(y))
                result.append(temp_list)
            return result
    elif type(a) is not list and type(b) is list:
        try:
            return [str(a) * ast_int_eval(x) for x in b]
        except:
            return [str(x) * ast_int_eval(a) for x in b]
    elif type(b) is not list and type(a) is list:
        try:
            return [str(x) * ast_int_eval(b) for x in a]
        except:
            return [str(b) * ast_int_eval(x) for x in a]
    else:
        try:
            result = []
            for x in range(0, len(a)):
                result.append(str(a[x]) * ast_int_eval(b[x]))
            return result
        except:
            try:
                result = []
                for x in range(0, len(a)):
                    result.append(str(b[x]) * ast_int_eval(a[x]))
                return result
            except:
                result = []
                for x in a:
                    temp_list = []
                    for y in b:
                        temp_list.append(str(x) + str(y))
                    result.append(temp_list)
                return result


def even_divide(a, b):
    b = int(ast_int_eval(b))

    if type(a) is not list:
        a = str(a)

    result = []
    temp_list = []

    for index in range(0, len(a)):
        temp_list.append(a[index])
        if len(temp_list) == b:
            result.append(temp_list)
            temp_list = []

    if temp_list:
        result.append(temp_list)

    if type(a) is str:
        return list(map(''.join, result))

    return result


def get_hash(string):
    string = "filler for the string" + str(string)

    hash_num = 0
    for index in range(0, len(string)):
        hash_num += ord(string[index]) * (index + 1) ** 8
        hash_num %= 2**32

    return hash_num


def closest_to(a, b):
    if type(b) is list:
        return a

    try:
        b = ast_int_eval(b)
    except:
        # if a is not a list, applies char difference
        # otherwise we can use string distances
        if type(a) is not list:
            b = ord(b)
        pass

    if type(a) is list:
        a = deep_flatten(a)

        if type(b) is not str:
            try:
                a = [ast_int_eval(x) for x in a]
            except:
                # fallback to string distances if there is a string in a
                b = str(b)
    else:
        a = str(a)

    closest = a
    distance = float('inf')

    for element in a:
        if type(a) is str:
            if abs(ord(element) - b) < distance:
                distance = abs(ord(element) - b)
                closest = element
        elif type(b) is str:
            element_dist = 1 - SequenceMatcher(None, str(element), b).ratio()

            if element_dist < distance:
                distance = element_dist
                closest = str(element)
        elif abs(element - b) < distance:
            distance = abs(element - b)
            closest = element

    return closest

def zip_with(a, b):
    temp = a

    if type(temp) is not list:
        temp = str(temp)

    if type(temp) is str:
        temp = temp.split("\n")

    maximum_length = max([len(x) for x in temp])

    if type(a[0]) is list:
        temp_list = []
        for element in temp:
            temp_list.append(element + [str(b)] * (maximum_length - len(element)))
        filled_list = temp_list[:]
    else:
        filled_list = [str(x) + (str(b) * (maximum_length - len(x))) for x in temp]

    zipped_list = [list(x) for x in zip(*filled_list)]
    result = []

    if type(a) is not list:
        for element in zipped_list:
            result.append(''.join(element))
        result = '\n'.join(result)

    elif type(a[0]) is str:
        for element in zipped_list:
            result.append(''.join(element))

    else:
        result = zipped_list[:]

    return result


def multi_split(a, b: list):
    if type(a) is not list:
        a = str(a)

    delimiter = ''.join(
        random.choice(" !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLM"
                      "NOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~")
        for _ in range(10))
    while delimiter in a:
        delimiter = ''.join(
            random.choice(" !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLM"
                          "NOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~")
            for _ in range(10))

    a = transliterate(a, b, [delimiter] * len(b))

    return [i for i in a.split(delimiter) if i]


def shape_like(a, b):

    if type(b) is str:
        b = int(ast_int_eval(b))

    if type(a) is list and type(b) is list:
        result = []
        for element in b:
            result.append(shape_like(a, element))
        return result

    elif type(a) is list and type(b) is int:
        return (a * b)[:b]

    elif type(a) is not list and type(b) is list:
        result = []
        for element in b:
            result.append(shape_like(a, element))
        return result

    elif type(a) is not list and type(b) is not list:
        return (str(a) * b)[:b]

def sentence_case(a):
    a = str(a)
    temp_string = ""
    begin_sentence = True
    for Q in a:
        if begin_sentence:
            temp_string += Q.upper()
            if not Q == " ":
                begin_sentence = False
        else:
            temp_string += Q
        if Q == "." or Q == "?" or Q == "!":
            begin_sentence = True
    return temp_string

def list_multiply(a, b, recur=True):

    try:
        if type(a) is not list:
            a = [a]

        if type(b) is list:
            result = []

            for element in b:
                try:
                    result.append(a * int(element))
                except:
                    result.append(list_multiply(a, element, False))

            return result
        else:
            return a * int(b)

    except Exception as e:

        if recur:
            return list_multiply(b, a, False)

        else:
            raise e

def deltaify(a):
    if type(a) is not list:
        a = str(a)

    sublists = []
    values = []

    for i in a:
        if type(i) is list:
            sublists.append(i)
        else:
            try:
                values.append(ast_int_eval(i))
            except:
                pass

    result = []
    for Q in range(len(values) - 1):
        result.append(values[Q+1] - values[Q])

    if len(sublists):
        result += [deltaify(l) for l in sublists]    

    return result

def filtered_to_the_front(a, b):
    if type(a) is not list:
        a = str(a)

    filtered = []
    remaining = []

    for i in a:
        if type(i) is list:
            remaining.append(filtered_to_the_front(i, b))
        elif str(i) == str(b):
            filtered.append(str(i))
        else:
            remaining.append(str(i))

    result = filtered + remaining

    return result if type(a) is list else ''.join([str(x) for x in result])

def bijective_base_conversion(a, to_base):
    a = int(a)

    number = ""
    while a:
        a -= 1
        r = a % to_base
        a = a // to_base
        r += 1
        if r < 0:
            a += 1
            r -= to_base
        number += str(r)
    return number[::-1]

def bijective_decimal_conversion(a, from_base):
    a = str(int(a))

    number = 0
    for Q in a:
        number = number * from_base + int(Q)
    return number

def uniquify(a, connected=False):
    buf = []

    if type(a) is not list:
        a = str(a)

    for item in a:
        if type(item) is not list:
            item = str(item)

        if item not in buf:
            buf.append(item)
        elif connected and len(buf) and buf[-1] != item:
            buf.append(item)

    return buf if type(a) is list else ''.join(buf)

