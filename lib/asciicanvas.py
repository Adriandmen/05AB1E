
numbers = "0123456789"

movement_pattern_characters = [
    "U",        # Up
    "D",        # Down
    "L",        # Left
    "R",        # Right
    "\u03b1"    # Top-left
    "\u03b2"    # Top-right
    "\u03b3"    # Bottom-left
    "\u03b4"    # Bottom-right
]


def canvas_code_to_string(code):
    """
    Runs a canvas code and returns the resulting array.
    Canvas code is currently constucted in one of the following ways:

        pattern number (filler)     e.g. UL4# would result in:

        ####
           #
           #
           #

    :param code: The code that will be executed which returns an array of strings
    :return: An array from the canvas code
    """

    canvas = {}

    cursor = [0, 0]
    pattern = ""
    index = -1
    while index < len(code) - 1:

        index += 1
        current_command = code[index]

        if current_command in movement_pattern_characters:
            pattern += current_command

        elif current_command in numbers:

            parsed_number = current_command
            while index + 1 < len(code) and code[index + 1] in numbers:
                parsed_number += code[index + 1]
                index += 1

            parsed_number = int(parsed_number)
            filler = ""

            if index + 1 < len(code) and code[index + 1] == "\u201C":
                index += 1

                while index + 1 < len(code) and code[index + 1] != "\u201D":
                    filler += code[index + 1]
                    index += 1

            canvas, cursor = canvasify(pattern, parsed_number, filler, canvas, cursor)

    print(canvas)
    print(cursor)


def canvasify(pattern, number, filler, previous_canvas, cursor_position):

    current_canvas = previous_canvas
    current_position = cursor_position

    for character in pattern:
        if character == "U":
            for index in range(0, number - 1):
                current_canvas[' '.join(str(x) for x in current_position)] = filler
                current_position = [current_position[0], current_position[1] + 1]
                current_canvas[' '.join(str(x) for x in current_position)] = filler

        elif character == "D":
            for index in range(0, number - 1):
                current_canvas[' '.join(str(x) for x in current_position)] = filler
                current_position = [current_position[0], current_position[1] - 1]
                current_canvas[' '.join(str(x) for x in current_position)] = filler

        elif character == "L":
            for index in range(0, number - 1):
                current_canvas[' '.join(str(x) for x in current_position)] = filler
                current_position = [current_position[0] - 1, current_position[1]]
                current_canvas[' '.join(str(x) for x in current_position)] = filler

        elif character == "R":
            for index in range(0, number - 1):
                current_canvas[' '.join(str(x) for x in current_position)] = filler
                current_position = [current_position[0] + 1, current_position[1]]
                current_canvas[' '.join(str(x) for x in current_position)] = filler

    return current_canvas, current_position


canvas_code_to_string("UL4\u201C#\u201DUL4\u201CA\u201D")
