import argparse
import time
import lib.asciicanvas as canvas
import itertools
import os
import tempfile

from sys import stderr

from lib.constants import *
from lib.encoding import *
from lib.vectorizer import *
from lib.statements import *
from lib.constants import ConstantsInvoker
from lib.extended_math import ExtendedMathInvoker
from behaviour.status import Status
from behaviour.environment import Environment, GlobalEnvironment

ExtendedMath = ExtendedMathInvoker()
Constants = ConstantsInvoker()


recent_inputs = []
global_env = GlobalEnvironment()


def get_input():
    a = input()

    if a[:3] == "\"\"\"":
        a = a[3:]
        while a[-3:] != "\"\"\"":
            a += "\n" + input()

        a = a[:-3]

    if is_array(a):
        a = apply_safe(ast.literal_eval, a)

    recent_inputs.append(a)
    return a


def opt_input():
    try:
        return get_input()
    except:
        return recent_inputs[-1]


def is_array(array):
    if not array:
        return False

    array = str(array)
    if array[0] == "[" and array[-1] == "]":
        return True
    return False


class Osabie:

    def __init__(self,
                 commands: str,
                 debug: bool=False,
                 safe_mode: bool=False,
                 suppress_print: bool=False,
                 environment: Environment=None,
                 stack: list=None,
                 depth: int=0):

        # Params
        self.commands = commands
        self.debug = debug
        self.safe_mode = safe_mode
        self.suppress_print = suppress_print
        self.depth = depth

        # Pointer position
        self.pointer_position = -1

        # Configurable parameters
        self.stack = stack if stack else []
        self.environment = environment if environment else Environment()  # type: Environment

    def reset(self):
        global global_env
        global_env = GlobalEnvironment()
        self.environment = Environment()

    def interp(self) -> (list, Status):
        while self.pointer_position < len(self.commands) - 1:
            try:
                status = self.step()
                if status == Status.BREAK or status == Status.EXIT:
                    if self.debug:
                        print("Status was", status)
                    return self.stack, status

            except Exception as e:
                if self.debug:
                    print(e)

        return self.stack, Status.OK

    def run(self) -> (list, Status):
        self.interp()

        if not global_env.has_printed and not self.suppress_print:
            if self.stack:
                print(self.stack[len(self.stack) - 1])
            elif ".\u02c6" in self.commands:
                if len(recent_inputs) == 0:
                    try:
                        a = int(get_input())
                    except:
                        a = -1
                print(global_env.global_array[a])
            elif ".^" in self.commands:
                if len(recent_inputs) == 0:
                    try:
                        a = int(get_input())
                    except:
                        a = -1
                print(global_env.global_array[a])
            elif "\u00b5" in self.commands:
                print(self.environment.range_variable)
            elif "\u02c6" in self.commands:
                print(global_env.global_array)
            elif "\u039b" in self.commands:
                print(canvas.canvas_dict_to_string(self.environment.current_canvas))
            elif "\u00bc" in self.commands:
                print(global_env.counter_variable)
        if self.debug:
            print("stack > " + str(self.stack))

    def pop_stack(self, default=None):

        if self.stack:
            return self.stack.pop()

        try:
            a = opt_input()
        except:
            if default is None:
                raise
            a = default

        if is_array(a):
            a = ast_int_eval(a)

        return a

    def __run_subprogram(self, commands: str, environment: Environment=None, stack: list=None) -> (list, Status):
        env = environment if environment else self.environment
        stk = stack if stack else self.stack
        sub_program = Osabie(commands, debug=self.debug, safe_mode=self.safe_mode,
                             environment=env, stack=stk, depth=self.depth + 1)

        return sub_program.interp()

    def value(self, commands: str, stack: list):
        curr_stack, _ = self.__run_subprogram(commands, stack=stack)
        return curr_stack[-1] if curr_stack else None

    def step(self):

        global global_env

        self.pointer_position += 1
        current_command = self.commands[self.pointer_position]
        status = Status.OK

        if current_command == ".":
            self.pointer_position += 1
            current_command += self.commands[self.pointer_position]

        if current_command == "\u017e":
            self.pointer_position += 1
            current_command += self.commands[self.pointer_position]

        if current_command == "\u00c5":
            self.pointer_position += 1
            current_command += self.commands[self.pointer_position]

        if self.debug:
            try:
                print()
                print("----------------------------------")
                print("Depth:", self.depth)
                print("Stack:", self.stack)
                print("Current command:", current_command)
            except:
                pass

        if current_command == "h":
            a = self.pop_stack(default="")
            self.stack.append(vectorized_evaluation(a, 16, convert_to_base))

        # Command: b
        # pop a
        # push bin(a)
        elif current_command == "b":
            a = self.pop_stack(default="")
            self.stack.append(vectorized_evaluation(a, 2, convert_to_base))

        # Command: B
        # pop a,b
        # push base(a, b)
        elif current_command == "B":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")
            self.stack.append(vectorized_evaluation(a, b, convert_to_base))

        # Command: в
        # pop a,b
        # push a converted to base b (arbitrary)
        elif current_command == "\u0432":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")
            self.stack.append(vectorized_evaluation(a, b, convert_to_base_arbitrary))

        # self.commands: [0-9]+
        # Push the corresponding digit value onto the self.stack,
        # as a single number if multiple digits are consecutive
        elif is_digit_value(current_command):
            temp_number = ""
            temp_number += current_command
            temp_position = self.pointer_position
            while temp_position < len(self.commands) - 1:
                temp_position += 1
                try:
                    current_command = self.commands[temp_position]
                except:
                    break
                if is_digit_value(current_command):
                    temp_number += current_command
                    self.pointer_position += 1
                else:
                    break
            self.stack.append(temp_number)

        # Command: "
        # Start/end string literal
        elif current_command == "\"":
            temp_string = ""
            temp_string_2 = ""
            temp_position = self.pointer_position
            while temp_position < len(self.commands) - 1:
                temp_position += 1
                try:
                    current_command = self.commands[temp_position]
                except:
                    break
                if current_command == "\"":
                    break
                # String interpolation (command: ÿ)
                elif current_command == "\u00ff":
                    temp_string += str(self.pop_stack(default=""))
                    self.pointer_position += 1
                else:
                    temp_string += current_command
                    self.pointer_position += 1
            self.pointer_position += 1
            self.stack.append(temp_string)

        # Command: ’
        # start/end of a compressed string (no implicit space)
        elif current_command == "\u2019":
            temp_string = ""
            temp_string_2 = ""
            temp_index = ""
            temp_position = self.pointer_position
            while temp_position < len(self.commands) - 1:
                temp_position += 1
                try:
                    current_command = self.commands[temp_position]
                    if dictionary.unicode_index.__contains__(
                            current_command):
                        temp_index += str(dictionary.unicode_index.index(
                            current_command)).rjust(2, "0")
                        temp_position += 1
                        self.pointer_position += 2
                        current_command = self.commands[temp_position]
                        temp_index += str(dictionary.unicode_index.index(
                            current_command)).rjust(2, "0")
                        temp_string += dictionary.dictionary[
                            int(temp_index)]
                        temp_index = ""
                    elif current_command == "\u2019":
                        self.pointer_position += 1
                        break
                    # String interpolation (command: ÿ)
                    elif current_command == "\u00ff":
                        temp_string += str(self.pop_stack(default=""))
                        self.pointer_position += 1
                    else:
                        temp_string += current_command
                        self.pointer_position += 1
                except:
                    self.pointer_position += 1
                    break
                if self.debug:
                    print("{} with {}".format(
                        self.pointer_position, hex(ord(current_command))
                    ))

            self.stack.append(temp_string)

        # Command: ‘
        # Start/end of a compressed string (upper)
        elif current_command == "\u2018":
            temp_string = ""
            temp_string_2 = ""
            temp_index = ""
            temp_position = self.pointer_position
            while temp_position < len(self.commands) - 1:
                temp_position += 1
                try:
                    current_command = self.commands[temp_position]
                    if dictionary.unicode_index.__contains__(
                            current_command):
                        temp_index += str(dictionary.unicode_index.index(
                            current_command)).rjust(2, "0")
                        temp_position += 1
                        self.pointer_position += 2
                        current_command = self.commands[temp_position]
                        temp_index += str(dictionary.unicode_index.index(
                            current_command)).rjust(2, "0")
                        if temp_string == "":
                            temp_string += dictionary.dictionary[
                                int(temp_index)].upper()
                        else:
                            temp_string += " " + dictionary.dictionary[
                                int(temp_index)].upper()
                        temp_index = ""
                    elif current_command == "\u2018":
                        self.pointer_position += 1
                        break
                    # String interpolation (command: ÿ)
                    elif current_command == "\u00ff":
                        temp_string += str(self.pop_stack(default=""))
                        self.pointer_position += 1
                    else:
                        temp_string += current_command
                        self.pointer_position += 1
                except:
                    self.pointer_position += 1
                    break
                if self.debug:
                    print("{} with {}".format(
                        self.pointer_position, hex(ord(current_command))
                    ))

            self.stack.append(temp_string)

        # Command: “
        # Start/end of a compressed string (normal)
        elif current_command == "\u201c":
            temp_string = ""
            temp_string_2 = ""
            temp_index = ""
            temp_position = self.pointer_position
            while temp_position < len(self.commands) - 1:
                temp_position += 1
                try:
                    current_command = self.commands[temp_position]
                    if dictionary.unicode_index.__contains__(
                            current_command):
                        temp_index += str(dictionary.unicode_index.index(
                            current_command)).rjust(2, "0")
                        temp_position += 1
                        self.pointer_position += 2
                        current_command = self.commands[temp_position]
                        temp_index += str(dictionary.unicode_index.index(
                            current_command)).rjust(2, "0")
                        if temp_string == "":
                            temp_string += dictionary.dictionary[
                                int(temp_index)]
                        else:
                            temp_string += " " + dictionary.dictionary[
                                int(temp_index)]
                        temp_index = ""
                    elif current_command == "\u201c":
                        self.pointer_position += 1
                        break
                    # String interpolation (command: ÿ)
                    elif current_command == "\u00ff":
                        temp_string += str(self.pop_stack(default=""))
                        self.pointer_position += 1
                    else:
                        temp_string += current_command
                        self.pointer_position += 1
                except:
                    self.pointer_position += 1
                    break
                if self.debug:
                    print("{} with {}".format(
                        self.pointer_position, hex(ord(current_command))
                    ))

            self.stack.append(temp_string)

        # Command: ”
        # Start/end of a compressed string (title)
        elif current_command == "\u201d":
            temp_string = ""
            temp_string_2 = ""
            temp_index = ""
            temp_position = self.pointer_position
            while temp_position < len(self.commands) - 1:
                temp_position += 1
                try:
                    current_command = self.commands[temp_position]
                    if dictionary.unicode_index.__contains__(
                            current_command):
                        temp_index += str(dictionary.unicode_index.index(
                            current_command)).rjust(2, "0")
                        temp_position += 1
                        self.pointer_position += 2
                        current_command = self.commands[temp_position]
                        temp_index += str(dictionary.unicode_index.index(
                            current_command)).rjust(2, "0")
                        if temp_string == "":
                            temp_string += dictionary.dictionary[
                                int(temp_index)].title()
                        else:
                            temp_string += " " + dictionary.dictionary[
                                int(temp_index)].title()
                        temp_index = ""
                    elif current_command == "\u201d":
                        self.pointer_position += 1
                        break
                    # String interpolation (command: ÿ)
                    elif current_command == "\u00ff":
                        temp_string += str(self.pop_stack(default=""))
                        self.pointer_position += 1
                    else:
                        temp_string += current_command
                        self.pointer_position += 1
                except:
                    self.pointer_position += 1
                    break
                if self.debug:
                    print("{} with {}".format(
                        self.pointer_position, hex(ord(current_command))
                    ))

            self.stack.append(temp_string)

        # Command: ª
        # pop a
        # push sentence_cased(a)
        elif current_command == "\u00aa":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(a, sentence_case, str))

        # Command: ù
        # pop a,b
        # push a with elements of length b
        elif current_command == "\u00f9":
            b = self.pop_stack(default=0)
            a = self.pop_stack(default=[])

            if type(b) is not list:
                temp_list = []
                try:
                    b_length = int(ast_int_eval(b))
                except:
                    b_length = len(b)

                for Q in a:
                    lenQ = len(Q if type(Q) is list else str(Q))
                    if lenQ == b_length:
                        temp_list.append(Q)
                self.stack.append(temp_list)
            else:
                temp_list_2 = []
                for R in b:
                    temp_list = []

                    try:
                        R_length = int(ast_int_eval(R))
                    except:
                        R_length = len(R)

                    for Q in a:
                        lenQ = len(Q if type(Q) is list else str(Q))
                        if lenQ == R_length:
                            temp_list.append(Q)
                    temp_list_2.append(temp_list)
                self.stack.append(temp_list_2)

        # Command: Λ
        # pop a,b,c
        # store a canvas with {a: num, b: filler, c: pattern}
        elif current_command == "\u039B":
            pattern = self.pop_stack()
            filler = self.pop_stack()
            number_pattern = self.pop_stack()

            self.environment.current_canvas, self.environment.current_cursor = canvas.canvas_code_to_string(
                number_pattern, pattern, filler, self.environment.current_canvas, self.environment.current_cursor
            )

        # Command: .Λ
        # pop a,b,c
        # store a canvas with {a: num, b: filler, c: pattern}
        # and push the string to the self.stack
        elif current_command == ".\u039B":
            pattern = self.pop_stack()
            filler = self.pop_stack()
            number_pattern = self.pop_stack()

            self.environment.current_canvas, self.environment.current_cursor = canvas.canvas_code_to_string(
                number_pattern, pattern, filler, self.environment.current_canvas, self.environment.current_cursor
            )

            self.stack.append(canvas.canvas_dict_to_string(self.environment.current_canvas))

        # Command: ∊
        # pop a
        # push vertically mirrored a
        elif current_command == "\u220A":
            a = self.pop_stack(default="")
            self.stack.append(apply_safe(vertical_mirror, a))

        # Command: .∊
        # pop a
        # push intersected vertical mirror a
        elif current_command == ".\u220A":
            a = self.pop_stack(default="")
            self.stack.append(apply_safe(vertical_intersected_mirror, a))

        # Command: ∍
        # pop a,b
        # push a extended/shortened to length b
        elif current_command == "\u220D":
            b = self.pop_stack(default=0)
            a = self.pop_stack(default="")
            self.stack.append(apply_safe(shape_like, a, b))

        # Command: ā
        # get a
        # push range(1, len(a) + 1)
        elif current_command == "\u0101":
            a = self.pop_stack(default="")

            self.stack.append(a)

            if type(a) is not list:
                a = str(a)

            self.stack.append(apply_safe(lambda a: list(range(1, len(a) + 1)), a))

        # Command: Ā
        # pop a
        # push truthified a:
        #   if a can be converted to a number: 1 if != 0, 0 otherwise
        #   if a is a string: 1 if non-empty, 0 otherwise
        elif current_command == "\u0100":
            a = self.pop_stack(default=0)

            self.stack.append(single_vectorized_evaluation(
                a, lambda a: int(not not a), float
            ))

        # Command: ∞
        # pop a
        # push mirrored a
        elif current_command == "\u221e":
            a = self.pop_stack(default="")
            self.stack.append(apply_safe(mirror, a))

        # Command: .∞
        # pop a
        # push intersected mirror a
        elif current_command == ".\u221e":
            a = self.pop_stack(default="")
            self.stack.append(apply_safe(intersected_mirror, a))

        # Command: н
        # pop a
        # push a[0]
        elif current_command == "\u043D":
            a = self.pop_stack(default="")
            try:
                if type(a) is list:
                    self.stack.append(a[0])
                else:
                    self.stack.append(str(a)[0])
            except:
                self.stack.append(a)

        # Command: θ
        # pop a
        # push a[-1]
        elif current_command == "\u03B8":
            a = self.pop_stack(default="")

            if type(a) is list:
                self.stack.append(a[-1])
            else:
                self.stack.append(str(a)[-1])

        # Command: ζ
        # pop a,(b):
        # if a is list, zip with spaces
        # otherwise: pop b, zip a with b
        elif current_command == "\u03B6":
            b = self.pop_stack(default="")

            if type(b) is list:
                a, b = b, " "
                self.stack.append(apply_safe(zip_with, a, b))
            else:
                b = str(b)
                a = self.pop_stack(default="")
                self.stack.append(apply_safe(zip_with, a, b))

        # Command: ε
        # Usage: εCODE}
        # pop a
        # apply each on a
        elif current_command == "\u03B5":
            a = self.pop_stack(default="")

            if type(a) is not list:
                a = str(a)

            statement, remaining = get_statements(self.commands[self.pointer_position + 1:])

            result = []
            for element in a:
                value = self.value(statement, stack=[element])
                result.append(value)

            self.pointer_position += len(statement) + 1
            self.stack.append(result)

        # Command: !
        # pop a
        # push factorial(a)
        elif current_command == "!":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(a, math.factorial, int))

        # Command: +
        # pop a,b
        # push a+b
        elif current_command == "+":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            self.stack.append(vectorized_evaluation(
                a, b, lambda a, b: a + b if type(a) is not str and type(b) is not str else str(a) + str(b), ast_int_eval
            ))

        # Command: -
        # pop a,b
        # push a-b
        elif current_command == "-":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            self.stack.append(vectorized_evaluation(
                a, b, lambda a, b: a - b, ast_int_eval
            ))

        # Command: *
        # pop a,b
        # push a*b
        elif current_command == "*":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            self.stack.append(vectorized_evaluation(
                a, b, lambda a, b: a * b, ast_int_eval
            ))

        # Command: /
        # pop a,b
        # push a / b
        elif current_command == "/":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            self.stack.append(vectorized_evaluation(
                a, b, lambda a, b: a / b, ast_int_eval
            ))

        # Command: %
        # pop a,b
        # push a % b
        elif current_command == "%":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            self.stack.append(vectorized_evaluation(
                a, b, lambda a, b: a % b, ast_int_eval
            ))

        # Command: D
        # pop a
        # push a, a
        elif current_command == "D":
            a = self.pop_stack()
            self.stack.append(a)
            self.stack.append(a)

        # Command: R
        # pop a
        # push reversed a
        elif current_command == "R":
            a = self.pop_stack(default="")
            if type(a) is list:
                self.stack.append(a[::-1])
            else:
                self.stack.append(str(a)[::-1])

        # Command: I
        # push input()
        elif current_command == "I":
            a = opt_input()
            self.stack.append(a)

        # Command: $
        # push 1, input()
        elif current_command == "$":
            self.stack.append(1)

            try:
                a = get_input()
                self.stack.append(a)
                recent_inputs.append(a)
            except:
                self.stack.append("")

        # Command: H
        # pop a
        # push int(a, 16)
        elif current_command == "H":
            a = self.pop_stack(default="")

            self.stack.append(single_vectorized_evaluation(
                a, lambda a: int(a, 16), str
            ))

        # Command: C
        # pop a
        # push int(a, 2)
        # Error: push ""
        elif current_command == "C":
            a = self.pop_stack(default="")

            self.stack.append(single_vectorized_evaluation(
                a, lambda a: int(a, 2), str
            ))

        # Command: a
        # pop a
        # push isAlpha(a)
        elif current_command == "a":
            a = self.pop_stack(default=0)
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: is_alpha_value(a), str
            ))

        # Command: d
        # pop a
        # push isNumber(a)
        elif current_command == "d":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: int(type(a) is not str), ast_int_eval
            ))

        # Command: p
        # pop a
        # push isPrime(a)
        elif current_command == "p":
            a = self.pop_stack(default=0)
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: is_prime(a), ast_int_eval
            ))

        # Command: u
        # pop a
        # push uppercase(a)
        elif current_command == "u":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: a.upper(), str
            ))

        # Command: l
        # pop a
        # push lowercase(a)
        elif current_command == "l":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: a.lower(), str
            ))

        # Command: _
        # pop a
        # push negative bool of a:
        #   if a can be converted to a number: 1 if == 0, 0 otherwise
        #   if a is a string: 1 if empty, 0 otherwise
        # Error: push 0
        elif current_command == "_":
            a = self.pop_stack(default=1)
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: int(not a), float
            ))

        # Command: s
        # pop a,b
        # push b,a
        elif current_command == "s":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")
            self.stack.append(b)
            self.stack.append(a)

        # Command: |
        # push the rest of input as an array with strings
        elif current_command == "|":
            temp_list = []
            try:
                while True:
                    a = get_input()
                    if a == "":
                        break
                    temp_list.append(a)
            except:
                pass
            self.stack.append(temp_list)

        # Command: ≠
        # pop a
        # push 05AB1E falsified a (a != 1)
        elif current_command == "\u2260":
            a = self.pop_stack(default=0)

            self.stack.append(single_vectorized_evaluation(
                a, lambda a: int(a != 1), ast_int_eval
            ))

        # Command: Θ
        # pop a
        # push 05AB1E truthified a (a == 1)
        elif current_command == "\u0398":
            a = self.pop_stack(default=0)
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: int(a == 1), ast_int_eval
            ))

        # Command: м
        # pop a,b
        # push a.remove(all elements of b)
        elif current_command == "\u043C":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            if type(b) is list:
                b = [str(x) for x in deep_flatten(b)]
            else:
                b = [x for x in str(b)]

            for i in b:
                a = single_vectorized_evaluation(
                    a, lambda a: a.replace(i, ''), str
                )

            self.stack.append(a)

        # Command: L
        # pop a
        # push [1 .. a]
        elif current_command == "L":
            temp_list = []
            a = self.pop_stack(default=1)
            if type(a) is list:
                for Q in a:
                    Q = apply_safe(int, Q)

                    if type(Q) is not int:
                        temp_list.append(Q)
                    elif Q > 0:
                        for X in range(1, Q + 1):
                            temp_list.append(X)
                    elif Q < 0:
                        for X in range(1, (Q * -1) + 1):
                            temp_list.append(X * -1)
                    else:
                        temp_list.append(0)
            else:
                a = apply_safe(int, a)

                if type(a) is not int:
                    temp_list.append(a)
                elif a > 0:
                    for X in range(1, a + 1):
                        temp_list.append(X)
                elif a < 0:
                    for X in range(1, (a * -1) + 1):
                        temp_list.append(X * -1)
                else:
                    temp_list.append(0)

            self.stack.append(temp_list)

        # Command: r
        # reverse the self.stack
        elif current_command == "r":
            self.stack.reverse()

        # Command: i
        # if...}else...} statement
        elif current_command == "i":
            statement, else_statement, remaining = get_statements(self.commands[self.pointer_position + 1:], True)
            a = apply_safe(ast_int_eval, self.pop_stack(default=0))

            if a == 1:
                self.stack, status = self.__run_subprogram(statement)
            elif else_statement:
                self.stack, status = self.__run_subprogram(else_statement)

            self.pointer_position += len(statement) + len(else_statement) + 1

            if status == Status.BREAK:
                return Status.OK
            elif status == Status.EXIT:
                return Status.EXIT

        # Command: \
        # pop a
        elif current_command == "\\":
            self.pop_stack()

        # Command: `
        # pop a
        # push all items of a into the self.stack
        elif current_command == "`":
            a = self.pop_stack()

            if type(a) is not list:
                a = str(a)

            for x in a:
                self.stack.append(x)

        # Command: x
        # pop a
        # push a, a * 2
        elif current_command == "x":
            a = self.pop_stack(default="")
            self.stack.append(a)
            self.stack.append(single_vectorized_evaluation(a, lambda a: a * 2, ast_int_eval))

        # Command: F
        # pop a
        # for N in range(0, a) { }: F(self.commands)} / N = variable
        elif current_command == "F":
            statement, remaining = get_statements(self.commands[self.pointer_position + 1:])
            a = apply_safe(int, self.pop_stack(default=0))

            self.pointer_position += len(statement) + 1

            if type(a) is int and a != 0:
                for range_variable in range(0, a):
                    new_env = self.environment
                    new_env.range_variable = range_variable
                    self.stack, status = self.__run_subprogram(statement, environment=new_env)

                    if status == Status.BREAK:
                        return Status.OK
                    elif status == Status.EXIT:
                        return Status.EXIT

        # Command: G
        # pop a
        # for N in range(1, a) { }: F(self.commands)} / N = variable
        elif current_command == "G":
            statement, remaining = get_statements(self.commands[self.pointer_position + 1:])
            a = apply_safe(int, self.pop_stack(default=0))

            self.pointer_position += len(statement) + 1

            if type(a) is int and a > 1:
                for range_variable in range(1, a):
                    self.stack, status = self.__run_subprogram(statement)

                    if status == Status.BREAK:
                        return Status.OK
                    elif status == Status.EXIT:
                        return Status.EXIT

        # Command: µ
        # pop a
        # while counter_variable != a, do...
        elif current_command == "\u00b5":
            statement, remaining = get_statements(self.commands[self.pointer_position + 1:])
            a = apply_safe(int, self.pop_stack(default=0))

            self.pointer_position += len(statement) + 1

            if type(a) is int:
                range_variable = 0

                if '\u00bc' not in statement and '\u00bd' not in statement:
                    statement += '\u00bd'
                    self.pointer_position -= 1

                while global_env.counter_variable != a:
                    range_variable += 1
                    new_env = self.environment
                    new_env.range_variable = range_variable
                    self.stack, status = self.__run_subprogram(statement, environment=new_env)

                    if status == Status.BREAK:
                        return Status.OK
                    elif status == Status.EXIT:
                        return Status.EXIT

        # Command: Ë
        # pop a
        # push 1 if all equal else 0
        elif current_command == "\u00cb":
            a = self.pop_stack(default="")

            if type(a) is not list:
                a = str(a)

            if not len(a):
                self.stack.append(1)
                return

            # try to convert floats to int first so that
            # 1.0 and 1 are considered equal
            converted = []
            for item in a:
                item = str(item)
                try:
                    item = float(item)
                except:
                    pass
                else:
                    if int(item) == item:
                        item = int(item)

                converted.append(item)

            compare = converted[0]
            result = True

            for item in converted:
                result = result and item == compare

            self.stack.append(int(result))

        # Command: ƒ
        # pop a
        # push for N in range(0, a + 1)
        elif current_command == "\u0192":
            statement, remaining = get_statements(self.commands[self.pointer_position + 1:])
            a = apply_safe(int, self.pop_stack(default=-1))

            self.pointer_position += len(statement) + 1

            if type(a) is int and a > -1:
                for range_variable in range(0, a + 1):
                    new_env = self.environment
                    new_env.range_variable = range_variable
                    self.stack, status = self.__run_subprogram(statement, environment=new_env)

                    if status == Status.BREAK:
                        return Status.OK
                    elif status == Status.EXIT:
                        return Status.EXIT

        # Command: N
        # Push iteration counter
        elif current_command == "N":
            self.stack.append(self.environment.range_variable)

        # Command: T
        # Push 10
        elif current_command == "T":
            self.stack.append(10)

        # Command: S
        # pop a
        # push all chars a seperate
        elif current_command == "S":
            a = self.pop_stack(default="")

            if type(a) is not list:
                self.stack.append([x for x in str(a)])
            else:
                self.stack.append(vectorized_aggregator(
                    a, lambda acc, val: acc + [x for x in val], str, []
                ))

        # Command: ^
        # pop a,b
        # push a XOR b
        elif current_command == "^":
            b = self.pop_stack(default=0)
            a = self.pop_stack(default=0)
            self.stack.append(vectorized_evaluation(
                a, b, lambda a, b: a ^ b, int
            ))

        # Command: ~
        # pop a,b
        # push a OR b
        elif current_command == "~":
            b = self.pop_stack(default=0)
            a = self.pop_stack(default=0)
            self.stack.append(vectorized_evaluation(
                a, b, lambda a, b: a | b, int
            ))

        # Command: &
        # pop a,b
        # push a AND b
        elif current_command == "&":
            b = self.pop_stack(default=0)
            a = self.pop_stack(default=0)
            self.stack.append(vectorized_evaluation(
                a, b, lambda a, b: a & b, int
            ))

        # Command: c
        # pop a,b
        # push a nCr b
        elif current_command == "c":
            b = self.pop_stack(default=1)
            a = self.pop_stack(default=0)
            self.stack.append(vectorized_evaluation(
                a, b, lambda a, b: combinations(a, b), int
            ))

        # Command: e
        # pop a,b
        # push a nPr b
        elif current_command == "e":
            b = self.pop_stack(default=1)
            a = self.pop_stack(default=0)
            self.stack.append(vectorized_evaluation(
                a, b, lambda a, b: permutations(a, b), int
            ))

        # Command: >
        # pop a
        # push a + 1
        elif current_command == ">":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: a + 1, ast_int_eval
            ))

        # Command: <
        # pop a
        # push a - 1
        elif current_command == "<":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: a - 1, ast_int_eval
            ))

        # Command: '
        # push char ( 'a pushes "a" )
        elif current_command == "'":
            temp_string = ""
            temp_index = ""
            self.pointer_position += 1
            temp_position = self.pointer_position
            current_command = self.commands[self.pointer_position]
            if dictionary.unicode_index.__contains__(current_command):
                temp_index += str(dictionary.unicode_index.index(
                    current_command)).rjust(2, "0")
                temp_position += 1
                self.pointer_position += 1
                current_command = self.commands[temp_position]
                temp_index += str(dictionary.unicode_index.index(
                    current_command)).rjust(2, "0")
                if temp_string == "":
                    temp_string += dictionary.dictionary[int(temp_index)]
                else:
                    temp_string += " " + dictionary.dictionary[
                        int(temp_index)]
                temp_index = ""
                self.stack.append(temp_string)
            else:
                temp_string = self.commands[self.pointer_position]
                self.stack.append(temp_string)

        # Command: „
        # 2 char string / can also be used for 2 compressed strings
        elif current_command == "\u201e":
            temp_string = ""
            temp_index = ""

            word_count = 0

            while word_count != 2:
                self.pointer_position += 1
                temp_position = self.pointer_position
                current_command = self.commands[self.pointer_position]
                if dictionary.unicode_index.__contains__(current_command):
                    temp_index += str(dictionary.unicode_index.index(
                        current_command)).rjust(2, "0")
                    temp_position += 1
                    self.pointer_position += 1
                    current_command = self.commands[temp_position]
                    temp_index += str(dictionary.unicode_index.index(
                        current_command)).rjust(2, "0")
                    if temp_string == "":
                        temp_string += dictionary.dictionary[
                            int(temp_index)]
                    else:
                        temp_string += " " + dictionary.dictionary[
                            int(temp_index)]
                    temp_index = ""
                    word_count += 1
                # String interpolation (command: ÿ)
                elif current_command == "\u00ff":
                    temp_string += str(self.pop_stack(default=""))
                    word_count += 1
                else:
                    temp_string += self.commands[self.pointer_position]
                    word_count += 1

            self.stack.append(temp_string)

        # Command: …
        # 3 char string / can also be used for 3 compressed strings
        elif current_command == "\u2026":
            temp_string = ""
            temp_index = ""

            word_count = 0

            while word_count != 3:
                self.pointer_position += 1
                temp_position = self.pointer_position
                current_command = self.commands[self.pointer_position]
                if dictionary.unicode_index.__contains__(current_command):
                    temp_index += str(dictionary.unicode_index.index(
                        current_command)).rjust(2, "0")
                    temp_position += 1
                    self.pointer_position += 1
                    current_command = self.commands[temp_position]
                    temp_index += str(dictionary.unicode_index.index(
                        current_command)).rjust(2, "0")
                    if temp_string == "":
                        temp_string += dictionary.dictionary[
                            int(temp_index)]
                    else:
                        temp_string += " " + dictionary.dictionary[
                            int(temp_index)]
                    temp_index = ""
                    word_count += 1
                # String interpolation (command: ÿ)
                elif current_command == "\u00ff":
                    temp_string += str(self.pop_stack(default=""))
                    word_count += 1
                else:
                    temp_string += self.commands[self.pointer_position]
                    word_count += 1

            self.stack.append(temp_string)

        # Command: ö
        # pop a,b
        # push int(a, b)
        elif current_command == "\u00f6":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            self.stack.append(vectorized_evaluation(
                a, b, lambda a, b: convert_from_base(a, b)
            ))

        # Command: ¸
        # pop a
        # push [a]
        elif current_command == "\u00b8":
            a = self.pop_stack(default="")
            self.stack.append([a])

        # Command: .S
        # pop a,b
        # push 1 if a > b, -1 if a < b, 0 if a == b
        elif current_command == ".S":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            if type(a) is list:
                if type(b) is list:
                    temp_list = []
                    for Q in range(0, len(a)):
                        aieAq = apply_safe(ast_int_eval, str(a[Q]))
                        aieBq = apply_safe(ast_int_eval, str(b[Q]))

                        if type(aieAq) is not int or type(aieBq) is not int:
                            temp_list.append(aieAq)
                        elif aieAq > aieBq:
                            temp_list.append(1)
                        elif aieAq < aieBq:
                            temp_list.append(-1)
                        elif aieAq == aieBq:
                            temp_list.append(0)
                    self.stack.append(temp_list)
                else:
                    temp_list = []
                    aieBq = apply_safe(ast_int_eval, str(b))

                    for Q in a:
                        aieAq = apply_safe(ast_int_eval, str(Q))

                        if type(aieAq) is not int or type(aieBq) is not int:
                            temp_list.append(aieAq)
                        elif aieAq > aieBq:
                            temp_list.append(1)
                        elif aieAq < aieBq:
                            temp_list.append(-1)
                        elif aieAq == aieBq:
                            temp_list.append(0)
                    self.stack.append(temp_list)
            else:
                if type(b) is list:
                    temp_list = []
                    aieAq = apply_safe(ast_int_eval, str(a))

                    for Q in b:
                        aieBq = apply_safe(ast_int_eval, str(Q))

                        if type(aieAq) is not int or type(aieBq) is not int:
                            temp_list.append(aieAq)
                        elif aieAq > aieBq:
                            temp_list.append(1)
                        elif aieAq < aieBq:
                            temp_list.append(-1)
                        elif aieAq == aieBq:
                            temp_list.append(0)
                    self.stack.append(temp_list)
                else:
                    aieAq = apply_safe(ast_int_eval, str(a))
                    aieBq = apply_safe(ast_int_eval, str(b))

                    if type(aieAq) is not int or type(aieBq) is not int:
                        self.stack.append(aieAq)
                    elif aieAq > aieBq:
                        self.stack.append(1)
                    elif aieAq < aieBq:
                        self.stack.append(-1)
                    elif aieAq == aieBq:
                        self.stack.append(0)

        # Command: [
        # Infinite loop start
        elif current_command == "[":
            statement, remaining = get_statements(self.commands[self.pointer_position + 1:])
            range_variable = -1

            self.pointer_position += len(statement) + 1

            while True:
                range_variable += 1
                new_env = self.environment
                new_env.range_variable = range_variable
                self.stack, status = self.__run_subprogram(statement, environment=new_env)
                if status == Status.BREAK:
                    break

        # Command: #
        # pop a
        # if contains spaces, split on spaces
        # else if 1, break/end
        elif current_command == "#":
            a = self.pop_stack(default=0)
            if " " in str(a):
                self.stack.append(str(a).split(" "))
            else:
                try:
                    if ast_int_eval(a) == 1:
                        return Status.BREAK
                except:
                    pass

        # Command: é
        # pop a
        # push sorted a (key=length)
        elif current_command == "\u00e9":
            a = self.pop_stack(default="")

            if type(a) is not list:
                a = str(a)

            temp_list = []
            for Q in a:
                if type(Q) is not list:
                    temp_list.append(str(Q))
                else:
                    temp_list.append(Q)
            self.stack.append(sorted(temp_list, key=len))

        # Command: =
        # print last item
        elif current_command == "=":
            try:
                a = self.pop_stack()
                self.stack.append(a)
            except:
                a = ""

            print(a)
            global_env.has_printed = True

        # Command: Q
        # pop a,b
        # push a == b (bool)
        elif current_command == "Q":
            b = self.pop_stack(default=0)
            a = self.pop_stack(default=1)

            if type(a) is list and type(b) is list:
                self.stack.append(int(
                    str([str(apply_safe(ast_int_eval, x)) for x in a]) == str(
                        [str(apply_safe(ast_int_eval, x)) for x in b])
                ))
            else:
                self.stack.append(vectorized_evaluation(
                    a, b, lambda a, b: int(a == b), ast_int_eval
                ))

        # Command: Ê
        # pop a,b
        # push a != b (bool)
        elif current_command == "\u00ca":
            b = self.pop_stack(default=0)
            a = self.pop_stack(default=0)

            if type(a) is list and type(b) is list:
                self.stack.append(int(
                    str([str(apply_safe(ast_int_eval, x)) for x in a]) != str(
                        [str(apply_safe(ast_int_eval, x)) for x in b])
                ))
            else:
                self.stack.append(vectorized_evaluation(
                    a, b, lambda a, b: int(a != b), ast_int_eval
                ))

        # Command: (
        # pop a
        # push -a
        elif current_command == "(":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: ast_int_eval(a) * -1
            ))

        # Command: A
        # push [a-z]
        elif current_command == "A":
            self.stack.append('abcdefghijklmnopqrstuvwxyz')

        # Command: ™
        # pop a
        # push title_cased(a)
        elif current_command == "\u2122":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: a.title(), str
            ))

        # Command: E
        # get input
        elif current_command == "E":
            self.stack.append(single_vectorized_evaluation(get_input(), ast_int_eval))

        # Command: )
        # wrap total self.stack to an array
        elif current_command == ")":
            temp_list = []
            if self.stack:
                temp_list = list(self.stack)
                self.stack.clear()
            self.stack.append(temp_list)

        # Command: P
        # pop a
        # if a is list, push total product of a
        # else: push total product of self.stack
        elif current_command == "P":
            a = self.pop_stack(default=[])

            if type(a) is not list:
                a = self.stack + [a]
                self.stack.clear()

            self.stack.append(vectorized_aggregator(
                a, lambda acc, val: acc * val, ast_int_eval, 1
            ))

        # Command: O
        # pop a
        # if a is list, push total sum of a
        # else: push total sum of self.stack
        elif current_command == "O":
            a = self.pop_stack(default=[])

            if type(a) is not list:
                a = self.stack + [a]
                self.stack.clear()

            self.stack.append(vectorized_aggregator(
                a, lambda acc, val: acc + val, ast_int_eval, 0
            ))

        # Command: ;
        # pop a
        # push a / 2
        elif current_command == ";":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: a / 2, ast_int_eval))

        # Command: w
        # wait one second
        elif current_command == "w":
            time.sleep(1)

        # Command: m
        # pop a,b
        # push a**b
        elif current_command == "m":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")
            self.stack.append(vectorized_evaluation(
                a, b, lambda a, b: a ** b, ast_int_eval))

        # Command: X
        # Push variable X
        elif current_command == "X":
            self.stack.append(self.environment.x)

        # Command: Y
        # Push variable Y
        elif current_command == "Y":
            self.stack.append(self.environment.y)

        # Command: z
        # pop a
        # push 1 / a
        elif current_command == "z":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: 1 / a, ast_int_eval))

        # Command: U
        # pop a
        # stores a in variable X
        elif current_command == "U":
            a = self.pop_stack()
            self.environment.x = a

        # Command: V
        # pop a
        # stores a in variable Y
        elif current_command == "V":
            a = self.pop_stack()
            self.environment.y = a

        # Command: W
        # push min(a) without popping
        elif current_command == "W":
            a = self.pop_stack(default="")
            self.stack.append(a)

            a = str(a) if type(a) is not list else deep_flatten(a)
            minval = apply_safe(ast_int_eval, a[0])

            for i in a:
                if type(minval) is str or type(i) is str:
                    minval = min(str(minval), str(i))
                    # fallbacks to number comparison if possible
                    minval = apply_safe(ast_int_eval, minval)
                else:
                    minval = min(minval, i)

            self.stack.append(minval)

        # Command: Z
        # push max(a) without popping
        elif current_command == "Z":
            a = self.pop_stack(default="")
            self.stack.append(a)

            a = str(a) if type(a) is not list else deep_flatten(a)

            maxval = apply_safe(ast_int_eval, a[0])

            for i in a:
                if type(maxval) is str or type(i) is str:
                    maxval = max(str(maxval), str(i))
                    # fallbacks to number comparison if possible
                    maxval = apply_safe(ast_int_eval, maxval)
                else:
                    maxval = max(maxval, i)

            self.stack.append(maxval)

        # Command: q
        # exit the program
        elif current_command == "q":
            return Status.EXIT

        # Command: g
        # pop a
        # push length of a
        elif current_command == "g":
            a = self.pop_stack(default="")
            if type(a) is not list:
                self.stack.append(len(str(a)))
            else:
                self.stack.append(len(a))

        # Command: J
        # pop a
        # push ''.join(a) if a is list / if not, then push ''.join(self.stack)
        elif current_command == "J":
            a = self.pop_stack(default="")

            if type(a) is not list:
                a = self.stack + [a]
                self.stack.clear()

            self.stack.append(vectorized_aggregator(
                a, lambda acc, val: acc + val, str, ""
            ))

        # Command: :
        # pop a,b,c
        # a.replace(b, c) / infinite replacement
        elif current_command == ":":
            c = self.pop_stack()
            b = self.pop_stack()
            a = self.pop_stack()

            self.stack.append(infinite_replace(a, b, c))

        # Command: j
        # pop a,b
        # push ''.join(a) if a is list / if not, then push ''.join(self.stack)
        # Each joined string has a min size of b, and is right justified
        elif current_command == "j":
            b = apply_safe(int, self.pop_stack(default=""))
            a = self.pop_stack(default="")

            if type(b) is not int:
                self.stack.append(a)
                return

            if type(a) is not list:
                a = self.stack + [a]
                self.stack.clear()

            self.stack.append(vectorized_aggregator(
                a, lambda acc, val: acc + val.rjust(b), str, ""
            ))

        # Command: .j
        # (deprecated)
        elif current_command == ".j":
            a = self.pop_stack(default="")
            a = int(a)
            temp_string = ""
            for Q in range(0, len(self.stack) + 1):
                temp_string += str(Q).rjust(a)
            print(temp_string)
            temp_number = 0
            for Q in self.stack:
                temp_number += 1
                temp_string = ""
                if type(Q) is list:
                    for R in Q:
                        temp_string += str(R).rjust(a)
                    print(str(temp_number).rjust(a) + temp_string)
                else:
                    print(str(Q).rjust(a), end="")
            global_env.has_printed = True

        # Command: .J
        # (deprecated)
        elif current_command == ".J":
            a = self.pop_stack(default="")
            a = int(a)
            temp_string = ""
            for Q in range(1, len(self.stack) + 2):
                temp_string += str(Q).rjust(a)
            print(temp_string)
            temp_number = 1
            for Q in self.stack:
                temp_number += 1
                temp_string = ""
                if type(Q) is list:
                    for R in Q:
                        temp_string += str(R).rjust(a)
                    print(str(temp_number).rjust(a) + temp_string)
                else:
                    print(str(Q).rjust(a), end="")
            global_env.has_printed = True

        # Command: .b
        # pop a
        # push letterified(a)
        elif current_command == ".b":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: get_letter(a), int))

        # Command: @
        # pop a
        # pop and push the element at index a in the self.stack (leftmost element = index 0)
        elif current_command == "@":
            a = apply_safe(int, self.pop_stack())

            if type(a) is int:
                self.stack.append(self.stack.pop(a))

        # Command: M
        # push the largest number in the self.stack
        elif current_command == "M":
            temp_list = []
            temp_list.append(self.stack)

            temp_list = deep_flatten(temp_list)
            max_int = -float("inf")
            for Q in temp_list:
                try:
                    if ast_int_eval(Q) > max_int:
                        max_int = ast_int_eval(Q)
                except:
                    0
            self.stack.append(max_int)

        # Command: t
        # pop a
        # push sqrt(a)
        elif current_command == "t":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: math.sqrt(a), ast_int_eval))

        # Command: n
        # pop a
        # push a ** 2
        elif current_command == "n":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: a ** 2, ast_int_eval))

        # Command: o
        # pop a
        # push 2 ** a
        elif current_command == "o":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: 2 ** a, ast_int_eval))

        # Command: k
        # pop a,b
        # push 0-indexed index of b in a (-1 when not found)
        elif current_command == "k":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            try:
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(str(Q))

                    if type(b) is list:
                        self.stack.append([temp_list.index(str(c)) for c in b])
                    else:
                        self.stack.append(temp_list.index(str(b)))
                else:
                    if type(b) is list:
                        self.stack.append([str(a).index(str(c)) for c in b])
                    else:
                        self.stack.append(str(a).index(str(b)))
            except:
                self.stack.append(-1)

        # Command: {
        # pop a
        # push sorted a
        elif current_command == "{":
            a = self.pop_stack(default="")
            if type(a) is list:
                self.stack.append(apply_safe(sorted, a))
            else:
                self.stack.append(''.join(apply_safe(sorted, str(a))))

        # Command: °
        # pop a
        # push 10 ** a
        elif current_command == "\u00b0":
            a = self.pop_stack(default="")

            self.stack.append(single_vectorized_evaluation(
                a, lambda a: 10 ** a, ast_int_eval
            ))

        # Command: º
        # push len(self.stack) > 0
        elif current_command == "\u00ba":
            if len(self.stack) > 0:
                self.stack.append(1)
            else:
                self.stack.append(0)

        # Command: å
        # pop a,b
        # push a in b
        elif current_command == "\u00e5":
            b = self.pop_stack(default=0)
            a = self.pop_stack(default="")

            if type(a) is list:
                a = [str(c) for c in deep_flatten(a)]
            else:
                a = str(a)

            if type(b) is list:
                self.stack.append([int(str(c) in a) for c in deep_flatten(b)])
            else:
                self.stack.append(int(str(b) in a))

        # Command: .å
        # pop a,b
        # push a in b (vectorized)
        elif current_command == ".\u00e5":
            b = self.pop_stack(default=0)
            a = self.pop_stack(default="")

            if type(b) is list:
                a = [str(x) for x in deep_flatten(a)] if type(a) is list else str(a)

                self.stack.append(single_vectorized_evaluation(
                    b, lambda b: int(b in a), str
                ))
            else:
                self.stack.append(vectorized_evaluation(
                    a, b, lambda a, b: int(b in a), str
                ))

        # Command: v
        # pop a
        # range loop: for y in a (y = string, N = index)
        elif current_command == "v":
            statement, remaining = get_statements(self.commands[self.pointer_position + 1:])
            a = self.pop_stack()

            self.pointer_position += len(statement) + 1

            range_variable = -1
            if type(a) is not list:
                a = str(a)
            for string_variable in a:
                range_variable += 1
                if self.debug:
                    print("N = " + str(range_variable))

                new_env = self.environment
                new_env.range_variable = range_variable
                new_env.string_variable = string_variable
                self.stack, status = self.__run_subprogram(statement, environment=new_env)

                if status == Status.BREAK:
                    return Status.OK
                elif status == Status.EXIT:
                    return Status.EXIT

        # Command: y
        # push string variable (used in mapping loops)
        elif current_command == "y":
            self.stack.append(self.environment.string_variable)

        # Command: ,
        # pop a
        # print a
        elif current_command == ",":
            a = self.pop_stack()
            print(str(a))
            global_env.has_printed = True

        # Command: f
        # pop a
        # push list of prime factors (no duplicates)
        elif current_command == "f":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: prime_factorization(a), int
            ))

        # Command: Ò
        # pop a
        # push list of prime factors (with duplicates)
        elif current_command == "\u00d2":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: prime_factorization_duplicates(a), int
            ))

        # Command: Ó
        # pop a
        # push list of exponents of prime factors (2^a, 3^b, 5^c, 7^d, etc.)
        elif current_command == "\u00d3":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: prime_factorization_powers(a), int
            ))

        # Command: ú
        # pop a,b
        # push a padded with b spaces in the front
        elif current_command == "\u00fa":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            # backward compatibility: swap a<=>b if necessary
            try:
                [int(c) for c in deep_flatten([b])]
            except:
                a, b = b, a

            self.stack.append(vectorized_evaluation(
                a, b, lambda a, b: " " * int(b) + str(a)
            ))

        # Command: þ
        # pop a
        # push only digits of a
        elif current_command == "\u00fe":
            a = self.pop_stack(default="")
            self.stack.append(vectorized_filter(a, is_digit_value, str))

        # Command: á
        # pop a
        # push only letters of a
        elif current_command == "\u00e1":
            a = self.pop_stack(default="")
            self.stack.append(vectorized_filter(a, is_alpha_value, str))

        # Command: .u
        # pop a
        # push is_upper(a)
        elif current_command == ".u":
            a = self.pop_stack(default="")

            self.stack.append(single_vectorized_evaluation(
                a, lambda a: int(is_alpha_value(a) and str(a).upper() == str(a))
            ))

        # Command: .l
        # pop a
        # push is_lower(a)
        elif current_command == ".l":
            a = self.pop_stack(default="")

            self.stack.append(single_vectorized_evaluation(
                a, lambda a: int(is_alpha_value(a) and str(a).lower() == str(a))
            ))

        # Command: ê
        # pop a
        # push sorted_uniquified(a)
        elif current_command == "\u00ea":
            a = self.pop_stack(default="")
            a = apply_safe(uniquify, a)
            sorted_a = apply_safe(sorted, a)
            self.stack.append(sorted_a if type(a) is list else ''.join(sorted_a))

        # Command: Ç
        # pop a
        # push ASCII value of a
        elif current_command == "\u00c7":
            a = self.pop_stack("")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: ord(a) if len(a) == 1 else [ord(c) for c in a], str
            ))

        # Command: ç
        # pop a
        # push char a
        elif current_command == "\u00e7":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: chr(a), int
            ))

        # Command: ˜
        # pop a
        # push deep flattened a
        elif current_command == "\u02dc":
            a = self.pop_stack(default=[])
            self.stack.append(deep_flatten(a))

        # Command: ô
        # pop a,b
        # push a split in pieces of b
        elif current_command == "\u00f4":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            if type(b) is list and type(a) is not list:
                a, b = b, a

            self.stack.append(apply_safe(even_divide, a, b))

        # Command: í
        # pop a
        # push [reversed Q for Q in a] (short for €R)
        elif current_command == "\u00ed":
            a = self.pop_stack(default="")
            temp_list = []

            for Q in a:
                if type(Q) is not list:
                    Q = str(Q)
                temp_list.append(Q[::-1])
            self.stack.append(temp_list)

        # Command: ÷
        # pop a,b
        # push a // b
        elif current_command == "\u00f7":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")
            self.stack.append(vectorized_evaluation(
                a, b, lambda a, b: a // b, ast_int_eval
            ))

        # Command: ±
        # pop a
        # push bitwise not a
        elif current_command == "\u00b1":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: ~a, int
            ))

        # Command: Æ
        # pop a
        # push reduced substraction a
        elif current_command == "\u00c6":
            a = self.pop_stack(default=[])

            if type(a) is not list:
                a = self.stack + [a]
                self.stack.clear()

            self.stack.append(vectorized_aggregator(
                a, lambda acc, val: acc - val, ast_int_eval
            ))

        # Command: Ù
        # pop a
        # push uniquified a
        elif current_command == "\u00d9":
            a = self.pop_stack(default="")

            self.stack.append(uniquify(a))

        # Command: ø
        # pop (a,)b
        # push zipped b if b is list, else zipped a with b
        elif current_command == "\u00f8":
            b = self.pop_stack(default="")

            if type(b) is not list:
                b = str(b)
                a = self.pop_stack(default="")

                if type(a) is not list:
                    a = str(a)

                result = [list(x) for x in zip(*[a, b])]

                if type(a) is str:
                    self.stack.append([''.join(x) for x in result])
                else:
                    self.stack.append(result)
            else:
                if max([type(x) is list for x in b]):
                    result = [list(x) for x in zip(*b)]
                    self.stack.append(result)
                elif max([len(x) for x in b]) > 1:
                    result = [list(x) for x in zip(*b)]
                    self.stack.append([''.join(x) for x in result])
                else:
                    a = self.pop_stack(default="")

                    if type(a) is not list:
                        a = str(a)
                    result = [list(x) for x in zip(*[a, b])]
                    self.stack.append(result)

        # Command: Ú
        # pop a
        # push reverse uniquified a
        elif current_command == "\u00da":
            a = self.pop_stack(default="")
            if type(a) is not list:
                a = str(a)
            self.stack.append(uniquify(a[::-1])[::-1])

        # Command: Û
        # pop a,b
        # push a with leading b's trimmed off
        elif current_command == "\u00db":
            b = self.pop_stack(default="")
            a = self.pop_stack(default=[])

            if type(a) is not list:
                a = str(a)

            if type(b) is not list:
                b = [b]

            for i in b:
                while a and str(a[0]) == str(i):
                    a = a[1:]
            self.stack.append(a)

        # Command: ¥
        # pop a
        # push delta's a
        elif current_command == "\u00a5":
            a = self.pop_stack(default=[])

            self.stack.append(deltaify(a))

        # Command: ©
        # store a in register_c without popping
        elif current_command == "\u00a9":
            a = self.pop_stack()
            self.stack.append(a)
            self.environment.c = a

        # Command: ®
        # push the last item from register_c
        elif current_command == "\u00ae":
            self.stack.append(self.environment.c)

        # Command: Ü
        # pop a,b
        # push a with trailing b's trimmed off
        elif current_command == "\u00dc":
            b = self.pop_stack(default="")
            a = self.pop_stack(default=[])

            if type(a) is not list:
                a = str(a)

            if type(b) is not list:
                b = [b]

            for i in b:
                while a and str(a[-1]) == str(i):
                    a = a[:-1]
            self.stack.append(a)

        # Command: È
        # pop a
        # push a % 2 == 0 (is even)
        elif current_command == "\u00c8":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: int(a % 2 == 0), ast_int_eval
            ))

        # Command: ¿
        # pop (a,)b
        # push gcd(b) if b is list, else push gcd([b, a])
        elif current_command == "\u00bf":
            a = self.pop_stack(default=[])

            if type(a) is not list:
                a = [a, self.pop_stack(default="")]

            self.stack.append(vectorized_aggregator(
                a, lambda acc, val: fractions.gcd(acc, val) if acc and val else 0, ast_int_eval
            ))

        # Command: É
        # pop a
        # push a % 2 == 1 (is uneven)
        elif current_command == "\u00c9":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: int(a % 2 == 1), ast_int_eval
            ))


        # Command: ü
        # pairwise command (vectorizes if the first element is a list)
        elif current_command == "\u00fc":
            a = self.pop_stack()

            self.pointer_position += 1
            for_each_command = self.commands[self.pointer_position]
            if for_each_command == ".":
                self.pointer_position += 1
                for_each_command += self.commands[self.pointer_position]

            if type(a) is not list:
                a = str(a)

            zipper = a if type(a[0]) is list else zip(*[a, a[1:]])

            results = []
            for element in zipper:
                results.append(self.value(for_each_command, stack=[element[0], element[1]]))

            self.stack.append(results)

        # Command: ¡
        # pop a,b
        # push a.split(b)
        elif current_command == "\u00a1":
            b = self.pop_stack(default="")
            a = self.pop_stack(default=[])

            self.stack.append(
                single_vectorized_evaluation(a, lambda a: multi_split(a, b), str)
            )

        # Command: γ
        # pop a
        # push a split into chunks of consecutive equal elements
        elif current_command == "\u03b3":
            a = self.pop_stack(default="")

            if type(a) is not list:
                a = str(a)

            is_list = type(a) is list
            temp_list = []
            inner_str = ""
            inner_list = []
            i = 0
            while i < len(a):
                if is_list:
                    inner_list.append(a[i])
                else:
                    inner_str += a[i]
                if i == len(a) - 1 or a[i] != a[i + 1]:
                    if is_list:
                        temp_list.append(inner_list)
                    else:
                        temp_list.append(inner_str)
                    inner_list = []
                    inner_str = ""
                i += 1
            self.stack.append(temp_list)

        # Command: ï
        # pop a
        # push int(a)
        elif current_command == "\u00ef":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(a, lambda a: int(ast_int_eval(a))))

        # Command: Þ
        # pop a
        # push float(a)
        elif current_command == "\u00de":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(a, lambda a: floatify(a)))

        # Command: Ñ
        # pop a
        # push divisors(a)
        elif current_command == "\u00d1":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: divisors_of_number(a)
            ))

        # Command: Î
        # push 0 and input
        elif current_command == "\u00ce":
            self.stack.append(0)
            self.stack.append(get_input())

        # Command: §
        # pop a
        # push str(a)
        elif current_command == "\u00a7":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(a, lambda a: str(a)))

        # Command: ¦
        # pop a
        # push a[1:]
        elif current_command == "\u00a6":
            a = self.pop_stack(default="")
            if type(a) is not list:
                self.stack.append(str(a)[1:])
            else:
                self.stack.append(a[1:])

        # Command: š
        # pop a
        # push switch_cased(a)
        elif current_command == "\u0161":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(a, lambda a: a.swapcase(), str))

        # Command: £
        # pop a,b
        # push a[0:b]
        elif current_command == "\u00a3":
            b = self.pop_stack(default=0)
            a = self.pop_stack(default="")

            try:
                b = [int(x) for x in b] if type(b) is list else int(b)
            except:
                a, b = b, a

            try:
                if type(a) is not list:
                    a = str(a)

                if type(b) is list:
                    temp_list = []
                    temp_element = a
                    for Q in b:
                        temp_list.append(temp_element[0:int(Q)])
                        temp_element = temp_element[int(Q):]
                    self.stack.append(temp_list)
                else:
                    b = int(b)
                    self.stack.append(a[0:b])
            except:
                self.stack.append(a)

        # Command: K
        # pop a,b
        # push a with no b's
        elif current_command == "K":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            if type(b) is not list:
                b = [b]

            for i in b:
                if type(a) is not list:
                    a = str(a).replace(str(i), "")
                else:
                    a = vectorized_filter(a, lambda a: a != str(i), str)

            self.stack.append(a)

        # Command: ß
        # extract smallest element of list
        elif current_command == "\u00df":
            a = self.pop_stack("")
            has_skipped = False
            result = []

            if type(a) is not list:
                a = str(a)

            if not a:
                self.stack.append(a)
                self.stack.append('')
                return

            for element in a:
                if str(element) == str(min(a)) and not has_skipped:
                    has_skipped = True
                else:
                    result.append(element)
            if type(a) is not list:
                self.stack.append(''.join([str(x) for x in result]))
            else:
                self.stack.append(result)
            self.stack.append(min(a))

        # Command: à
        # extract greatest element of list
        elif current_command == "\u00e0":
            a = self.pop_stack(default="")
            has_skipped = False
            result = []

            if type(a) is not list:
                a = str(a)

            if not a:
                self.stack.append(a)
                self.stack.append('')
                return

            for element in a:
                if str(element) == str(max(a)) and not has_skipped:
                    has_skipped = True
                else:
                    result.append(element)
            if type(a) is not list:
                self.stack.append(''.join([str(x) for x in result]))
            else:
                self.stack.append(result)
            self.stack.append(max(a))

        # Command: ¤
        # get a
        # push tail(a)
        elif current_command == "\u00a4":
            if self.stack:
                a = self.stack[-1]
            else:
                a = self.pop_stack(default="")
                self.stack.append(a)

            if type(a) is not list:
                self.stack.append(str(a)[-1])
            else:
                self.stack.append(a[-1])

        # Command: ‹
        # pop a,b
        # push a < b
        elif current_command == "\u2039":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")
            self.stack.append(vectorized_evaluation(
                a, b, lambda a, b: int(str(a) < str(b) if type(a) is str or type(b) is str else a < b), ast_int_eval
            ))

        # Command: ʒ
        # pop a
        # filter a when the result of code == 1: usage ʒCODE}
        elif current_command == "\u0292":
            a = self.pop_stack(default="")

            if type(a) is not list:
                a = str(a)

            statement, remaining = get_statements(self.commands[self.pointer_position + 1:])

            filtered = []
            for element in a:
                value = self.value(statement, stack=[element])
                if value == 1 or ast_int_eval(value) == "1":
                    filtered.append(element)

            if type(a) is str:
                filtered = ''.join(str(x) for x in filtered)
            self.stack.append(filtered)
            self.pointer_position += len(statement) + 1

        # Command: Σ
        # pop a
        # sort a by the result of code: usage ΣCODE}
        elif current_command == "\u03A3":
            a = self.pop_stack(default="")

            if type(a) is not list:
                a = str(a)

            statement, remaining = get_statements(self.commands[self.pointer_position + 1:])

            results = []
            for element in a:
                value = self.value(statement, stack=[element])
                results.append([value if value else float('inf'), element])

            results = sorted(results, key=lambda element: element[0])
            if type(a) is list:
                self.stack.append([x[1] for x in results])
            else:
                self.stack.append(''.join([x[1] for x in results]))

            self.pointer_position += len(statement) + 1

        # Command: ›
        # pop a,b
        # push a > b
        elif current_command == "\u203A":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")
            self.stack.append(vectorized_evaluation(
                a, b, lambda a, b: int(str(a) > str(b) if type(a) is str or type(b) is str else a > b), ast_int_eval
            ))

        # Command: À
        # pop a
        # push a rotated 1 left
        elif current_command == "\u00c0":
            a = self.pop_stack(default="")

            if type(a) is list:
                if len(a):
                    b = a[0]
                    a = a[1:]
                    a.append(b)
            else:
                a = str(a)

                if len(a):
                    a += a[0]
                    a = a[1:]
            self.stack.append(a)

        # Command: Á
        # pop a
        # push a rotated 1 right
        elif current_command == "\u00c1":
            a = self.pop_stack(default="")

            if type(a) is list:
                if len(a):
                    b = []
                    b.append(a[-1])
                    for Q in a:
                        b.append(Q)
                    a = b[:-1]
            else:
                a = str(a)
                if len(a):
                    a = a[-1] + a
                    a = a[:-1]

            self.stack.append(a)

        # Command: Ø
        # pop a
        # push ath prime (zero-indexed)
        elif current_command == "\u00d8":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: get_nth_prime(a), int
            ))

        # Command: .Ø
        # pop a
        # push 0-index number of the greatest prime <= a
        elif current_command == ".\u00d8":
            a = self.pop_stack(default="")
            self.stack.append(
                single_vectorized_evaluation(
                    a, lambda a: get_index_of_prime(a), int
                )
            )

        # Command: ¢
        # pop a,b
        # push a.count(b)
        elif current_command == "\u00a2":
            b = self.pop_stack(default=0)
            a = self.pop_stack(default="")

            if type(a) is list:
                a = [str(x) for x in deep_flatten(a)]

            self.stack.append(single_vectorized_evaluation(
                b, lambda b: a.count(b), str
            ))

        # Command: ¨
        # pop a
        # push a[0:-1]
        elif current_command == "\u00a8":
            a = self.pop_stack(default="")
            if type(a) is not list:
                self.stack.append(str(a)[0:-1])
            else:
                self.stack.append(a[0:-1])

        # Command: æ
        # pop a
        # push powerset(a)
        elif current_command == "\u00e6":
            a = self.pop_stack(default="")
            b = None
            if type(a) is not list:
                b = list(str(a))
            else:
                b = [str(x) if type(x) is int else x for x in a]
            s = list(b)
            s = list(itertools.chain.from_iterable(
                itertools.combinations(s, r) for r in range(len(s) + 1)
            ))
            list_of_lists = [list(elem) for elem in s]

            if type(a) is not list:
                self.stack.append([''.join(x) for x in list_of_lists])
            else:
                self.stack.append(list_of_lists)

        # Command: œ
        # pop a
        # push permutations(a)
        elif current_command == "\u0153":
            a = self.pop_stack(default="")

            if type(a) is not list:
                b = list(str(a))
            else:
                b = a
            b = list(itertools.permutations(list(b)))
            list_of_lists = [list(elem) for elem in b]

            if type(a) is not list:
                self.stack.append([''.join(x) for x in list_of_lists])
            else:
                self.stack.append(list_of_lists)

        # Command: Œ
        # pop a
        # push substrings(a)
        elif current_command == "\u0152":
            a = self.pop_stack(default="")
            self.stack.append(apply_safe(get_all_substrings, a))

        # Command: Ð
        # pop a
        # triplicate (push a, push a, push a)
        elif current_command == "\u00d0":
            a = self.pop_stack(default="")
            self.stack.append(a)
            self.stack.append(a)
            self.stack.append(a)

        # Command: Ä
        # pop a
        # push abs(a)
        elif current_command == "\u00c4":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: abs(a), ast_int_eval
            ))

        # Command: Ý
        # pop a
        # push [0..a]
        elif current_command == "\u00dd":
            a = self.pop_stack(default="")
            incr = lambda i: -1 if i < 0 else 1

            self.stack.append(single_vectorized_evaluation(
                a, lambda a: list(range(0, a + incr(a), incr(a))), int
            ))

        # Command: û
        # pop a
        # push palindromized(a)
        elif current_command == "\u00fb":
            a = self.pop_stack(default="")

            if type(a) is not list:
                a = str(a)

            self.stack.append(a + a[::-1][1:])

        # Command: ¶
        # push a newline character
        elif current_command == "\u00b6":
            self.stack.append("\n")

        # Command: ý
        # pop (a,)b
        # push b.join(a) if a is list, else b.join(self.stack)
        elif current_command == "\u00fd":
            b = str(self.pop_stack(default=""))

            if self.stack and type(self.stack[-1]) is list:
                a = self.pop_stack()
            else:
                a = list(self.stack)
                self.stack.clear()

            if a:
                self.stack.append(vectorized_aggregator(
                    a, lambda acc, val: acc + b + val, str
                ))
            else:
                self.stack.append("")

        # Command: Ÿ
        # pop (a,)b
        # push [a, ..., b] if b not a list, otherwise push [b[0],...,b[1],...,b[n]]
        elif current_command == "\u0178":
            b = self.pop_stack(default="")

            if type(b) is not list:
                b = [self.pop_stack(default=""), b]

            milestones = []
            for i in b:
                try:
                    milestones.append(int(ast_int_eval(i)))
                except:
                    pass

            ranges = []
            for i in range(len(milestones) - 1):
                x = milestones[i]
                y = milestones[i + 1]

                if x == y:
                    ranges.append(x)
                else:
                    incr = lambda: 1 if x < y else -1
                    # do not repeat a milestone
                    if i > 0:
                        x += incr()
                    ranges += list(range(x, y + incr(), incr()))

            self.stack.append(ranges)

        # Command: Š
        # pop a,b,c
        # push c,a,b
        elif current_command == "\u0160":
            c = self.pop_stack()
            # defaulting to prevent losing a value if there is
            # at least one on the self.stack, but no input is available
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            # a b c -> c a b
            self.stack.append(c)
            self.stack.append(a)
            self.stack.append(b)

        # Command: Ö
        # pop a,b
        # push a % b == 0
        elif current_command == "\u00d6":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")
            self.stack.append(vectorized_evaluation(
                a, b, lambda a, b: int(a % b == 0), ast_int_eval
            ))

        # Command: ¬
        # get a
        # push head(a)
        elif current_command == "\u00ac":
            a = self.pop_stack(default="")
            self.stack.append(a)

            if type(a) is not list:
                self.stack.append(str(a)[0])
            else:
                self.stack.append(self.stack[-1][0])

        # Command: Ž
        # break/end if self.stack is empty
        elif current_command == "\u017d":
            if not self.stack:
                return True

        # Command: »
        # pop (a)
        # if list, join list by newlines, else join self.stack by newlines
        elif current_command == "\u00bb":
            if self.stack and type(self.stack[-1]) is list:
                a = self.pop_stack()
            else:
                a = list(self.stack)
                self.stack.clear()

            result = []
            for Q in a:
                if type(Q) is list:
                    result.append(' '.join([str(x) for x in Q]))
                else:
                    result.append(str(Q))

            self.stack.append("\n".join(result))

        # Command: «
        # pop a,b
        # push concatenated(a, b)
        elif current_command == "\u00ab":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            if type(a) is list and type(b) is list:
                self.stack.append(a + b)
            elif type(a) is list:
                self.stack.append(single_vectorized_evaluation(a, lambda a: a + str(b), str))
            elif type(b) is list:
                self.stack.append(single_vectorized_evaluation(b, lambda b: str(a) + b, str))
            else:
                self.stack.append(str(a) + str(b))

        # Command: ì
        # pop a,b
        # push a.prepend(b)
        elif current_command == "\u00ec":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            if type(a) is list and type(b) is list:
                self.stack.append(b + a)
            elif type(a) is list:
                self.stack.append(single_vectorized_evaluation(a, lambda a: str(b) + a, str))
            elif type(b) is list:
                self.stack.append(single_vectorized_evaluation(b, lambda b: b + str(a), str))
            else:
                self.stack.append(str(b) + str(a))

        # Command: ×
        # pop a,b
        # push a x b (strings)
        elif current_command == "\u00d7":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            self.stack.append(string_multiplication(a, b))

        # Command: .×
        # Command: и
        # pop a,b
        # push a n-repeat (list-multiply) b
        elif current_command == ".\u00d7" or current_command == "\u0438":
            b = self.pop_stack(default=0)
            a = self.pop_stack(default=[])
            self.stack.append(list_multiply(a, b))

        # Command: ò
        # pop a
        # push a rounded to nearest integer
        elif current_command == "\u00f2":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(a, round, ast_int_eval))

        # Command: .ò
        # pop a,b
        # round a with b digits precision (bankers rounding)
        elif current_command == ".\u00f2":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            self.stack.append(vectorized_evaluation(
                a, b, lambda a, b: round(a, b), ast_int_eval
            ))

        # Command: ð
        # push a space character
        elif current_command == "\u00f0":
            self.stack.append(" ")

        # Command: ƶ
        # pop a
        # push lifted a, each element is multiplied by its index (1-indexed)
        elif current_command == "\u01b6":
            a = self.pop_stack(default="")

            if type(a) is not list:
                a = str(a)
                result = []
                for n in range(len(a)):
                    result.append(a[n] * (n + 1))
                self.stack.append(result)
            else:
                result = []
                for n in range(len(a)):
                    result.append(vectorized_evaluation(
                        a[n], n + 1, lambda a, b: a * b, ast_int_eval
                    ))
                self.stack.append(result)

        # Command: .M
        # pop a
        # push most frequent in a
        elif current_command == ".M":
            a = self.pop_stack(default="")

            if type(a) is list:
                buf = []
                for item in a:
                    if type(item) is list:
                        # stringify sublists to make them hashable
                        buf.append(str(item))
                    else:
                        buf.append(apply_safe(ast_int_eval, item))
                a = buf
            else:
                a = list(str(a))

            result = []

            if a:
                uniques = list(set(a))
                counts = list(map(lambda i: a.count(i), uniques))
                max_count = max(counts)

                for Q in range(len(counts)):
                    if counts[Q] == max_count:
                        result.append(uniques[Q])

            # unstringified sublists if necessary
            self.stack.append([apply_safe(ast_int_eval, x) for x in result])

        # Command: .m
        # pop a
        # push least frequent in a
        elif current_command == ".m":
            a = self.pop_stack(default="")

            if type(a) is list:
                buf = []
                for item in a:
                    if type(item) is list:
                        # stringify sublists to make them hashable
                        buf.append(str(item))
                    else:
                        buf.append(apply_safe(ast_int_eval, item))
                a = buf
            else:
                a = list(str(a))

            result = []

            if a:
                uniques = list(set(a))
                counts = list(map(lambda i: a.count(i), uniques))
                min_count = min(counts)

                for Q in range(len(counts)):
                    if counts[Q] == min_count:
                        result.append(uniques[Q])

            # unstringified sublists if necessary
            self.stack.append([apply_safe(ast_int_eval, x) for x in result])

        # Command: Ì
        # pop a
        # push a + 2
        elif current_command == "\u00cc":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(a, lambda a: a + 2, ast_int_eval))

        # Command: Í
        # pop a
        # push a - 2
        elif current_command == "\u00cd":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(a, lambda a: a - 2, ast_int_eval))

        # Command: †
        # pop a,b
        # push a with b filtered to the front
        elif current_command == "\u2020":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            self.stack.append(filtered_to_the_front(a, b))

        # Command: ¼
        # counter_variable++
        elif current_command == "\u00bc":
            global_env.counter_variable += 1

        # Command: .¼
        # pop a
        # push tan(a)
        elif current_command == ".\u00bc":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: math.tan(ast_int_eval(a))
            ))

        # Command: ½
        # pop a
        # if 1, then counter_variable++
        elif current_command == "\u00bd":
            if str(ast_int_eval(self.pop_stack(default=""))) == "1":
                global_env.counter_variable += 1

        # Command: .½
        # pop a
        # push sin(a)
        elif current_command == ".\u00bd":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: math.sin(ast_int_eval(a))
            ))

        # Command: .x
        # pop a,b
        # push the element in a closest to b
        elif current_command == ".x":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")
            self.stack.append(apply_safe(closest_to, a, b))

        # Command: .¥
        # pop a
        # push undelta a
        elif current_command == ".\u00a5":
            a = self.pop_stack(default="")
            self.stack.append(vectorized_aggregator(
                a, lambda acc, val: acc + [acc[-1] + ast_int_eval(val)], start=[0]
            ))

        # Command: ¾
        # push counter_variable
        elif current_command == "\u00be":
            self.stack.append(global_env.counter_variable)

        # Command: .¾
        # pop a
        # push cos(a)
        elif current_command == ".\u00be":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: math.cos(ast_int_eval(a))
            ))

        # Command: ó
        # pop a
        # push round_down(a)
        elif current_command == "\u00f3":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, math.floor, ast_int_eval
            ))

        # Command: ?
        # pop a
        # push a no newline
        elif current_command == "?":
            a = self.pop_stack(default="")
            print(a, end="")
            global_env.has_printed = True

        # Command: .o
        # pop a,b
        # push overlab(b) (deprecated)
        elif current_command == ".o":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")
            a = " " + str(a)
            b = str(b)
            temp_string = ""
            stop = False
            for Q in b:
                if stop:
                    temp_string += Q
                else:
                    if a[0] == Q:
                        temp_string += Q
                        a = a[1:]
                    else:
                        while a[0] != Q:
                            a = a[1:]
                            if a == "":
                                stop = True
                                temp_string += Q
                                break
                            if a[0] == Q or Q == "\u00f0":
                                temp_string += Q
                                break
                            else:
                                temp_string += " "

            self.stack.append(temp_string)

        # Command: .O
        # pop a,b
        # push connected_overlap(b) (deprecated)
        elif current_command == ".O":
            b = str(self.pop_stack(default=""))
            a = str(self.pop_stack(default="")) + b

            temp_string = b
            while True:
                is_substring = True
                for Q in range(0, len(b)):
                    if a[Q] != b[Q] and a[Q] != "\u00f0":
                        is_substring = False
                        break
                if is_substring:
                    break
                else:
                    temp_string = " " + temp_string
                    a = a[1:]
            self.stack.append(temp_string)

        # Command: .N
        # pop a
        # push hashed(a)
        elif current_command == ".N":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(a, lambda a: get_hash(a)))

        # Command: ‡
        # pop a,b,c
        # push a.transliterate(b -> c)
        elif current_command == "\u2021":
            c = self.pop_stack(default="")
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            if type(b) is not list:
                b = str(b)

            if type(c) is not list:
                c = str(c)

            self.stack.append(single_vectorized_evaluation(
                a, lambda a: transliterate(a, b, c), str
            ))

        # Command: Ï
        # pop a,b
        # push the elements from a at which the same index at b is 1
        elif current_command == "\u00cf":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            if type(b) is not list:
                b = str(b)

            if type(a) is not list:
                a = str(a)

            filtered = []
            for i in range(min(len(a), len(b))):
                if apply_safe(ast_int_eval, b[i]) == 1:
                    filtered.append(a[i])

            if type(a) is str:
                filtered = ''.join(filtered)

            self.stack.append(filtered)

        # Command: ñ
        # pop a,b,c
        # push a + b merged with c as merge character
        elif current_command == "\u00f1":
            c = str(self.pop_stack(default=""))
            b = str(self.pop_stack(default=""))[::-1]
            a = str(self.pop_stack(default=""))[::-1]

            if len(b) > len(a):
                a = str(a).ljust(len(b), c)

            if len(a) > len(b):
                b = str(b).ljust(len(a), c)

            temp_string = ""

            for Q in range(len(a)):
                if a[Q] == c and b[Q] != c:
                    temp_string += b[Q]
                else:
                    temp_string += a[Q]

            self.stack.append(temp_string[::-1])

        # Command: .ï
        # pop a
        # push is_int(a)
        elif current_command == ".\u00ef":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: int(type(a) is float and int(a) == a), float
            ))

        # Command: .¿
        # pop (a,)b
        # push lcm(b) if b is list, else push lcm(b, a)
        elif current_command == ".\u00bf":
            a = self.pop_stack(default=[])

            if type(a) is not list:
                a = [a, self.pop_stack(default="")]

            self.stack.append(vectorized_aggregator(
                a, lambda acc, val: abs(acc) * abs(val) // fractions.gcd(acc, val) if acc and val else 0, ast_int_eval
            ))

        # Command: .ø
        # pop a,b
        # surround a with b
        elif current_command == ".\u00f8":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            if type(b) is not list:
                b = [b]

            if type(a) is not list:
                self.stack.append(vectorized_aggregator(
                    b, lambda acc, val: val + acc + val, str, str(a)
                ))
            else:
                self.stack.append(vectorized_aggregator(
                    b, lambda acc, val: [val] + acc + [val], str, a
                ))

        # Command: –
        # pop a
        # if 1, print N (used in loops)
        elif current_command == "\u2013":
            a = self.pop_stack(default=0)
            if apply_safe(ast_int_eval, a) == 1:
                print(self.environment.range_variable)
                global_env.has_printed = True

        # Command: —
        # pop a
        # if 1, print y (used in loops)
        elif current_command == "\u2014":
            a = self.pop_stack(default=0)
            if apply_safe(ast_int_eval, a) == 1:
                print(self.environment.string_variable)
                global_env.has_printed = True

        # Command: .e
        # pop a
        # run with experimental python evaluation (does not work in safe mode)
        elif current_command == ".e":
            if self.safe_mode:
                print("exec self.commands are ignored in safe mode")
            else:
                temp_string = str(self.pop_stack(default=""))

                if len(temp_string):
                    temp_string = temp_string.replace("#", "self.stack")
                    temp_string = temp_string.replace(";", "\n")
                    exec(temp_string)

        # Command: .E
        # pop a
        # run with experimental batch evaluation (does not work in safe mode)
        elif current_command == ".E":
            if self.safe_mode:
                print("exec self.commands are ignored in safe mode")
            else:
                a = str(self.pop_stack(default=""))

                if len(a):
                    f = tempfile.NamedTemporaryFile()
                    f.write(bytes(str(a), "cp1252"))
                    os.system(f.name)
                    f.close()

        # Command: .V
        # pop a
        # run with experimental batch evaluation (does not work in safe mode)
        elif current_command == ".V":
            a = self.pop_stack(default="")
            self.stack, status = self.__run_subprogram(str(a))

            if status == Status.BREAK:
                return Status.OK
            elif status == Status.EXIT:
                return Status.EXIT

        # Command: .R
        # Command: Ω
        # pop a
        # push random_pick(a)
        elif current_command == ".R" or current_command == "\u03A9":
            a = self.pop_stack(default="")
            if type(a) is not list:
                a = str(a)

            if len(a):
                self.stack.append(random.choice(a))
            else:
                self.stack.append(a)

        # Command: .r
        # pop a
        # push random_shuffle(a)
        elif current_command == ".r":
            a = self.pop_stack(default="")
            b = a if type(a) is list else list(str(a))
            random.shuffle(b)
            self.stack.append(b if type(a) is list else ''.join(b))

        # Command: ¹
        # push the first item from the input history
        elif current_command == "\u00b9":
            if len(recent_inputs) > 0:
                self.stack.append(recent_inputs[0])
            else:
                while len(recent_inputs) <= 0:
                    get_input()
                self.stack.append(recent_inputs[0])

        # Command: ²
        # push the second item from the input history
        elif current_command == "\u00b2":
            if len(recent_inputs) > 1:
                self.stack.append(recent_inputs[1])
            else:
                while len(recent_inputs) <= 1:
                    get_input()
                self.stack.append(recent_inputs[1])

        # Command: ³
        # push the third item from the input history
        elif current_command == "\u00b3":
            if len(recent_inputs) > 2:
                self.stack.append(recent_inputs[2])
            else:
                while len(recent_inputs) <= 2:
                    get_input()
                self.stack.append(recent_inputs[2])

        # Command: •
        # start/end a 1-9 char compressed string
        elif current_command == "\u2022":
            temp_string = ""
            temp_string_2 = ""
            temp_position = self.pointer_position
            while temp_position < len(self.commands) - 1:
                temp_position += 1
                try:
                    current_command = self.commands[temp_position]
                except:
                    break
                if current_command == "\u2022":
                    break
                else:
                    temp_string += current_command
                    self.pointer_position += 1
            self.pointer_position += 1
            self.stack.append(apply_safe(convert_from_base, temp_string, 255))

        # Command: .•
        # decompress a base 255 alphabet based string
        elif current_command == ".\u2022":
            temp_string = ""
            temp_string_2 = ""
            temp_position = self.pointer_position
            while temp_position < len(self.commands) - 1:
                temp_position += 1
                try:
                    current_command = self.commands[temp_position]
                except:
                    break
                if current_command == "\u2022":
                    break
                else:
                    temp_string += current_command
                    self.pointer_position += 1
            self.pointer_position += 1
            processed_value = convert_from_base(temp_string, 255)
            processed_value = convert_to_base_arbitrary(
                processed_value, 27)
            self.stack.append(''.join(
                [chr(x + 96) if x > 0 else " " for x in processed_value]
            ))

        # Command: β
        # pop a,b
        # push a converted from base b (arbitrary)
        elif current_command == "\u03B2":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            self.stack.append(single_vectorized_evaluation(
                b, lambda b: convert_from_base_arbitrary(a, b), int
            ))

        # Command: .L
        # pop a,b
        # push levenshtein(a, b)
        elif current_command == ".L":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")
            self.stack.append(vectorized_evaluation(a, b, minimum_edit_distance, str))

        # Command: â
        # pop a,b
        # push cartesian product
        elif current_command == "\u00e2":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            if type(a) is not list:
                a = str(a)
            if type(b) is not list:
                b = str(b)

            c = list(itertools.product(a, b))
            if type(a) is list or type(b) is list:
                self.stack.append([list(Q) for Q in c])
            else:
                self.stack.append([''.join(str(y) for y in x) for x in c])

        # Command: ã
        # pop a,b
        # push a choose b (cartesian product repeat)
        elif current_command == "\u00e3":
            b = self.pop_stack(default="")
            a = None
            if type(b) is list:
                a, b = b[:], 2
            else:
                a = self.pop_stack(default="")

            try:
                b = int(ast_int_eval(b))
            except:
                self.stack.append(a)
            else:
                if type(a) is not list:
                    a = str(a)

                c = list(itertools.product(a, repeat=b))
                if type(a) is list:
                    self.stack.append([list(Q) for Q in c])
                else:
                    self.stack.append([''.join(str(y) for y in x) for x in c])

        # Command: è
        # pop a,b
        # push a[b]
        elif current_command == "\u00e8":
            b = self.pop_stack(default=0)
            a = self.pop_stack(default="")

            if type(a) is not list:
                a = str(a)

            if not len(a):
                self.stack.append(a)
                return

            if type(b) is list:
                temp_list = []
                for Q in b:
                    try:
                        Q = int(Q)
                    except:
                        pass
                    else:
                        temp_list.append(a[Q % len(a)])
                self.stack.append(temp_list)
            else:
                try:
                    b = int(b)
                except:
                    self.stack.append(a)
                else:
                    self.stack.append(a[b % len(a)])

        # Command: .p
        # Command: η
        # pop a
        # push prefixes(a)
        elif current_command == ".p" or current_command == "\u03B7":
            a = self.pop_stack(default="")
            if type(a) is not list:
                a = str(a)
            temp_list = []
            for Q in range(1, len(a) + 1):
                temp_list.append(a[0:Q])
            self.stack.append(temp_list)

        # Command: .s
        # pop a
        # push suffixes(a)
        elif current_command == ".s":
            a = self.pop_stack(default="")
            if type(a) is not list:
                a = str(a)
            temp_list = []
            for Q in range(1, len(a) + 1):
                temp_list.append(a[-Q:])
            self.stack.append(temp_list)

        # Command: .À
        # rotate self.stack 1 left
        elif current_command == ".\u00C0":
            temp_stack = self.stack[:]
            self.stack.clear()
            for Q in temp_stack[1:]:
                self.stack.append(Q)
            self.stack.append(temp_stack[0])

        # Command: .Á
        # rotate self.stack 1 right
        elif current_command == ".\u00C1":
            temp_stack = self.stack[:]
            self.stack.clear()
            self.stack.append(temp_stack[-1])
            for Q in temp_stack[:-1]:
                self.stack.append(Q)

        # Command: Ć
        # pop a
        # push enclosed a: a + a[0]
        elif current_command == "\u0106":
            a = self.pop_stack(default="")
            if type(a) is not list:
                a = str(a)

            if not len(a):
                self.stack.append(a)
            else:
                self.stack.append(a + [a[0]] if type(a) is list else a + a[0])

        # Command: ć
        # pop a
        # push head_extracted a: a[1:], a[0]
        elif current_command == "\u0107":
            a = self.pop_stack(default="")
            if type(a) is not list:
                a = str(a)

            if not len(a):
                self.stack.append(a)
            else:
                self.stack.append(a[1:])
                self.stack.append(a[0])

        # Command: €
        # pop a
        elif current_command == "\u20AC":
            a = self.pop_stack(default="")
            if type(a) is not list:
                a = str(a)

            self.pointer_position += 1
            for_each_command = self.commands[self.pointer_position]
            # Double chars self.commands: . À
            # Pairwise: ü
            # or for-each itself: €
            if for_each_command in ".\u00c5\u20AC\u00fc":
                self.pointer_position += 1
                for_each_command += self.commands[self.pointer_position]

            result = []
            for element in a:
                result.append(self.value(for_each_command, stack=[element]))

            self.stack.append(result)

        # Command: α
        # pop a,b
        # push absolute difference of a and b
        elif current_command == "\u03b1":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")
            self.stack.append(vectorized_evaluation(
                a, b, lambda a, b: abs(a - b), ast_int_eval
            ))

        # Command: .B
        # pop a
        # push squarified(a)
        elif current_command == ".B":
            a = self.pop_stack(default="")

            if type(a) is not list:
                a = str(a).split("\n")

            max_length = 0
            for Q in a:
                if len(str(Q)) > max_length:
                    max_length = len(str(Q))

            temp_list = []
            for Q in a:
                temp_list.append(
                    str(Q) + ((max_length - len(str(Q))) * " ")
                )

            self.stack.append(temp_list)

        # Command: .«
        # foldr
        # folds a dyadic command between each element in a list from right to left
        #
        # Command: .»
        # foldl
        # folds a dyadic command between each element in a list from right to left
        # with opposite right/left operands
        elif current_command == ".\u00AB" or current_command == ".\u00BB":
            self.pointer_position += 1
            fold_command = self.commands[self.pointer_position]

            if self.stack and type(self.stack[-1]) is list and len(self.stack[-1]) > 1:
                a = self.pop_stack()

                if current_command == ".\u00AB":
                    result = a[-1]
                    for element in a[:-1][::-1]:
                        result = self.value(fold_command, stack=[element, result])
                else:
                    result = a[0]
                    for element in a[1:]:
                        result = self.value(fold_command, stack=[result, element])

                self.stack.append(result)

        # Command: .h
        # pop a,b
        # bijectively convert a from base 10 to base b
        elif current_command == ".h":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            try:
                b = int(ast_int_eval(b))

                # throw if b = 0
                1 / b
            except:
                self.stack.append(a)
            else:
                self.stack.append(single_vectorized_evaluation(
                    a, lambda a: bijective_base_conversion(a, b)
                ))

        # Command: .H
        # pop a,b
        # bijectively convert a from base b to base 10
        elif current_command == ".H":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            try:
                b = int(ast_int_eval(b))
            except:
                self.stack.append(a)
            else:
                self.stack.append(single_vectorized_evaluation(
                    a, lambda a: bijective_decimal_conversion(a, b)
                ))

        # Command: .D
        # pop a,b
        # push b copies of a if b is int, else push len(b) copies of a
        elif current_command == ".D":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")
            L = []
            try:
                L = int(ast_int_eval(b)) or 1
            except:
                L = len(b) or 1

            for Q in range(L):
                self.stack.append(a)

        # Command: Â
        # pop a
        # push a, reversed(a)
        elif current_command == "\u00c2":
            a = self.pop_stack(default="")
            if type(a) is not list:
                a = str(a)
            self.stack.append(a)
            self.stack.append(a[::-1])

        # Command: õ
        # push empty string
        elif current_command == "\u00f5":
            self.stack.append("")

        # Command: Ô
        # pop a
        # push connected uniquified a
        elif current_command == "\u00d4":
            a = self.pop_stack(default="")
            self.stack.append(apply_safe(uniquify, a, True))

        # Command: ‚
        # pop a,b
        # push [a, b]
        elif current_command == "\u201A":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")
            self.stack.append([a, b])

        # Command: .€
        # pop a
        # self.debug printer (default encoding, fallbacks on cp1252)
        elif current_command == ".\u20AC":
            a = self.pop_stack(default="")

            if type(a) is not list:
                a = str(a)

            for Q in a:
                try:
                    print(Q, end="")
                except:
                    print(str(Q).encode("cp1252"), end="")
            print()
            global_env.has_printed = True

        # Command: Õ
        # pop a
        # push euler_totient(a)
        elif current_command == "\u00d5":
            a = self.pop_stack(default="")
            if type(a) is list:
                self.stack.append(single_vectorized_evaluation(
                    a, euler_totient, int
                ))
            else:
                self.stack.append(apply_safe(euler_totient, a))

        # Command: .ä
        # pop a
        # self.debug printer (cp1252)
        elif current_command == ".\u00e4":
            a = self.pop_stack(default="")
            print(str(a).encode("cp1252"))
            global_env.has_printed = True

        # Command: .c
        # pop a
        # push centralized(a) focused to the left
        elif current_command == ".c":
            a = self.pop_stack(default="")
            if type(a) is not list:
                a = str(a).split("\n")

            max_length = 0
            for Q in a:
                if len(str(Q)) > max_length:
                    max_length = len(str(Q))

            temp_list = []

            for Q in a:
                Q = str(Q)
                space_length = (max_length - len(Q)) // 2
                if space_length > 0:
                    temp_list.append(space_length * " " + Q)
                else:
                    temp_list.append(Q)

            self.stack.append('\n'.join(temp_list))

        # Command: .C
        # pop a
        # push centralized(a) focused to the right
        elif current_command == ".C":
            a = self.pop_stack(default="")

            if type(a) is not list:
                a = str(a).split("\n")

            max_length = 0
            for Q in a:
                if len(str(Q)) > max_length:
                    max_length = len(str(Q))

            temp_list = []

            for Q in a:
                Q = str(Q)
                space_length = (max_length - len(Q) + 1) // 2
                if space_length > 0:
                    temp_list.append(space_length * " " + Q)
                else:
                    temp_list.append(Q)

            self.stack.append('\n'.join(temp_list))

        # Command: Ã
        # pop a, b
        # push a.keep(b)
        elif current_command == "\u00c3":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            if type(b) is list:
                b = [str(x) for x in deep_flatten(b)]
            else:
                b = str(b)

            self.stack.append(vectorized_filter(a, lambda a: a in b, str))

        # Command: ˆ
        # pop a
        # add to global array
        elif current_command == "\u02c6":
            a = self.pop_stack()
            global_env.global_array.append(a)

        # Command: .ˆ
        # pop a
        # insert a into global array and after quit, print array[input_1]
        elif current_command == "\u02c6":
            a = self.pop_stack()
            global_env.global_array.append(a)

        # Command: .^
        # pop a
        # insert a into global array with immediate sorting and
        # after quit, print array[input_1]
        elif current_command == ".^":
            a = self.pop_stack()
            global_env.global_array.append(a)
            temp_list = sorted(global_env.global_array)
            global_env.global_array.clear()

            for x in temp_list:
                global_env.global_array.append(x)

        # Command: ¯
        # push global array
        elif current_command == "\u00af":
            self.stack.append(global_env.global_array)

        # Command: ´
        # clear global array
        elif current_command == "\u00b4":
            global_env.global_array.clear()

        # Command: ‰
        # pop a, b
        # push a divmod b
        elif current_command == "\u2030":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            self.stack.append(vectorized_evaluation(
                a, b, lambda a, b: list(divmod(a, b)), ast_int_eval
            ))

        # Command: ·
        # pop a
        # push 2 * a
        elif current_command == "\u00b7":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, lambda a: 2 * a, ast_int_eval
            ))

        # Command: .n
        # pop a,b
        # push log_b(a)
        elif current_command == ".n":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            self.stack.append(vectorized_evaluation(
                a, b, lambda a, b: math.log(a, b), ast_int_eval
            ))

        # Command: .w
        # pop a
        # push a.readall()
        # (internet access, doesn't work in safe mode)
        # (returns 0 on error)
        elif current_command == ".w":
            if self.safe_mode:
                print("internet access is prohibited in safe mode")
            else:
                try:
                    a = self.pop_stack(default="")
                    import urllib.request as req
                    f = req.urlopen("http://" + str(a))
                    self.stack.append(f.read())
                except:
                    self.stack.append(0)

        # Command: .W
        # pop a
        # wait a millisecodns
        elif current_command == ".W":
            a = ast_int_eval(self.pop_stack())
            time.sleep(a / 1000)

        # Command: ä
        # pop a,b
        # push a sliced into b pieces
        elif current_command == "\u00e4":
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")
            self.stack.append(apply_safe(chunk_divide, a, b))

        # Command: Ƶ
        # convert the next char from base 255 to base 10 and add 101
        elif current_command == "\u01B5":
            self.pointer_position += 1
            current_command = self.commands[self.pointer_position]
            self.stack.append(convert_from_base(current_command, 255) + 101)

        # Command: δ
        # pop a, b
        # get the next command, push double vectorized command
        elif current_command == "\u03B4":
            self.pointer_position += 1
            current_program = self.commands[self.pointer_position]

            while current_program[-1] in ".\u20AC":
                self.pointer_position += 1
                current_program += self.commands[self.pointer_position]

            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            if type(b) is not list:
                b = str(b)
            if type(a) is not list:
                a = str(a)

            result = []
            for outer_element in a:
                inner_result = []
                for inner_element in b:
                    value = self.value(current_program, stack=[outer_element, inner_element])
                    inner_result.append(value)
                result.append(inner_result)

            self.stack.append(result)

        # Command: .g
        # push length of self.stack
        elif current_command == ".g":
            self.stack.append(len(self.stack))

        # Command: .ǝ
        # pop a
        # print a to STDERR
        elif current_command == ".\u01DD":
            a = self.pop_stack(default="")
            print(a, file=stderr)

        # Command: .0
        # throw a division by zero error
        elif current_command == ".0":
            global_env.zero_division = True

        # Command: .æ
        # Permute by function
        elif current_command == ".æ":
            a = self.pop_stack(default="")
            if type(a) is not list:
                a = str(a)

            statement, remaining = get_statements(self.commands[self.pointer_position + 1:])

            results = []
            for element in a:
                sub_result = [element]

                while True:
                    value = self.value(statement, stack=[element])
                    if value in sub_result:
                        break
                    sub_result.append(value)
                results.append(sub_result)

            self.pointer_position += len(statement) + 1
            result = list_permutations(results)
            self.stack.append(result)

        #
        # Extended self.commands
        #
        elif current_command in ExtendedMath.commands_list:
            arity = ExtendedMath.commands_list.get(current_command).arity
            arguments = [self.pop_stack(default="") for _ in range(0, arity)]

            self.stack.append(ExtendedMath.invoke_command(current_command, *arguments))

        # Command: î
        # pop a
        # push round_up(a)
        elif current_command == "\u00ee":
            a = self.pop_stack(default="")
            self.stack.append(single_vectorized_evaluation(
                a, math.ceil, ast_int_eval
            ))

        # Command: ǝ
        # pop a,b,c
        # insert b into a on location c
        elif current_command == "\u01dd":
            c = self.pop_stack(default="")
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")

            if type(c) is list:
                for Q in c:
                    a = apply_safe(insert, a, b, Q)
                self.stack.append(a)
            else:
                self.stack.append(apply_safe(insert, a, b, c))

        #
        # CONSTANTS
        #

        elif current_command in Constants.commands_list:
            arity = Constants.commands_list.get(current_command).arity
            arguments = [self.pop_stack(default="") for _ in range(0, arity)]
            self.stack.append(Constants.invoke_command(current_command, *arguments))

        # Command: .:
        # pop a,b,c
        # push a.replace(b, c)
        elif current_command == ".:":
            c = self.pop_stack(default="")
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")
            self.stack.append(apply_safe(single_replace, a, b, c))

        # Command: .;
        # pop a,b,c
        # push a.replace_first(b, c)
        elif current_command == ".;":
            c = self.pop_stack(default="")
            b = self.pop_stack(default="")
            a = self.pop_stack(default="")
            self.stack.append(apply_safe(first_replace, a, b, c))

        # Command: .A
        # pop a
        # push acronymified a
        elif current_command == ".A":
            a = self.pop_stack(default="")

            if type(a) is not list:
                a = str(a).split(" ")

            self.stack.append(vectorized_aggregator(
                a, lambda acc, val: acc + [val[0]], str, []
            ))

        # Command: Δ
        # pop a
        # Repeat CODE until a doesn't change
        elif current_command == "\u0394":
            a = self.pop_stack()
            statement, remaining = get_statements(self.commands[self.pointer_position + 1:])

            curr_value, prev_value = a, None

            range_variable = -1

            while curr_value != prev_value:
                range_variable += 1
                curr_value, prev_value = self.value(statement, stack=[curr_value]), curr_value

            self.stack.append(curr_value)
            self.pointer_position += len(statement) + 1


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '-d', '--debug', help="Debug mode", action="store_true")
    parser.add_argument('-s', '--safe', help="Safe mode", action="store_true")
    parser.add_argument(
        '-c', '--osabie', help="Encode from osabie", action="store_true")
    parser.add_argument(
        '-t', '--time', help="Time the program", action="store_true")
    parser.add_argument(
        '-e', '--eval', help="Evaluate as 05AB1E code", action="store",
        type=str, nargs="?", default=argparse.SUPPRESS)
    parser.add_argument(
        "program_path", help="Program path", action="store", type=str,
        nargs="?")

    args = parser.parse_args()
    filename = args.program_path
    DEBUG = args.debug
    SAFE_MODE = args.safe
    ENCODE_OSABIE = args.osabie
    TIME_IT = args.time

    EVAL = None

    if not filename:
        try:
            EVAL = args.eval
        except:
            parser.error("program_path is required if not using -e flag")
        else:
            # If EVAL is still None and there was no error
            # then it was called without arguments
            if not EVAL:
                parser.error("no code passed to -e")

    if EVAL:
        code = EVAL
    # Do not load from file if just eval'ing
    elif ENCODE_OSABIE:
        code = open(filename, "rb").read()
        code = osabie_to_utf8(code)
    else:
        code = open(filename, "r", encoding="utf-8").read()

    if code == "":
        code = zero_byte_code

    if TIME_IT:
        start_time = time.time()
        Osabie(code, debug=DEBUG, safe_mode=SAFE_MODE).run()
        end_time = time.time()
        print()
        print("Elapsed: " + str(end_time - start_time) + " seconds")
    else:
        Osabie(code, debug=DEBUG, safe_mode=SAFE_MODE).run()
