import lib.dictionary as dictionary

# Constants, delimiters and block indicators
if_delimiters = ['ë', '}']
string_delimiters = ['"', '‘', '’', '“', '”']
two_char_indicators = [".", "Å", "ž", "'", "λ"]
compressed_chars = ["'", '„', '…']
block_commands = ["F", "i", "v", "G", "[", "ƒ", "ʒ", "Σ", "ε", "µ"]


def get_statements(code_block, is_if_command=False):

    delimiter_stack = ["if" if is_if_command else "block"]

    else_position = 0
    end_position = 0

    string_mode = False
    string_delimiter = None
    compressed_string = False
    else_passed = False
    skip = 0

    for char in code_block:

        if skip == 0:
            compressed_string = False

        if skip > 0:
            if compressed_string and char in dictionary.unicode_index:
                skip -= 1
            else:
                skip -= 2

        # Strings
        elif char in string_delimiters and not string_mode:
            string_mode = True
            string_delimiter = char

        # If in string mode
        elif string_mode:
            if char == string_delimiter:
                string_mode = False

        # One-char delimited strings
        elif char in compressed_chars:
            compressed_string = True
            skip = (compressed_chars.index(char) + 1) * 2

        # Two-char functions
        elif char in [".", "Å", "ž", "λ"]:
            skip = 2

        # New if-statement found
        elif char == "i":
            delimiter_stack.append("if")

        # New block-statement found
        elif char in block_commands:
            delimiter_stack.append("block")

        # Else bracket
        elif char == "ë":
            while delimiter_stack and (delimiter_stack[-1] == "block" or delimiter_stack[-1] == "else"):
                if delimiter_stack[-1] == "else" and len(delimiter_stack) == 1:
                    break
                delimiter_stack.pop()

            if delimiter_stack[-1] == "if":
                if len(delimiter_stack) == 1:
                    else_passed = True

                delimiter_stack.pop()
                delimiter_stack.append("else")

        # Closing bracket
        elif char == "}":
            delimiter_stack.pop()
            if not delimiter_stack:
                break

        # Infinite bracket
        elif char == "]":
            delimiter_stack.clear()
            break

        else_position += not else_passed
        end_position += 1

    if is_if_command:
        return code_block[:else_position], code_block[else_position + 1:end_position], code_block[end_position + 1:]
    else:
        return code_block[:end_position], code_block[end_position + 1:]
