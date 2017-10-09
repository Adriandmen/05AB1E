import argparse
import time
import math
import lib.dictionary as dictionary
import lib.asciicanvas as canvas
import ast
import itertools
import datetime
import os
import tempfile
import random

from sys import stderr

from lib.constants import *
from lib.commands import *
from lib.encoding import *
from lib.vectorizer import *
from lib.extended_math import ExtendedMathInvoker
from lib.constants import ConstantsInvoker

ExtendedMath = ExtendedMathInvoker()
Constants = ConstantsInvoker()

stack = []
exit_program = []
has_printed = []
zero_division = []

recent_inputs = []
input_index = [0]

# Global registers
register_x = [1]
register_y = [2]
register_z = [3]
register_c = []

last_pop = []

suspend_restore_register = []

# Global values
counter_variable = [0]
global_array = []
is_queue = []
previous_len = []

# Block commands:
block_commands = ["F", "i", "v", "G", "\u0192", "\u0292", "\u03A3", "\u03B5", "\u00b5"]

# Global data

VERSION = "version 8.0"
DATE = "14:37 - May 9, 2016"

current_canvas = {}
current_cursor = [0, 0]

def get_input():
    a = input()

    if a[:3] == "\"\"\"":
        a = a[3:]
        while a[-3:] != "\"\"\"":
            a += "\n" + input()

        a = a[:-3]

    if is_array(a):
        a = ast.literal_eval(a)

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


def pop_stack(default=None):
    if stack:
        return stack.pop()

    errored = False
    try:
        a = opt_input()
    except:
        if default is None:
            raise
        a = default
        errored = True

    if is_array(a):
        a = ast_int_eval(a)

    if not errored:
        recent_inputs.append(a)
    return a

def get_block_statement(commands, pointer_position):
    statement = ""
    temp_position = pointer_position
    temp_position += 1
    current_command = commands[temp_position]
    amount_brackets = 1
    temp_string_mode = False
    while amount_brackets != 0:
        if current_command in "\"\u2018\u2019\u201C\u201D":
            temp_string_mode = not temp_string_mode
        if not temp_string_mode:
            if current_command == "}":
                amount_brackets -= 1
                if amount_brackets == 0:
                    break
            elif current_command in block_commands:
                amount_brackets += 1
            statement += current_command
        else:
            statement += current_command
        try:
            temp_position += 1
            current_command = commands[temp_position]
        except:
            break

    return statement, temp_position

def run_program(commands,
                debug,
                safe_mode,
                suppress_print,
                range_variable=0,
                string_variable=""):

    global current_canvas
    global current_cursor

    TEST_MODE = False
    if commands[0:5] == "TEST:":
        TEST_MODE = True
        commands = commands[5:]

    if debug:
        try:
            print("Full program: {}".format(commands))
        except:
            pass
    pointer_position = -1
    temp_position = 0

    while pointer_position < len(commands) - 1:
        if zero_division:
            0 / 0

        try:
            if exit_program:
                return True
            pointer_position += 1
            current_command = commands[pointer_position]

            if debug:
                try:
                    print("current >> {}  ||  stack: {}".format(
                        current_command, stack
                    ))
                except:
                    pass

            if current_command == ".":
                pointer_position += 1
                current_command += commands[pointer_position]

            if current_command == "\u017e":
                pointer_position += 1
                current_command += commands[pointer_position]

            if current_command == "\u00c5":
                pointer_position += 1
                current_command += commands[pointer_position]

            # Command: h
            # pop a
            # push hex(a)
            if current_command == "h":
                a = pop_stack(default="")
                stack.append(vectorized_evaluation(a, 16, convert_to_base))

            # Command: b
            # pop a
            # push bin(a)
            elif current_command == "b":
                a = pop_stack(default="")
                stack.append(vectorized_evaluation(a, 2, convert_to_base))

            # Command: B
            # pop a,b
            # push base(a, b)
            elif current_command == "B":
                b = pop_stack(default="")
                a = pop_stack(default="")
                stack.append(vectorized_evaluation(a, b, convert_to_base))

            # Command: в
            # pop a,b
            # push a converted to base b (arbitrary)
            elif current_command == "\u0432":
                b = pop_stack(default="")
                a = pop_stack(default="")
                stack.append(vectorized_evaluation(a, b, convert_to_base_arbitrary))

            # Commands: [0-9]+
            # Push the corresponding digit value onto the stack,
            # as a single number if multiple digits are consecutive
            elif is_digit_value(current_command):
                temp_number = ""
                temp_number += current_command
                temp_position = pointer_position
                while temp_position < len(commands) - 1:
                    temp_position += 1
                    try:
                        current_command = commands[temp_position]
                    except:
                        break
                    if is_digit_value(current_command):
                        temp_number += current_command
                        pointer_position += 1
                    else:
                        break
                stack.append(temp_number)

            # Command: "
            # Start/end string literal
            elif current_command == "\"":
                temp_string = ""
                temp_string_2 = ""
                temp_position = pointer_position
                while temp_position < len(commands) - 1:
                    temp_position += 1
                    try:
                        current_command = commands[temp_position]
                    except:
                        break
                    if current_command == "\"":
                        break
                    # String interpolation (command: ÿ)
                    # Error: replace with nothing
                    elif current_command == "\u00ff":
                        temp_string += str(pop_stack(default=""))
                        pointer_position += 1
                    else:
                        temp_string += current_command
                        pointer_position += 1
                pointer_position += 1
                stack.append(temp_string)

            # Command: ’
            # start/end of a compressed string (no implicit space)
            elif current_command == "\u2019":
                temp_string = ""
                temp_string_2 = ""
                temp_index = ""
                temp_position = pointer_position
                while temp_position < len(commands) - 1:
                    temp_position += 1
                    try:
                        current_command = commands[temp_position]
                        if dictionary.unicode_index.__contains__(
                                current_command):
                            temp_index += str(dictionary.unicode_index.index(
                                current_command)).rjust(2, "0")
                            temp_position += 1
                            pointer_position += 2
                            current_command = commands[temp_position]
                            temp_index += str(dictionary.unicode_index.index(
                                current_command)).rjust(2, "0")
                            temp_string += dictionary.dictionary[
                                int(temp_index)]
                            temp_index = ""
                        elif current_command == "\u2019":
                            pointer_position += 1
                            break
                        # String interpolation (command: ÿ)
                        # Error: replace with nothing
                        elif current_command == "\u00ff":
                            temp_string += str(pop_stack(default=""))
                            pointer_position += 1
                        else:
                            temp_string += current_command
                            pointer_position += 1
                    except:
                        pointer_position += 1
                        break
                    if debug:
                        print("{} with {}".format(
                            pointer_position, hex(ord(current_command))
                        ))

                stack.append(temp_string)

            # Command: ‘
            # Start/end of a compressed string (upper)
            elif current_command == "\u2018":
                temp_string = ""
                temp_string_2 = ""
                temp_index = ""
                temp_position = pointer_position
                while temp_position < len(commands) - 1:
                    temp_position += 1
                    try:
                        current_command = commands[temp_position]
                        if dictionary.unicode_index.__contains__(
                                current_command):
                            temp_index += str(dictionary.unicode_index.index(
                                current_command)).rjust(2, "0")
                            temp_position += 1
                            pointer_position += 2
                            current_command = commands[temp_position]
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
                            pointer_position += 1
                            break
                        # String interpolation (command: ÿ)
                        # Error: replace with nothing
                        elif current_command == "\u00ff":
                            temp_string += str(pop_stack(default=""))
                            pointer_position += 1
                        else:
                            temp_string += current_command
                            pointer_position += 1
                    except:
                        pointer_position += 1
                        break
                    if debug:
                        print("{} with {}".format(
                            pointer_position, hex(ord(current_command))
                        ))

                stack.append(temp_string)

            # Command: “
            # Start/end of a compressed string (normal)
            elif current_command == "\u201c":
                temp_string = ""
                temp_string_2 = ""
                temp_index = ""
                temp_position = pointer_position
                while temp_position < len(commands) - 1:
                    temp_position += 1
                    try:
                        current_command = commands[temp_position]
                        if dictionary.unicode_index.__contains__(
                                current_command):
                            temp_index += str(dictionary.unicode_index.index(
                                current_command)).rjust(2, "0")
                            temp_position += 1
                            pointer_position += 2
                            current_command = commands[temp_position]
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
                            pointer_position += 1
                            break
                        elif current_command == "\u00ff":
                            # String interpolation (command: ÿ)
                            # Error: replace with nothing
                            temp_string += str(pop_stack(default=""))
                            pointer_position += 1
                        else:
                            temp_string += current_command
                            pointer_position += 1
                    except:
                        pointer_position += 1
                        break
                    if debug:
                        print("{} with {}".format(
                            pointer_position, hex(ord(current_command))
                        ))

                stack.append(temp_string)

            # Command: ”
            # Start/end of a compressed string (title)
            elif current_command == "\u201d":
                temp_string = ""
                temp_string_2 = ""
                temp_index = ""
                temp_position = pointer_position
                while temp_position < len(commands) - 1:
                    temp_position += 1
                    try:
                        current_command = commands[temp_position]
                        if dictionary.unicode_index.__contains__(
                                current_command):
                            temp_index += str(dictionary.unicode_index.index(
                                current_command)).rjust(2, "0")
                            temp_position += 1
                            pointer_position += 2
                            current_command = commands[temp_position]
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
                            pointer_position += 1
                            break
                        # String interpolation (command: ÿ)
                        # Error: replace with nothing
                        elif current_command == "\u00ff":
                            temp_string += str(pop_stack(default=""))
                            pointer_position += 1
                        else:
                            temp_string += current_command
                            pointer_position += 1
                    except:
                        pointer_position += 1
                        break
                    if debug:
                        print("{} with {}".format(
                            pointer_position, hex(ord(current_command))
                        ))

                stack.append(temp_string)

            # Command: ª
            # pop a
            # push sentence_cased(a)
            elif current_command == "\u00aa":
                a = pop_stack(default="")
                stack.append(single_vectorized_evaluation(a, sentence_case, str))

            # Command: ù
            # pop a,b
            # push a with elements of length b
            elif current_command == "\u00f9":
                if len(stack) > 1:
                    b = pop_stack(default=0)
                    a = pop_stack(default=[])
                else:
                    a = pop_stack(default=[])
                    b = pop_stack(default=0)

                if type(b) is not list:
                    temp_list = []
                    try:
                        b_length = ast_int_eval(b)
                    except:
                        b_length = 0

                    for Q in a:
                        lenQ = len(Q if type(Q) is list else str(Q))
                        if lenQ == b_length:
                            temp_list.append(Q)
                    stack.append(temp_list)
                else:
                    temp_list_2 = []
                    for R in b:
                        temp_list = []

                        try:
                            R_length = ast_int_eval(R)
                        except:
                            R_length = 0

                        for Q in a:
                            lenQ = len(Q if type(Q) is list else str(Q))
                            if lenQ == R_length:
                                temp_list.append(Q)
                        temp_list_2.append(temp_list)
                    stack.append(temp_list_2)

            # Command: Λ
            # pop a,b,c
            # store a canvas with {a: num, b: filler, c: pattern}
            elif current_command == "\u039B":  
                pattern = pop_stack()
                filler = pop_stack()
                number_pattern = pop_stack()

                current_canvas, current_cursor = canvas.canvas_code_to_string(
                    number_pattern, pattern, filler, current_canvas, current_cursor
                )

            # Command: .Λ
            # pop a,b,c
            # store a canvas with {a: num, b: filler, c: pattern} 
            # and push the string to the stack
            elif current_command == ".\u039B":
                pattern = pop_stack()
                filler = pop_stack()
                number_pattern = pop_stack()

                current_canvas, current_cursor = canvas.canvas_code_to_string(
                    number_pattern, pattern, filler, current_canvas, current_cursor
                )

                stack.append(canvas.canvas_dict_to_string(current_canvas))

            # Command: ∊
            # pop a
            # push vertically mirrored a
            elif current_command == "\u220A":
                a = pop_stack(default="")
                result = apply_safe(vertical_mirror, a)
                stack.append('\n'.join(result))

            # Command: .∊
            # pop a
            # push intersected vertical mirror a
            elif current_command == ".\u220A":
                a = pop_stack(default="")
                result = apply_safe(vertical_intersected_mirror, a)
                stack.append('\n'.join(result))

            # Command: ∍
            # pop a,b
            # push a extended/shortened to length b
            elif current_command == "\u220D":
                b = pop_stack(default=0)
                a = pop_stack(default="")

                stack.append(apply_safe(shape_like, a, b))

            # Command: ā
            # get a
            # push range(1, len(a) + 1)
            elif current_command == "\u0101":
                a = pop_stack(default="")

                stack.append(a)

                if type(a) is int:
                    a = str(a)

                stack.append(apply_safe(lambda a: list(range(1, len(a) + 1)), a))

            # Command: Ā
            # pop a
            # push truthified a:
            #   if a can be converted to a number: 1 if != 0, 0 otherwise
            #   if a is a string or a list: 1 if non-empty, 0 otherwise
            elif current_command == "\u0100":
                a = pop_stack(default=0)

                stack.append(single_vectorized_evaluation(
                    a, lambda a: int(not not (a if is_digit_value(a) else len(a)>0)),
                ))

            # Command: ∞
            # pop a
            # push mirrored a
            elif current_command == "\u221e":
                a = pop_stack(default="")
                stack.append(apply_safe(mirror, a))

            # Command: .∞
            # pop a
            # push intersected mirror a
            elif current_command == ".\u221e":
                a = pop_stack(default="")
                stack.append(apply_safe(intersected_mirror, a))

            # Command: н
            # pop a
            # push a[0]
            elif current_command == "\u043D":
                a = pop_stack(default="")
                if type(a) is list:
                    stack.append(a[0])
                else:
                    stack.append(str(a)[0])

            # Command: θ
            # pop a
            # push a[-1]
            elif current_command == "\u03B8":
                a = pop_stack(default="")
                if type(a) is list:
                    stack.append(a[-1])
                else:
                    stack.append(str(a)[-1])

            # Command: ζ
            # pop a,(b):
            # if a is list, zip with spaces
            # otherwise: pop b, zip a with b
            elif current_command == "\u03B6":
                b = pop_stack(default="")

                if type(b) is list:
                    a, b = b, " "
                    stack.append(apply_safe(zip_with(a, b)))
                else:
                    b = str(b)
                    a = pop_stack(default="")
                    stack.append(apply_safe(zip_with(a, b)))

            # Command: ε
            # Usage: εCODE}
            # pop a
            # apply each on a
            elif current_command == "\u03B5":
                a = pop_stack(default="")

                if type(a) is int:
                    a = str(a)

                temp_stack = []
                temp_list = []
                for Q in stack:
                    temp_stack.append(Q)
                stack.clear()

                statement, temp_position = get_block_statement(commands, pointer_position)

                if debug:
                    try:
                        print("For each: {}".format(statement))
                    except:
                        pass

                for Q in a:
                    stack.append(Q)
                    run_program(statement, debug, safe_mode, True, range_variable, string_variable)
                    temp_list.append(stack[-1])
                    stack.clear()

                stack.clear()
                for Q in temp_stack:
                    stack.append(Q)
                stack.append(temp_list)

                pointer_position = temp_position

            # Command: !
            # pop a
            # push factorial(a)
            elif current_command == "!":
                a = pop_stack(default="")
                stack.append(single_vectorized_evaluation(a, math.factorial, int))

            # Command: +
            # pop a,b
            # push a+b 
            elif current_command == "+":
                if stack:
                    b = pop_stack(default="")
                    a = pop_stack(default="")
                else:
                    a = pop_stack(default="")
                    b = pop_stack(default="")

                stack.append(vectorized_evaluation(
                    a, b, lambda a, b: a + b, ast_int_eval
                ))

            # Command: -
            # pop a,b
            # push a-b
            elif current_command == "-":
                b = pop_stack(default="")
                a = pop_stack(default="")

                stack.append(vectorized_evaluation(
                    a, b, lambda a, b: a - b, ast_int_eval
                ))

            # Command: *
            # pop a,b
            # push a*b
            elif current_command == "*":
                b = pop_stack(default="")
                a = pop_stack(default="")

                stack.append(vectorized_evaluation(
                    a, b, lambda a, b: a * b, ast_int_eval
                ))

            # Command: /
            # pop a,b
            # push a / b 
            elif current_command == "/":
                b = pop_stack(default="")
                a = pop_stack(default="")

                stack.append(vectorized_evaluation(
                    a, b, lambda a, b: a / b, ast_int_eval
                ))

            # Command: %
            # pop a,b
            # push a % b
            elif current_command == "%":
                b = pop_stack(default="")
                a = pop_stack(default="")

                stack.append(vectorized_evaluation(
                    a, b, lambda a, b: a % b, ast_int_eval
                ))

            # Command: D
            # pop a
            # push a, a
            elif current_command == "D":
                a = pop_stack(default="")
                stack.append(a)
                stack.append(a)

            # Command: R
            # pop a
            # push reversed a
            elif current_command == "R":
                a = pop_stack(default="")
                if type(a) is list:
                    stack.append(a[::-1])
                else:
                    stack.append(str(a)[::-1])

            # Command: I
            # push input()
            elif current_command == "I":
                a = opt_input()
                stack.append(a)
                recent_inputs.append(a)

            # Command: $
            # push 1, input()
            elif current_command == "$":
                stack.append(1)

                try:
                    a = get_input()
                    stack.append(a)
                    recent_inputs.append(a)
                except:
                    stack.append("")

            # Command: H
            # pop a
            # push int(a, 16)
            elif current_command == "H":
                a = pop_stack(default="")

                stack.append(single_vectorized_evaluation(
                    a, lambda a: int(a, 16), str
                ))

            # Command: C
            # pop a
            # push int(a, 2)
            # Error: push ""
            elif current_command == "C":
                a = pop_stack(default="")

                stack.append(single_vectorized_evaluation(
                    a, lambda a: int(a, 2), str
                ))

            # Command: a
            # pop a
            # push isAlpha(a)
            elif current_command == "a":
                a = pop_stack(default=0)
                stack.append(single_vectorized_evaluation(
                    a, lambda a: is_alpha_value(a), str
                ))

            # Command: d
            # pop a
            # push isNumber(a)
            elif current_command == "d":
                a = pop_stack(default="")
                stack.append(single_vectorized_evaluation(
                    a, lambda a: is_digit_value(a), str
                ))

            # Command: p
            # pop a
            # push isPrime(a)
            elif current_command == "p":
                a = pop_stack(default=0)
                stack.append(single_vectorized_evaluation(
                    a, lambda a: is_prime(a)
                ))

            # Command: u
            # pop a
            # push uppercase(a)
            elif current_command == "u":
                a = pop_stack(default="")
                stack.append(single_vectorized_evaluation(
                    a, lambda a: a.upper(), str
                ))

            # Command: l
            # pop a
            # push lowercase(a)
            elif current_command == "l":
                a = pop_stack(default="")
                stack.append(single_vectorized_evaluation(
                    a, lambda a: a.lower(), str
                ))

            # Command: _
            # pop a
            # push negative bool of a:
            #   if a can be converted to a number: 1 if == 0, 0 otherwise
            #   if a is a string or a list: 1 if empty, 0 otherwise
            # Error: push 0
            elif current_command == "_":
                a = pop_stack(default=1)
                stack.append(single_vectorized_evaluation(
                    a, lambda a: int(not (a if is_digit_value(a) else len(a)))
                ))

            # Command: s
            # pop a,b
            # push b,a
            elif current_command == "s":
                a = pop_stack(default="")
                b = pop_stack(default="")
                stack.append(a)
                stack.append(b)

            # Command: |
            # push the rest of input as an array with strings
            elif current_command == "|":
                a = input()
                temp_list = []
                try:
                    while True:
                        temp_list.append(a)
                        a = input()
                        if a == "":
                            break
                except:
                    pass
                stack.append(temp_list)

            # Command: ≠
            # pop a
            # push 05AB1E falsified a (a != 1)
            elif current_command == "\u2260":
                a = pop_stack(default=0)

                stack.append(single_vectorized_evaluation(
                    a, lambda a: int(ast_int_eval(a) != 1 if is_digit_value(a) else 1)
                ))

            # Command: Θ
            # pop a
            # push 05AB1E truthified a (a == 1)
            elif current_command == "\u0398":
                a = pop_stack(default=0)
                stack.append(single_vectorized_evaluation(
                    a, lambda a: int(ast_int_eval(a) == 1 if is_digit_value(a) else 0)
                ))

            # Command: м
            # pop a,b
            # push a.remove(all elements of b)
            elif current_command == "\u043C":
                b = pop_stack(default="")
                a = pop_stack(default="")
                stack.append(apply_save(remove_all, a, b))

            # Command: L
            # pop a
            # push [1 .. a]
            elif current_command == "L":
                temp_list = []
                a = pop_stack(default=1)
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

                stack.append(temp_list)

            # Command: r
            # reverse the stack
            elif current_command == "r":
                stack.reverse()

            # Command: i
            # if...}else...} statement
            elif current_command == "i":
                statement, temp_position = get_block_statement(commands, pointer_position)
                else_statement = ""

                if '\u00eb' in statement:
                    expected_else = 1
                    pos = 0
                    for c in statement:
                        if c == '\u00eb':
                            expected_else -= 1
                        elif c == 'i':
                            expected_else += 1

                        if expected_else == 0:
                            break

                        pos += 1
                    else_statement = statement[pos+1:]
                    statement = statement[0:pos]

                if debug:
                    print("if: ", end="")
                    for Q in statement:
                        try:
                            print(Q, end="")
                        except:
                            print("?", end="")
                    print()
                    if else_statement:
                        print("else: ", end="")
                        for Q in else_statement:
                            try:
                                print(Q, end="")
                            except:
                                print("?", end="")
                        print()

                a = pop_stack(default=0)

                if a == 1 or a == "1":
                    run_program(statement, debug, safe_mode, True,
                                range_variable, string_variable)
                elif else_statement:
                    run_program(else_statement, debug, safe_mode, True,
                                range_variable, string_variable)
                pointer_position = temp_position

            # Command: \
            # pop a
            elif current_command == "\\":
                pop_stack()

            # Command: `
            # pop a
            # push all items of a into the stack
            elif current_command == "`":
                a = pop_stack()

                if type(a) is int:
                    a = str(a)

                for x in a:
                    stack.append(x)

            # Command: x
            # pop a
            # push a, a * 2
            elif current_command == "x":
                a = pop_stack(default="")
                stack.append(a)
                stack.append(single_vectorized_evaluation(a, lambda a: int(a)*2))

            # Command: F
            # pop a
            # for N in range(0, a) { }: F(commands)} / N = variable
            elif current_command == "F":
                statement, temp_position = get_block_statement(commands, pointer_position)

                if debug:
                    try:
                        print("Loop: {}".format(statement))
                    except:
                        pass

                a = apply_safe(int, pop_stack(default=0))

                if type(a) is int and a != 0:
                    for range_variable in range(0, a):
                        run_program(statement, debug, safe_mode, True,
                                    range_variable, string_variable)
                pointer_position = temp_position

            # Command: G
            # pop a
            # for N in range(1, a) { }: F(commands)} / N = variable
            elif current_command == "G":
                statement, temp_position = get_block_statement(commands, pointer_position)

                if debug:
                    try:
                        print("Loop: {}".format(statement))
                    except:
                        pass
                
                a = apply_safe(int, pop_stack(default=0))

                if type(a) is int and a > 1:
                    for range_variable in range(1, a):
                        run_program(statement, debug, safe_mode, True,
                                    range_variable, string_variable)
                pointer_position = temp_position

            # Command: µ
            # pop a
            # while counter_variable != a, do...
            elif current_command == "\u00b5":
                statement, temp_position = get_block_statement(commands, pointer_position)

                if debug:
                    try:
                        print("Loop: {}".format(statement))
                    except:
                        pass

                a = apply_safe(int, pop_stack(default=0))

                if type(a) is int:
                    range_variable = 0

                    if '\u00bc' not in statement and '\u00bd' not in statement:
                        statement += '\u00bd'

                    while counter_variable[-1] != a:
                        range_variable += 1
                        run_program(statement, debug, safe_mode, True,
                                    range_variable, string_variable)

                pointer_position = temp_position

            # Command: Ë
            # pop a
            # push 1 if all equal else 0
            elif current_command == "\u00cb":
                a = pop_stack(default="")

                if type(a) is int:
                    a = str(a)

                if len(a) < 2:
                    stack.append(1)
                else:
                    FIRST_ELEMENT = str(a[0])
                    all_equal = True

                    for element in a:
                        if str(element) != FIRST_ELEMENT:
                            all_equal = False

                    stack.append(int(all_equal))

            # Command: ƒ
            # pop a
            # push for N in range(0, a + 1)
            elif current_command == "\u0192":
                statement, temp_position = get_block_statement(commands, pointer_position)

                if debug:
                    try:
                        print("Loop: {}".format(statement))
                    except:
                        pass

                a = apply_safe(int, pop_stack(default=-1))

                if type(a) is int and a > -1:
                    for range_variable in range(0, a + 1):
                        run_program(statement, debug, safe_mode, True,
                                    range_variable, string_variable)
                pointer_position = temp_position

            # Command: N
            # Push iteration counter
            elif current_command == "N":
                stack.append(range_variable)

            # Command: T
            # Push 10
            elif current_command == "T":
                stack.append(10)

            # Command: S
            # pop a
            # push all chars a seperate
            elif current_command == "S":
                a = pop_stack(default="")
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        for X in str(Q):
                            temp_list.append(X)
                    stack.append(temp_list)
                else:
                    temp_list = []
                    for X in str(a):
                        temp_list.append(X)
                    stack.append(temp_list)

            # Command: ^
            # pop a,b
            # push a XOR b
            elif current_command == "^":
                b = pop_stack(default=0)
                a = pop_stack(default=0)
                stack.append(vectorized_evaluation(
                    a, b, lambda a, b: a ^ b, int
                ))

            # Command: ~
            # pop a,b
            # push a OR b
            elif current_command == "~":
                b = pop_stack(default=0)
                a = pop_stack(default=0)
                stack.append(vectorized_evaluation(
                    a, b, lambda a, b: a | b, int
                ))

            # Command: &
            # pop a,b
            # push a AND b
            elif current_command == "&":
                b = pop_stack(default=0)
                a = pop_stack(default=0)
                stack.append(vectorized_evaluation(
                    a, b, lambda a, b: a & b, int
                ))

            # Command: c
            # pop a,b
            # push a nCr b
            elif current_command == "c":
                b = pop_stack(default=1)
                a = pop_stack(default=0)
                stack.append(vectorized_evaluation(
                    a, b, lambda a, b: combinations(a, b), int
                ))

            # Command: e
            # pop a,b
            # push a nPr b
            elif current_command == "e":
                b = pop_stack(default=1)
                a = pop_stack(default=0)
                stack.append(vectorized_evaluation(
                    a, b, lambda a, b: permutations(a, b), int
                ))

            # Command: >
            # pop a
            # push a + 1
            elif current_command == ">":
                a = pop_stack(default="")
                stack.append(single_vectorized_evaluation(
                    a, lambda a: a + 1, ast_int_eval
                ))

            # Command: >
            # pop a
            # push a - 1
            elif current_command == "<":
                a = pop_stack(default="")
                stack.append(single_vectorized_evaluation(
                    a, lambda a: a - 1, ast_int_eval
                ))

            # Command: '
            # push char ( 'a pushes "a" )
            elif current_command == "'":
                temp_string = ""
                temp_index = ""
                pointer_position += 1
                temp_position = pointer_position
                current_command = commands[pointer_position]
                if dictionary.unicode_index.__contains__(current_command):
                    temp_index += str(dictionary.unicode_index.index(
                        current_command)).rjust(2, "0")
                    temp_position += 1
                    pointer_position += 1
                    current_command = commands[temp_position]
                    temp_index += str(dictionary.unicode_index.index(
                        current_command)).rjust(2, "0")
                    if temp_string == "":
                        temp_string += dictionary.dictionary[int(temp_index)]
                    else:
                        temp_string += " " + dictionary.dictionary[
                            int(temp_index)]
                    temp_index = ""
                    stack.append(temp_string)
                else:
                    temp_string = commands[pointer_position]
                    stack.append(temp_string)

            # Command: „
            # 2 char string / can also be used for 2 compressed strings
            elif current_command == "\u201e":
                temp_string = ""
                temp_index = ""

                word_count = 0

                while word_count != 2:
                    pointer_position += 1
                    temp_position = pointer_position
                    current_command = commands[pointer_position]
                    if dictionary.unicode_index.__contains__(current_command):
                        temp_index += str(dictionary.unicode_index.index(
                            current_command)).rjust(2, "0")
                        temp_position += 1
                        pointer_position += 1
                        current_command = commands[temp_position]
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
                        temp_string += str(pop_stack(default=""))
                        word_count += 1
                    else:
                        temp_string += commands[pointer_position]
                        word_count += 1

                stack.append(temp_string)

            # Command: …
            # 3 char string / can also be used for 3 compressed strings
            elif current_command == "\u2026":
                temp_string = ""
                temp_index = ""

                word_count = 0

                while word_count != 3:
                    pointer_position += 1
                    temp_position = pointer_position
                    current_command = commands[pointer_position]
                    if dictionary.unicode_index.__contains__(current_command):
                        temp_index += str(dictionary.unicode_index.index(
                            current_command)).rjust(2, "0")
                        temp_position += 1
                        pointer_position += 1
                        current_command = commands[temp_position]
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
                        temp_string += str(pop_stack(default=""))
                        word_count += 1
                    else:
                        temp_string += commands[pointer_position]
                        word_count += 1

                stack.append(temp_string)

            # Command: ö
            # pop a,b
            # push int(a, b)
            elif current_command == "\u00f6":
                b = pop_stack(default="")
                a = pop_stack(default="")

                stack.append(vectorized_evaluation(
                    a, b, lambda a, b: convert_from_base(a, b)
                ))

            # Command: ¸
            # pop a
            # push [a]
            elif current_command == "\u00b8":
                a = pop_stack(default="")
                stack.append([a])

            # Command: .S
            # pop a,b
            # push 1 if a > b, -1 if a < b, 0 if a == b
            elif current_command == ".S":
                b = pop_stack(default="")
                a = pop_stack(default="")

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
                        stack.append(temp_list)
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
                        stack.append(temp_list)
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
                        stack.append(temp_list)
                    else:
                        aieAq = apply_safe(ast_int_eval, str(a))
                        aieBq = apply_safe(ast_int_eval, str(b))

                        if type(aieAq) is not int or type(aieBq) is not int:
                            stack.append(aieAq)
                        elif aieAq > aieBq:
                            stack.append(1)
                        elif aieAq < aieBq:
                            stack.append(-1)
                        elif aieAq == aieBq:
                            stack.append(0)

            # Command: [
            # Infinite loop start
            elif current_command == "[":
                STATEMENT = ""
                temp_position = pointer_position
                temp_position += 1
                current_command = commands[temp_position]
                amount_brackets = 1
                while amount_brackets != 0:
                    if current_command == "]":
                        amount_brackets -= 1
                        if amount_brackets == 0:
                            break
                    elif current_command == "[":
                        amount_brackets += 1
                    STATEMENT += current_command
                    try:
                        temp_position += 1
                        current_command = commands[temp_position]
                    except:
                        break
                if debug:
                    print(STATEMENT)
                range_variable = -1
                while True:
                    range_variable += 1
                    if run_program(STATEMENT, debug, safe_mode, True,
                                   range_variable, string_variable):
                        break
                pointer_position = temp_position

            elif current_command == "#":
                a = pop_stack(1)
                if " " in str(a):
                    stack.append(str(a).split(" "))
                else:
                    try:
                        if ast_int_eval(a) == 1:
                            return True
                    except:
                        pass

            elif current_command == "\u00e9":
                a = pop_stack(1)
                temp_list = []
                for Q in a:
                    if type(Q) is int:
                        temp_list.append(str(Q))
                    else:
                        temp_list.append(Q)
                stack.append(sorted(temp_list, key=len))

            elif current_command == "=":
                a = pop_stack(1)
                stack.append(a)
                print(a)
                has_printed.append(True)

            elif current_command == "Q":
                b = pop_stack(1)
                a = pop_stack(1)
                if type(a) is list and type(b) is list:
                    a = [str(x) for x in a]
                    b = [str(x) for x in b]

                    a = ast_int_eval(str(a))
                    b = ast_int_eval(str(b))

                    stack.append(int(str(a) == str(b)))
                elif type(a) is list:
                    temp_list = []
                    b = ast_int_eval("\"" + str(b) + "\"")
                    for Q in a:
                        if is_digit_value(str(Q)):
                            Q = ast_int_eval(str(Q))
                        temp_list.append(int(str(Q) == str(b)))
                    stack.append(temp_list)
                elif type(b) is list:
                    temp_list = []
                    a = ast_int_eval("\"" + str(a) + "\"")
                    for Q in b:
                        if is_digit_value(str(Q)):
                            Q = ast_int_eval(str(Q))
                        temp_list.append(int(str(Q) == str(a)))
                    stack.append(temp_list)
                else:
                    a = ast_int_eval("\"" + str(a) + "\"")
                    b = ast_int_eval("\"" + str(b) + "\"")
                    stack.append(int(str(a) == str(b)))

            elif current_command == "\u00ca":
                b = pop_stack(1)
                a = pop_stack(1)
                if type(a) is list and type(b) is list:
                    stack.append(int(
                        str([str(x) for x in a]) != str([str(x) for x in b])
                    ))
                else:
                    stack.append(vectorized_evaluation(
                        a, b, lambda a, b: int(str(a) != str(b))
                    ))

            elif current_command == "(":
                a = pop_stack(1)
                stack.append(single_vectorized_evaluation(
                    a, lambda a: a * -1, ast_int_eval
                ))

            elif current_command == "A":
                stack.append('abcdefghijklmnopqrstuvwxyz')

            elif current_command == "\u2122":
                a = pop_stack(1)
                stack.append(single_vectorized_evaluation(
                    a, lambda a: a.title(), str
                ))

            elif current_command == "E":
                try:
                    a = get_input()
                    stack.append(a)
                except:
                    pass

            elif current_command == ")":
                temp_list = []
                temp_list_2 = []
                if stack:
                    for S in stack:
                        temp_list_2.append(S)
                    for Q in temp_list_2:
                        R = pop_stack(1)
                        temp_list.append(R)
                    temp_list.reverse()
                stack.append(temp_list)

            elif current_command == "P":
                temp_number = 1
                if not stack:
                    try:
                        stack.append(get_input())
                    except:
                        stack.append([])

                if type(stack[-1]) is list:
                    a = pop_stack(1)
                    if len(a) == 0:
                        stack.append(1)
                        continue

                    if type(a[0]) is list:
                        temp_list = []
                        for Q in a:
                            temp_number_2 = 1
                            for X in Q:
                                temp_number_2 *= ast_int_eval(X)
                            temp_list.append(temp_number_2)
                        stack.append(temp_list)
                    else:
                        for Q in a:
                            temp_number *= ast_int_eval(str(Q))
                        stack.append(temp_number)
                else:
                    for Q in stack:
                        temp_number *= ast_int_eval(str(Q))
                    stack.clear()
                    stack.append(temp_number)

            elif current_command == "O":
                temp_number = 0
                temp_list_2 = []

                if not stack:
                    try:
                        stack.append(get_input())
                    except:
                        stack.append([])

                if type(stack[-1]) is list:
                    a = pop_stack(1)
                    if len(a) == 0:
                        stack.append(0)

                    elif type(a[-1]) is list:
                        for Q in a:
                            temp_number = 0
                            for R in Q:
                                temp_number += ast_int_eval(str(R))
                            temp_list_2.append(temp_number)
                        stack.append(temp_list_2)
                    else:
                        for Q in a:
                            temp_number += ast_int_eval(str(Q))
                        stack.append(temp_number)
                else:
                    for Q in stack:
                        temp_number += ast_int_eval(str(Q))
                    stack.clear()
                    stack.append(temp_number)

            elif current_command == ";":
                a = pop_stack(1)
                stack.append(single_vectorized_evaluation(
                    a, lambda a: a / 2, ast_int_eval))

            elif current_command == "w":
                time.sleep(1)

            elif current_command == "m":
                b = pop_stack(1)
                a = pop_stack(1)
                stack.append(vectorized_evaluation(
                    a, b, lambda a, b: a ** b, ast_int_eval))

            elif current_command == "X":
                stack.append(register_x[-1])

            elif current_command == "Y":
                stack.append(register_y[-1])

            elif current_command == "z":
                a = pop_stack(1)
                stack.append(single_vectorized_evaluation(
                    a, lambda a: 1 / a, ast_int_eval))

            elif current_command == "U":  # x variable
                a = pop_stack(1)
                register_x.append(a)

            elif current_command == "V":  # y variable
                a = pop_stack(1)
                register_y.append(a)

            elif current_command == "W":
                a = pop_stack(1)
                stack.append(a)

                min_val = a[0]
                if type(min_val) is list:
                    Q = 0
                    for x in min_val:
                        Q += ast_int_eval(x)
                    min_val = Q
                else:
                    min_val = ast_int_eval(min_val)

                for X in a:
                    if ast_int_eval(X) < min_val:
                        min_val = ast_int_eval(X)

                stack.append(min_val)

            elif current_command == "Z":
                a = pop_stack(1)
                stack.append(a)

                max_val = a[0]
                temp_max = 0
                if type(max_val) is list:
                    Q = 0
                    for x in max_val:
                        Q += ast_int_eval(x)
                    temp_max = max_val
                    max_val = Q
                else:
                    temp_max = ast_int_eval(max_val)
                    max_val = ast_int_eval(max_val)

                for X in a:
                    Q = 0
                    if type(X) is list:
                        for y in X:
                            Q += ast_int_eval(y)
                        if Q > max_val:
                            max_val = Q
                            temp_max = X
                    else:
                        if ast_int_eval(X) > max_val:
                            max_val = ast_int_eval(X)
                            temp_max = max_val

                stack.append(temp_max)

            elif current_command == "q":
                exit_program.append(1)
                break

            elif current_command == "g":
                a = pop_stack(1)
                if type(a) is int:
                    stack.append(len(str(a)))
                else:
                    stack.append(len(a))

            elif current_command == "J":
                temp_list = []
                temp_string = ""
                if not stack:
                    try:
                        stack.append(get_input())
                    except:
                        stack.append('')
                for Q in stack:
                    temp_list.append(Q)
                a = temp_list.pop()
                if type(a) is list:
                    if type(a[0]) is list:

                        temp_list = []
                        for Q in a:
                            temp_list.append(''.join([str(x) for x in Q]))
                        temp_string = temp_list
                    else:
                        for Q in a:
                            if type(Q) is bool:
                                temp_string += str(int(Q))
                            else:
                                temp_string += str(Q)
                    pop_stack(1)
                else:
                    R = len(stack)
                    stack.reverse()
                    for Q in range(R):
                        a = pop_stack(1)
                        if type(a) is bool:
                            temp_string += str(int(a))
                        else:
                            temp_string += str(a)
                stack.append(temp_string)

            elif current_command == ":":
                c = pop_stack(1)
                b = pop_stack(1)
                a = pop_stack(1)

                stack.append(infinite_replace(a, b, c))

            elif current_command == "j":
                a = pop_stack(1)

                if type(stack[-1]) is list:
                    b = pop_stack(1)
                    temp_string = ""
                    for Q in b:
                        temp_string += str(Q).rjust(int(a))
                else:
                    temp_string = ""
                    for Q in stack:
                        temp_string += str(Q).rjust(int(a))
                stack.append(temp_string)

            elif current_command == ".j":
                a = pop_stack(1)
                a = int(a)
                temp_string = ""
                for Q in range(0, len(stack) + 1):
                    temp_string += str(Q).rjust(a)
                print(temp_string)
                temp_number = 0
                for Q in stack:
                    temp_number += 1
                    temp_string = ""
                    if type(Q) is list:
                        for R in Q:
                            temp_string += str(R).rjust(a)
                        print(str(temp_number).rjust(a) + temp_string)
                    else:
                        print(str(Q).rjust(a), end="")
                has_printed.append(True)

            elif current_command == ".J":
                a = pop_stack(1)
                a = int(a)
                temp_string = ""
                for Q in range(1, len(stack) + 2):
                    temp_string += str(Q).rjust(a)
                print(temp_string)
                temp_number = 1
                for Q in stack:
                    temp_number += 1
                    temp_string = ""
                    if type(Q) is list:
                        for R in Q:
                            temp_string += str(R).rjust(a)
                        print(str(temp_number).rjust(a) + temp_string)
                    else:
                        print(str(Q).rjust(a), end="")
                has_printed.append(True)

            elif current_command == ".b":
                a = pop_stack(1)
                stack.append(single_vectorized_evaluation(
                    a, lambda a: get_letter(a), int))

            elif current_command == "@":
                a = int(pop_stack(1))
                stack.append(stack.pop(a))

            elif current_command == "M":
                temp_list = []
                temp_list.append(stack)

                temp_list = deep_flatten(temp_list)
                max_int = -float("inf")
                for Q in temp_list:
                    try:
                        if ast_int_eval(Q) > max_int:
                            max_int = ast_int_eval(Q)
                    except:
                        0
                stack.append(max_int)

            elif current_command == "t":
                a = pop_stack(1)
                stack.append(single_vectorized_evaluation(
                    a, lambda a: math.sqrt(a), ast_int_eval))

            elif current_command == "n":
                a = pop_stack(1)
                stack.append(single_vectorized_evaluation(
                    a, lambda a: a ** 2, ast_int_eval))

            elif current_command == "o":
                a = pop_stack(1)
                stack.append(single_vectorized_evaluation(
                    a, lambda a: 2 ** a, ast_int_eval))

            elif current_command == "k":
                if stack:
                    b = pop_stack(1)
                    a = pop_stack(1)
                else:
                    a = pop_stack(1)
                    b = pop_stack(1)

                try:
                    if type(a) is list:
                        temp_list = []
                        for Q in a:
                            temp_list.append(str(Q))

                        if type(b) is list:
                            stack.append([temp_list.index(str(c)) for c in b])
                        else:
                            stack.append(temp_list.index(str(b)))
                    else:
                        if type(b) is list:
                            stack.append([str(a).index(str(c)) for c in b])
                        else:
                            stack.append(str(a).index(str(b)))
                except:
                    stack.append(-1)

            elif current_command == "{":
                a = pop_stack(1)
                if type(a) is list:
                    stack.append(sorted(a))
                else:
                    stack.append(''.join(sorted(str(a))))

            elif current_command == "\u00b0":
                a = pop_stack(1)
                stack.append(single_vectorized_evaluation(
                    a, lambda a: 10 ** a, ast_int_eval
                ))

            elif current_command == "\u00ba":
                if len(stack) > 0:
                    stack.append(1)
                else:
                    stack.append(0)

            elif current_command == "\u00e5":
                b = pop_stack(1)
                a = pop_stack(1)

                if type(a) is int:
                    a = str(a)
                if type(b) is int:
                    b = str(b)

                if type(b) is list:
                    temp_list = []
                    for Q in b:
                        Q = str(Q) if type(Q) is int else Q
                        temp_list.append(int(Q in a))
                    stack.append(temp_list)

                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(str(Q) if type(Q) is int else Q)
                    stack.append(int(b in temp_list))

                else:
                    stack.append(int(b in a))

            elif current_command == ".\u00e5":
                b = pop_stack(1)
                a = pop_stack(1)

                if type(a) is int:
                    a = str(a)
                if type(b) is int:
                    b = str(b)

                if type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(int(str(Q) in a))
                    stack.append(temp_list)

                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(int(str(b) in str(Q)))
                    stack.append(temp_list)

                else:
                    stack.append(int(b in a))

            elif current_command == "v":
                statement, temp_position = get_block_statement(commands, pointer_position)

                if debug:
                    try:
                        print("Loop: {}".format(statement))
                    except:
                        pass

                a = 0
                a = pop_stack(1)

                range_variable = -1
                if type(a) is int:
                    a = str(a)
                for string_variable in a:
                    range_variable += 1
                    if debug:
                        print("N = " + str(range_variable))
                    run_program(statement, debug, safe_mode, True,
                                range_variable, string_variable)

                pointer_position = temp_position

            elif current_command == "y":
                stack.append(string_variable if not is_queue else is_queue[-1])

            elif current_command == ",":
                a = pop_stack(1)
                print(str(a))
                has_printed.append(True)

            elif current_command == "f":
                a = pop_stack(1)
                stack.append(single_vectorized_evaluation(
                    a, lambda a: prime_factorization(a), int
                ))

            elif current_command == "\u00d2":
                a = pop_stack(1)
                stack.append(single_vectorized_evaluation(
                    a, lambda a: prime_factorization_duplicates(a), int
                ))

            elif current_command == "\u00d3":
                a = pop_stack(1)
                stack.append(single_vectorized_evaluation(
                    a, lambda a: prime_factorization_powers(a), int
                ))

            elif current_command == "\u00fa":
                b = pop_stack(1)
                a = pop_stack(1)

                try:
                    stack.append(vectorized_evaluation(
                        a, b, lambda a, b: " " * int(b) + (a if type(a) is list else str(a))
                    ))
                except:
                    stack.append(vectorized_evaluation(
                        b, a, lambda a, b: " " * int(b) + (a if type(a) is list else str(a))
                    ))

            elif current_command == "\u00fe":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list_2 = []
                    for Q in a:
                        if is_digit_value(Q):
                            temp_list_2.append(str(Q))
                    stack.append(temp_list_2)
                else:
                    temp_list = []
                    for Q in str(a):
                        if is_digit_value(Q):
                            temp_list.append(Q)
                    stack.append(''.join(temp_list))

            elif current_command == "\u00e1":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list_2 = []
                    for Q in a:
                        if is_alpha_value(Q):
                            temp_list_2.append(Q)
                    stack.append(temp_list_2)
                else:
                    temp_list = []
                    for Q in str(a):
                        if is_alpha_value(Q):
                            temp_list.append(Q)
                    stack.append(''.join(temp_list))

            elif current_command == ".u":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        if str(Q).upper() == str(Q):
                            temp_list.append(1)
                        else:
                            temp_list.append(0)
                    stack.append(temp_list)
                else:
                    if str(a).upper() == str(a):
                        stack.append(1)
                    else:
                        stack.append(0)

            elif current_command == ".l":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        if str(Q).lower() == str(Q):
                            temp_list.append(1)
                        else:
                            temp_list.append(0)
                    stack.append(temp_list)
                else:
                    if str(a).lower() == str(a):
                        stack.append(1)
                    else:
                        stack.append(0)

            elif current_command == "\u00ea":
                a = pop_stack(1)
                if type(a) is int:
                    a = str(a)
                temp_list = []
                temp_string = sorted(a)
                for Q in temp_string:
                    if type(Q) is int:
                        Q = str(Q)
                    if Q not in temp_list:
                        temp_list.append(Q)
                if type(a) is list:
                    stack.append(temp_list)
                else:
                    stack.append(''.join(temp_list))

            elif current_command == "\u00c7":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(ord(str(Q)))
                    stack.append(temp_list)
                else:
                    temp_list = []
                    for Q in a:
                        temp_list.append(ord(str(Q)))

                    stack.append(temp_list)

            elif current_command == "\u00e7":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(chr(int(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(chr(int(a)))

            elif current_command == "\u02dc":
                a = pop_stack(1)
                stack.append(deep_flatten(a))

            elif current_command == "\u00f4":
                b = pop_stack(1)
                a = pop_stack(1)

                try:
                    stack.append(even_divide(a, b))
                except:
                    stack.append(even_divide(b, a))

            elif current_command == "\u00ed":
                a = pop_stack(1)
                temp_list = []

                for Q in a:
                    if type(Q) is int:
                        Q = str(Q)
                    temp_list.append(Q[::-1])
                stack.append(temp_list)

            elif current_command == "\u00f7":
                b = pop_stack(1)
                a = pop_stack(1)
                stack.append(vectorized_evaluation(
                    a, b, lambda a, b: a // b, ast_int_eval
                ))

            elif current_command == "\u00b1":
                a = pop_stack(1)
                stack.append(single_vectorized_evaluation(
                    a, lambda a: ~a, int
                ))

            elif current_command == "\u00c6":
                if stack and type(stack[-1]) is not list:
                    a = ast_int_eval(stack[0])
                    for element in stack[1:]:
                        a -= ast_int_eval(element)
                    stack.append(a)
                else:
                    a = pop_stack(1)
                    a = a[::-1]
                    result = ast_int_eval(str(a.pop()))
                    for Q in a:
                        result -= ast_int_eval(str(Q))
                    stack.append(result)

            elif current_command == "\u00d9":
                a = pop_stack(1)
                temp_list = []
                for Q in a:
                    if type(Q) is int:
                        Q = str(Q)
                    if Q not in temp_list:
                        temp_list.append(Q)
                if type(a) is list:
                    stack.append(temp_list)
                else:
                    stack.append(''.join(temp_list))

            elif current_command == "\u00f8":

                b = pop_stack(1)
                if type(b) is not list:
                    b = str(b)
                    a = pop_stack(1)
                    if type(a) is int:
                        a = str(a)
                    result = [list(x) for x in zip(*[a, b])]
                    if type(a) is str:
                        stack.append([''.join(x) for x in result])
                    else:
                        stack.append(result)
                else:
                    if max([type(x) is list for x in b]):
                        result = [list(x) for x in zip(*b)]
                        stack.append(result)
                    elif max([len(x) for x in b]) > 1:
                        result = [list(x) for x in zip(*b)]
                        stack.append([''.join(x) for x in result])

                    else:
                        a = pop_stack(1)

                        if type(a) is int:
                            a = str(a)
                        result = [list(x) for x in zip(*[a, b])]
                        stack.append(result)

            elif current_command == "\u00da":
                a = pop_stack(1)
                a = a[::-1]
                temp_list = []
                for Q in a:
                    if type(Q) is int:
                        Q = str(Q)
                    if Q not in temp_list:
                        temp_list.append(Q)
                if type(a) is list:
                    stack.append(temp_list[::-1])
                else:
                    stack.append(''.join(temp_list[::-1]))

            elif current_command == "\u00db":
                b = pop_stack(1)
                a = pop_stack(1)
                if type(a) is int:
                    a = str(a)
                if type(b) is int:
                    b = str(b)

                if a:
                    while a and str(a[0]) == str(b):
                        a = a[1:]
                    stack.append(a)
                else:
                    stack.append([])

            elif current_command == "\u00a5":
                a = pop_stack(1)
                temp_list = []
                length_of_list = len(a)
                for Q in range(0, length_of_list - 1):
                    temp_list.append(
                        ast_int_eval(str(a[Q + 1])) - ast_int_eval(str(a[Q]))
                    )
                stack.append(temp_list)

            elif current_command == "\u00a9":
                if stack:
                    a = stack[-1]
                else:
                    a = get_input()
                    stack.append(a)
                register_c.append(a)

            elif current_command == "\u00ae":
                if len(register_c) > 0:
                    stack.append(register_c[-1])
                else:
                    stack.append(-1)

            elif current_command == "\u00dc":
                b = pop_stack(1)
                a = pop_stack(1)

                if type(a) is int:
                    a = str(a)
                if type(b) is int:
                    b = str(b)

                if a:
                    while a and str(a[-1]) == str(b):
                        a = a[:-1]

                    stack.append(a)
                else:
                    stack.append([])

            elif current_command == "\u00c8":
                a = pop_stack(1)
                stack.append(single_vectorized_evaluation(
                    a, lambda a: int(a % 2 == 0), ast_int_eval
                ))

            elif current_command == "\u00bf":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(int(Q))
                    stack.append(command_gcd(temp_list))
                else:
                    b = pop_stack(1)
                    stack.append(command_gcd([int(a), int(b)]))

            elif current_command == "\u00c9":
                a = pop_stack(1)
                stack.append(single_vectorized_evaluation(
                    a, lambda a: int(a % 2 == 1), ast_int_eval
                ))

            elif current_command == "\u00fc":
                a = pop_stack(1)
                temp_stack = []
                temp_list = []
                for Q in stack:
                    temp_stack.append(Q)
                stack.clear()
                pointer_position += 1
                for_each_command = commands[pointer_position]
                if for_each_command == ".":
                    pointer_position += 1
                    for_each_command += commands[pointer_position]
                if type(a[0]) is not list:
                    zipper = zip(*[a, a[1:]])
                else:
                    zipper = a
                for Q in zipper:
                    stack.append(Q[0])
                    stack.append(Q[1])
                    run_program(for_each_command, debug, safe_mode, True,
                                range_variable, string_variable)
                for Q in stack:
                    temp_list.append(Q)
                stack.clear()
                for Q in temp_stack:
                    stack.append(Q)
                stack.append(temp_list)

            elif current_command == "\u00a1":
                b = pop_stack(1)
                a = pop_stack(1)

                if type(b) is list:
                    stack.append(multi_split(a, b))
                else:
                    stack.append(
                        vectorized_evaluation(a, b, lambda a, b: a.split(b), str)
                    )

            elif current_command == "\u03b3":
                a = pop_stack(1)
                if type(a) is int:
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
                    if i == len(a)-1 or a[i] != a[i+1]:
                        if is_list:
                            temp_list.append(inner_list)
                        else:
                            temp_list.append(inner_str)
                        inner_list = []
                        inner_str = ""
                    i += 1
                stack.append(temp_list)

            elif current_command == "\u00ef":
                a = pop_stack(1)
                stack.append(single_vectorized_evaluation(a, lambda a: int(a)))

            elif current_command == "\u00de":
                a = pop_stack(1)
                stack.append(single_vectorized_evaluation(
                    a, lambda a: floatify(a), str
                ))

            elif current_command == "\u00d1":
                a = pop_stack(1)
                stack.append(single_vectorized_evaluation(
                    a, lambda a: divisors_of_number(a)
                ))

            elif current_command == "\u00ce":
                stack.append(0)
                a = get_input()
                stack.append(a)
                recent_inputs.append(a)

            elif current_command == "\u00a7":
                a = pop_stack(1)
                stack.append(single_vectorized_evaluation(a, lambda a: str(a)))

            elif current_command == "\u00a6":
                a = pop_stack(1)
                if type(a) is int:
                    stack.append(str(a)[1:])
                else:
                    stack.append(a[1:])

            elif current_command == "\u0161":
                a = pop_stack(1)
                stack.append(single_vectorized_evaluation(
                    a, lambda a: a.swapcase(), str
                ))

            elif current_command == "\u00a3":
                b = pop_stack(1)
                a = pop_stack(1)

                try:
                    if type(a) is not list:
                        a = str(a)

                    if type(b) is list:
                        temp_list = []
                        temp_element = a
                        for Q in b:
                            temp_list.append(temp_element[0:int(Q)])
                            temp_element = temp_element[int(Q):]
                        stack.append(temp_list)
                    else:
                        b = int(b)
                        stack.append(a[0:b])
                except:
                    a, b = b, a
                    if type(a) is not list:
                        a = str(a)

                    if type(b) is list:
                        temp_list = []
                        temp_element = a
                        for Q in b:
                            temp_list.append(temp_element[0:int(Q)])
                            temp_element = temp_element[int(Q):]
                        stack.append(temp_list)
                    else:
                        b = int(b)
                        stack.append(a[0:b])

            elif current_command == "K":
                b = pop_stack(1)
                a = pop_stack(1)

                if type(a) is not list and type(b) is not list:
                    temp_list = str(a).replace(str(b), "")
                else:
                    temp_list = []
                    if type(b) is list:
                        b = [str(x) for x in b]
                    else:
                        b = [str(b)]

                    for Q in a:
                        if str(Q) not in b:
                            temp_list.append(str(Q))

                    if type(a) is not list:
                        temp_list = ''.join(temp_list)

                stack.append(temp_list)

            elif current_command == "\u00df":
                a = pop_stack(1)
                has_skipped = False
                result = []

                if type(a) is int:
                    a = str(a)

                for element in a:
                    if str(element) == str(min(a)) and not has_skipped:
                        has_skipped = True
                    else:
                        result.append(element)
                if type(a) is not list:
                    stack.append(''.join([str(x) for x in result]))
                else:
                    stack.append(result)
                stack.append(min(a))

            elif current_command == "\u00e0":
                a = pop_stack(1)
                has_skipped = False
                result = []

                if type(a) is int:
                    a = str(a)

                for element in a:
                    if str(element) == str(max(a)) and not has_skipped:
                        has_skipped = True
                    else:
                        result.append(element)
                if type(a) is not list:
                    stack.append(''.join([str(x) for x in result]))
                else:
                    stack.append(result)
                stack.append(max(a))

            elif current_command == "\u00a4":
                if stack:
                    a = stack[-1]
                else:
                    a = pop_stack(1)
                    stack.append(a)

                if type(a) is int:
                    stack.append(str(a)[-1])
                else:
                    stack.append(a[-1])

            elif current_command == "\u2039":
                b = pop_stack(1)
                a = pop_stack(1)
                stack.append(vectorized_evaluation(
                    a, b, lambda a, b: int(a < b), ast_int_eval
                ))

            elif current_command == "\u0292":
                a = pop_stack(1)
                if type(a) is int:
                    a = str(a)

                temp_stack = []
                temp_list = []
                for Q in stack:
                    temp_stack.append(Q)
                stack.clear()

                statement, temp_position = get_block_statement(commands, pointer_position)

                if debug:
                    try:
                        print("Filter: {}".format(statement))
                    except:
                        pass

                for Q in a:
                    stack.append(Q)
                    run_program(statement, debug, safe_mode, True,
                                range_variable, string_variable)
                    if not stack:
                        continue
                    if stack[-1] == 1 or stack[-1] == "1":
                        temp_list.append(Q)
                    stack.clear()

                stack.clear()
                for Q in temp_stack:
                    stack.append(Q)
                stack.append(temp_list)
                pointer_position = temp_position

            elif current_command == "\u03A3":
                a = pop_stack(1)
                if type(a) is int:
                    a = str(a)

                temp_stack = []
                temp_list = []
                for Q in stack:
                    temp_stack.append(Q)
                stack.clear()

                statement, temp_position = get_block_statement(commands, pointer_position)

                if debug:
                    try:
                        print("Sort with: {}".format(statement))
                    except:
                        pass

                for Q in a:
                    is_queue.append(Q)
                    stack.append(Q)
                    run_program(statement, debug, safe_mode, True,
                                range_variable, string_variable)
                    temp_list.append([stack[-1] if stack else float('inf'), Q])
                    stack.clear()
                    is_queue.pop()

                stack.clear()
                temp_list = sorted(temp_list, key=lambda element: element[0])
                if type(a) is list:
                    stack.append([x[1] for x in temp_list])
                else:
                    stack.append(''.join([x[1] for x in temp_list]))

                pointer_position = temp_position

            elif current_command == "\u203A":
                b = pop_stack(1)
                a = pop_stack(1)
                stack.append(vectorized_evaluation(
                    a, b, lambda a, b: int(a > b), ast_int_eval
                ))

            elif current_command == "\u00c0":
                a = pop_stack(1)
                if type(a) is list:
                    b = a[0]
                    a = a[1:]
                    a.append(b)
                    stack.append(a)
                else:
                    a = str(a)
                    a += a[0]
                    a = a[1:]
                    stack.append(a)

            elif current_command == "\u00c1":
                a = pop_stack(1)
                if type(a) is list:
                    b = []
                    b.append(a[-1])
                    for Q in a:
                        b.append(Q)
                    a = b[:-1]
                    stack.append(a)
                else:
                    a = str(a)
                    a = a[-1] + a
                    a = a[:-1]
                    stack.append(a)

            elif current_command == "\u00d8":
                a = pop_stack(1)
                stack.append(single_vectorized_evaluation(
                    a, lambda a: get_nth_prime(a), int
                ))

            elif current_command == ".\u00d8":
                a = pop_stack(1)
                stack.append(
                    single_vectorized_evaluation(
                        a, lambda a: get_index_of_prime(a), int
                    )
                )

            elif current_command == "\u00a2":
                b = pop_stack(1)
                a = pop_stack(1)
                stack.append(
                    vectorized_evaluation(
                        ''.join([str(x) for x in a]) if type(a) is list else a,
                        b,
                        lambda a, b: a.count(b), str
                    )
                )

            elif current_command == "\u00a8":
                a = pop_stack(1)
                if type(a) is int:
                    stack.append(str(a)[0:-1])
                else:
                    stack.append(a[0:-1])

            elif current_command == "\u00e6":
                a = pop_stack(1)
                b = None
                if type(a) is int or type(a) is str:
                    b = list(str(a))
                else:
                    b = [str(x) if type(x) is int else x for x in a]
                s = list(b)
                s = list(itertools.chain.from_iterable(
                    itertools.combinations(s, r) for r in range(len(s)+1)
                    ))
                list_of_lists = [list(elem) for elem in s]

                if type(a) is str or type(a) is int:
                    stack.append([''.join(x) for x in list_of_lists])
                else:
                    stack.append(list_of_lists)

            elif current_command == "\u0153":
                a = pop_stack(1)
                if type(a) is int or type(a) is str:
                    b = list(str(a))
                else:
                    b = a
                b = list(itertools.permutations(list(b)))
                list_of_lists = [list(elem) for elem in b]

                if type(a) is str or type(a) is int:
                    stack.append([''.join(x) for x in list_of_lists])
                else:
                    stack.append(list_of_lists)

            elif current_command == "\u0152":
                a = pop_stack(1)
                a = get_all_substrings(a)

                stack.append(a)

            elif current_command == "\u00d0":
                a = pop_stack(1)
                stack.append(a)
                stack.append(a)
                stack.append(a)

            elif current_command == "\u00c4":
                a = pop_stack(1)
                stack.append(single_vectorized_evaluation(
                    a, lambda a: abs(a), ast_int_eval
                ))

            elif current_command == "\u00dd":
                temp_list = []
                a = pop_stack(1)
                if type(a) is list:
                    for Q in a:
                        Q = int(Q)
                        if Q > 0:
                            for X in range(0, Q + 1):
                                temp_list.append(X)
                        elif Q < 0:
                            for X in range(0, (Q * -1) + 1):
                                temp_list.append(X * -1)
                        else:
                            temp_list.append(0)
                else:
                    a = int(a)
                    if a > 0:
                        for X in range(0, a + 1):
                            temp_list.append(X)
                    elif a < 0:
                        for X in range(0, (a * -1) + 1):
                            temp_list.append(X * -1)
                    else:
                        temp_list.append(0)

                stack.append(temp_list)

            elif current_command == "\u00fb":
                a = pop_stack(1)

                if type(a) is int:
                    a = str(a)

                stack.append(a + a[::-1][1:])

            elif current_command == "\u00b6":
                stack.append("\n")

            elif current_command == "\u00fd":
                b = pop_stack(1)

                a = []
                if stack and type(stack[-1]) is list:
                    c = pop_stack(1)
                    for Q in c:
                        a.append(str(Q))
                else:
                    for Q in stack:
                        a.append(Q)
                    stack.clear()

                stack.append(str(b).join(a))

            elif current_command == "\u0178":
                try:
                    if type(stack[-1]) is list:
                        current_list = pop_stack(1)
                        temp_list = []
                        is_inclusive = False
                        for N in range(0, len(current_list) - 1):
                            b = int(current_list[N])
                            a = int(current_list[N + 1])
                            temp_list_2 = []
                            if int(b) > int(a):
                                for Q in range(int(a), int(b) + 1):
                                    temp_list_2.append(Q)
                                temp_list_2 = temp_list_2[::-1]
                            else:
                                for Q in range(int(b), int(a) + 1):
                                    temp_list_2.append(Q)
                            for Q in temp_list_2:
                                if is_inclusive and len(temp_list_2) > 1:
                                    is_inclusive = False
                                    continue
                                temp_list.append(Q)
                            is_inclusive = True
                    else:
                        if len(stack) > 1:
                            a = pop_stack(1)
                            b = pop_stack(1)
                        else:
                            b = pop_stack(1)
                            a = pop_stack(1)
                        temp_list = []
                        if int(b) > int(a):
                            for Q in range(int(a), int(b) + 1):
                                temp_list.append(Q)
                            temp_list = temp_list[::-1]
                        else:
                            for Q in range(int(b), int(a) + 1):
                                temp_list.append(Q)
                except:
                    a = pop_stack(1)
                    if type(a) is list:
                        current_list = a
                        temp_list = []
                        is_inclusive = False
                        for N in range(0, len(current_list) - 1):
                            b = int(current_list[N])
                            a = int(current_list[N + 1])
                            temp_list_2 = []
                            if int(b) > int(a):
                                for Q in range(int(a), int(b) + 1):
                                    temp_list_2.append(Q)
                                temp_list_2 = temp_list_2[::-1]
                            else:
                                for Q in range(int(b), int(a) + 1):
                                    temp_list_2.append(Q)
                            for Q in temp_list_2:
                                if is_inclusive and len(temp_list_2) > 1:
                                    is_inclusive = False
                                    continue
                                temp_list.append(Q)
                            is_inclusive = True
                    else:
                        b, a = a, pop_stack(1)
                        temp_list = []
                        if int(b) > int(a):
                            for Q in range(int(a), int(b) + 1):
                                temp_list.append(Q)
                            temp_list = temp_list[::-1]
                        else:
                            for Q in range(int(b), int(a) + 1):
                                temp_list.append(Q)

                stack.append(temp_list)

            elif current_command == "\u0160":
                c = pop_stack(1)
                b = pop_stack(1)
                a = pop_stack(1)

                # a b c -> c a b

                stack.append(c)
                stack.append(a)
                stack.append(b)

            elif current_command == "\u00d6":
                b = pop_stack(1)
                a = pop_stack(1)
                stack.append(vectorized_evaluation(
                    a, b, lambda a, b: int(a % b == 0), ast_int_eval
                ))

            elif current_command == "\u00ac":
                if stack:
                    if type(stack[-1]) is int:
                        stack.append(str(stack[-1])[0])
                    else:
                        stack.append(stack[-1][0])
                else:
                    a = pop_stack(1)
                    stack.append(a)
                    stack.append(stack[-1][0])

            elif current_command == "\u017d":
                if not stack:
                    return True

            elif current_command == "\u00bb":
                b = "\n"

                a = []
                if stack and type(stack[-1]) is list:
                    c = pop_stack(1)
                    for Q in c:
                        if type(Q) is list:
                            a.append(' '.join([str(x) for x in Q]))
                        else:
                            a.append(str(Q))
                else:
                    for Q in stack:
                        if type(Q) is list:
                            a.append(' '.join([str(x) for x in Q]))
                        else:
                            a.append(Q)
                    stack.clear()

                stack.append(str(b).join(a))

            elif current_command == "\u00ab":
                if len(stack) > 1:
                    b = pop_stack(1)
                    a = pop_stack(1)
                else:
                    a = pop_stack(1)
                    b = pop_stack(1)

                if type(a) is list and type(b) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(Q)
                    for Q in b:
                        temp_list.append(Q)
                    stack.append(temp_list)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(str(Q) + str(b))
                    stack.append(temp_list)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(str(a) + str(Q))
                    stack.append(temp_list)
                else:
                    stack.append(str(a) + str(b))

            elif current_command == "\u00ec":
                if len(stack) > 1:
                    b = pop_stack(1)
                    a = pop_stack(1)
                else:
                    a = pop_stack(1)
                    b = pop_stack(1)

                if type(a) is list and type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(Q)
                    for Q in a:
                        temp_list.append(Q)
                    stack.append(temp_list)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(str(b) + str(Q))
                    stack.append(temp_list)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(str(Q) + str(a))
                    stack.append(temp_list)
                else:
                    stack.append(str(b) + str(a))

            elif current_command == "\u00d7":
                if len(stack) > 1:
                    b = pop_stack(1)
                    a = pop_stack(1)
                else:
                    a = pop_stack(1)
                    b = pop_stack(1)

                stack.append(string_multiplication(a, b))

            elif current_command == ".\u00d7":
                a = pop_stack(1)
                b = pop_stack(1)
                temp_list = []
                if type(a) is list and is_digit_value(b):
                    a, b = b, a
                if type(b) is list and is_digit_value(a):
                    for Q in range(ast_int_eval(a)):
                        for R in b:
                            temp_list.append(R)
                stack.append(temp_list)

            elif current_command == "\u00f2":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(int(Q) + 1)
                    stack.append(temp_list)
                else:
                    stack.append(int(a) + 1)

            elif current_command == "\u00f0":
                stack.append(" ")

            elif current_command == "\u01b6":
                a = pop_stack(1)
                if type(a) is int:
                    a = str(a)

                if type(a) is str:
                    result = []
                    for n in range(0, len(a)):
                        result.append(a[n] * (n + 1))
                    stack.append(result)

                elif type(a) is list:
                    result = []
                    for n in range(0, len(a)):
                        try:
                            result.append(vectorized_evaluation(
                                a[n], n + 1, lambda a, b: a * b, ast_int_eval
                            ))
                        except:
                            result.append(vectorized_evaluation(
                                a[n], n + 1, lambda a, b: a * b
                            ))
                    stack.append(result)

            elif current_command == ".M":
                a = pop_stack(1)
                if type(a) is not list:
                    a = list(str(a))

                temp_list = []
                for Q in set(a):
                    temp_list.append(a.count(Q))
                temp_list_2 = []
                for Q in range(0, len(temp_list)):
                    if temp_list[Q] == max(temp_list):
                        temp_list_2.append(list(set(a))[Q])
                stack.append(temp_list_2)

            elif current_command == ".m":
                a = pop_stack(1)
                if type(a) is not list:
                    a = list(str(a))

                temp_list = []
                for Q in set(a):
                    temp_list.append(a.count(Q))
                temp_list_2 = []
                for Q in range(0, len(temp_list)):
                    if temp_list[Q] == min(temp_list):
                        temp_list_2.append(list(set(a))[Q])
                stack.append(temp_list_2)

            elif current_command == "\u00cc":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(ast_int_eval(str(Q)) + 2)
                    stack.append(temp_list)
                else:
                    stack.append(ast_int_eval(str(a)) + 2)

            elif current_command == "\u00cd":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(ast_int_eval(str(Q)) - 2)
                    stack.append(temp_list)
                else:
                    stack.append(ast_int_eval(str(a)) - 2)

            elif current_command == "\u2020":
                if len(stack) > 0:
                    a = pop_stack(1)
                    b = pop_stack(1)
                else:
                    b = pop_stack(1)
                    a = pop_stack(1)

                if type(b) is not list:
                    b = str(b)

                temp_list = []
                temp_list_2 = []

                for Q in b:
                    if str(Q) == str(a):
                        temp_list.append(str(Q))
                    else:
                        temp_list_2.append(str(Q))
                for P in temp_list_2:
                    temp_list.append(P)

                if type(b) is list:
                    stack.append(temp_list)
                else:
                    stack.append(''.join([str(x) for x in temp_list]))

            elif current_command == "\u00bc":
                a = counter_variable[-1]
                a += 1
                counter_variable.pop()
                counter_variable.append(a)

            elif current_command == "\u00bd":
                a = counter_variable[-1]
                if str(ast_int_eval(str(pop_stack(1)))) == "1":
                    a += 1
                counter_variable.pop()
                counter_variable.append(a)

            elif current_command == ".x":
                b = pop_stack(1)
                a = pop_stack(1)
                stack.append(closest_to(a, b))

            elif current_command == ".\u00a5":
                a = pop_stack(1)
                stack.append(undelta(a))

            elif current_command == "\u00be":
                stack.append(counter_variable[-1])

            elif current_command == "\u00f3":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        c = float(Q)
                        if str(c)[-1] == "0" and str(c)[-2] == ".":
                            c -= 1
                            c = int(c)
                        else:
                            c = int(c)
                        temp_list.append(c)
                    stack.append(temp_list)
                else:
                    c = float(a)
                    if str(c)[-1] == "0" and str(c)[-2] == ".":
                        c -= 1
                        c = int(c)
                    else:
                        c = int(c)
                    stack.append(c)

            elif current_command == "?":
                a = pop_stack(1)
                print(a, end="")
                has_printed.append(True)

            elif current_command == ".o":
                b = pop_stack(1)
                a = pop_stack(1)
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

                stack.append(temp_string)

            elif current_command == ".O":
                b = str(pop_stack(1))
                a = str(pop_stack(1)) + b

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
                stack.append(temp_string)

            elif current_command == ".N":
                a = pop_stack(1)
                stack.append(single_vectorized_evaluation(
                    a, lambda a: get_hash(a)
                ))

            elif current_command == "\u2021":
                c = pop_stack(1)
                b = pop_stack(1)
                a = pop_stack(1)
                stack.append(transliterate(a, b, c))

            elif current_command == "\u00cf":
                b = pop_stack(1)
                a = pop_stack(1)

                try:
                    temp_list = []
                    for Q in range(0, len(a)):
                        if ast_int_eval(b[Q]) == 1:
                            temp_list.append(a[Q])
                except:
                    a, b = b, a
                    temp_list = []
                    for Q in range(0, len(a)):
                        if ast_int_eval(b[Q]) == 1:
                            temp_list.append(a[Q])

                stack.append(temp_list)

            elif current_command == "\u00f1":
                c = str(pop_stack(1))
                b = str(pop_stack(1))[::-1]
                a = str(pop_stack(1))[::-1]

                if len(b) > len(a):
                    a = str(a).ljust(len(b), c)

                if len(a) > len(b):
                    b = str(b).ljust(len(a), c)

                temp_string = ""

                for Q in range(0, len(a)):
                    if a[Q] == c and b[Q] != c:
                        temp_string += b[Q]
                    else:
                        temp_string += a[Q]

                stack.append(temp_string[::-1])

            elif current_command == ".\u00ef":
                a = pop_stack(1)
                b = ast_int_eval(str(a))
                try:
                    stack.append(int(int(a) == b))
                except:
                    stack.append(0)

            elif current_command == ".\u00bf":
                b = pop_stack(1)
                if type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(ast_int_eval(str(Q)))
                    stack.append(command_lcm(temp_list))
                else:
                    a = pop_stack(1)
                    stack.append(
                        lcm(ast_int_eval(str(a)), ast_int_eval(str(b)))
                    )

            elif current_command == ".\u00f8":
                if stack:
                    b = pop_stack(1)
                    a = pop_stack(1)
                else:
                    a = pop_stack(1)
                    b = pop_stack(1)
                if type(a) is int:
                    a = str(a)
                if type(a) is str:
                    stack.append(str(b) + a + str(b))
                elif type(a) is list:
                    stack.append([b] + a + [b])

            elif current_command == "\u2013":
                a = pop_stack(1)
                if a == "1" or a == 1:
                    print(range_variable)
                    has_printed.append(1)

            elif current_command == "\u2014":
                a = pop_stack(1)
                if a == "1" or a == 1:
                    print(string_variable)
                    has_printed.append(1)

            elif current_command == ".e":
                if safe_mode:
                    print("exec commands are ignored in safe mode")
                else:
                    temp_string = str(pop_stack(1))
                    temp_string = temp_string.replace("#", "stack")
                    temp_string = temp_string.replace(";", "\n")
                    exec(temp_string)

            elif current_command == ".E":
                if safe_mode:
                    print("exec commands are ignored in safe mode")
                else:
                    a = pop_stack(1)
                    f = tempfile.NamedTemporaryFile()
                    f.write(bytes(str(a), "cp1252"))
                    os.system(f.name)
                    f.close()

            elif current_command == ".V":
                a = pop_stack(1)
                run_program(str(a), debug, safe_mode, True, range_variable,
                            string_variable)

            elif current_command == ".R" or current_command == "\u03A9":
                a = pop_stack(1)
                if type(a) is int:
                    a = str(a)
                stack.append(random.choice(a))

            elif current_command == ".r":
                a = pop_stack(1)
                if type(a) is int:
                    a = str(a)
                if type(a) is list:
                    random.shuffle(a)
                    b = a
                else:
                    a = list(a)
                    random.shuffle(a)
                    b = ''.join(a)
                stack.append(b)

            elif current_command == "\u00b9":
                if len(recent_inputs) > 0:
                    stack.append(recent_inputs[0])
                else:
                    stack.append(get_input())

            elif current_command == "\u00b2":
                if len(recent_inputs) > 1:
                    stack.append(recent_inputs[1])
                else:
                    if len(recent_inputs) == 0:
                        get_input()
                    stack.append(get_input())
    
            elif current_command == "\u00b3":
                while len(recent_inputs) < 3:
                    get_input()

                stack.append(recent_inputs[2])

            elif current_command == "\u2022":
                temp_string = ""
                temp_string_2 = ""
                temp_position = pointer_position
                while temp_position < len(commands) - 1:
                    temp_position += 1
                    try:
                        current_command = commands[temp_position]
                    except:
                        break
                    if current_command == "\u2022":
                        break
                    else:
                        temp_string += current_command
                        pointer_position += 1
                pointer_position += 1
                stack.append(convert_from_base(temp_string, 255))

            elif current_command == ".\u2022":
                temp_string = ""
                temp_string_2 = ""
                temp_position = pointer_position
                while temp_position < len(commands) - 1:
                    temp_position += 1
                    try:
                        current_command = commands[temp_position]
                    except:
                        break
                    if current_command == "\u2022":
                        break
                    else:
                        temp_string += current_command
                        pointer_position += 1
                pointer_position += 1
                processed_value = convert_from_base(temp_string, 255)
                processed_value = convert_to_base_arbitrary(
                    processed_value, 27)
                stack.append(''.join(
                    [chr(x + 96) if x > 0 else " " for x in processed_value]
                ))

            elif current_command == "\u03B2":
                b = pop_stack(1)
                a = pop_stack(1)

                stack.append(convert_from_base_arbitrary(a, int(b)))

            elif current_command == ".L":
                b = pop_stack(1)
                a = pop_stack(1)
                stack.append(minimum_edit_distance(a, b))

            elif current_command == "\u00e2":
                b = pop_stack(1)
                a = pop_stack(1)

                if type(a) is not list:
                    a = str(a)
                if type(b) is not list:
                    b = str(b)

                c = list(itertools.product(a, b))
                if type(a) is list or type(b) is list:
                    stack.append([list(Q) for Q in c])
                else:
                    stack.append([''.join(str(y) for y in x) for x in c])

            elif current_command == "\u00e3":
                b = pop_stack(1)
                a = None
                if type(b) is list:
                    a, b = b[:], 2
                else:
                    a = pop_stack(1)

                if type(a) is not list:
                    a = str(a)

                c = list(itertools.product(a, repeat=int(b)))
                if type(a) is list:
                    stack.append([list(Q) for Q in c])
                else:
                    stack.append([''.join(str(y) for y in x) for x in c])

            elif current_command == "\u00e8":
                b = pop_stack(1)
                a = pop_stack(1)

                if type(a) is not list:
                    a = str(a)

                try:
                    temp_list = []
                    if type(b) is list:
                        for Q in b:
                            temp_list.append(a[int(Q) % len(a)])
                        stack.append(temp_list)
                    else:
                        b = int(b)
                        if type(a) is list:
                            stack.append(a[b % len(a)])
                        else:
                            stack.append(str(a)[b % len(a)])
                except:
                    a, b = b, a
                    temp_list = []
                    if type(b) is list:
                        for Q in b:
                            temp_list.append(a[int(Q) % len(a)])
                        stack.append(temp_list)
                    else:
                        b = int(b)
                        if type(a) is list:
                            stack.append(a[b % len(a)])
                        else:
                            stack.append(str(a)[b % len(a)])

            elif current_command == ".p" or current_command == "\u03B7":
                a = pop_stack(1)
                if type(a) is int:
                    a = str(a)
                temp_list = []
                for Q in range(1, len(a) + 1):
                    temp_list.append(a[0:Q])
                stack.append(temp_list)

            elif current_command == ".s":
                a = pop_stack(1)
                if type(a) is int:
                    a = str(a)
                temp_list = []
                for Q in range(1, len(a) + 1):
                    temp_list.append(a[-Q:])
                stack.append(temp_list)

            elif current_command == ".\u00C0":
                temp_stack = stack[:]
                stack.clear()
                for Q in temp_stack[1:]:
                    stack.append(Q)
                stack.append(temp_stack[0])

            elif current_command == ".\u00C1":
                temp_stack = stack[:]
                stack.clear()
                stack.append(temp_stack[-1])
                for Q in temp_stack[:-1]:
                    stack.append(Q)

            elif current_command == "\u0106":
                a = pop_stack(1)
                if type(a) is int:
                    a = str(a)

                if a == "":
                    stack.append("")
                else:
                    stack.append(a + [a[0]] if type(a) is list else a + a[0])

            elif current_command == "\u0107":
                a = pop_stack(1)
                if type(a) is int:
                    a = str(a)

                if a == "":
                    stack.append("")
                else:
                    stack.append(a[1:])
                    stack.append(a[0])

            elif current_command == "\u20AC":
                a = pop_stack(1)
                if type(a) is int:
                    a = str(a)
                temp_stack = []
                temp_list = []
                for Q in stack:
                    temp_stack.append(Q)
                stack.clear()
                pointer_position += 1
                for_each_command = commands[pointer_position]
                if for_each_command in ".\u00c5\u20AC":
                    pointer_position += 1
                    for_each_command += commands[pointer_position]
                for Q in a:
                    stack.append(Q)
                    run_program(for_each_command, debug, safe_mode, True,
                                range_variable, string_variable)
                for Q in stack:
                    temp_list.append(Q)
                stack.clear()
                for Q in temp_stack:
                    stack.append(Q)
                stack.append(temp_list)

            elif current_command == "\u03b1":
                b = pop_stack(1)
                a = pop_stack(1)
                stack.append(vectorized_evaluation(
                    a, b, lambda a, b: abs(a - b), ast_int_eval
                ))

            elif current_command == ".B":
                a = pop_stack(1)

                if type(a) is int:
                    a = str(a)
                if type(a) is str:
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

                stack.append(temp_list)

            elif current_command == ".\u00AB" or current_command == ".\u00BB":
                pointer_position += 1
                fold_command = commands[pointer_position]
                if type(stack[-1]) is list and len(stack[-1]) > 1:
                    a = pop_stack(1)
                    temp_stack = []
                    for Q in stack:
                        temp_stack.append(Q)
                    stack.clear()
                    for Q in a:
                        stack.append(Q)
                    for Q in a[:-1]:
                        if current_command == ".\u00AB":
                            x = pop_stack(1)
                            y = pop_stack(1)
                            stack.append(x)
                            stack.append(y)
                        run_program(fold_command, debug, safe_mode, True,
                                    range_variable, string_variable)
                    b = pop_stack(1)
                    stack.clear()
                    for Q in temp_stack:
                        stack.append(Q)
                    stack.append(b)

            elif current_command == ".h":
                a = pop_stack(1)
                b = pop_stack(1)
                b = ast_int_eval(b)
                a = ast_int_eval(a)
                number = ""
                while b:
                    b -= 1
                    r = b % a
                    b = b // a
                    r += 1
                    if r < 0:
                        b += 1
                        r -= a
                    number += str(r)
                stack.append(number[::-1])

            elif current_command == ".H":
                a = pop_stack(1)
                b = pop_stack(1)
                a = ast_int_eval(a)
                number = 0
                for Q in b:
                    number = number * a + ast_int_eval(Q)
                stack.append(number)

            elif current_command == ".D":
                a = pop_stack(1)
                b = pop_stack(1)
                L = []
                try:
                    L = range(ast_int_eval(a))
                except:
                    L = range(len(a))
                for Q in L:
                    stack.append(b)

            elif current_command == "\u00c2":
                a = pop_stack(1)
                if type(a) is int:
                    a = str(a)
                stack.append(a)
                stack.append(a[::-1])

            elif current_command == "\u00f5":
                stack.append("")

            elif current_command == "\u00d4":
                a = pop_stack(1)
                if type(a) is int:
                    a = str(a)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        if len(temp_list) == 0 or Q != temp_list[-1]:
                            temp_list.append(Q)
                    stack.append(temp_list)
                if type(a) is str:
                    temp_string = ""
                    for Q in a:
                        if len(temp_string) == 0 or Q != temp_string[-1]:
                            temp_string += Q
                    stack.append(temp_string)

            elif current_command == "\u201A":
                b = pop_stack(1)
                a = pop_stack(1)
                stack.append([a, b])

            elif current_command == ".\u20AC":
                a = pop_stack(1)
                for Q in a:
                    try:
                        print(Q, end="")
                    except:
                        print(str(Q).encode("cp1252"), end="")
                print()
                has_printed.append(1)

            elif current_command == "\u00d5":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(euler_totient(int(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(euler_totient(int(a)))

            elif current_command == ".\u00e4":
                a = pop_stack(1)
                print(str(a).encode("cp1252"))
                has_printed.append(1)

            elif current_command == ".c":
                a = pop_stack(1)
                if type(a) is int:
                    a = str(a)

                if type(a) is str:
                    a = str(a).split("\n")

                max_length = 0
                for Q in a:
                    if len(str(Q)) > max_length:
                        max_length = len(str(Q))

                temp_list = []

                for Q in a:
                    space_length = (max_length - len(str(Q))) // 2
                    if space_length > 0:
                        temp_list.append(space_length * " " + str(Q))
                    else:
                        temp_list.append(str(Q))

                stack.append('\n'.join(temp_list))

            elif current_command == ".C":
                a = pop_stack(1)
                if type(a) is int:
                    a = str(a)

                if type(a) is str:
                    a = str(a).split("\n")

                max_length = 0
                for Q in a:
                    if len(str(Q)) > max_length:
                        max_length = len(str(Q))

                temp_list = []

                for Q in a:
                    space_length = (max_length - len(str(Q)) + 1) // 2
                    if space_length > 0:
                        temp_list.append(space_length * " " + str(Q))
                    else:
                        temp_list.append(str(Q))

                stack.append('\n'.join(temp_list))

            elif current_command == "\u00c3":
                b = pop_stack(1)
                a = pop_stack(1)

                if type(a) is int:
                    a = str(a)
                if type(b) is int:
                    b = str(b)

                if type(a) is list and type(b) is list:
                    stack.append(
                        [x for x in a if str(x) in [str(y) for y in b]]
                    )
                elif type(a) is list:
                    stack.append([x for x in a if str(x) in str(b)])
                else:
                    stack.append(''.join([x for x in str(a) if x in str(b)]))

            elif current_command == "\u02c6":
                a = pop_stack(1)
                global_array.append(a)

            elif current_command == ".\u02c6":
                a = pop_stack(1)
                global_array.append(a)

            elif current_command == ".^":
                a = pop_stack(1)
                global_array.append(a)
                temp_list = []
                for Q in global_array:
                    temp_list.append(Q)
                temp_list = sorted(temp_list)

                global_array.clear()

                for x in temp_list:
                    global_array.append(x)

            elif current_command == "\u00af":
                stack.append(global_array)

            elif current_command == "\u00b4":
                global_array.clear()

            elif current_command == "\u2030":
                b = pop_stack(1)
                a = pop_stack(1)

                stack.append(vectorized_evaluation(
                    a, b, lambda a, b: list(divmod(a, b)), ast_int_eval
                ))

            elif current_command == "\u00b7":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(2 * ast_int_eval(str(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(2 * ast_int_eval(str(a)))

            elif current_command == ".n":
                if len(stack) > 0:
                    b = pop_stack(1)
                    a = pop_stack(1)
                else:
                    a = pop_stack(1)
                    b = pop_stack(1)

                stack.append(
                    math.log(ast_int_eval(str(a)), ast_int_eval(str(b)))
                )

            elif current_command == ".w":
                if safe_mode:
                    print("internet access is prohibited in safe mode")
                else:
                    try:
                        a = pop_stack(1)
                        a = str(a)
                        import urllib.request as req
                        f = req.urlopen("http://" + a)
                        stack.append(f.read())
                    except:
                        stack.append(0)

            elif current_command == ".W":
                a = ast_int_eval(pop_stack(1))
                time.sleep(a / 1000)

            elif current_command == "\u00e4":
                b = pop_stack(1)
                a = pop_stack(1)

                try:
                    stack.append(chunk_divide(a, int(b)))
                except:
                    stack.append(chunk_divide(b, int(a)))

            elif current_command == "\u01B5":
                pointer_position += 1
                current_command = commands[pointer_position]
                stack.append(convert_from_base(current_command, 255) + 101)

            elif current_command == "\u03B4":

                pointer_position += 1
                current_program = commands[pointer_position]

                while current_program[-1] in ".\u20AC":
                    pointer_position += 1
                    current_program += commands[pointer_position]

                b = pop_stack(1)
                a = pop_stack(1)

                if type(b) is int:
                    b = str(b)
                if type(a) is int:
                    a = str(a)

                temp_stack = stack[:]

                result = []
                for outer_element in a:
                    inner_result = []
                    for inner_element in b:
                        stack.clear()
                        stack.append(outer_element)
                        stack.append(inner_element)
                        run_program(current_program, debug, safe_mode, True,
                                    range_variable, string_variable)
                        inner_result.append(stack[-1])
                    result.append(inner_result)

                stack.clear()
                while temp_stack:
                    stack.append(temp_stack.pop())

                stack.append(result)

            elif current_command == ".g":
                stack.append(len(stack))

            elif current_command == ".\u01DD":
                a = pop_stack(1)
                print(a, file=stderr)

            elif current_command == ".0":
                zero_division.append(1)

            #
            # Extended commands
            #
            elif current_command in ExtendedMath.commands_list:
                arity = ExtendedMath.commands_list.get(current_command).arity
                arguments = [pop_stack(1) for _ in range(0, arity)]

                stack.append(ExtendedMath.invoke_command(current_command, *arguments))

            elif current_command == "\u00ee":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(math.ceil(ast_int_eval(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(math.ceil(ast_int_eval(a)))

            elif current_command == "\u01dd":
                c = pop_stack(1)
                b = pop_stack(1)
                a = pop_stack(1)

                if type(c) is list:
                    for Q in c:
                        a = insert(a, b, Q)
                    stack.append(a)
                else:
                    stack.append(insert(a, b, c))

            #
            # CONSTANTS
            #

            elif current_command in Constants.commands_list:
                arity = Constants.commands_list.get(current_command).arity
                arguments = [pop_stack(1) for _ in range(0, arity)]
                stack.append(Constants.invoke_command(current_command, *arguments))

            elif current_command == ".:":
                c = pop_stack(1)
                b = pop_stack(1)
                a = pop_stack(1)
                stack.append(single_replace(a, b, c))

            elif current_command == ".;":
                c = pop_stack(1)
                b = pop_stack(1)
                a = pop_stack(1)
                stack.append(first_replace(a, b, c))

            elif current_command == ".A":
                a = pop_stack(1)
                a = a.split(" ")
                temp_list = []
                for Q in a:
                    temp_list.append(str(Q)[0])
                stack.append(temp_list)

        except Exception as ex:
            if debug:
                print(str(ex))

    if TEST_MODE:
        END_RESULT = stack[-1]
        stack.clear()
        exit_program.clear()

        register_x.clear()
        register_x.append(1)
        register_y.clear()
        register_y.append(2)
        register_c.clear()
        counter_variable.clear()
        counter_variable.append(0)
        global_array.clear()

        return END_RESULT

    if not has_printed and not suppress_print:
        if stack:
            print(stack[len(stack) - 1])
        elif ".\u02c6" in code:
            if len(recent_inputs) == 0:
                get_input()
            print(global_array[int(recent_inputs[0])])
        elif ".^" in code:
            if len(recent_inputs) == 0:
                get_input()
            print(global_array[int(recent_inputs[0])])
        elif "\u00b5" in code:
            print(range_variable)
        elif "\u02c6" in code:
            print(global_array)
        elif "\u039b" in code:
            print(canvas.canvas_dict_to_string(current_canvas))
        elif "\u00bc" in code:
            print(counter_variable[-1])
    if debug:
        print("stack > " + str(stack))

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
    if code == "\\version":
        print(VERSION)
        print(DATE)
    else:
        if TIME_IT:
            import time
            start_time = time.time()
            run_program(code, DEBUG, SAFE_MODE, False, 0)
            end_time = time.time()
            print()
            print("Elapsed: " + str(end_time - start_time) + " seconds")
        else:
            run_program(code, DEBUG, SAFE_MODE, False, 0)
