import argparse
import math
from commands import *

stack = []


def run_program(commands, debug, suppress_print, range_variable=0):

    if debug:
        print("Full program: " + str(commands))
    pointer_position = -1
    temp_position = 0
    current_command = ""

    has_printed = False

    while pointer_position < len(commands) - 1:
        pointer_position += 1
        current_command = commands[pointer_position]

        if debug:print("current >> " + current_command + "  ||  stack: " + str(stack))
        # Base Conversion // a = to base2, b = to base3, etc...
        if current_command == "h":
            if stack:
                a = stack.pop()
            else:
                a = input()
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
                a = input()
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
                    b = input()
                else:
                    a = input()
                    b = input()
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
            temp_position = pointer_position
            while temp_position < len(commands) - 1:
                temp_position += 1
                try:
                    current_command = commands[temp_position]
                except:
                    break
                if current_command != "\"":
                    temp_string += current_command
                    pointer_position += 1
                else:
                    break
            pointer_position += 1
            stack.append(temp_string)

        elif current_command == "!":
            if stack:
                a = stack.pop()
            else:
                a = input()

            if type(a) is list:
                temp_list = []
                for Q in a:
                    temp_list.append(math.factorial(int(Q)))
                for S in temp_list:
                    stack.append(S)
            else:
                stack.append(math.factorial(int(a)))

        elif current_command == "+":
            if len(stack) > 1:
                a = stack.pop()
                b = stack.pop()
            else:
                if len(stack) > 0:
                    a = stack.pop()
                    b = input()
                else:
                    a = input()
                    b = input()
            if type(a) is list and type(b) is list:
                temp_list = []
                temp_list_2 = []
                for Q in a:
                    temp_list_2 = []
                    for R in b:
                        temp_list_2.append(int(Q) + int(R))
                    temp_list.append(temp_list_2)
                for S in temp_list:
                    stack.append(S)
            elif type(a) is list:
                temp_list = []
                for Q in a:
                    temp_list.append(int(Q) + int(b))
                for S in temp_list:
                    stack.append(S)
            elif type(b) is list:
                temp_list = []
                for Q in b:
                    temp_list.append(int(a) + int(Q))
                for S in temp_list:
                    stack.append(S)
            else:
                stack.append(int(a) + int(b))

        elif current_command == "-":
            if len(stack) > 1:
                a = stack.pop()
                b = stack.pop()
            else:
                if len(stack) > 0:
                    a = stack.pop()
                    b = input()
                else:
                    a = input()
                    b = input()
            if type(a) is list and type(b) is list:
                temp_list = []
                temp_list_2 = []
                for Q in a:
                    temp_list_2 = []
                    for R in b:
                        temp_list_2.append(int(R) - int(Q))
                    temp_list.append(temp_list_2)
                for S in temp_list:
                    stack.append(S)
            elif type(a) is list:
                temp_list = []
                for Q in a:
                    temp_list.append(int(b) - int(Q))
                for S in temp_list:
                    stack.append(S)
            elif type(b) is list:
                temp_list = []
                for Q in b:
                    temp_list.append(int(Q) - int(a))
                for S in temp_list:
                    stack.append(S)
            else:
                stack.append(int(b) - int(a))

        elif current_command == "*":
            if len(stack) > 1:
                a = stack.pop()
                b = stack.pop()
            else:
                if len(stack) > 0:
                    a = stack.pop()
                    b = input()
                else:
                    a = input()
                    b = input()
            if type(a) is list and type(b) is list:
                temp_list = []
                temp_list_2 = []
                for Q in a:
                    temp_list_2 = []
                    for R in b:
                        temp_list_2.append(int(Q) * int(R))
                    temp_list.append(temp_list_2)
                for S in temp_list:
                    stack.append(S)
            elif type(a) is list:
                temp_list = []
                for Q in a:
                    temp_list.append(int(Q) * int(b))
                for S in temp_list:
                    stack.append(S)
            elif type(b) is list:
                temp_list = []
                for Q in b:
                    temp_list.append(int(a) * int(Q))
                for S in temp_list:
                    stack.append(S)
            else:
                stack.append(int(a) * int(b))

        elif current_command == "/":
            if len(stack) > 1:
                a = stack.pop()
                b = stack.pop()
            else:
                if len(stack) > 0:
                    a = stack.pop()
                    b = input()
                else:
                    a = input()
                    b = input()
            if type(a) is list and type(b) is list:
                temp_list = []
                temp_list_2 = []
                for Q in a:
                    temp_list_2 = []
                    for R in b:
                        temp_list_2.append(int(R) / int(Q))
                    temp_list.append(temp_list_2)
                for S in temp_list:
                    stack.append(S)
            elif type(a) is list:
                temp_list = []
                for Q in a:
                    temp_list.append(int(b) / int(Q))
                for S in temp_list:
                    stack.append(S)
            elif type(b) is list:
                temp_list = []
                for Q in b:
                    temp_list.append(int(Q) / int(a))
                for S in temp_list:
                    stack.append(S)
            else:
                stack.append(int(b) / int(a))

        elif current_command == "%":
            if len(stack) > 1:
                a = stack.pop()
                b = stack.pop()
            else:
                if len(stack) > 0:
                    a = stack.pop()
                    b = input()
                else:
                    a = input()
                    b = input()
            if type(a) is list and type(b) is list:
                temp_list = []
                temp_list_2 = []
                for Q in a:
                    temp_list_2 = []
                    for R in b:
                        temp_list_2.append(int(Q) % int(R))
                    temp_list.append(temp_list_2)
                for S in temp_list:
                    stack.append(S)
            elif type(a) is list:
                temp_list = []
                for Q in a:
                    temp_list.append(int(Q) % int(b))
                for S in temp_list:
                    stack.append(S)
            elif type(b) is list:
                temp_list = []
                for Q in b:
                    temp_list.append(int(a) % int(Q))
                for S in temp_list:
                    stack.append(S)
            else:
                stack.append(int(a) % int(b))

        elif current_command == "D":
            if stack:
                a = str(stack.pop())
                stack.append(a)
                stack.append(a)
            else:
                a = str(input())
                stack.append(a)
                stack.append(a)

        elif current_command == "R":
            if stack:
                a = str(stack.pop())
                stack.append(a[::-1])
            else:
                a = str(input())
                stack.append(a[::-1])

        elif current_command == "I":
            stack.append(str(input()))

        elif current_command == "$":
            stack.append(1)
            stack.append(str(input()))

        elif current_command == "H":
            if stack:
                a = stack.pop()
                if type(a) is list:
                    for Q in a:
                        stack.append(int(str(Q), 16))
                else:
                    stack.append(int(a, 16))
            else:
                a = str(input())
                stack.append(int(a, 16))

        elif current_command == "C":
            if stack:
                a = stack.pop()
                if type(a) is list:
                    for Q in a:
                        stack.append(int(str(Q), 2))
                else:
                    stack.append(int(a, 2))
            else:
                a = str(input())
                stack.append(int(a, 2))

        elif current_command == "a":
            if stack:
                a = stack.pop()
                if type(a) is list:
                    for Q in a:
                        stack.append(is_alpha_value(str(Q)))
                else:
                    stack.append(is_alpha_value(str(a)))
            else:
                a = input()
                stack.append(is_alpha_value(a))

        elif current_command == "d":
            if stack:
                a = stack.pop()
                if type(a) is list:
                    for Q in a:
                        stack.append(is_digit_value(str(Q)))
                else:
                    stack.append(is_digit_value(str(a)))
            else:
                a = input()
                stack.append(is_digit_value(a))

        elif current_command == "p":
            if stack:
                a = stack.pop()
                if type(a) is list:
                    for Q in a:
                        stack.append(is_prime(int(Q)))
                else:
                    stack.append(is_prime(int(a)))
            else:
                a = int(input())
                stack.append(is_prime(a))

        elif current_command == "u":
            if stack:
                a = stack.pop()
                if type(a) is list:
                    for Q in a:
                        stack.append(str(Q))
                else:
                    stack.append(str(a).upper())
            else:
                a = str(input())
                stack.append(a.upper())

        elif current_command == "l":
            if stack:
                a = stack.pop()
                if type(a) is list:
                    for Q in a:
                        stack.append(str(a).lower())
                else:
                    stack.append(str(a).lower())
            else:
                a = str(input())
                stack.append(a.lower())

        elif current_command == "_":
            if stack:
                a = stack.pop()
                if type(a) is list:
                    for Q in a:
                        try:
                            a = int(a)
                            if a == 1:
                                stack.append(False)
                            else:
                                stack.append(True)
                        except:
                            stack.append(False)
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
                a = input()
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
            has_printed = True

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
                a = int(input())
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
            temp_position = pointer_position
            temp_position += 1
            current_command = commands[temp_position]
            amount_brackets = 1
            while amount_brackets != 0:
                if current_command == "}":
                    amount_brackets -= 1
                    if amount_brackets == 0:
                        break
                elif current_command == "i" or current_command == "F":
                    amount_brackets += 1
                STATEMENT += current_command
                try:
                    temp_position += 1
                    current_command = commands[temp_position]
                except:
                    break
            if debug:
                print(STATEMENT)
            if stack.pop() == 1:
                run_program(STATEMENT, debug, True, 0)
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
                a = int(input())
                stack.append(a)
                stack.append(a * 2)

        elif current_command == "F":
            STATEMENT = ""
            temp_position = pointer_position
            temp_position += 1
            current_command = commands[temp_position]
            amount_brackets = 1
            while amount_brackets != 0:
                if current_command == "}":
                    amount_brackets -= 1
                    if amount_brackets == 0:
                        break
                elif current_command == "i" or current_command == "F":
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
                a = int(input())
            for range_variable in range(0, a):
                run_program(STATEMENT, debug, True, range_variable)
            pointer_position = temp_position

        elif current_command == "N":
            stack.append(range_variable)

        elif current_command == "T":
            stack.append(10)

        elif current_command == "S":
            if stack:
                a = stack.pop()
                if type(a) is list:
                    for Q in a:
                        for X in str(Q):
                            stack.append(X)
                else:
                    for X in str(a):
                        stack.append(X)
            else:
                a = str(input())
                for X in a:
                    stack.append(X)

        elif current_command == "^":
            if len(stack) > 1:
                a = stack.pop()
                b = stack.pop()
            else:
                if len(stack) > 0:
                    a = stack.pop()
                    b = input()
                else:
                    a = input()
                    b = input()
            if type(a) is list and type(b) is list:
                temp_list = []
                temp_list_2 = []
                for Q in a:
                    temp_list_2 = []
                    for R in b:
                        temp_list_2.append(int(R) ^ int(Q))
                    temp_list.append(temp_list_2)
                for S in temp_list:
                    stack.append(S)
            elif type(a) is list:
                temp_list = []
                for Q in a:
                    temp_list.append(int(b) ^ int(Q))
                for S in temp_list:
                    stack.append(S)
            elif type(b) is list:
                temp_list = []
                for Q in b:
                    temp_list.append(int(Q) ^ int(a))
                for S in temp_list:
                    stack.append(S)
            else:
                stack.append(int(b) ^ int(a))

        elif current_command == "~":
            if len(stack) > 1:
                a = stack.pop()
                b = stack.pop()
            else:
                if len(stack) > 0:
                    a = stack.pop()
                    b = input()
                else:
                    a = input()
                    b = input()
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
                    b = input()
                else:
                    a = input()
                    b = input()
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
                    b = input()
                else:
                    a = input()
                    b = input()
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
                    b = input()
                else:
                    a = input()
                    b = input()
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
                    for Q in a:
                        stack.append(int(Q) + 1)
                else:
                    stack.append(int(a) + 1)
            else:
                a = int(input())
                stack.append(a + 1)

        elif current_command == "<":
            if stack:
                a = stack.pop()
                if type(a) is list:
                    for Q in a:
                        stack.append(int(Q) - 1)
                else:
                    stack.append(int(a) - 1)
            else:
                a = int(input())
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
                if run_program(STATEMENT, debug, True, 0):
                    break
            pointer_position = temp_position

        elif current_command == "#":
            a = stack.pop()
            if a:
                return True

        elif current_command == "=":
            if stack:
                a = str(stack[-1])
                print(a)
                has_printed = True

        elif current_command == "Q":
            if len(stack) > 1:
                a = stack.pop()
                b = stack.pop()
            else:
                if len(stack) > 0:
                    a = stack.pop()
                    b = input()
                else:
                    a = input()
                    b = input()
            if type(a) is list and type(b) is list:
                temp_list = []
                temp_list_2 = []
                for Q in a:
                    temp_list_2 = []
                    for R in b:
                        temp_list_2.append(eval("\"" + str(R) + "\"" + "==" + "\"" + str(Q) + "\""))
                    temp_list.append(temp_list_2)
                for S in temp_list:
                    stack.append(S)
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
                stack.append(eval("\"" + a + "\"" + "==" + "\"" + b + "\""))

        elif current_command == "(":
            if stack:
                a = stack.pop()
                if type(a) is list:
                    for Q in a:
                        stack.append(int(Q) * -1)
                else:
                    stack.append(int(a) * -1)
            else:
                a = int(input())
                stack.append(a * -1)

        elif current_command == "A":
            stack.append('abcdefghijklmnopqrstuvwxyz')

        elif current_command == "E":
            a = input()
            try:
                b = eval(a)
                stack.append(b)
            except:
                stack.append(a)

    if not has_printed and not suppress_print:
        if stack: print(stack[len(stack) - 1])
        else: print("-> None")
    if debug:
        print("stack > " + str(stack))

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--debug', help="Debug mode", action="store_true")
    parser.add_argument("program_path", help="Program path", type=str)

    args = parser.parse_args()
    filename = args.program_path
    DEBUG = args.debug

    code = open(filename, "r").read()
    run_program(code, DEBUG, False, 0)