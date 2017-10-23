import math
import sys
from .commands import ast_int_eval, first_n_primes, primes_upto_n
from .vectorizer import *
sys.setrecursionlimit(5000)


# Global dicts for recursive methods
pre_fibonacci = {0: 0, 1: 1}
pre_lucas = {0: 2, 1: 1}


class MethodAttribute:
    """
    A method attribute is an attribute with the method and
    its corresponding arity attached as parameters. It simply acts
    as a tuple for easy access
    """

    def __init__(self, method, arity):
        self.method = method
        self.arity = arity


def list_until(function, number, condition=None):
    """
    Returns a list of all values f(0), f(1), .., f(n) whereas f(n) <= number
    :param function: A strictly increasing method that returns a number
    :param number: The number that will be used as the arguments for the function
    :param condition: The condition that needs to be satisfied for the number
    :return: A list of all values up till f(n) <= number
    """

    result = []
    index = 0
    current_number = function(index)

    while current_number <= number:

        if condition is None or condition(current_number):
            result.append(current_number)

        index += 1
        current_number = function(index)

    return result


def fibonacci(number):
    """
    Calculates the <number>th term of the Fibonacci sequence
    :param number: The term that needs to be calculated of the Fibonacci sequence
    :return: The corresponding term of the Fibonacci sequence
    """
    if number in pre_fibonacci:
        return pre_fibonacci[number]

    if number - 500 > max(pre_fibonacci):
        pre_fibonacci[number - 500] = fibonacci(number - 500)

    pre_fibonacci[number] = fibonacci(number - 1) + fibonacci(number - 2)
    return pre_fibonacci[number]


def lucas(number):
    """
    Calculates the <number>th term of the Lucas sequence
    :param number: The term that needs to be calculated of the Lucas sequence
    :return: The corresponding term of the Lucas sequence
    """
    if number in pre_lucas:
        return pre_lucas[number]

    if number - 500 > max(pre_lucas):
        pre_lucas[number - 500] = lucas(number - 500)

    pre_lucas[number] = lucas(number - 1) + lucas(number - 2)
    return pre_lucas[number]


def polygonal_number(sides, n):
    """
    Calculates the nth-order polygonal number with sides sides
    :param sides: Number of sides
    :param n: The order of the polygonal number
    :return: The corresponding polygonal number
    """
    return (n**2*(sides - 2) - n*(sides - 4)) // 2


def is_square(number):
    """
    Check whether a number is a squared number or not without precision errors
    :param number: The number that needs to be checked
    :return: An integer (boolean) whether the number is a square
    """
    if number == 0 or number == 1:
        return 1

    if number % 1 != 0:
        return 0

    x = number // 2
    seen = {x}
    while x * x != number:
        x = (x + (number // x)) // 2
        if x in seen:
            return 0
        seen.add(x)

    return 1


def arithmetic_mean(number):
    """
    Calculates the arithmetic mean of the number (which can also be a list)
    :param number: A number of list with numeric elements
    :return: The arithmetic mean
    """

    if type(number) is list:
        try:
            return sum(ast_int_eval(x) for x in number) / len(number)
        except:
            return [arithmetic_mean(x) for x in number]
    else:
        return sum(ast_int_eval(x) for x in str(number)) / len(str(number))


extended_commands = {
    "Å!": MethodAttribute(
        lambda x: list_until(lambda a: math.factorial(a), int(x)),
        arity=1
    ),

    "Å1": MethodAttribute(
        lambda x: [1 for _ in range(0, int(x))],
        arity=1
    ),

    "Å2": MethodAttribute(
        lambda x: [2 for _ in range(0, int(x))],
        arity=1
    ),

    "Å3": MethodAttribute(
        lambda x: [3 for _ in range(0, int(x))],
        arity=1
    ),

    "Å4": MethodAttribute(
        lambda x: [4 for _ in range(0, int(x))],
        arity=1
    ),

    "Å5": MethodAttribute(
        lambda x: [5 for _ in range(0, int(x))],
        arity=1
    ),

    "Å6": MethodAttribute(
        lambda x: [6 for _ in range(0, int(x))],
        arity=1
    ),

    "Å7": MethodAttribute(
        lambda x: [7 for _ in range(0, int(x))],
        arity=1
    ),

    "Å8": MethodAttribute(
        lambda x: [8 for _ in range(0, int(x))],
        arity=1
    ),

    "Å9": MethodAttribute(
        lambda x: [9 for _ in range(0, int(x))],
        arity=1
    ),

    "Å0": MethodAttribute(
        lambda x: [0 for _ in range(0, int(x))],
        arity=1
    ),

    "ÅÈ": MethodAttribute(
        lambda x: list_until(lambda a: 2 * a, int(x)),
        arity=1
    ),

    "ÅÉ": MethodAttribute(
        lambda x: list_until(lambda a: 2 * a + 1, int(x)),
        arity=1
    ),

    "ÅF": MethodAttribute(
        lambda x: list_until(fibonacci, int(x), lambda a: a > 0),
        arity=1
    ),

    "Åf": MethodAttribute(
        lambda x: fibonacci(int(x)),
        arity=1
    ),

    "ÅG": MethodAttribute(
        lambda x: list_until(lucas, int(x), lambda a: a > 0),
        arity=1
    ),

    "Åg": MethodAttribute(
        lambda x: lucas(int(x)),
        arity=1
    ),

    "Åp": MethodAttribute(
        lambda x: first_n_primes(int(x)),
        arity=1
    ),

    "ÅA": MethodAttribute(
        lambda x: arithmetic_mean(x),
        arity=1
    ),

    "ÅP": MethodAttribute(
        lambda x: primes_upto_n(int(x)),
        arity=1
    ),
    
    "ÅT": MethodAttribute(
        lambda x: list_until(lambda a: a * (a + 1) // 2, int(x)),
        arity=1
    ),

    "ÅU": MethodAttribute(
        lambda sides, n: polygonal_number(ast_int_eval(sides), ast_int_eval(n)),
        arity=2
    ),

    "Å²": MethodAttribute(
        lambda x: is_square(ast_int_eval(x)),
        arity=1
    ),

    "ÅL": MethodAttribute(
        lambda x, y: (lambda a, b: a if a < b else b)(ast_int_eval(x), ast_int_eval(y)),
        arity=2
    ),

    ".²": MethodAttribute(
        lambda x: math.log(ast_int_eval(x), 2),
        arity=1
    )
}


class ExtendedMathInvoker:

    def __init__(self):
        self.commands_list = extended_commands

    def invoke_command(self, command, *args):
        """
        Invokes the command passed through the argument and computes the desired
        result using the rest of the arguments as args for the method
        :param command: A string representation of the 05AB1E command
        :param args: The arguments that will be passed on the method
        :return: Any variable, determined by the corresponding method
        """

        current_method = self.commands_list.get(command)
        try:
            return current_method.method(*args)
        except Exception as e:
            if len(args) == 1:
                return single_vectorized_evaluation(args[0], current_method.method)

            elif len(args) == 2:
                return vectorized_evaluation(args[0], args[1], current_method.method)

            raise e
