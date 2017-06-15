
numbers = "0123456789"

movement_pattern_characters = [
    "U",        # Up
    "D",        # Down
    "L",        # Left
    "R",        # Right
    "\u03b1",    # Top-left
    "\u03b2",    # Top-right
    "\u03b3",    # Bottom-left
    "\u03b4"    # Bottom-right
]


def canvas_code_to_string(code, prev_canvas, prev_cursor):
    """
    Runs a canvas code and returns the resulting array.
    Canvas code is currently constucted in one of the following ways:

        pattern number (filler)     e.g. UL4# would result in:

        ####
           #
           #
           #

    :param code: The code that will be executed which returns an array of
                 strings
    :return: An array from the canvas code
    """

    canvas = prev_canvas
    cursor = prev_cursor
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

            elif index + 1 < len(code)\
                    and code[index + 1] not in movement_pattern_characters:
                index += 1

                filler += code[index]
                while index + 1 < len(code)\
                        and code[index + 1] not in movement_pattern_characters:
                    filler += code[index + 1]
                    index += 1

            canvas, cursor = canvasify(pattern, parsed_number, filler, canvas,
                                       cursor)
            pattern = ""

    return canvas, cursor


def canvasify(pattern, number, filler, previous_canvas, cursor_position):
    """
    Converts the arguments that are passed through to a dictionary object
    which in this case will be the canvas. The canvas itself is made up
    of a key and a value. The key is in the following string format:

        x y

    The value attached to that key is a character. The dict is used for
    it's easy accessibility and space complexity.
    :param pattern: The pattern that will be used for the line to draw
    :param number: The length of each line
    :param filler: The filler character for the lines (can be empty)
    :param previous_canvas: The state of the previous canvas
    :param cursor_position: The current position for the cursor
    :return: Returns a new canvas and a new cursor position
    """
    curr_canvas = previous_canvas
    curr_position = cursor_position

    for character in pattern:
        if character == "U":
            for index in range(0, number - 1):
                curr_canvas[' '.join(str(x) for x in curr_position)] = filler
                curr_position = [curr_position[0], curr_position[1] + 1]
                curr_canvas[' '.join(str(x) for x in curr_position)] = filler

        elif character == "D":
            for index in range(0, number - 1):
                curr_canvas[' '.join(str(x) for x in curr_position)] = filler
                curr_position = [curr_position[0], curr_position[1] - 1]
                curr_canvas[' '.join(str(x) for x in curr_position)] = filler

        elif character == "L":
            for index in range(0, number - 1):
                curr_canvas[' '.join(str(x) for x in curr_position)] = filler
                curr_position = [curr_position[0] - 1, curr_position[1]]
                curr_canvas[' '.join(str(x) for x in curr_position)] = filler

        elif character == "R":
            for index in range(0, number - 1):
                curr_canvas[' '.join(str(x) for x in curr_position)] = filler
                curr_position = [curr_position[0] + 1, curr_position[1]]
                curr_canvas[' '.join(str(x) for x in curr_position)] = filler

        elif character == "\u03b1":
            for index in range(0, number - 1):
                curr_canvas[' '.join(str(x) for x in curr_position)] = filler
                curr_position = [curr_position[0] - 1, curr_position[1] + 1]
                curr_canvas[' '.join(str(x) for x in curr_position)] = filler

        elif character == "\u03b2":
            for index in range(0, number - 1):
                curr_canvas[' '.join(str(x) for x in curr_position)] = filler
                curr_position = [curr_position[0] + 1, curr_position[1] + 1]
                curr_canvas[' '.join(str(x) for x in curr_position)] = filler

        elif character == "\u03b3":
            for index in range(0, number - 1):
                curr_canvas[' '.join(str(x) for x in curr_position)] = filler
                curr_position = [curr_position[0] - 1, curr_position[1] - 1]
                curr_canvas[' '.join(str(x) for x in curr_position)] = filler

        elif character == "\u03b4":
            for index in range(0, number - 1):
                curr_canvas[' '.join(str(x) for x in curr_position)] = filler
                curr_position = [curr_position[0] + 1, curr_position[1] - 1]
                curr_canvas[' '.join(str(x) for x in curr_position)] = filler

    return curr_canvas, curr_position


def canvas_dict_to_string(canvas: dict):
    """
    Converts a dictionary object to a string
    :param canvas: A dict object with all keys and values for the canvas
    :return: A 2D string (joined by newlines) that represents the canvas
    """

    min_x = float('inf')
    min_y = float('inf')
    max_x = float('-inf')
    max_y = float('-inf')

    for key in canvas.keys():
        current_x = int(key.split()[0])
        current_y = int(key.split()[1])

        if current_x < min_x:
            min_x = current_x
        if current_y < min_y:
            min_y = current_y

        if current_x > max_x:
            max_x = current_x
        if current_y > max_y:
            max_y = current_y

    width = (max_x - min_x) + 1
    height = (max_y - min_y) + 1
    canvas_array = [[" " for _ in range(0, width)] for _ in range(0, height)]

    for element in canvas.items():
        x_index = int(element[0].split()[0])
        y_index = int(element[0].split()[1])

        canvas_array[y_index - min_y][x_index - min_x] = element[1]

    return '\n'.join(list(map(''.join, canvas_array))[::-1])

if __name__ == '__main__':
    string = "\u03b2DR4\u201C#\u201D"
    print(canvas_code_to_string("LU4#RDA"))
