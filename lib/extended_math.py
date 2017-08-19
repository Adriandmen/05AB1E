import math
import sys
from .commands import ast_int_eval, first_n_primes
sys.setrecursionlimit(5000)


# Global dicts for recursive methods
pre_fibonacci = {0: 0, 1: 1}


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
    
    "Åp": MethodAttribute(
        lambda x: first_n_primes(int(x)),
        arity=1
    ),

    "ÅA": MethodAttribute(
        lambda y: (lambda x: sum(ast_int_eval(a) for a in x) / len(x))(str(y) if type(y) is int else y),
        arity=1
    ),

    "ÅT": MethodAttribute(
        lambda x: list_until(lambda a: a * (a + 1) // 2, int(x)),
        arity=1
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
        result = current_method.method(*args)

        return result

