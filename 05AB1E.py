import argparse
import time
import math
import dictionary
import ast
import itertools
import datetime
import os
import tempfile
import random

from constants import *
from commands import *

stack = []
exit_program = []
has_printed = []

recent_inputs = []

# Global registers
register_x = [1]
register_y = [2]
register_z = [3]
register_c = []

suspend_restore_register = []

# Global values
counter_variable = [0]
global_array = []

# Looping commands:
loop_commands = ["F", "i", "v", "G", "\u0192"]

# Global data

VERSION = "version 8.0"
DATE = "14:37 - May 9, 2016"

def opt_input():
    a = input()
    if a[:3] == "\"\"\"":
        a = a[3:]
        while a[-3:] != "\"\"\"":
            a += "\n" + input()

        a = a[:-3]

    return a


def is_array(array):
    array = str(array)
    if array[0] == "[" and array[-1] == "]":
        return True
    else:
        return False


def pop_stack(amount=1):
    if amount == 1:
        if stack:
            return stack.pop()
        else:
            a = opt_input()
            if is_array(a):
                a = ast_int_eval(a)
                recent_inputs.append(a)
                return a
            else:
                recent_inputs.append(a)
                return a

    elif amount == 2:
        if len(stack) > 1:
            a = stack.pop()
            b = stack.pop()
            return a, b

        elif len(stack) > 0:
            a = stack.pop()
            b = opt_input()
            if is_array(b):
                b = ast_int_eval(b)
            recent_inputs.append(b)
            return a, b

        else:
            a = opt_input()
            b = opt_input()
            if is_array(a):
                a = ast_int_eval(a)
            if is_array(b):
                b = ast_int_eval(b)

            recent_inputs.append(a)
            recent_inputs.append(b)
            return a, b

    elif amount == 3:
        if len(stack) > 2:
            a = stack.pop()
            b = stack.pop()
            c = stack.pop()
            return a, b, c

        elif len(stack) > 1:
            a = stack.pop()
            b = stack.pop()
            c = opt_input()
            if is_array(c):
                c = ast_int_eval(c)

            recent_inputs.append(c)
            return a, b, c

        elif len(stack) > 0:
            a = stack.pop()
            b = opt_input()
            c = opt_input()
            if is_array(b):
                b = ast_int_eval(b)
            if is_array(c):
                c = ast_int_eval(c)

            recent_inputs.append(b)
            recent_inputs.append(c)
            return a, b, c

        else:
            a = opt_input()
            b = opt_input()
            c = opt_input()
            if is_array(a):
                a = ast_int_eval(a)
            if is_array(b):
                b = ast_int_eval(b)
            if is_array(c):
                c = ast_int_eval(c)

            recent_inputs.append(a)
            recent_inputs.append(b)
            recent_inputs.append(c)
            return a, b, c


def get_input():
    a = input()
    if is_array(a):
        a = ast.literal_eval(a)

    recent_inputs.append(a)
    return a


def ast_int_eval(number):
    a = str(number)
    try:
        a = ast.literal_eval(a)
    except:
        a = int(a)

    return a


def run_program(commands,
                debug,
                safe_mode,
                suppress_print,
                range_variable=0,
                string_variable=""):

    if debug:
        try:print("Full program: " + str(commands))
        except:0
    pointer_position = -1
    temp_position = 0
    current_command = ""

    while pointer_position < len(commands) - 1:
        try:
            if exit_program:
                return True
            pointer_position += 1
            current_command = commands[pointer_position]

            if debug:
                try:print("current >> " + current_command + "  ||  stack: " + str(stack))
                except:0

            if current_command == ".":
                pointer_position += 1
                current_command += commands[pointer_position]

            if current_command == "\u017e":
                pointer_position += 1
                current_command += commands[pointer_position]

            if current_command == "\u00c5":
                pointer_position += 1
                current_command += commands[pointer_position]

            if current_command == "h":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(convert_to_base(abs(int(Q)), 16))
                    stack.append(temp_list)
                else:
                    stack.append(convert_to_base(abs(int(a)), 16))

            elif current_command == "b":
                a = pop_stack(1)

                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(convert_to_base(abs(int(Q)), 2))
                    stack.append(temp_list)
                else:
                    stack.append(convert_to_base(abs(int(a)), 2))

            elif current_command == "B":
                b, a = pop_stack(2)
                if type(a) is list and type(b) is list:
                    temp_list = []
                    for Q in len(a):
                        temp_list.append(convert_to_base(abs(ast_int_eval(str(a[Q]))), ast_int_eval(str(b[Q]))))
                    stack.append(temp_list)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(convert_to_base(abs(int(Q)), int(b)))
                    stack.append(temp_list)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(convert_to_base(abs(int(a)), int(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(convert_to_base(a, b))

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
                    elif current_command == "\u00ff":
                        temp_string += str(pop_stack(1))
                        pointer_position += 1
                    else:
                        temp_string += current_command
                        pointer_position += 1
                pointer_position += 1
                stack.append(temp_string)

            elif current_command == "\u2019":
                temp_string = ""
                temp_string_2 = ""
                temp_index = ""
                temp_position = pointer_position
                while temp_position < len(commands) - 1:
                    temp_position += 1
                    try:
                        current_command = commands[temp_position]
                        if dictionary.unicode_index.__contains__(current_command):
                            temp_index += str(dictionary.unicode_index.index(current_command)).rjust(2, "0")
                            temp_position += 1
                            pointer_position += 2
                            current_command = commands[temp_position]
                            temp_index += str(dictionary.unicode_index.index(current_command)).rjust(2, "0")
                            temp_string += dictionary.dictionary[int(temp_index)]
                            temp_index = ""
                        elif current_command == "\u2019":
                            pointer_position += 1
                            break
                        elif current_command == "\u00ff":
                            temp_string += str(pop_stack(1))
                            pointer_position += 1
                        else:
                            temp_string += current_command
                            pointer_position += 1
                    except:
                        pointer_position += 1
                        break
                    if debug:print(str(pointer_position) + " with " + str(hex(ord(current_command))))

                stack.append(temp_string)

            elif current_command == "\u2018":
                temp_string = ""
                temp_string_2 = ""
                temp_index = ""
                temp_position = pointer_position
                while temp_position < len(commands) - 1:
                    temp_position += 1
                    try:
                        current_command = commands[temp_position]
                        if dictionary.unicode_index.__contains__(current_command):
                            temp_index += str(dictionary.unicode_index.index(current_command)).rjust(2, "0")
                            temp_position += 1
                            pointer_position += 2
                            current_command = commands[temp_position]
                            temp_index += str(dictionary.unicode_index.index(current_command)).rjust(2, "0")
                            if temp_string == "":
                                temp_string += dictionary.dictionary[int(temp_index)].upper()
                            else:
                                temp_string += " " + dictionary.dictionary[int(temp_index)].upper()
                            temp_index = ""
                        elif current_command == "\u2018":
                            pointer_position += 1
                            break
                        elif current_command == "\u00ff":
                            temp_string += str(pop_stack(1))
                            pointer_position += 1
                        else:
                            temp_string += current_command
                            pointer_position += 1
                    except:
                        pointer_position += 1
                        break
                    if debug:print(str(pointer_position) + " with " + str(hex(ord(current_command))))

                stack.append(temp_string)

            elif current_command == "\u201c":
                temp_string = ""
                temp_string_2 = ""
                temp_index = ""
                temp_position = pointer_position
                while temp_position < len(commands) - 1:
                    temp_position += 1
                    try:
                        current_command = commands[temp_position]
                        if dictionary.unicode_index.__contains__(current_command):
                            temp_index += str(dictionary.unicode_index.index(current_command)).rjust(2, "0")
                            temp_position += 1
                            pointer_position += 2
                            current_command = commands[temp_position]
                            temp_index += str(dictionary.unicode_index.index(current_command)).rjust(2, "0")
                            if temp_string == "":
                                temp_string += dictionary.dictionary[int(temp_index)]
                            else:
                                temp_string += " " + dictionary.dictionary[int(temp_index)]
                            temp_index = ""
                        elif current_command == "\u201c":
                            pointer_position += 1
                            break
                        elif current_command == "\u00ff":
                            temp_string += str(pop_stack(1))
                            pointer_position += 1
                        else:
                            temp_string += current_command
                            pointer_position += 1
                    except:
                        pointer_position += 1
                        break
                    if debug:print(str(pointer_position) + " with " + str(hex(ord(current_command))))

                stack.append(temp_string)

            elif current_command == "\u201d":
                temp_string = ""
                temp_string_2 = ""
                temp_index = ""
                temp_position = pointer_position
                while temp_position < len(commands) - 1:
                    temp_position += 1
                    try:
                        current_command = commands[temp_position]
                        if dictionary.unicode_index.__contains__(current_command):
                            temp_index += str(dictionary.unicode_index.index(current_command)).rjust(2, "0")
                            temp_position += 1
                            pointer_position += 2
                            current_command = commands[temp_position]
                            temp_index += str(dictionary.unicode_index.index(current_command)).rjust(2, "0")
                            if temp_string == "":
                                temp_string += dictionary.dictionary[int(temp_index)].title()
                            else:
                                temp_string += " " + dictionary.dictionary[int(temp_index)].title()
                            temp_index = ""
                        elif current_command == "\u201d":
                            pointer_position += 1
                            break
                        elif current_command == "\u00ff":
                            temp_string += str(pop_stack(1))
                            pointer_position += 1
                        else:
                            temp_string += current_command
                            pointer_position += 1
                    except:
                        pointer_position += 1
                        break
                    if debug:print(str(pointer_position) + " with " + str(hex(ord(current_command))))

                stack.append(temp_string)

            elif current_command == "\u00aa":
                a = pop_stack(1)
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
                stack.append(temp_string)

            elif current_command == "\u00f9":
                if len(stack) > 1:
                    b = pop_stack(1)
                    a = pop_stack(1)
                else:
                    a = pop_stack(1)
                    b = pop_stack(1)

                temp_list = []
                for Q in a:
                    if len(Q if type(Q) is list else str(Q)) == ast_int_eval(b):
                        temp_list.append(Q)

                stack.append(temp_list)

            elif current_command == "!":
                a = pop_stack(1)

                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        if "." not in str(Q):
                            temp_list.append(math.factorial(int(Q)))
                        else:
                            temp_list.append(trim_float(math.gamma(float(Q) + 1)))
                    stack.append(temp_list)
                else:
                    if "." not in str(a):
                        stack.append(math.factorial(int(a)))
                    else:
                        stack.append(trim_float(math.gamma(float(a) + 1)))

            elif current_command == "+":
                if stack:
                    b = pop_stack(1)
                    a = pop_stack(1)
                else:
                    a = pop_stack(1)
                    b = pop_stack(1)

                if type(a) is list and type(b) is list:
                    temp_list = []
                    for Q in range(len(a)):
                        temp_list.append(ast_int_eval(str(a[Q])) + ast_int_eval(str(b[Q])))
                    stack.append(temp_list)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(ast_int_eval(str(Q)) + ast_int_eval(str(b)))
                    stack.append(temp_list)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(ast_int_eval(str(a)) + ast_int_eval(str(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(ast_int_eval(str(a)) + ast_int_eval(str(b)))

            elif current_command == "-":
                a, b = pop_stack(2)
                if type(a) is list and type(b) is list:
                    temp_list = []
                    for Q in range(len(a)):
                        temp_list.append(ast_int_eval(str(a[Q])) - ast_int_eval(str(b[Q])))
                    stack.append(temp_list)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(ast_int_eval(str(b)) - ast_int_eval(str(Q)))
                    stack.append(temp_list)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(ast_int_eval(str(Q)) - ast_int_eval(str(a)))
                    stack.append(temp_list)
                elif (type(b) is str and not is_float_value(b)) or (type(a) is str and not is_float_value(a)):
                    for Q in str(a):
                        b = b.replace(Q, "")
                    stack.append(str(b))
                else:
                    stack.append(ast_int_eval(str(b)) - ast_int_eval(str(a)))

            elif current_command == "*":
                a, b = pop_stack(2)
                if type(a) is list and type(b) is list:
                    temp_list = []
                    for Q in range(len(a)):
                        temp_list.append(ast_int_eval(str(a[Q])) * ast_int_eval(str(b[Q])))
                    stack.append(temp_list)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(ast_int_eval(str(Q)) * ast_int_eval(str(b)))
                    stack.append(temp_list)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(ast_int_eval(str(a)) * ast_int_eval(str(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(ast_int_eval(str(a)) * ast_int_eval(str(b)))

            elif current_command == "/":
                a, b = pop_stack(2)
                if type(a) is list and type(b) is list:
                    temp_list = []
                    for Q in range(len(a)):
                        temp_list.append(ast_int_eval(str(a[Q])) / ast_int_eval(str(b[Q])))
                    stack.append(temp_list)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(ast_int_eval(str(b)) / ast_int_eval(str(Q)))
                    stack.append(temp_list)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(ast_int_eval(str(Q)) / ast_int_eval(str(a)))
                    stack.append(temp_list)
                else:
                    stack.append(ast_int_eval(str(b)) / ast_int_eval(str(a)))

            elif current_command == "%":
                a, b = pop_stack(2)
                if type(a) is list and type(b) is list:
                    temp_list = []
                    for Q in range(len(a)):
                        temp_list.append(ast_int_eval(str(a[Q])) % ast_int_eval(str(b[Q])))
                    stack.append(temp_list)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(ast_int_eval(str(b)) % ast_int_eval(str(Q)))
                    stack.append(temp_list)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(ast_int_eval(str(Q)) % ast_int_eval(str(a)))
                    stack.append(temp_list)
                else:
                    stack.append(ast_int_eval(str(b)) % ast_int_eval(str(a)))

            elif current_command == "D":
                a = pop_stack(1)
                stack.append(a)
                stack.append(a)

            elif current_command == "R":
                a = pop_stack(1)
                if type(a) is list:
                    stack.append(a[::-1])
                else:
                    stack.append(str(a)[::-1])

            elif current_command == "I":
                a = opt_input()
                stack.append(a)
                recent_inputs.append(a)

            elif current_command == "$":
                a = get_input()
                stack.append(1)
                stack.append(a)

            elif current_command == "H":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(int(str(Q), 16))
                    stack.append(temp_list)
                else:
                    stack.append(int(str(a), 16))

            elif current_command == "C":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(int(str(Q), 2))
                    stack.append(temp_list)
                else:
                    stack.append(int(a, 2))

            elif current_command == "a":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(is_alpha_value(str(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(is_alpha_value(str(a)))

            elif current_command == "d":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(is_digit_value(str(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(is_digit_value(str(a)))

            elif current_command == "p":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(is_prime(int(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(is_prime(int(a)))

            elif current_command == "u":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(str(Q).upper())
                    stack.append(temp_list)
                else:
                    stack.append(str(a).upper())

            elif current_command == "l":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(str(Q).lower())
                    stack.append(temp_list)
                else:
                    stack.append(str(a).lower())

            elif current_command == "_":
                a = pop_stack(1)
                if type(a) is list:
                    if len(a) != 0:
                        temp_list = []
                        for Q in a:
                            temp_list.append(int(not ast_int_eval(str(Q))))
                        stack.append(temp_list)
                    else:
                        stack.append(1)
                else:
                    stack.append(int(not ast_int_eval(str(a))))

            elif current_command == "s":
                a = pop_stack(1)
                b = pop_stack(1)
                stack.append(a)
                stack.append(b)

            elif current_command == "|":
                a = input()
                temp_list = []
                try:
                    while True:
                        temp_list.append(a)
                        a = input()
                        if a == "":
                            break
                except:0
                stack.append(temp_list)

            elif current_command == "L":
                temp_list = []
                a = pop_stack(1)
                if type(a) is list:
                    for Q in a:
                        Q = int(Q)
                        if Q > 0:
                            for X in range(1, Q + 1):
                                temp_list.append(X)
                        elif Q < 0:
                            for X in range(1, (Q * -1) + 1):
                                temp_list.append(X * -1)
                        else:
                            temp_list.append(0)
                else:
                    a = int(a)
                    if a > 0:
                        for X in range(1, a + 1):
                            temp_list.append(X)
                    elif a < 0:
                        for X in range(1, (a * -1) + 1):
                            temp_list.append(X * -1)
                    else:
                        temp_list.append(0)

                stack.append(temp_list)

            elif current_command == "r":
                stack.reverse()

            elif current_command == "i":
                STATEMENT = ""
                ELSE_STATEMENT = ""
                elseify = False
                temp_position = pointer_position
                temp_position += 1
                current_command = commands[temp_position]
                amount_brackets = 1
                amount_else = 1
                temp_string_mode = False
                temp_char_mode = False

                while amount_brackets != 0:
                    if current_command == "\"":
                        temp_string_mode = not temp_string_mode

                    elif current_command == "'" and temp_char_mode == False:
                        temp_char_mode = True

                    if temp_string_mode == False or temp_char_mode == False:
                        if current_command == "}" or current_command == "\u00eb":
                            if current_command == "}":
                                amount_brackets -= 1
                            if current_command == "\u00eb":
                                amount_else -= 1
                                elseify = True
                            if amount_brackets == 0:
                                break
                        elif current_command in loop_commands:
                            amount_brackets += 1
                            if current_command == "i":
                                amount_else += 1

                    temp_char_mode = True

                    if not elseify:
                        STATEMENT += current_command
                    else:
                        ELSE_STATEMENT += current_command

                    try:
                        temp_position += 1
                        current_command = commands[temp_position]
                    except:
                        break

                if debug:
                    print("if: ", end="")
                    for Q in STATEMENT:
                        try:
                            print(Q, end="")
                        except:
                            print("?", end="")
                    print()
                    if amount_else < 1:
                        print("else: ", end="")
                        for Q in ELSE_STATEMENT:
                            try:
                                print(Q, end="")
                            except:
                                print("?", end="")
                        print()
                a = pop_stack(1)
                if a == 1 or a == "1":
                    run_program(STATEMENT, debug, safe_mode, True, range_variable, string_variable)
                elif amount_else == 0:
                    run_program(ELSE_STATEMENT[1:], debug, safe_mode, True, range_variable, string_variable)
                pointer_position = temp_position

            elif current_command == "\\":
                pop_stack(1)

            elif current_command == "`":
                a = pop_stack(1)
                for x in a:
                    stack.append(x)

            elif current_command == "x":
                a = pop_stack(1)
                stack.append(a)

                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(ast_int_eval(str(Q)) * 2)
                    stack.append(temp_list)
                else:
                    stack.append(ast_int_eval(str(a)) * 2)

            elif current_command == "F":
                STATEMENT = ""
                temp_position = pointer_position
                temp_position += 1
                current_command = commands[temp_position]
                amount_brackets = 1
                temp_string_mode = False
                while amount_brackets != 0:
                    if current_command == "\"":
                        temp_string_mode = not temp_string_mode
                    if temp_string_mode == False:
                        if current_command == "}":
                            amount_brackets -= 1
                            if amount_brackets == 0:
                                break
                        elif current_command in loop_commands:
                            amount_brackets += 1
                        STATEMENT += current_command
                    else:
                        STATEMENT += current_command
                    try:
                        temp_position += 1
                        current_command = commands[temp_position]
                    except:
                        break
                if debug:
                    try:print(STATEMENT)
                    except:0
                a = 0
                if stack:
                    a = int(pop_stack(1))
                else:
                    a = int(input())
                    recent_inputs.append(a)

                if a != 0:
                    for range_variable in range(0, a):
                        run_program(STATEMENT, debug, safe_mode, True, range_variable, string_variable)
                pointer_position = temp_position

            elif current_command == "G":
                STATEMENT = ""
                temp_position = pointer_position
                temp_position += 1
                current_command = commands[temp_position]
                amount_brackets = 1
                temp_string_mode = False
                while amount_brackets != 0:
                    if current_command == "\"":
                        temp_string_mode = not temp_string_mode
                    if temp_string_mode == False:
                        if current_command == "}":
                            amount_brackets -= 1
                            if amount_brackets == 0:
                                break
                        elif current_command in loop_commands:
                            amount_brackets += 1
                        STATEMENT += current_command
                        try:
                            temp_position += 1
                            current_command = commands[temp_position]
                        except:
                            break
                if debug:
                    try:print(STATEMENT)
                    except:0
                a = 0
                if stack:
                    a = int(pop_stack(1))
                else:
                    a = int(input())
                    recent_inputs.append(a)

                if a > 1:
                    for range_variable in range(1, a):
                        run_program(STATEMENT, debug, safe_mode, True, range_variable, string_variable)
                pointer_position = temp_position

            elif current_command == "\u00b5":
                STATEMENT = ""
                ELSE_STATEMENT = ""
                temp_position = pointer_position
                temp_position += 1
                current_command = commands[temp_position]
                amount_brackets = 1
                amount_else = 1
                temp_string_mode = False
                while amount_brackets != 0:
                    if current_command == "\"":
                        temp_string_mode = not temp_string_mode
                    if temp_string_mode == False:
                        if current_command == "}" or current_command == "\u00eb":
                            if current_command == "}":
                                amount_brackets -= 1
                            if current_command == "\u00eb":
                                amount_else -= 1
                            if amount_brackets == 0:
                                break
                        elif current_command in loop_commands:
                            amount_brackets += 1
                            if current_command == "i":
                                amount_else += 1
                    if amount_else > 0:
                        STATEMENT += current_command
                    else:
                        ELSE_STATEMENT += current_command
                    try:
                        temp_position += 1
                        current_command = commands[temp_position]
                    except:
                        break
                if debug:
                    print("if: ", end="")
                    for Q in STATEMENT:
                        try:
                            print(Q, end="")
                        except:
                            print("?", end="")
                    print()
                    if amount_else < 1:
                        print("else: ", end="")
                        for Q in ELSE_STATEMENT:
                            try:
                                print(Q, end="")
                            except:
                                print("?", end="")
                        print()
                a = pop_stack(1)
                range_variable = 0
                while counter_variable[-1] != int(a):
                    range_variable += 1
                    run_program(STATEMENT, debug, safe_mode, True, range_variable, string_variable)
                pointer_position = temp_position

            elif current_command == "\u00cb":
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
                a = pop_stack(1)
                range_variable = 0
                while pop_stack(1) is not True:
                    range_variable += 1
                    run_program(STATEMENT, debug, safe_mode, True, range_variable, string_variable)
                pointer_position = temp_position

            elif current_command == "\u0192":
                STATEMENT = ""
                temp_position = pointer_position
                temp_position += 1
                current_command = commands[temp_position]
                amount_brackets = 1
                temp_string_mode = False
                while amount_brackets != 0:
                    if current_command == "\"":
                        temp_string_mode = not temp_string_mode
                    if temp_string_mode == False:
                        if current_command == "}":
                            amount_brackets -= 1
                            if amount_brackets == 0:
                                break
                        elif current_command in loop_commands:
                            amount_brackets += 1
                        STATEMENT += current_command
                        try:
                            temp_position += 1
                            current_command = commands[temp_position]
                        except:
                            break
                if debug:
                    try:print(STATEMENT)
                    except:0
                a = 0
                if stack:
                    a = int(pop_stack(1))
                else:
                    a = int(input())
                    recent_inputs.append(a)

                if a > -1:
                    for range_variable in range(0, a + 1):
                        run_program(STATEMENT, debug, safe_mode, True, range_variable, string_variable)
                pointer_position = temp_position

            elif current_command == "N":
                stack.append(range_variable)

            elif current_command == "T":
                stack.append(10)

            elif current_command == "S":
                a = pop_stack(1)
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

            elif current_command == "^":
                a, b = pop_stack(2)
                if type(a) is list and type(b) is list:
                    temp_list = []
                    for Q in range(len(a)):
                        temp_list.append(int(a[Q]) ^ int(b[Q]))
                    stack.append(temp_list)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(int(b) ^ int(Q))
                    stack.append(temp_list)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(int(Q) ^ int(a))
                    stack.append(temp_list)
                else:
                    stack.append(int(b) ^ int(a))

            elif current_command == "~":
                a, b = pop_stack(2)
                if type(a) is list and type(b) is list:
                    temp_list = []
                    for Q in range(len(a)):
                        temp_list.append(int(a[Q]) | int(b[Q]))
                    stack.append(temp_list)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(int(b) | int(Q))
                    for S in temp_list:
                        stack.append(S)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(int(Q) | int(a))
                    for S in temp_list:
                        stack.append(S)
                else:
                    stack.append(int(b) | int(a))

            elif current_command == "&":
                a, b = pop_stack(2)
                if type(a) is list and type(b) is list:
                    temp_list = []
                    for Q in range(len(a)):
                        temp_list.append(int(a[Q]) & int(b[Q]))
                    stack.append(temp_list)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(int(b) & int(Q))
                    for S in temp_list:
                        stack.append(S)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(int(Q) & int(a))
                    for S in temp_list:
                        stack.append(S)
                else:
                    stack.append(int(b) & int(a))

            elif current_command == "c":
                a, b = pop_stack(2)
                if type(a) is list and type(b) is list:
                    temp_list = []
                    for Q in range(len(a)):
                        temp_list.append(combinations(int(a[Q]), int(b[Q])))
                    stack.append(temp_list)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(combinations(int(Q), int(b)))
                    stack.append(temp_list)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(combinations(int(a), int(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(combinations(int(b), int(a)))

            elif current_command == "e":
                a, b = pop_stack(2)
                if type(a) is list and type(b) is list:
                    temp_list = []
                    for Q in range(len(a)):
                        temp_list.append(permutations(int(a[Q]), int(b[Q])))
                    stack.append(temp_list)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(permutations(int(Q), int(b)))
                    stack.append(temp_list)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(permutations(int(a), int(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(combinations(int(b), int(a)))

            elif current_command == ">":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(ast_int_eval(str(Q)) + 1)

                    stack.append(temp_list)
                else:
                    stack.append(ast_int_eval(str(a)) + 1)

            elif current_command == "<":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(ast_int_eval(str(Q)) - 1)

                    stack.append(temp_list)
                else:
                    stack.append(ast_int_eval(str(a)) - 1)

            elif current_command == "'":
                temp_string = ""
                temp_index = ""
                pointer_position += 1
                temp_position = pointer_position
                current_command = commands[pointer_position]
                if dictionary.unicode_index.__contains__(current_command):
                    temp_index += str(dictionary.unicode_index.index(current_command)).rjust(2, "0")
                    temp_position += 1
                    pointer_position += 1
                    current_command = commands[temp_position]
                    temp_index += str(dictionary.unicode_index.index(current_command)).rjust(2, "0")
                    if temp_string == "":
                        temp_string += dictionary.dictionary[int(temp_index)]
                    else:
                        temp_string += " " + dictionary.dictionary[int(temp_index)]
                    temp_index = ""
                    stack.append(temp_string)
                else:
                    temp_string = commands[pointer_position]
                    stack.append(temp_string)

            elif current_command == "\u201e":
                temp_string = ""
                temp_index = ""

                word_count = 0

                while word_count != 2:
                    pointer_position += 1
                    temp_position = pointer_position
                    current_command = commands[pointer_position]
                    if dictionary.unicode_index.__contains__(current_command):
                        temp_index += str(dictionary.unicode_index.index(current_command)).rjust(2, "0")
                        temp_position += 1
                        pointer_position += 1
                        current_command = commands[temp_position]
                        temp_index += str(dictionary.unicode_index.index(current_command)).rjust(2, "0")
                        if temp_string == "":
                            temp_string += dictionary.dictionary[int(temp_index)]
                        else:
                            temp_string += " " + dictionary.dictionary[int(temp_index)]
                        temp_index = ""
                        word_count += 1
                    elif current_command == "\u00ff":
                        temp_string += str(pop_stack(1))
                        word_count += 1
                    else:
                        temp_string += commands[pointer_position]
                        word_count += 1

                stack.append(temp_string)

            elif current_command == "\u2026":
                temp_string = ""
                temp_index = ""

                word_count = 0

                while word_count != 3:
                    pointer_position += 1
                    temp_position = pointer_position
                    current_command = commands[pointer_position]
                    if dictionary.unicode_index.__contains__(current_command):
                        temp_index += str(dictionary.unicode_index.index(current_command)).rjust(2, "0")
                        temp_position += 1
                        pointer_position += 1
                        current_command = commands[temp_position]
                        temp_index += str(dictionary.unicode_index.index(current_command)).rjust(2, "0")
                        if temp_string == "":
                            temp_string += dictionary.dictionary[int(temp_index)]
                        else:
                            temp_string += " " + dictionary.dictionary[int(temp_index)]
                        temp_index = ""
                        word_count += 1
                    elif current_command == "\u00ff":
                        temp_string += str(pop_stack(1))
                        word_count += 1
                    else:
                        temp_string += commands[pointer_position]
                        word_count += 1

                stack.append(temp_string)

            elif current_command == "\u00f6":
                b = pop_stack(1)
                a = pop_stack(1)

                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(convert_from_base(str(Q), int(b)))
                    stack.append(temp_list)
                else:
                    stack.append(convert_from_base(str(a), int(b)))

            elif current_command == "\u00b8":
                a = pop_stack(1)
                stack.append([a])

            elif current_command == ".S":
                b = pop_stack(1)
                a = pop_stack(1)
                if type(a) is list:
                    if type(b) is list:
                        temp_list = []
                        for Q in range(0, len(a)):
                            if ast_int_eval(str(a[Q])) > ast_int_eval(str(b[Q])):
                                temp_list.append(1)
                            if ast_int_eval(str(a[Q])) < ast_int_eval(str(b[Q])):
                                temp_list.append(-1)
                            if ast_int_eval(str(a[Q])) == ast_int_eval(str(b[Q])):
                                temp_list.append(0)
                        stack.append(temp_list)
                    else:
                        temp_list = []
                        for Q in a:
                            if ast_int_eval(str(Q)) > ast_int_eval(str(b)):
                                temp_list.append(1)
                            if ast_int_eval(str(Q)) < ast_int_eval(str(b)):
                                temp_list.append(-1)
                            if ast_int_eval(str(Q)) == ast_int_eval(str(b)):
                                temp_list.append(0)
                        stack.append(temp_list)
                else:
                    if type(b) is list:
                        temp_list = []
                        for Q in b:
                            if ast_int_eval(str(a)) > ast_int_eval(str(Q)):
                                temp_list.append(1)
                            if ast_int_eval(str(a)) < ast_int_eval(str(Q)):
                                temp_list.append(-1)
                            if ast_int_eval(str(a)) == ast_int_eval(str(Q)):
                                temp_list.append(0)
                        stack.append(temp_list)
                    else:
                        if ast_int_eval(str(a)) > ast_int_eval(str(b)):
                            stack.append(1)
                        if ast_int_eval(str(a)) < ast_int_eval(str(b)):
                            stack.append(-1)
                        if ast_int_eval(str(a)) == ast_int_eval(str(b)):
                            stack.append(0)

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
                    if run_program(STATEMENT, debug, safe_mode, True, range_variable, string_variable):
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
                    except: 0

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
                a, b = pop_stack(2)
                if type(a) is list and type(b) is list:
                    a = ast_int_eval(str(a))
                    b = ast_int_eval(str(b))
                    stack.append(int(str(a) == str(b)))
                elif type(a) is list:
                    temp_list = []
                    b = ast_int_eval("\"" + str(b) + "\"")
                    for Q in a:
                        if is_digit_value(str(Q)): Q = ast_int_eval(str(Q))
                        temp_list.append(int(str(Q) == str(b)))
                    stack.append(temp_list)
                elif type(b) is list:
                    temp_list = []
                    a = ast_int_eval("\"" + str(a) + "\"")
                    for Q in b:
                        if is_digit_value(str(Q)): Q = ast_int_eval(str(Q))
                        temp_list.append(int(str(Q) == str(a)))
                    stack.append(temp_list)
                else:
                    a = ast_int_eval("\"" + str(a) + "\"")
                    b = ast_int_eval("\"" + str(b) + "\"")
                    stack.append(int(str(a) == str(b)))

            elif current_command == "\u00ca":
                a, b = pop_stack(2)
                if type(a) is list and type(b) is list:
                    a = ast_int_eval(str(a))
                    b = ast_int_eval(str(b))
                    stack.append(int(str(a) != str(b)))
                elif type(a) is list:
                    temp_list = []
                    b = ast_int_eval("\"" + str(b) + "\"")
                    for Q in a:
                        if is_digit_value(str(Q)): Q = ast_int_eval(str(Q))
                        temp_list.append(int(str(Q) != str(b)))
                    stack.append(temp_list)
                elif type(b) is list:
                    temp_list = []
                    a = ast_int_eval("\"" + str(a) + "\"")
                    for Q in b:
                        if is_digit_value(str(Q)): Q = ast_int_eval(str(Q))
                        temp_list.append(int(str(Q) != str(a)))
                    stack.append(temp_list)
                else:
                    a = ast_int_eval("\"" + str(a) + "\"")
                    b = ast_int_eval("\"" + str(b) + "\"")
                    stack.append(int(str(a) != str(b)))

            elif current_command == "(":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(ast_int_eval(str(Q)) * -1)
                    stack.append(temp_list)
                else:
                    stack.append(ast_int_eval(str(a)) * -1)

            elif current_command == "A":
                stack.append('abcdefghijklmnopqrstuvwxyz')

            elif current_command == "\u2122":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(str(Q).title())
                    stack.append(temp_list)
                else:
                    stack.append(str(a).title())

            elif current_command == "E":
                a = get_input()
                stack.append(a)

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
                    stack.append(get_input())

                if type(stack[-1]) is list:
                    a = pop_stack(1)
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
                    stack.append(get_input())

                if type(stack[-1]) is list:
                    a = pop_stack(1)
                    if type(a[-1]) is list:
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
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(ast_int_eval(str(Q)) / 2)
                    stack.append(temp_list)
                else:
                    stack.append(ast_int_eval(str(a)) / 2)

            elif current_command == "w":
                time.sleep(1)

            elif current_command == "m":
                if stack:
                    a, b = pop_stack(2)
                else:
                    b, a = pop_stack(2)
                if type(a) is list and type(b) is list:
                    temp_list = []
                    for Q in range(len(a)):
                        temp_list.append(ast_int_eval(str(a[Q])) ** ast_int_eval(str(b[Q])))
                    stack.append(temp_list)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(ast_int_eval(str(b)) ** ast_int_eval(str(Q)))
                    stack.append(temp_list)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(ast_int_eval(str(Q)) ** ast_int_eval(str(a)))
                    stack.append(temp_list)
                else:
                    stack.append(ast_int_eval(str(b)) ** ast_int_eval(str(a)))

            elif current_command == "X":
                stack.append(register_x[-1])

            elif current_command == "Y":
                stack.append(register_y[-1])

            elif current_command == "z":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(1 / float(ast_int_eval(str(Q))))
                    stack.append(temp_list)
                else:
                    stack.append(1 / float(ast_int_eval(str(a))))

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
                    stack.append(get_input())
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
                c, b, a = pop_stack(3)
                if type(a) is list:
                    if type(b) is list:
                        for Q in a:
                            temp_string = temp_string_2 = str(Q)
                            while True:
                                for R in b:
                                    temp_string = temp_string.replace(R, c)
                                if temp_string == temp_string_2:
                                    break
                                else:
                                    temp_string_2 = temp_string
                            stack.append(temp_string)
                    else:
                        b = str(b)
                        for Q in a:
                            temp_string = temp_string_2 = str(Q)
                            while True:
                                temp_string = temp_string.replace(b, c)
                                if temp_string == temp_string_2:
                                    break
                                else:
                                    temp_string_2 = temp_string
                            stack.append(temp_string)
                else:
                    if type(b) is list:
                        temp_string = temp_string_2 = str(a)
                        while True:
                            for R in b:
                                temp_string = temp_string.replace(R, c)
                            if temp_string == temp_string_2:
                                break
                            else:
                                temp_string_2 = temp_string
                        stack.append(temp_string)
                    else:
                        b = str(b)
                        temp_string = temp_string_2 = str(a)
                        while True:
                            temp_string = temp_string.replace(b, c)
                            if temp_string == temp_string_2:
                                break
                            else:
                                temp_string_2 = temp_string
                        stack.append(temp_string)

            elif current_command == "j":
                a = pop_stack(1)
                for Q in stack:
                    temp_string = ""
                    if type(Q) is list:
                        for R in Q:
                            temp_string += str(R).rjust(int(a))
                        print(temp_string)
                    else:
                        print(str(Q).rjust(int(a)), end="")
                has_printed.append(True)

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
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(get_letter(int(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(get_letter(int(a)))

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
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(float(Q))
                    stack.append(temp_list)
                else:
                    stack.append(math.sqrt(float(a)))

            elif current_command == "n":
                a = pop_stack(1)
                temp_list = []
                if type(a) is list:
                    for Q in a:
                        temp_list.append(ast_int_eval(str(Q)) ** 2)
                    stack.append(temp_list)
                else:
                    stack.append(ast_int_eval(str(a)) ** 2)

            elif current_command == "o":
                a = pop_stack(1)
                temp_list = []
                if type(a) is list:
                    for Q in a:
                        temp_list.append(2 ** ast_int_eval(str(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(2 ** ast_int_eval(str(a)))

            elif current_command == "k":
                if stack:
                    b, a = pop_stack(2)
                else:
                    a, b = pop_stack(2)

                try:
                    if type(a) is list:
                        temp_list = []
                        for Q in a:
                            temp_list.append(str(Q))
                        stack.append(temp_list.index(str(b)))
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
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(int(10 ** ast_int_eval(str(Q))))
                    stack.append(temp_list)
                else:
                    stack.append(int(10 ** ast_int_eval(str(a))))

            elif current_command == "\u00ba":
                if len(stack) > 0:
                    stack.append(False)
                else:
                    stack.append(True)

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
                        temp_list.append(int(str(Q) in a))
                    stack.append(temp_list)

                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(int(a in str(Q)))
                    stack.append(temp_list)

                else:
                    stack.append(int(b in a))

            elif current_command == "v":
                STATEMENT = ""
                temp_position = pointer_position
                temp_position += 1
                current_command = commands[temp_position]
                amount_brackets = 1
                temp_string_mode = False
                while amount_brackets != 0:
                    if current_command == "\"":
                        temp_string_mode = not temp_string_mode
                    if temp_string_mode == False:
                        if current_command == "}":
                            amount_brackets -= 1
                            if amount_brackets == 0:
                                break
                        elif current_command in loop_commands:
                            amount_brackets += 1
                        STATEMENT += current_command
                        try:
                            temp_position += 1
                            current_command = commands[temp_position]
                        except:
                            break
                if debug:
                    try:print(STATEMENT)
                    except:0
                a = 0
                a = pop_stack(1)

                range_variable = -1
                if type(a) is int: a = str(a)
                for string_variable in a:
                    range_variable += 1
                    if debug:print("N = " + str(range_variable))
                    run_program(STATEMENT, debug, safe_mode, True, range_variable, string_variable)
                pointer_position = temp_position

            elif current_command == "y":
                stack.append(string_variable)

            elif current_command == ",":
                a = pop_stack(1)
                print(str(a))
                has_printed.append(True)

            elif current_command == "f":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(prime_factorization(int(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(prime_factorization(int(a)))

            elif current_command == "\u00d2":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(prime_factorization_duplicates(int(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(prime_factorization_duplicates(int(a)))

            elif current_command == "\u00d3":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(prime_factorization_powers(int(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(prime_factorization_powers(int(a)))

            elif current_command == "\u00fe":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list_2 = []
                    for Q in a:
                        temp_list = []
                        for R in Q:
                            if is_digit_value(Q):
                                temp_list.append(str(Q))
                            temp_list_2.append(temp_list)
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
                        temp_list = []
                        for R in Q:
                            if is_alpha_value(Q):
                                temp_list.append(str(Q))
                            temp_list_2.append(temp_list)
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

                    if len(temp_list) == 1:
                        stack.append(temp_list[0])
                    else:
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
                if stack:
                    b = pop_stack(1)
                    a = pop_stack(1)
                    b = int(b)
                    if type(a) is int:
                        a = str(a)
                else:
                    a = get_input()
                    b = get_input()

                if type(a) is not list:
                    temp_string = ""
                    R = 0
                    temp_list = []
                    for Q in a:
                        temp_string += Q
                        R += 1
                        if R == b:
                            temp_list.append(temp_string)
                            temp_string = ""
                            R = 0
                    if temp_string != "":
                        temp_list.append(temp_string)
                    stack.append(temp_list)
                else:
                    temp_list = []
                    R = 0
                    temp_list_2 = []
                    for Q in a:
                        temp_list.append(Q)
                        R += 1
                        if R == b:
                            temp_list_2.append(temp_list)
                            temp_list = []
                            R = 0
                    if temp_list != []:
                        temp_list_2.append(temp_list)
                    stack.append(temp_list_2)

            elif current_command == "\u00ed":
                a = pop_stack(1)
                temp_list = []

                for Q in a:
                    if type(Q) is int:
                        Q = str(Q)
                    temp_list.append(Q[::-1])
                stack.append(temp_list)

            elif current_command == "\u00f7":
                a, b = pop_stack(2)
                if type(a) is list and type(b) is list:
                    temp_list = []
                    for Q in range(len(a)):
                        temp_list.append(ast_int_eval(str(a[Q])) // ast_int_eval(str(b[Q])))
                    stack.append(temp_list)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(ast_int_eval(str(b)) // ast_int_eval(str(Q)))
                    stack.append(temp_list)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(ast_int_eval(str(Q)) // ast_int_eval(str(a)))
                    stack.append(temp_list)
                else:
                    stack.append(ast_int_eval(str(b)) // ast_int_eval(str(a)))

            elif current_command == "\u00b1":
                a = pop_stack(1)

                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(~ast_int_eval(str(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(~ast_int_eval(str(a)))

            elif current_command == "\u00c6":
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
                a = pop_stack(1)
                if type(a) is list:
                    zipped = [list(x) for x in zip(*a)]
                    if type(a[0]) is not list:
                        zipped = [''.join(x) for x in zipped]
                    stack.append(zipped)
                else:
                    b = pop_stack(1)
                    c = [b, a]
                    zipped = [list(x) for x in zip(*c)]
                    zipped = [''.join(x) for x in zipped]
                    stack.append(zipped)

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
                b, a = pop_stack(2)
                if type(a) is not list:
                    a = str(a)
                    b = str(b)
                    length_of_str = len(b)
                else:
                    b = str(b)
                    length_of_str = 1
                while True:
                    if type(a[0:length_of_str]) is list:
                        x = str(a[0:length_of_str])[1:-1]
                    else:
                        x = str(a[0:length_of_str])
                    if x == b:
                        a = a[length_of_str:]
                    else:
                        break
                stack.append(a)

            elif current_command == "\u00a5":
                a = pop_stack(1)
                temp_list = []
                length_of_list = len(a)
                for Q in range(0, length_of_list - 1):
                    temp_list.append(ast_int_eval(str(a[Q + 1])) - ast_int_eval(str(a[Q])))
                stack.append(temp_list)

            elif current_command == "\u00a9":
                a = stack[-1]
                register_c.append(a)

            elif current_command == "\u00ae":
                if len(register_c) > 0:
                    stack.append(register_c[-1])
                else:
                    stack.append(-1)

            elif current_command == "\u00dc":
                b, a = pop_stack(2)
                if type(a) is not list:
                    a = str(a)
                    b = str(b)
                    length_of_str = len(b)
                else:
                    b = str(b)
                    length_of_str = 1

                while True:
                    if type(a[len(a) - length_of_str:len(a)]) is list:
                        x = str(a[len(a) - length_of_str:len(a)])[1:-1]
                    else:
                        x = str(a[len(a) - length_of_str:len(a)])
                    if x == str(b):
                        a = a[0:len(a) - length_of_str]
                    else:
                        break
                stack.append(a)

            elif current_command == "\u00c8":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(int(ast_int_eval(str(Q)) % 2 == 0))
                    stack.append(temp_list)
                else:
                    stack.append(int(ast_int_eval(str(a)) % 2 == 0))

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
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(int(ast_int_eval(str(Q)) % 2 == 1))
                    stack.append(temp_list)
                else:
                    stack.append(int(ast_int_eval(str(a)) % 2 == 1))

            elif current_command == "\u00fc":
                a = pop_stack(1)
                temp_stack = []
                temp_list = []
                for Q in stack:
                    temp_stack.append(Q)
                stack.clear()
                pointer_position += 1
                for_each_command = commands[pointer_position]
                if type(a[0]) is not list:
                    zipper = zip(*[a, a[1:]])
                else:
                    zipper = a
                for Q in zipper:
                    stack.append(Q[0])
                    stack.append(Q[1])
                    run_program(for_each_command, DEBUG, SAFE_MODE, True, range_variable, string_variable)
                for Q in stack:
                    temp_list.append(Q)
                stack.clear()
                for Q in temp_stack:
                    stack.append(Q)
                stack.append(temp_list)

            elif current_command == "\u00a1":
                b, a = pop_stack(2)
                if type(a) is int:
                    a = str(a)
                if type(b) is int:
                    b = str(b)
                temp_list = a.split(b)
                stack.append(temp_list)

            elif current_command == "\u00ef":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(int(Q))
                    stack.append(temp_list)
                else:
                    stack.append(int(a))

            elif current_command == "\u00de":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for R in a:
                        temp_list.append(floatify(str(R)))
                    stack.append(temp_list)
                else:
                    stack.append(floatify(str(a)))

            elif current_command == "\u00d1":
                a = pop_stack(1)

                temp_list = []
                for N in range(1, int(a) + 1):
                    if int(a) % N == 0:
                        temp_list.append(N)

                stack.append(temp_list)

            elif current_command == "\u00ce":
                stack.append(0)
                a = get_input()
                stack.append(a)
                recent_inputs.append(a)

            elif current_command == "\u00a7":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(str(Q))
                    stack.append(temp_list)
                else:
                    stack.append(str(a))

            elif current_command == "\u00a6":
                a = pop_stack(1)
                if type(a) is int:
                    stack.append(str(a)[1:])
                else:
                    stack.append(a[1:])

            elif current_command == "\u0161":
                a = pop_stack(1)

                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(str(Q).swapcase())
                    stack.append(temp_list)
                else:
                    stack.append(a.swapcase())

            elif current_command == "\u00a3":
                b, a = pop_stack(2)
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
                b, a = pop_stack(2)
                temp_list = []
                if type(a) is list:
                    for Q in a:
                        if str(Q) != str(b):
                            temp_list.append(Q)
                    stack.append(temp_list)
                else:
                    a = str(a)
                    while str(a).replace(str(b), "") != str(a):
                        a = str(a).replace(str(b), "")
                    stack.append(a)

            elif current_command == "\u00df":
                a = stack[-1]
                b = pop_stack(1)
                a = sorted(a)[::-1].pop()
                temp_list = []
                has_done = False
                for Q in b:
                    if Q == a and has_done == False:
                        has_done = True
                        continue
                    else:
                        temp_list.append(Q)
                stack.append(temp_list)
                stack.append(a)

            elif current_command == "\u00e0":
                a = stack[-1]
                b = pop_stack(1)
                a = sorted(a).pop()
                temp_list = []
                has_done = False
                for Q in b:
                    if Q == a and has_done == False:
                        has_done = True
                        continue
                    else:
                        temp_list.append(Q)
                stack.append(temp_list)
                stack.append(a)

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
                b, a = pop_stack(2)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        if int(Q) < int(b):
                            temp_list.append(1)
                        else:
                            temp_list.append(0)
                    stack.append(temp_list)
                else:
                    if int(a) < int(b):
                        stack.append(1)
                    else:
                        stack.append(0)

            elif current_command == "\u203A":
                b, a = pop_stack(2)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        if int(Q) > int(b):
                            temp_list.append(1)
                        else:
                            temp_list.append(0)
                    stack.append(temp_list)
                else:
                    if int(a) > int(b):
                        stack.append(1)
                    else:
                        stack.append(0)

            elif current_command == "\u00c0":
                a = pop_stack(1)
                if type(a) is list:
                    a += [a[0]]
                    a = a[1:]
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

                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(get_nth_prime(int(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(get_nth_prime(int(a)))

            elif current_command == "\u00a2":
                a, b = pop_stack(2)
                if type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(str(Q).count(str(a)))
                    stack.append(temp_list)
                else:
                    stack.append(str(b).count(str(a)))

            elif current_command == "\u00a8":
                a = pop_stack(1)
                if type(a) is int:
                    stack.append(str(a)[0:-1])
                else:
                    stack.append(a[0:-1])

            elif current_command == "\u00e6":
                a = pop_stack(1)
                if type(a) is int or type(a) is str:
                    a = list(str(a))
                s = list(a)
                s = list(itertools.chain.from_iterable(itertools.combinations(s, r) for r in range(len(s)+1)))
                list_of_lists = [list(elem) for elem in s]
                stack.append(list_of_lists)

            elif current_command == "\u0153":
                a = pop_stack(1)
                if type(a) is int or type(a) is str:
                    a = list(str(a))
                a = list(itertools.permutations(list(a)))
                list_of_lists = [list(elem) for elem in a]
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
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(abs(ast_int_eval(str(Q))))
                    stack.append(temp_list)
                else:
                    stack.append(abs(ast_int_eval(str(a))))

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
                            a, b = pop_stack(2)
                        else:
                            b, a = pop_stack(2)
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
                c, b, a = pop_stack(3)

                # a b c -> c a b

                stack.append(c)
                stack.append(a)
                stack.append(b)

            elif current_command == "\u00d6":
                a, b = pop_stack(2)
                if type(a) is list and type(b) is list:
                    temp_list = []
                    temp_list_2 = []
                    for Q in a:
                        temp_list_2 = []
                        for R in b:
                            temp_list_2.append(ast_int_eval(str(R)) % ast_int_eval(str(Q)) == 0)
                        temp_list.append(temp_list_2)
                    stack.append(temp_list)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(ast_int_eval(str(b)) % ast_int_eval(str(Q)) == 0)
                    stack.append(temp_list)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(ast_int_eval(str(Q)) % ast_int_eval(str(a)) == 0)
                    stack.append(temp_list)
                else:
                    stack.append(ast_int_eval(str(b)) % ast_int_eval(str(a)) == 0)

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
                    b, a = pop_stack(2)
                else:
                    a, b = pop_stack(2)

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
                    b, a = pop_stack(2)
                else:
                    a, b = pop_stack(2)

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
                    b, a = pop_stack(2)
                else:
                    a, b = pop_stack(2)

                if is_digit_value(b):
                    b = int(b)
                elif is_digit_value(a):
                    a, b = b, a
                    b = int(b)

                temp_string = ""
                if b != 0:
                    for Q in range(0, b):
                        temp_string += str(a)
                stack.append(temp_string)

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
                    a, b = pop_stack(2)
                else:
                    b, a = pop_stack(2)

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
                stack.append(temp_list)

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

            elif current_command == "\u2021":
                c = pop_stack(1)
                b = pop_stack(1)
                a = pop_stack(1)

                a = str(a)
                temp_string = ""
                has_transliterated = False

                for S in a:
                    for Q in range(0, len(b)):
                        if S != S.replace(b[Q], c[Q]):
                            temp_string += S.replace(b[Q], c[Q])
                            has_transliterated = True
                            break

                    if not has_transliterated:
                        temp_string += S
                    has_transliterated = False

                stack.append(temp_string)

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
                    stack.append(lcm(ast_int_eval(str(a)), ast_int_eval(str(b))))

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
                run_program(str(a), debug, safe_mode, True)

            elif current_command == ".R":
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
                    a = input()
                    if is_array(a):
                        recent_inputs.append(ast_int_eval(a))
                    else:
                        recent_inputs.append(a)
                    stack.append(recent_inputs[0])

            elif current_command == "\u00b2":
                if len(recent_inputs) > 1:
                    stack.append(recent_inputs[1])
                elif len(recent_inputs) == 1:
                    a = input()
                    if is_array(a):
                        recent_inputs.append(ast_int_eval(a))
                    else:
                        recent_inputs.append(a)
                    stack.append(recent_inputs[1])
                else:
                    a = input()
                    if is_array(a):
                        recent_inputs.append(ast_int_eval(a))
                    else:
                        recent_inputs.append(a)

                    b = input()
                    if is_array(b):
                        recent_inputs.append(ast_int_eval(b))
                    else:
                        recent_inputs.append(b)
                    stack.append(recent_inputs[1])

            elif current_command == "\u00b3":
                if len(recent_inputs) > 2:
                    stack.append(recent_inputs[2])
                elif len(recent_inputs) == 2:
                    a = input()
                    if is_array(a):
                        recent_inputs.append(ast_int_eval(a))
                    else:
                        recent_inputs.append(a)
                    stack.append(recent_inputs[2])
                elif len(recent_inputs) == 1:
                    a = input()
                    if is_array(a):
                        recent_inputs.append(ast_int_eval(a))
                    else:
                        recent_inputs.append(a)

                    b = input()
                    if is_array(b):
                        recent_inputs.append(ast_int_eval(b))
                    else:
                        recent_inputs.append(b)
                    stack.append(recent_inputs[2])
                elif len(recent_inputs) == 0:
                    a = input()
                    if is_array(a):
                        recent_inputs.append(ast_int_eval(a))
                    else:
                        recent_inputs.append(a)

                    b = input()
                    if is_array(b):
                        recent_inputs.append(ast_int_eval(b))
                    else:
                        recent_inputs.append(b)

                    c = input()
                    if is_array(c):
                        recent_inputs.append(ast_int_eval(c))
                    else:
                        recent_inputs.append(c)

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
                stack.append(convert_from_base(temp_string, 214))

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
                d = [list(Q) for Q in c]
                if type(a) is not list and type(b) is not list:
                    temp_list = []
                    for Q in d:
                        temp_string = ""
                        for R in Q:
                            temp_string += str(R)
                        temp_list.append(temp_string)
                    stack.append(temp_list)
                else:
                    stack.append(d)

            elif current_command == "\u00e3":
                b = pop_stack(1)
                a = pop_stack(1)

                if type(a) is not list:
                    a = str(a)

                c = list(itertools.product(a, repeat=int(b)))
                d = [list(Q) for Q in c]
                if type(a) is not list:
                    temp_list = []
                    for Q in d:
                        temp_string = ""
                        for R in Q:
                            temp_string += str(R)
                        temp_list.append(temp_string)
                    stack.append(temp_list)
                else:
                    stack.append(d)

            elif current_command == "\u00e8":
                b = pop_stack(1)
                a = pop_stack(1)

                if type(a) is not list:
                    a = str(a)

                try:
                    temp_string = ""
                    if type(b) is list:
                        for Q in b:
                            temp_string += (a[int(Q) % len(a)])
                        stack.append(temp_string)
                    else:
                        b = int(b)
                        if type(a) is list:
                            stack.append(a[b % len(a)])
                        else:
                            stack.append(str(a)[b % len(a)])
                except:
                    a, b = b, a
                    temp_string = ""
                    if type(b) is list:
                        for Q in b:
                            temp_string += (a[int(Q) % len(a)])
                        stack.append(temp_string)
                    else:
                        b = int(b)
                        if type(a) is list:
                            stack.append(a[b % len(a)])
                        else:
                            stack.append(str(a)[b % len(a)])

            elif current_command == ".p":
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

            elif current_command == "\u20AC":
                a = pop_stack(1)
                temp_stack = []
                temp_list = []
                for Q in stack:
                    temp_stack.append(Q)
                stack.clear()
                pointer_position += 1
                for_each_command = commands[pointer_position]
                for Q in a:
                    stack.append(Q)
                    run_program(for_each_command, DEBUG, SAFE_MODE, True, range_variable, string_variable)
                for Q in stack:
                    temp_list.append(Q)
                stack.clear()
                for Q in temp_stack:
                    stack.append(Q)
                stack.append(temp_list)

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
                temp_string = ""
                temp_string_2 = ""
                if type(a) is int:
                    a = str(a)

                for Q in a:
                    if Q != temp_string_2:
                        temp_string_2 = Q
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

            elif current_command == "\u00c3":
                b = pop_stack(1)
                a = pop_stack(1)

                if type(a) is int:
                    a = str(a)
                if type(b) is int:
                    b = str(b)

                if type(a) is list:
                    temp_list = []
                    temp_list_2 = []
                    for Q in a:
                        temp_list_2.append(str(Q))
                    for Q in b:
                        if str(Q) in temp_list_2:
                            temp_list.append(Q)
                    stack.append(temp_list)
                else:
                    temp_string = ""
                    for Q in a:
                        if str(Q) in str(b):
                            temp_string += str(Q)
                    stack.append(temp_string)

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
                for Q in global_array: temp_list.append(Q)
                temp_list = sorted(temp_list)

            elif current_command == "\u00af":
                stack.append(global_array)

            elif current_command == "\u00b4":
                global_array.clear()

            elif current_command == "\u2030":
                b = pop_stack(1)
                a = pop_stack(1)
                temp_list = []

                temp_list.append(int(a) // int(b))
                temp_list.append(int(a) % int(b))

                stack.append(temp_list)

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

                stack.append(math.log(ast_int_eval(str(a)), ast_int_eval(str(b))))

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

            elif current_command == "\u00e4":
                b = pop_stack(1)
                a = pop_stack(1)

                stack.append(chunk_divide(a, int(b)))

            #
            # LIST COMMANDS
            #

            elif current_command == "\u00c5!":
                a = int(pop_stack(1))
                temp_list = []
                Q = 0
                while math.factorial(Q) <= a:
                    temp_list.append(math.factorial(Q))
                    Q += 1
                stack.append(temp_list)

            elif current_command == "\u00c50":
                a = int(pop_stack(1))
                temp_list = []
                Q = 0
                while Q < a:
                    temp_list.append(0)
                    Q += 1
                stack.append(temp_list)

            elif current_command == "\u00c51":
                a = int(pop_stack(1))
                temp_list = []
                Q = 0
                while Q < a:
                    temp_list.append(1)
                    Q += 1
                stack.append(temp_list)

            elif current_command == "\u00c52":
                a = int(pop_stack(1))
                temp_list = []
                Q = 0
                while Q < a:
                    temp_list.append(2)
                    Q += 1
                stack.append(temp_list)

            elif current_command == "\u00c53":
                a = int(pop_stack(1))
                temp_list = []
                Q = 0
                while Q < a:
                    temp_list.append(3)
                    Q += 1
                stack.append(temp_list)

            elif current_command == "\u00c54":
                a = int(pop_stack(1))
                temp_list = []
                Q = 0
                while Q < a:
                    temp_list.append(4)
                    Q += 1
                stack.append(temp_list)

            elif current_command == "\u00c55":
                a = int(pop_stack(1))
                temp_list = []
                Q = 0
                while Q < a:
                    temp_list.append(5)
                    Q += 1
                stack.append(temp_list)

            elif current_command == "\u00c56":
                a = int(pop_stack(1))
                temp_list = []
                Q = 0
                while Q < a:
                    temp_list.append(6)
                    Q += 1
                stack.append(temp_list)

            elif current_command == "\u00c57":
                a = int(pop_stack(1))
                temp_list = []
                Q = 0
                while Q < a:
                    temp_list.append(7)
                    Q += 1
                stack.append(temp_list)

            elif current_command == "\u00c58":
                a = int(pop_stack(1))
                temp_list = []
                Q = 0
                while Q < a:
                    temp_list.append(8)
                    Q += 1
                stack.append(temp_list)

            elif current_command == "\u00c59":
                a = int(pop_stack(1))
                temp_list = []
                Q = 0
                while Q < a:
                    temp_list.append(9)
                    Q += 1
                stack.append(temp_list)

            elif current_command == "\u00c5\u00c8":
                a = int(pop_stack(1))
                temp_list = []
                Q = 0
                while Q * 2 <= a:
                    temp_list.append(Q * 2)
                    Q += 1
                stack.append(temp_list)

            elif current_command == "\u00c5\u00c9":
                a = int(pop_stack(1))
                temp_list = []
                Q = 0
                while Q * 2 + 1 <= a:
                    temp_list.append(Q * 2 + 1)
                    Q += 1
                stack.append(temp_list)

            elif current_command == "\u00c5F":
                a = int(pop_stack(1))
                temp_list = []
                F_1 = 0
                F_2 = 1
                F_3 = 1
                while F_3 <= a:
                    temp_list.append(F_3)
                    F_3 = F_1 + F_2
                    F_1 = F_2
                    F_2 = F_3

                stack.append(temp_list)

            elif current_command == ".\u00b2":
                a = pop_stack(1)
                stack.append(math.log(int(a), 2))

            elif current_command == "\u00ee":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(math.ceil(ast_int_eval(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(math.ceil(ast_int_eval(a)))

            #
            # CONSTANTS
            #

            elif current_command == "\u017ea":
                stack.append(int(datetime.datetime.now().hour))

            elif current_command == "\u017eb":
                stack.append(int(datetime.datetime.now().minute))

            elif current_command == "\u017ec":
                stack.append(int(datetime.datetime.now().second))

            elif current_command == "\u017ed":
                stack.append(int(datetime.datetime.now().microsecond))

            elif current_command == "\u017ee":
                stack.append(int(datetime.datetime.now().day))

            elif current_command == "\u017ef":
                stack.append(int(datetime.datetime.now().month))

            elif current_command == "\u017eg":
                stack.append(int(datetime.datetime.now().year))

            elif current_command == "\u017eh":
                stack.append("0123456789")

            elif current_command == "\u017ei":
                stack.append("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")

            elif current_command == "\u017ej":
                stack.append("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_")

            elif current_command == "\u017ek":
                stack.append("zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA")

            elif current_command == "\u017el":
                stack.append("zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA9876543210_")

            elif current_command == "\u017em":
                stack.append("9876543210")

            elif current_command == "\u017en":
                stack.append("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")

            elif current_command == "\u017eo":
                stack.append("ZYXWVUTSRQPONMLKJIHGFEDCBAzyxwvutsrqponmlkjihgfedcba")

            elif current_command == "\u017ep":
                stack.append("ZYXWVUTSRQPONMLKJIHGFEDCBA")

            elif current_command == "\u017eq":
                stack.append(math.pi)

            elif current_command == "\u017er":
                stack.append(math.e)

            elif current_command == "\u017es":
                a = pop_stack(1)
                a = int(a)
                stack.append(constant_pi[0:a + 2])

            elif current_command == "\u017et":
                a = pop_stack(1)
                a = int(a)
                stack.append(constant_e[0:a + 2])

            elif current_command == "\u017eu":
                stack.append("()<>[]{}")

            elif current_command == "\u017ev":
                stack.append(16)

            elif current_command == "\u017ew":
                stack.append(32)

            elif current_command == "\u017ex":
                stack.append(64)

            elif current_command == "\u017ey":
                stack.append(128)

            elif current_command == "\u017ez":
                stack.append(256)

            elif current_command == "\u017eA":
                stack.append(512)

            elif current_command == "\u017eB":
                stack.append(1024)

            elif current_command == "\u017eC":
                stack.append(2048)

            elif current_command == "\u017eD":
                stack.append(4096)

            elif current_command == "\u017eE":
                stack.append(8192)

            elif current_command == "\u017eF":
                stack.append(16384)

            elif current_command == "\u017eG":
                stack.append(32768)

            elif current_command == "\u017eH":
                stack.append(65536)

            elif current_command == "\u017eI":
                stack.append(2147483648)

            elif current_command == "\u017eJ":
                stack.append(4294967296)

            elif current_command == "\u017eK":
                stack.append("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")

            elif current_command == "\u017eL":
                stack.append("zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA9876543210")

            elif current_command == "\u017eM":
                stack.append("aeiou")

            elif current_command == "\u017eN":
                stack.append("bcdfghjklmnpqrstvwxyz")

            elif current_command == "\u017eO":
                stack.append("aeiouy")

            elif current_command == "\u017eP":
                stack.append("bcdfghjklmnpqrstvwxz")

            elif current_command == "\u017eQ":
                stack.append(" !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~")

            elif current_command == ".:":
                c, b, a = pop_stack(3)
                if type(a) is list:
                    if type(b) is list:
                        temp_list = []
                        for Q in a:
                            temp_string = str(Q)
                            for R in b:
                                temp_string = temp_string.replace(R, c)
                            temp_list.append(temp_string)
                        stack.append(temp_list)
                    else:
                        b = str(b)
                        for Q in a:
                            temp_string = str(Q)
                            temp_string = temp_string.replace(b, c)
                            temp_list.append(temp_string)
                        stack.append(temp_list)
                else:
                    if type(b) is list:
                        temp_string = str(a)
                        for R in b:
                            temp_string = temp_string.replace(R, c)
                        stack.append(temp_string)
                    else:
                        b = str(b)
                        temp_string = str(a)
                        temp_string = temp_string.replace(b, c)
                        stack.append(temp_string)

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

    if not has_printed and not suppress_print:
        if stack: print(stack[len(stack) - 1])
        elif ".\u02c6" in code: print(global_array[recent_inputs[0]])
        elif "\u00b5" in code: print(range_variable)
        elif "\u02c6" in code: print(global_array)
        elif "\u00bc" in code: print(counter_variable[-1])
    if debug:
        print("stack > " + str(stack))

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--debug', help="Debug mode", action="store_true")
    parser.add_argument('-s', '--safe', help="Safe mode", action="store_true")
    parser.add_argument('-c', '--cp1252', help="Encode from CP-1252", action="store_true")
    parser.add_argument('-t', '--time', help="Time the program", action="store_true")
    parser.add_argument("program_path", help="Program path", type=str)

    args = parser.parse_args()
    filename = args.program_path
    DEBUG = args.debug
    SAFE_MODE = args.safe
    ENCODE_CP1252 = args.cp1252
    TIME_IT = args.time

    if ENCODE_CP1252:
        code = open(filename, "r", encoding="cp1252").read()
    else:
        code = open(filename, "r", encoding="utf-8").read()

    if code == "":
        code = "$FDR+{"
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
