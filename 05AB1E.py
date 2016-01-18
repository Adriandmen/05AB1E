import argparse
import time
import math
import binascii
from commands import *

stack = []
exit_program = []
has_printed = []

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
                if stack:
                    a = stack.pop()
                else:
                    a = input("> ")
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(convert_to_base(int(Q), 16))
                        print(Q)
                    stack.append(temp_list)
                else:
                    stack.append(convert_to_base(int(a), 16))

            elif current_command == "b":
                if stack:
                    a = stack.pop()
                else:
                    a = input("> ")
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(convert_to_base(int(Q), 2))
                        print(Q)
                    stack.append(temp_list)
                else:
                    stack.append(convert_to_base(int(a), 2))

            elif current_command == "B":
                if len(stack) > 1:
                    a = stack.pop()
                    b = stack.pop()
                else:
                    if len(stack) > 0:
                        a = stack.pop()
                        b = input("> ")
                    else:
                        a = input("> ")
                        b = input("> ")
                if type(a) is list and type(b) is list:
                    temp_list = []
                    temp_list_2 = []
                    for Q in a:
                        temp_list_2 = []
                        for R in b:
                            temp_list_2.append(convert_to_base(int(Q), int(R)))
                        temp_list.append(temp_list_2)
                    for S in temp_list:
                        stack.append(S)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(convert_to_base(int(Q), int(b)))
                    for S in temp_list:
                        stack.append(S)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(convert_to_base(int(a), int(Q)))
                    for S in temp_list:
                        stack.append(S)
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

            elif current_command == "\u201c":
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

            elif current_command == "!":
                if stack:
                    a = stack.pop()
                else:
                    a = input("> ")

                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(math.factorial(int(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(math.factorial(int(a)))

            elif current_command == "+":
                if len(stack) > 1:
                    a = stack.pop()
                    b = stack.pop()
                else:
                    if len(stack) > 0:
                        a = stack.pop()
                        b = input("> ")
                    else:
                        a = input("> ")
                        b = input("> ")
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
                if len(stack) > 1:
                    a = stack.pop()
                    b = stack.pop()
                else:
                    if len(stack) > 0:
                        a = stack.pop()
                        b = input("> ")
                    else:
                        a = input("> ")
                        b = input("> ")
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
                if len(stack) > 1:
                    a = stack.pop()
                    b = stack.pop()
                else:
                    if len(stack) > 0:
                        a = stack.pop()
                        b = input("> ")
                    else:
                        a = input("> ")
                        b = input("> ")
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
                if len(stack) > 1:
                    a = stack.pop()
                    b = stack.pop()
                else:
                    if len(stack) > 0:
                        a = stack.pop()
                        b = input("> ")
                    else:
                        a = input("> ")
                        b = input("> ")
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
                if len(stack) > 1:
                    a = stack.pop()
                    b = stack.pop()
                else:
                    if len(stack) > 0:
                        a = stack.pop()
                        b = input("> ")
                    else:
                        a = input("> ")
                        b = input("> ")
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
                if stack:
                    a = stack.pop()
                    stack.append(a)
                    stack.append(a)
                else:
                    a = input("> ")
                    stack.append(a)
                    stack.append(a)

            elif current_command == "R":
                if stack:
                    a = stack.pop()
                else:
                    a = str(input("> "))
                if type(a) is list:
                    stack.append(a[::-1])
                else:
                    stack.append(str(a)[::-1])

            elif current_command == "I":
                stack.append(str(input("> ")))

            elif current_command == "$":
                stack.append(1)
                stack.append(str(input("> ")))

            elif current_command == "H":
                if stack:
                    a = stack.pop()
                    if type(a) is list:
                        temp_list = []
                        for Q in a:
                            temp_list.append(int(str(Q), 16))
                        stack.append(temp_list)
                    else:
                        stack.append(int(str(a), 16))
                else:
                    a = str(input("> "))
                    stack.append(int(str(a), 16))

            elif current_command == "C":
                if stack:
                    a = stack.pop()
                    if type(a) is list:
                        temp_list = []
                        for Q in a:
                            temp_list.append(int(str(Q), 2))
                        stack.append(temp_list)
                    else:
                        stack.append(int(a, 2))
                else:
                    a = str(input("> "))
                    stack.append(int(a, 2))

            elif current_command == "a":
                if stack:
                    a = stack.pop()
                    if type(a) is list:
                        temp_list = []
                        for Q in a:
                            temp_list.append(is_alpha_value(str(Q)))
                        stack.append(temp_list)
                    else:
                        stack.append(is_alpha_value(str(a)))
                else:
                    a = input("> ")
                    stack.append(is_alpha_value(str(a)))

            elif current_command == "d":
                if stack:
                    a = stack.pop()
                    if type(a) is list:
                        temp_list = []
                        for Q in a:
                            temp_list.append(is_digit_value(str(Q)))
                        stack.append(temp_list)
                    else:
                        stack.append(is_digit_value(str(a)))
                else:
                    a = input("> ")
                    stack.append(is_digit_value(a))

            elif current_command == "p":
                if stack:
                    a = stack.pop()
                    if type(a) is list:
                        temp_list = []
                        for Q in a:
                            temp_list.append(is_prime(int(Q)))
                        stack.append(temp_list)
                    else:
                        stack.append(is_prime(int(a)))
                else:
                    a = int(input("> "))
                    stack.append(is_prime(a))

            elif current_command == "u":
                if stack:
                    a = stack.pop()
                    if type(a) is list:
                        temp_list = []
                        for Q in a:
                            temp_list.append(str(Q).upper())
                        stack.append(temp_list)
                    else:
                        stack.append(str(a).upper())
                else:
                    a = str(input("> "))
                    stack.append(a.upper())

            elif current_command == "l":
                if stack:
                    a = stack.pop()
                    if type(a) is list:
                        temp_list = []
                        for Q in a:
                            temp_list.append(str(a).lower())
                        stack.append(temp_list)
                    else:
                        stack.append(str(a).lower())
                else:
                    a = str(input("> "))
                    stack.append(a.lower())

            elif current_command == "_":
                if stack:
                    a = stack.pop()
                    if type(a) is list:
                        temp_list = []
                        for Q in a:
                            try:
                                a = int(a)
                                if a == 1:
                                    temp_list.append(False)
                                else:
                                    temp_list.append(True)
                            except:
                                temp_list.append(False)
                        stack.append(temp_list)
                    else:
                        try:
                            a = int(a)
                            if a == 1:
                                stack.append(False)
                            else:
                                stack.append(True)
                        except:
                            stack.append(False)
                else:
                    a = input("> ")
                    try:
                        a = int(a)
                        if a == 1:
                            stack.append(False)
                        else:
                            stack.append(True)
                    except:
                        stack.append(False)

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
                if stack:
                    a = stack.pop()
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
                else:
                    a = int(input("> "))
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
                        if current_command == "}" or current_command == "\u20ac":
                            if current_command == "}":
                                amount_brackets -= 1
                            if current_command == "\u20ac":
                                amount_else -= 1
                            if amount_brackets == 0:
                                break
                        elif current_command == "i" or current_command == "F" or current_command == "v":
                            amount_brackets += 1
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
                    print("if: " + STATEMENT)
                    if amount_else == 0: print("else: " + ELSE_STATEMENT)
                if stack.pop() == 1:
                    run_program(STATEMENT, debug, True, range_variable, x_integer, y_integer, z_integer, string_variable)
                elif amount_else == 0:
                    run_program(ELSE_STATEMENT[1:], debug, True, range_variable, x_integer, y_integer, z_integer, string_variable)
                pointer_position = temp_position

            elif current_command == "\\":
                stack.pop()

            elif current_command == "`":
                a = stack.pop()
                for x in a:
                    stack.append(x)

            elif current_command == "x":
                if stack:
                    a = int(stack.pop())
                    stack.append(a)
                    stack.append(a * 2)
                else:
                    a = int(input("> "))
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
                        elif current_command == "i" or current_command == "F" or current_command == "v":
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
                    print(STATEMENT)
                a = 0
                if stack:
                    a = int(stack.pop())
                else:
                    a = int(input("> "))

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
                        elif current_command == "i" or current_command == "F" or current_command == "v":
                            amount_brackets += 1
                        STATEMENT += current_command
                        try:
                            temp_position += 1
                            current_command = commands[temp_position]
                        except:
                            break
                if debug:
                    print(STATEMENT)
                a = 0
                if stack:
                    a = int(stack.pop())
                else:
                    a = int(input("> "))

                if a != 0:
                    for range_variable in range(1, a):
                        run_program(STATEMENT, debug, True, range_variable, x_integer, y_integer, z_integer, string_variable)
                pointer_position = temp_position

            elif current_command == "N":
                stack.append(range_variable)

            elif current_command == "T":
                stack.append(10)

            elif current_command == "S":
                if stack:
                    a = stack.pop()
                    if type(a) is list:
                        temp_list = []
                        for Q in a:
                            for X in str(Q):
                                temp_list.append(X)
                        stack.append(temp_list)
                    else:
                        for X in str(a):
                            stack.append(X)
                else:
                    a = str(input("> "))
                    for X in a:
                        stack.append(X)

            elif current_command == "^":
                if len(stack) > 1:
                    a = stack.pop()
                    b = stack.pop()
                else:
                    if len(stack) > 0:
                        a = stack.pop()
                        b = input("> ")
                    else:
                        a = input("> ")
                        b = input("> ")
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
                if len(stack) > 1:
                    a = stack.pop()
                    b = stack.pop()
                else:
                    if len(stack) > 0:
                        a = stack.pop()
                        b = input("> ")
                    else:
                        a = input("> ")
                        b = input("> ")
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
                if len(stack) > 1:
                    a = stack.pop()
                    b = stack.pop()
                else:
                    if len(stack) > 0:
                        a = stack.pop()
                        b = input("> ")
                    else:
                        a = input("> ")
                        b = input("> ")
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
                if len(stack) > 1:
                    a = stack.pop()
                    b = stack.pop()
                else:
                    if len(stack) > 0:
                        a = stack.pop()
                        b = input("> ")
                    else:
                        a = input("> ")
                        b = input("> ")
                if type(a) is list and type(b) is list:
                    temp_list = []
                    temp_list_2 = []
                    for Q in a:
                        temp_list_2 = []
                        for R in b:
                            temp_list_2.append(combinations(int(Q), int(R)))
                        temp_list.append(temp_list_2)
                    for S in temp_list:
                        stack.append(S)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(combinations(int(Q), int(b)))
                    for S in temp_list:
                        stack.append(S)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(combinations(int(a), int(Q)))
                    for S in temp_list:
                        stack.append(S)
                else:
                    stack.append(combinations(int(b), int(a)))

            elif current_command == "e":
                if len(stack) > 1:
                    a = stack.pop()
                    b = stack.pop()
                else:
                    if len(stack) > 0:
                        a = stack.pop()
                        b = input("> ")
                    else:
                        a = input("> ")
                        b = input("> ")
                if type(a) is list and type(b) is list:
                    temp_list = []
                    temp_list_2 = []
                    for Q in a:
                        temp_list_2 = []
                        for R in b:
                            temp_list_2.append(permutations(int(Q), int(R)))
                        temp_list.append(temp_list_2)
                    for S in temp_list:
                        stack.append(S)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(permutations(int(Q), int(b)))
                    for S in temp_list:
                        stack.append(S)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(permutations(int(a), int(Q)))
                    for S in temp_list:
                        stack.append(S)
                else:
                    stack.append(combinations(int(b), int(a)))

            elif current_command == ">":
                if stack:
                    a = stack.pop()
                    if type(a) is list:
                        temp_list = []
                        for Q in a:
                            temp_list.append(int(Q) + 1)
                        stack.append(temp_list)
                    else:
                        stack.append(int(a) + 1)
                else:
                    a = int(input("> "))
                    stack.append(a + 1)

            elif current_command == "<":
                if stack:
                    a = stack.pop()
                    if type(a) is list:
                        temp_list = []
                        for Q in a:
                            temp_list.append(int(Q) - 1)
                        stack.append(temp_list)
                    else:
                        stack.append(int(a) - 1)
                else:
                    a = int(input("> "))
                    stack.append(a - 1)

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
                if len(stack) > 1:
                    a = stack.pop()
                    b = stack.pop()
                else:
                    if len(stack) > 0:
                        a = stack.pop()
                        b = input("> ")
                    else:
                        a = input("> ")
                        b = input("> ")
                if type(a) is list and type(b) is list:
                    stack.append(eval("\"" + str(a) + "\"" + "==" + "\"" + str(b) + "\""))
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(eval("\"" + str(b) + "\"" + "==" + "\"" + str(Q) + "\""))
                    for S in temp_list:
                        stack.append(S)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(eval("\"" + str(Q) + "\"" + "==" + "\"" + str(a) + "\""))
                    for S in temp_list:
                        stack.append(S)
                else:
                    stack.append(eval("\"" + str(a) + "\"" + "==" + "\"" + str(b) + "\""))

            elif current_command == "(":
                if stack:
                    a = stack.pop()
                    if type(a) is list:
                        for Q in a:
                            stack.append(int(Q) * -1)
                    else:
                        stack.append(int(a) * -1)
                else:
                    a = int(input("> "))
                    stack.append(a * -1)

            elif current_command == "A":
                stack.append('abcdefghijklmnopqrstuvwxyz')

            elif current_command == "E":
                a = input("> ")
                try:
                    b = eval(a)
                    stack.append(b)
                except:
                    stack.append(a)

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
                a = stack.pop()
                for Q in a:
                    temp_number *= int(Q)
                stack.append(temp_number)

            elif current_command == "O":
                temp_number = 0
                temp_list_2 = []
                for Q in stack:
                    temp_list_2.append(Q)
                a = temp_list_2.pop()
                if type(a) is list:
                    for Q in a:
                        temp_number += int(Q)
                else:
                    for Q in stack:
                        temp_number += int(Q)
                stack.append(temp_number)

            elif current_command == "w":
                time.sleep(1)

            elif current_command == "m":
                if len(stack) > 1:
                    a = stack.pop()
                    b = stack.pop()
                else:
                    if len(stack) > 0:
                        a = stack.pop()
                        b = input("> ")
                    else:
                        b = input("> ")
                        a = input("> ")
                if type(a) is list and type(b) is list:
                    temp_list = []
                    temp_list_2 = []
                    for Q in a:
                        temp_list_2 = []
                        for R in b:
                            temp_list_2.append(int(R) ** int(Q))
                        temp_list.append(temp_list_2)
                    for S in temp_list:
                        stack.append(S)
                elif type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(int(b) ** int(Q))
                    for S in temp_list:
                        stack.append(S)
                elif type(b) is list:
                    temp_list = []
                    for Q in b:
                        temp_list.append(int(Q) ** int(a))
                    for S in temp_list:
                        stack.append(S)
                else:
                    stack.append(int(b) ** int(a))

            elif current_command == "X":
                stack.append(x_integer)

            elif current_command == "Y":
                stack.append(y_integer)

            elif current_command == "Z":
                stack.append(z_integer)

            elif current_command == "U":  # x variable
                if stack:
                    a = int(stack.pop())
                else:
                    a = int(input("> "))
                x_integer = a

            elif current_command == "V":  # y variable
                if stack:
                    a = int(stack.pop())
                else:
                    a = int(input("> "))
                y_integer = a

            elif current_command == "W":  # z variable
                a = int(input("> "))
                z_integer = a
                stack.append(a)

            elif current_command == "q":
                exit_program.append(1)
                break

            elif current_command == "g":
                if stack:
                    a = stack.pop()
                else:
                    a = input("> ")
                if type(a) is int:
                    stack.append(len(str(a)))
                else:
                    stack.append(len(a))

            elif current_command == "J":
                temp_list = []
                temp_string = ""
                for Q in stack:
                    temp_list.append(str(Q))
                a = temp_list.pop()
                if type(a) is list:
                    for Q in a:
                        if type(Q) is bool:
                            temp_string += str(int(Q))
                        else:
                            temp_string += str(Q)
                else:
                    R = len(stack)
                    for Q in range(R):
                        a = stack.pop()
                        if type(a) is bool:
                            temp_string += str(int(a))
                        else:
                            temp_string += str(a)
                    temp_string = temp_string[::-1]
                stack.append(temp_string)

            elif current_command == ":":
                if len(stack) > 2:
                    c = str(stack.pop())
                    b = stack.pop()
                    a = stack.pop()
                elif len(stack) > 1:
                    c = str(stack.pop())
                    b = stack.pop()
                    a = str(input("> "))
                elif len(stack) > 0:
                    c = str(stack.pop())
                    b = str(input("> "))
                    a = str(input("> "))
                else:
                    c = str(input("> "))
                    b = str(input("> "))
                    a = str(input("> "))
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
                a = int(stack.pop())
                for Q in stack:
                    temp_string = ""
                    if type(Q) is list:
                        for R in Q:
                            temp_string += str(R).rjust(a)
                        print(temp_string)
                    else:
                        print(str(Q).rjust(a), end="")
                has_printed.append(True)

            elif current_command == ".j":
                a = int(stack.pop())
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
                a = int(stack.pop())
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
                if stack:
                    a = stack.pop()
                else:
                    a = int(input())
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
                if stack:
                    a = int(stack.pop())
                else:
                    a = int(input("> "))
                stack.append(int(math.sqrt(int(a))))

            elif current_command == "n":
                if stack:
                    a = stack.pop()
                    temp_list = []
                    if type(a) is list:
                        for Q in a:
                            temp_list.append(int(Q) ** 2)
                        stack.append(temp_list)
                    else:
                        stack.append(int(a) ** 2)
                else:
                    a = int(input("> "))
                stack.append(int(int(a) ** 2))

            elif current_command == "o":
                if stack:
                    a = stack.pop()
                    temp_list = []
                    if type(a) is list:
                        for Q in a:
                            temp_list.append(2 ** int(Q))
                        stack.append(temp_list)
                    else:
                        stack.append(2 ** int(a))
                else:
                    a = int(input("> "))
                    stack.append(int(2 ** int(a)))

            elif current_command == "k":
                a = stack.pop()
                if stack:
                    b = str(stack.pop())
                else:
                    b = str(input("> "))
                index_value = 0
                for Q in a:
                    index_value += 1
                    if str(Q) == str(b):
                        stack.append(index_value)
                        break
                stack.append(-1)

            elif current_command == "{":
                if stack:
                    a = stack.pop()
                else:
                    a = str(input("> "))
                if type(a) is list:
                    stack.append(sorted(a))
                else:
                    stack.append(''.join(sorted(str(a))))

            elif current_command == ".T":
                if stack:
                    a = stack.pop()
                else:
                    a = int(input("> "))
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
                        elif current_command == "i" or current_command == "F" or current_command == "v":
                            amount_brackets += 1
                        STATEMENT += current_command
                        try:
                            temp_position += 1
                            current_command = commands[temp_position]
                        except:
                            break
                if debug:
                    print(STATEMENT)
                a = 0
                if stack:
                    a = str(stack.pop())
                else:
                    a = str(input("> "))
                range_variable = -1
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
                if stack:
                    a = stack.pop()
                else:
                    a = int(input())
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(prime_factorization(int(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(prime_factorization(int(a)))

            elif current_command == ".f":
                if stack:
                    a = stack.pop()
                else:
                    a = int(input())
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(prime_factorization_duplicates(int(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(prime_factorization_duplicates(int(a)))

            elif current_command == ".p":
                if stack:
                    a = stack.pop()
                else:
                    a = int(input())
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(prime_factorization_powers(int(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(prime_factorization_powers(int(a)))

            elif current_command == ".d":
                if stack:
                    a = stack.pop()
                else:
                    a = str(input())
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
                if stack:
                    a = stack.pop()
                else:
                    a = str(input())
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
                if stack:
                    a = stack.pop()
                else:
                    a = str(input())
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
                if stack:
                    a = stack.pop()
                else:
                    a = str(input())
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
                if stack:
                    a = stack.pop()
                else:
                    a = str(input())
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(ord(str(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(ord(str(a)))

            elif current_command == "\u00e7":
                if stack:
                    a = stack.pop()
                else:
                    a = str(input())
                if type(a) is list:
                    temp_list = []
                    for Q in a:
                        temp_list.append(chr(int(Q)))
                    stack.append(temp_list)
                else:
                    stack.append(chr(int(a)))

            elif current_command == "\u00f7":
                if len(stack) > 1:
                    b = int(stack.pop())
                    a = str(stack.pop())
                elif len(stack) > 0:
                    b = int(stack.pop())
                    a = str(input())
                else:
                    a = str(input())
                    b = int(input())
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
                if stack:
                    a = stack.pop()
                else:
                    a = eval(input())
                a = a[::-1]
                result = int(a.pop())
                for Q in range(0, len(a)):
                    result -= int(a[Q])
                stack.append(Q)

            elif current_command == "\u00d9":
                a = stack.pop()
                temp_list = []
                for Q in a:
                    if Q not in temp_list:
                        temp_list.append(Q)
                stack.append(temp_list)

            elif current_command == "\u00da":
                a = stack.pop()
                a = a[::-1]
                temp_list = []
                for Q in a:
                    if Q not in temp_list:
                        temp_list.append(Q)
                stack.append(temp_list[::-1])

            elif current_command == "\u00db":
                if len(stack) > 1:
                    b = str(stack.pop())
                    a = str(stack.pop())
                elif stack:
                    b = str(stack.pop())
                    a = input()
                else:
                    b = input()
                    a = input()
                length_of_str = len(b)
                while True:
                    if a[0:length_of_str] == b:
                        a = a[length_of_str:]
                    else:
                        break
                stack.append(a)

            elif current_command == "\u00dc":
                if len(stack) > 1:
                    b = str(stack.pop())
                    a = str(stack.pop())
                elif stack:
                    b = str(stack.pop())
                    a = input()
                else:
                    b = input()
                    a = input()
                length_of_str = len(b)
                while True:
                    if a[len(a) - length_of_str:len(a)] == b:
                        a = a[0:len(a) - length_of_str]
                    else:
                        break
                stack.append(a)

            elif current_command == "\u00c8":
                if stack:
                    a = int(stack.pop())
                else:
                    a = int(input())
                stack.append(a % 2 == 0)

            elif current_command == "\u00c9":
                if stack:
                    a = int(stack.pop())
                else:
                    a = int(input())
                stack.append(a % 2 == 1)

            elif current_command == "\u00a1":
                if len(stack) > 1:
                    b = str(stack.pop())
                    a = str(stack.pop())
                elif stack:
                    b = str(stack.pop())
                    a = input()
                else:
                    b = input()
                    a = input()
                temp_list = str(a).split(b)
                for Q in temp_list:
                    stack.append(str(Q))

            elif current_command == "\u00ef":
                if stack:
                    a = int(stack.pop())
                else:
                    a = int(input())
                stack.append(a)

            elif current_command == "\u00de":
                if stack:
                    a = str(stack.pop())
                else:
                    a = str(input())
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
                if stack:
                    a = str(stack.pop())
                else:
                    a = str(input())
                stack.append(a)

            elif current_command == "\u00a3":
                if len(stack) > 1:
                    b = int(stack.pop())
                    a = stack.pop()
                elif stack:
                    b = int(stack.pop())
                    a = input()
                else:
                    b = int(input())
                    a = input()
                stack.append(a[0:b])

            elif current_command == "\u00df":
                a = stack[-1]
                b = stack.pop()
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
                b = stack.pop()
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
                b = stack.pop()
                a = stack.pop()
                if int(a) < int(b):
                    stack.append(True)
                else:
                    stack.append(False)

            elif current_command == "\u203A":
                b = stack.pop()
                a = stack.pop()
                if int(a) > int(b):
                    stack.append(True)
                else:
                    stack.append(False)

            elif current_command == "?":
                a = stack.pop()
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
    run_program(code, DEBUG, False, 0)