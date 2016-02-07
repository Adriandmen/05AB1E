import argparse
import time
import math
import binascii
import dictionary
from commands import *

stack = []
exit_program = []
has_printed = []

recent_inputs = []


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
            a = input()
            if is_array(a):
                recent_inputs.append(a)
                return eval(a)
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
            b = input()
            if is_array(b):
                b = eval(b)
            recent_inputs.append(b)
            return a, b

        else:
            a = input()
            b = input()
            if is_array(a):
                a = eval(a)
            if is_array(b):
                b = eval(b)

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
            c = input()
            if is_array(c):
                c = eval(c)

            recent_inputs.append(c)
            return a, b, c

        elif len(stack) > 0:
            a = stack.pop()
            b = input()
            c = input()
            if is_array(b):
                b = eval(b)
            if is_array(c):
                c = eval(c)

            recent_inputs.append(b)
            recent_inputs.append(c)
            return a, b, c

        else:
            a = input()
            b = input()
            c = input()
            if is_array(a):
                a = eval(a)
            if is_array(b):
                b = eval(b)
            if is_array(c):
                c = eval(c)

            recent_inputs.append(a)
            recent_inputs.append(b)
            recent_inputs.append(c)
            return a, b, c


def run_program(commands,
                debug,
                suppress_print,
                range_variable=0,
                x_integer=1,
                y_integer=2,
                z_integer=0,
                string_variable=""):

    # Replace short expressions
    commands = commands.replace(".j", "Mg>.j")
    commands = commands.replace(".J", "Mg>.J")

    if debug:
        try:print("Full program: " + str(commands))
        except:0
    pointer_position = -1
    temp_position = 0
    current_command = ""

    while pointer_position < len(commands) - 1:
        try:
            if exit_program:
                break
            pointer_position += 1
            current_command = commands[pointer_position]

            if debug:
                try:print("current >> " + current_command + "  ||  stack: " + str(stack))
                except:0
            if current_command == ".":
                pointer_position += 1
                current_command += commands[pointer_position]

            if current_command == "h":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(convert_to_base(int(Q), 16))
                        print(Q)
                    stack.append(temp_list)
                else:
                    stack.append(convert_to_base(int(a), 16))

            elif current_command == "b":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(convert_to_base(int(Q), 2))
                        print(Q)
                    stack.append(temp_list)
                else:
                    stack.append(convert_to_base(int(a), 2))

            elif current_command == "B":
                a, b = pop_stack(2)
                if type(a) is list and type(b) is list:
                    temp_list = []
                    temp_list_2 = []
                    for Q in a:
                        temp_list_2 = []
                        for R in b:
                            temp_list_2.append(convert_to_base(int(Q), int(R)))
                        temp_list.append(temp_list_2)
                    stack.append(temp_list)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(convert_to_base(int(Q), int(b)))
                    stack.append(temp_list)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(convert_to_base(int(a), int(Q)))
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
                            temp_index += str(dictionary.unicode_index.index(current_command))
                            temp_position += 1
                            pointer_position += 2
                            current_command = commands[temp_position]
                            temp_index += str(dictionary.unicode_index.index(current_command))
                            temp_string += dictionary.dictionary[int(temp_index)]
                            temp_index = ""
                        elif current_command == "\u2019":
                            pointer_position += 1
                            break
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
                            temp_index += str(dictionary.unicode_index.index(current_command))
                            temp_position += 1
                            pointer_position += 2
                            current_command = commands[temp_position]
                            temp_index += str(dictionary.unicode_index.index(current_command))
                            if temp_string == "":
                                temp_string += dictionary.dictionary[int(temp_index)].upper()
                            else:
                                temp_string += " " + dictionary.dictionary[int(temp_index)].upper()
                            temp_index = ""
                        elif current_command == "\u2018":
                            pointer_position += 1
                            break
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
                            temp_index += str(dictionary.unicode_index.index(current_command))
                            temp_position += 1
                            pointer_position += 2
                            current_command = commands[temp_position]
                            temp_index += str(dictionary.unicode_index.index(current_command))
                            if temp_string == "":
                                temp_string += dictionary.dictionary[int(temp_index)]
                            else:
                                temp_string += " " + dictionary.dictionary[int(temp_index)]
                            temp_index = ""
                        elif current_command == "\u201c":
                            pointer_position += 1
                            break
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
                            temp_index += str(dictionary.unicode_index.index(current_command))
                            temp_position += 1
                            pointer_position += 2
                            current_command = commands[temp_position]
                            temp_index += str(dictionary.unicode_index.index(current_command))
                            if temp_string == "":
                                temp_string += dictionary.dictionary[int(temp_index)].title()
                            else:
                                temp_string += " " + dictionary.dictionary[int(temp_index)].title()
                            temp_index = ""
                        elif current_command == "\u201d":
                            pointer_position += 1
                            break
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
                    if Q == ".":
                        begin_sentence = True
                stack.append(temp_string)

            elif current_command == "!":
                a = pop_stack(1)

                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(math.factorial(int(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(math.factorial(int(a)))

            elif current_command == "+":
                a, b = pop_stack(2)
                if type(a) is list and type(b) is list:
                    temp_list = []
                    temp_list_2 = []
                    for Q in a:
                        temp_list_2 = []
                        for R in b:
                            temp_list_2.append(int(Q) + int(R))
                        temp_list.append(temp_list_2)
                    stack.append(temp_list)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(int(Q) + int(b))
                    stack.append(temp_list)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(int(a) + int(Q))
                    stack.append(temp_list)
                else:
                    stack.append(int(a) + int(b))

            elif current_command == "-":
                a, b = pop_stack(2)
                if type(a) is list and type(b) is list:
                    temp_list = []
                    temp_list_2 = []
                    for Q in a:
                        temp_list_2 = []
                        for R in b:
                            temp_list_2.append(int(R) - int(Q))
                        temp_list.append(temp_list_2)
                    stack.append(temp_list)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(int(b) - int(Q))
                    stack.append(temp_list)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(int(Q) - int(a))
                    stack.append(temp_list)
                elif (type(b) is str and not is_digit_value(b)) or (type(a) is str and not is_digit_value(a)):
                    for Q in str(a):
                        b = b.replace(Q, "")
                    stack.append(str(b))
                else:
                    stack.append(int(b) - int(a))

            elif current_command == "*":
                a, b = pop_stack(2)
                if type(a) is list and type(b) is list:
                    temp_list = []
                    temp_list_2 = []
                    for Q in a:
                        temp_list_2 = []
                        for R in b:
                            temp_list_2.append(int(Q) * int(R))
                        temp_list.append(temp_list_2)
                    stack.append(temp_list)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(int(Q) * int(b))
                    stack.append(temp_list)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(int(a) * int(Q))
                    stack.append(temp_list)
                else:
                    stack.append(int(a) * int(b))

            elif current_command == "/":
                a, b = pop_stack(2)
                if type(a) is list and type(b) is list:
                    temp_list = []
                    temp_list_2 = []
                    for Q in a:
                        temp_list_2 = []
                        for R in b:
                            temp_list_2.append(int(R) / int(Q))
                        temp_list.append(temp_list_2)
                    stack.append(temp_list)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(int(b) / int(Q))
                    stack.append(temp_list)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(int(Q) / int(a))
                    stack.append(temp_list)
                else:
                    stack.append(int(b) / int(a))

            elif current_command == "%":
                a, b = pop_stack(2)
                if type(a) is list and type(b) is list:
                    temp_list = []
                    temp_list_2 = []
                    for Q in a:
                        temp_list_2 = []
                        for R in b:
                            temp_list_2.append(int(R) % int(Q))
                        temp_list.append(temp_list_2)
                    stack.append(temp_list)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(int(b) % int(Q))
                    stack.append(temp_list)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(int(Q) % int(a))
                    stack.append(temp_list)
                else:
                    stack.append(int(b) % int(a))

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
                a = str(input())
                stack.append(a)
                recent_inputs.append(a)

            elif current_command == "$":
                a = str(input())
                stack.append(1)
                stack.append(a)
                recent_inputs.append(a)

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
                a = stack.pop()
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
                    temp_list = []
                    for Q in a:
                        temp_list.append(int(not int(Q)))
                    stack.append(temp_list)
                else:
                    temp_list.append(int(not int(a)))

            elif current_command == "s":
                a = stack.pop()
                b = stack.pop()
                stack.append(a)
                stack.append(b)

            elif current_command == "|":
                print(stack)
                has_printed.append(True)

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
                        elif current_command == "i" or current_command == "F" or current_command == "v" or current_command == "G" or current_command == "\u0192":
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
                a = stack.pop()
                if a == 1 or a == "1":
                    run_program(STATEMENT, debug, True, range_variable, x_integer, y_integer, z_integer, string_variable)
                elif amount_else == 0:
                    run_program(ELSE_STATEMENT[1:], debug, True, range_variable, x_integer, y_integer, z_integer, string_variable)
                pointer_position = temp_position

            elif current_command == "\\":
                stack.pop()

            elif current_command == "`":
                a = pop_stack(1)
                for x in a:
                    stack.append(x)

            elif current_command == "x":
                a = pop_stack(1)
                stack.append(a)
                stack.append(a * 2)

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
                        elif current_command == "i" or current_command == "F" or current_command == "v" or current_command == "G" or current_command == "\u0192":
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
                    a = int(stack.pop())
                else:
                    a = int(input())
                    recent_inputs.append(a)

                if a != 0:
                    for range_variable in range(0, a):
                        run_program(STATEMENT, debug, True, range_variable, x_integer, y_integer, z_integer, string_variable)
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
                        elif current_command == "i" or current_command == "F" or current_command == "v" or current_command == "G" or current_command == "\u0192":
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
                    a = int(stack.pop())
                else:
                    a = int(input())
                    recent_inputs.append(a)

                if a > 1:
                    for range_variable in range(1, a):
                        run_program(STATEMENT, debug, True, range_variable, x_integer, y_integer, z_integer, string_variable)
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
                        elif current_command == "i" or current_command == "F" or current_command == "v" or current_command == "G" or current_command == "\u0192":
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
                    a = int(stack.pop())
                else:
                    a = int(input())
                    recent_inputs.append(a)

                if a > -1:
                    for range_variable in range(0, a + 1):
                        run_program(STATEMENT, debug, True, range_variable, x_integer, y_integer, z_integer, string_variable)
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
                    for X in str(a):
                        stack.append(X)

            elif current_command == "^":
                a, b = pop_stack(2)
                if type(a) is list and type(b) is list:
                    temp_list = []
                    temp_list_2 = []
                    for Q in a:
                        temp_list_2 = []
                        for R in b:
                            temp_list_2.append(int(R) ^ int(Q))
                        temp_list.append(temp_list_2)
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
                    temp_list_2 = []
                    for Q in a:
                        temp_list_2 = []
                        for R in b:
                            temp_list_2.append(int(R) | int(Q))
                        temp_list.append(temp_list_2)
                    for S in temp_list:
                        stack.append(S)
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
                    temp_list_2 = []
                    for Q in a:
                        temp_list_2 = []
                        for R in b:
                            temp_list_2.append(int(R) & int(Q))
                        temp_list.append(temp_list_2)
                    for S in temp_list:
                        stack.append(S)
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
                    temp_list_2 = []
                    for Q in a:
                        temp_list_2 = []
                        for R in b:
                            temp_list_2.append(combinations(int(Q), int(R)))
                        temp_list.append(temp_list_2)
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
                    temp_list_2 = []
                    for Q in a:
                        temp_list_2 = []
                        for R in b:
                            temp_list_2.append(permutations(int(Q), int(R)))
                        temp_list.append(temp_list_2)
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
                        temp_list.append(int(Q) + 1)
                    stack.append(temp_list)
                else:
                    stack.append(int(a) + 1)

            elif current_command == "<":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(int(Q) - 1)
                    stack.append(temp_list)
                else:
                    stack.append(int(a) - 1)

            elif current_command == "'":
                temp_string = ""
                pointer_position += 1
                temp_string = commands[pointer_position]
                stack.append(temp_string)

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
                while True:
                    if run_program(STATEMENT, debug, True, range_variable, x_integer, y_integer, z_integer, string_variable):
                        break
                pointer_position = temp_position

            elif current_command == "#":
                a = stack.pop()
                if a == 1:
                    return True

            elif current_command == "=":
                if stack:
                    a = str(stack[-1])
                    print(a)
                    has_printed.append(True)

            elif current_command == "Q":
                a, b = pop_stack(2)
                if type(a) is list and type(b) is list:
                    stack.append(eval("\"" + str(a) + "\"" + "==" + "\"" + str(b) + "\""))
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        if is_digit_value(str(Q)): Q = eval(str(Q))
                        temp_list.append(eval("\"" + str(b) + "\"" + "==" + "\"" + str(Q) + "\""))
                    stack.append(temp_list)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        if is_digit_value(str(Q)): Q = eval(str(Q))
                        temp_list.append(eval("\"" + str(Q) + "\"" + "==" + "\"" + str(a) + "\""))
                    stack.append(temp_list)
                else:
                    stack.append(eval("\"" + str(a) + "\"" + "==" + "\"" + str(b) + "\""))

            elif current_command == "(":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(int(Q) * -1)
                    stack.append(temp_list)
                else:
                    stack.append(int(a) * -1)

            elif current_command == "A":
                stack.append('abcdefghijklmnopqrstuvwxyz')

            elif current_command == "\u2122":
                a = pop_stack(1)
                stack.append(str(a).title())

            elif current_command == "E":
                a = input()
                try:
                    b = eval(a)
                    stack.append(b)
                    recent_inputs.append(b)
                except:
                    stack.append(a)
                    recent_inputs.append(a)

            elif current_command == ")":
                temp_list = []
                temp_list_2 = []
                if stack:
                    for S in stack:
                        temp_list_2.append(S)
                    for Q in temp_list_2:
                        R = stack.pop()
                        temp_list.append(R)
                    temp_list.reverse()
                stack.append(temp_list)

            elif current_command == "P":
                temp_number = 1
                a = pop_stack(1)
                for Q in a:
                    temp_number *= int(Q)
                stack.append(temp_number)

            elif current_command == "O":
                temp_number = 0
                temp_list_2 = []
                a = pop_stack(1)

                if type(a) is list:
                    for Q in a:
                        temp_number += int(Q)
                else:
                    for Q in stack:
                        temp_number += int(Q)
                stack.append(temp_number)

            elif current_command == ";":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(int(Q) // 2)
                    stack.append(temp_list)
                else:
                    stack.append(int(a) // 2)

            elif current_command == "w":
                time.sleep(1)

            elif current_command == "m":
                if stack:
                    a, b = pop_stack(2)
                else:
                    b, a = pop_stack(2)
                if type(a) is list and type(b) is list:
                    temp_list = []
                    temp_list_2 = []
                    for Q in a:
                        temp_list_2 = []
                        for R in b:
                            temp_list_2.append(int(R) ** int(Q))
                        temp_list.append(temp_list_2)
                    stack.append(temp_list)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(int(b) ** int(Q))
                    stack.append(temp_list)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(int(Q) ** int(a))
                    stack.append(temp_list)
                else:
                    stack.append(int(b) ** int(a))

            elif current_command == "X":
                stack.append(x_integer)

            elif current_command == "Y":
                stack.append(y_integer)

            elif current_command == "Z":
                stack.append(z_integer)

            elif current_command == "U":  # x variable
                a = pop_stack(1)
                x_integer = a

            elif current_command == "V":  # y variable
                a = pop_stack(1)
                y_integer = a

            elif current_command == "W":  # z variable
                a = input()
                z_integer = a
                stack.append(a)
                recent_inputs.append(a)

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
                for Q in stack:
                    temp_list.append(Q)
                a = temp_list.pop()
                if type(a) is list:
                    for Q in a:
                        if type(Q) is bool:
                            temp_string += str(int(Q))
                        else:
                            temp_string += str(Q)
                    stack.pop()
                else:
                    R = len(stack)
                    stack.reverse()
                    for Q in range(R):
                        a = stack.pop()
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
                a = int(stack.pop())
                stack.append(stack.pop(a))

            elif current_command == "M":
                temp_list = []
                temp_list_2 = []
                for Q in stack:
                    temp_list_2.append(Q)
                while True:
                    for Q in temp_list_2:
                        if type(Q) is list:
                            for R in Q:
                                temp_list.append(R)
                        else:
                            temp_list.append(Q)
                    if temp_list == temp_list_2:
                        break
                    else:
                        temp_list_2 = []
                        for Q in temp_list:
                            temp_list_2.append(Q)
                        temp_list = []
                max_int = -9999999999999999999999
                for Q in temp_list:
                    if str(Q).isnumeric():
                        if int(Q) > max_int:
                            max_int = int(Q)
                stack.append(max_int)

            elif current_command == "t":
                a = pop_stack(1)
                stack.append(math.sqrt(float(a)))

            elif current_command == "n":
                a = pop_stack(1)
                temp_list = []
                if type(a) is list:
                    for Q in a:
                        temp_list.append(int(Q) ** 2)
                    stack.append(temp_list)
                else:
                    stack.append(int(a) ** 2)

            elif current_command == "o":
                a = pop_stack(1)
                temp_list = []
                if type(a) is list:
                    for Q in a:
                        temp_list.append(2 ** int(Q))
                    stack.append(temp_list)
                else:
                    stack.append(2 ** int(a))

            elif current_command == "k":
                a, b = pop_stack(2)
                index_value = 0
                for Q in a:
                    index_value += 1
                    if str(Q) == str(b):
                        stack.append(index_value)
                        break
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
                        temp_list.append(int(10 ** int(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(int(10 ** int(a)))

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
                        elif current_command == "i" or current_command == "F" or current_command == "v" or current_command == "G" or current_command == "\u0192":
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
                    a = stack.pop()
                else:
                    a = str(input(a))
                    recent_inputs.append(a)

                range_variable = -1
                if type(a) is int: a = str(a)
                for string_variable in a:
                    range_variable += 1
                    if debug:print("N = " + str(range_variable))
                    run_program(STATEMENT, debug, True, range_variable, x_integer, y_integer, z_integer, string_variable)
                pointer_position = temp_position

            elif current_command == "y":
                stack.append(string_variable)

            elif current_command == ",":
                a = stack.pop()
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

            elif current_command == ".f":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(prime_factorization_duplicates(int(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(prime_factorization_duplicates(int(a)))

            elif current_command == ".p":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(prime_factorization_powers(int(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(prime_factorization_powers(int(a)))

            elif current_command == ".d":
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

            elif current_command == ".a":
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
                            temp_list.append(True)
                        else:
                            temp_list.append(False)
                    stack.append(temp_list)
                else:
                    if str(a).upper() == str(a):
                        stack.append(True)
                    else:
                        stack.append(False)

            elif current_command == ".l":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        if str(Q).lower() == str(Q):
                            temp_list.append(True)
                        else:
                            temp_list.append(False)
                    stack.append(temp_list)
                else:
                    if str(a).lower() == str(a):
                        stack.append(True)
                    else:
                        stack.append(False)

            elif current_command == "\u00c7":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(ord(str(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(ord(str(a)))

            elif current_command == "\u00e7":
                a = pop_stack(1)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(chr(int(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(chr(int(a)))

            elif current_command == "\u00f7":
                if stack:
                    b, a = pop_stack(2)
                    b = int(b)
                    a = str(a)
                else:
                    a = str(input())
                    recent_inputs.append(a)
                    b = int(input())
                    recent_inputs.append(b)
                temp_string = ""
                R = 0
                for Q in a:
                    temp_string += Q
                    R += 1
                    if R == b:
                        stack.append(temp_string)
                        temp_string = ""
                        R = 0
                if temp_string != "":
                    stack.append(temp_string)

            elif current_command == "\u00c6":
                a = pop_stack(1)
                a = a[::-1]
                result = int(a.pop())
                for Q in range(0, len(a)):
                    result -= int(a[Q])
                stack.append(Q)

            elif current_command == "\u00d9":
                a = pop_stack(1)
                temp_list = []
                for Q in a:
                    if Q not in temp_list:
                        temp_list.append(Q)
                stack.append(temp_list)

            elif current_command == "\u00da":
                a = pop_stack(1)
                a = a[::-1]
                temp_list = []
                for Q in a:
                    if Q not in temp_list:
                        temp_list.append(Q)
                stack.append(temp_list[::-1])

            elif current_command == "\u00db":
                b, a = pop_stack(2)
                a = str(a)
                b = str(b)
                length_of_str = len(b)
                while True:
                    if a[0:length_of_str] == b:
                        a = a[length_of_str:]
                    else:
                        break
                stack.append(a)

            elif current_command == "\u00dc":
                b, a = pop_stack(2)
                b = str(b)
                a = str(a)
                length_of_str = len(b)
                while True:
                    if a[len(a) - length_of_str:len(a)] == b:
                        a = a[0:len(a) - length_of_str]
                    else:
                        break
                stack.append(a)

            elif current_command == "\u00c8":
                a = pop_stack(1)
                stack.append(int(a) % 2 == 0)

            elif current_command == "\u00c9":
                a = pop_stack(1)
                stack.append(int(a) % 2 == 1)

            elif current_command == "\u00a1":
                b, a = pop_stack(2)
                temp_list = str(a).split(str(b))
                for Q in temp_list:
                    stack.append(str(Q))

            elif current_command == "\u00ef":
                a = pop_stack(1)
                stack.append(int(a))

            elif current_command == "\u00de":
                a = pop_stack(1)
                a = str(a)
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
                stack.append(a)

            elif current_command == "\u00a7":
                a = pop_stack(1)
                stack.append(str(a))

            elif current_command == "\u0161":
                a = pop_stack(1)
                a = str(a)
                temp_string = ""
                for Q in a:
                    if Q.isupper(): temp_string += Q.lower()
                    else: temp_string += Q.upper()

                stack.append(temp_string)

            elif current_command == "\u00a3":
                b, a = pop_stack(2)
                b = int(b)
                stack.append(a[0:b])

            elif current_command == "K":
                b, a = pop_stack(2)
                temp_list = []
                for Q in a:
                    if str(Q) != str(b):
                        temp_list.append(Q)
                stack.append(temp_list)

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

            elif current_command == "\u2039":
                b, a = pop_stack(2)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        if int(Q) < int(b):
                            temp_list.append(True)
                        else:
                            temp_list.append(False)
                    stack.append(temp_list)
                else:
                    if int(a) < int(b):
                        stack.append(True)
                    else:
                        stack.append(False)

            elif current_command == "\u203A":
                b, a = pop_stack(2)
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        if int(Q) > int(b):
                            temp_list.append(True)
                        else:
                            temp_list.append(False)
                    stack.append(temp_list)
                else:
                    if int(a) > int(b):
                        stack.append(True)
                    else:
                        stack.append(False)

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
                stack.append(str(b).count(str(a)))

            elif current_command == "\u00d0":
                a = pop_stack(1)
                stack.append(a)
                stack.append(a)
                stack.append(a)

            elif current_command == "\u00c4":
                a = pop_stack(1)
                stack.append(abs(int(a)))

            elif current_command == "\u00dd":
                if len(stack) > 1:
                    a, b = pop_stack(2)
                else:
                    b, a = pop_stack(2)
                temp_list = []
                for Q in range(int(b), int(a)):
                    temp_list.append(Q)
                stack.append(temp_list)

            elif current_command == "\u0178":
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
                            temp_list_2.append(int(R) % int(Q) == 0)
                        temp_list.append(temp_list_2)
                    stack.append(temp_list)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(int(b) % int(Q) == 0)
                    stack.append(temp_list)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(int(Q) % int(a) == 0)
                    stack.append(temp_list)
                else:
                    stack.append(int(b) % int(a) == 0)

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

            elif current_command == "\u00ab":
                if len(stack) > 1:
                    b, a = pop_stack(2)
                else:
                    a, b  = pop_stack(2)
                temp_list = []
                for Q in a:
                    temp_list.append(Q)
                for Q in b:
                    temp_list.append(Q)
                stack.append(temp_list)

            elif current_command == "\u00f2":
                a = pop_stack(1)
                stack.append(int(a) + 1)

            elif current_command == "\u00f3":
                a = pop_stack(1)
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

            elif current_command == ".e":
                temp_string = ""
                try:
                    while commands[pointer_position + 1] != "}":
                        temp_string += commands[pointer_position + 1]
                        pointer_position += 1
                except:0
                temp_string = temp_string.replace("#", "stack")
                temp_string = temp_string.replace(";", "\n")
                if debug:
                    print("-- PYTHON EXEC --")
                    print(temp_string)
                    print("------ END ------")
                exec(temp_string)

            elif current_command == "\u00b9":
                if len(recent_inputs) > 0:
                    stack.append(recent_inputs[0])

            elif current_command == "\u00b2":
                if len(recent_inputs) > 1:
                    stack.append(recent_inputs[1])

            elif current_command == "\u00b3":
                if len(recent_inputs) > 2:
                    stack.append(recent_inputs[2])

        except Exception as ex:
            if debug:
                print(str(ex))

    if not has_printed and not suppress_print:
        if stack: print(stack[len(stack) - 1])
    if debug:
        print("stack > " + str(stack))

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--debug', help="Debug mode", action="store_true")
    parser.add_argument("program_path", help="Program path", type=str)

    args = parser.parse_args()
    filename = args.program_path
    DEBUG = args.debug

    code = open(filename, "r", encoding="utf-8").read()

    if code == "":
        code = "$FDR+{"
    run_program(code, DEBUG, False, 0)