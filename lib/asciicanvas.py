
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


def canvas_code_to_string(number, pattern, filler, prev_canvas=None, prev_cursor=None):
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

    if not prev_canvas:
        prev_canvas = {}

    if not prev_cursor:
        prev_cursor = [0, 0]

    if type(number) is str:
        number = int(number)
    if type(number) is list:
        number = [int(x) for x in number]

    if type(pattern) is int:
        pattern = str(pattern)
    if type(pattern) is list:
        pattern = [str(x) for x in pattern]

    if type(filler) is int:
        filler = int(filler)
    if type(filler) is list:
        filler = [str(x) for x in filler]

    if type(number) is list and type(pattern) is str:
        for num in number:
            prev_canvas, prev_cursor = canvasify(pattern, num, filler, prev_canvas, prev_cursor)

    elif type(number) is list and type(pattern) is list:
        pattern_index = 0
        for num in number:
            prev_canvas, prev_cursor = canvasify(
                pattern[pattern_index % len(pattern)], num, filler, prev_canvas, prev_cursor
            )

            pattern_index += 1

    elif type(number) is int and type(pattern) is str:
        prev_canvas, prev_cursor = canvasify(pattern, number, filler, prev_canvas, prev_cursor)

    elif type(number) is int and type(pattern) is list:
        pattern_index = 0
        for num in [number] * number:
            prev_canvas, prev_cursor = canvasify(
                pattern[pattern_index % len(pattern)], num, filler, prev_canvas, prev_cursor
            )

            pattern_index += 1

    return prev_canvas, prev_cursor


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


def canvasify(pattern, number, filler, previous_canvas, cursor_position):
    """
    Converts the arguments that are passed through to a dictionary object
    which in this case will be the canvas. The canvas itself is made up
    of a key and a value. The key is in the following string format:

        x y

    The value attached to that key is a character. The dict is used for
    its easy accessibility and space complexity.
    :param pattern: The pattern that will be used for the line to draw
    :param number: The length of each line
    :param filler: The filler character for the lines (can be empty)
    :param previous_canvas: The state of the previous canvas
    :param cursor_position: The current position for the cursor
    :return: Returns a new canvas and a new cursor position
    """
    current_canvas = previous_canvas
    current_position = cursor_position

    pattern = pattern.replace("8", "226044")

    deltas = {
        "0": [0, 1],
        "4": [0, -1],
        "6": [-1, 0],
        "2": [1, 0],
        "7": [-1, 1],
        "1": [1, 1],
        "5": [-1, -1],
        "3": [1, -1]
    }

    current_canvas[' '.join(str(x) for x in current_position)] = filler[0]

    filler_index = 1
    for character in pattern:

        delta_x, delta_y = deltas.get(character)
        for index in range(0, number - 1):
            current_filler = filler[filler_index % len(filler)]
            filler_index += 1
            current_position = [current_position[0] + delta_x, current_position[1] + delta_y]
            current_canvas[' '.join(str(x) for x in current_position)] = current_filler

    return current_canvas, current_position

if __name__ == '__main__':
    # number, pattern, filler, prev_canvas, prev_cursor
    canvas, _ = canvas_code_to_string(5, ["\u03b4", "R", "\u03b2", "R"], "O")
    print(canvas_dict_to_string(canvas))
