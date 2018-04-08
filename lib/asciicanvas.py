
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


def rotate(string, number):
    number = number % len(string)
    return string[number:] + string[:number]


def canvas_code_to_string(number, pattern, filler, prev_canvas=None, prev_cursor=None):
    """
    Converts the code parameters from the stack into a canvas and a final
    cursor position that will be passed along to the main 05AB1E program.
    :param number: An integer or list that determines the length of the (current) side-length
    :param pattern: An integer or list of integers that indicates the movement of the cursor
    :param filler: The string that is used to draw on the canvas
    :param prev_canvas: The previous canvas that will be used to write on
    :param prev_cursor: The previous cursor position that will be used as the current cursor
    :return: A pair of a new canvas and a new cursor position
    """

    if not number:
        number = len(filler)

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
        filler = str(filler)
    if type(filler) is list:
        filler = [str(x) for x in filler]

    if type(number) is list and type(pattern) is str:
        current_filler = filler
        for index in range(0, len(number)):
            prev_canvas, prev_cursor = canvasify(
                pattern, number[index], current_filler, prev_canvas, prev_cursor
            )
            current_filler = rotate(current_filler, number[index] * len(pattern) - 2)

    elif type(number) is list and type(pattern) is list:
        pattern_index = 0
        current_filler = filler
        for index in range(0, len(number)):
            prev_canvas, prev_cursor = canvasify(
                pattern[pattern_index % len(pattern)],
                number[index],
                current_filler,
                prev_canvas,
                prev_cursor
            )
            current_filler = rotate(current_filler, number[index] - 1)
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

    full_pattern_mode = False
    vertical_mode = False
    mirror_cycle_mode = False
    if "80" in pattern:
        pattern = pattern.replace("80", "")
        full_pattern_mode = True

    if "81" in pattern:
        pattern = pattern.replace("81", "")
        full_pattern_mode = True
        vertical_mode = True

    if "82" in pattern:
        pattern = pattern.replace("82", "")
        mirror_cycle_mode = True

    pattern = pattern.replace("90", "226044")
    pattern = pattern.replace("91", "0246")
    pattern = pattern.replace("92", "337155")

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

    if full_pattern_mode:
        for i in range(0, len(filler)):
            if vertical_mode:
                current_canvas[' '.join([str(current_position[0]), str(current_position[1] + i)])] = filler[i]
            else:
                current_canvas[' '.join([str(current_position[0] + i), str(current_position[1])])] = filler[i]
    else:
        current_canvas[' '.join(str(x) for x in current_position)] = filler[0]

    if number == 1:
        return current_canvas, current_position

    filler_index = 1
    for character in pattern:

        delta_x, delta_y = deltas.get(character)
        for index in range(0, number - 1):
            if mirror_cycle_mode:
                current_filler = (filler + filler[::-1][1:])[filler_index % len(filler + filler[::-1][1:][:-1])]
            else:
                current_filler = filler[filler_index % len(filler)]
            filler_index += 1
            current_position = [current_position[0] + delta_x, current_position[1] + delta_y]

            if full_pattern_mode:
                for i in range(0, len(filler)):
                    if vertical_mode:
                        current_canvas[' '.join([str(current_position[0]), str(current_position[1] + i)])] = filler[i]
                    else:
                        current_canvas[' '.join([str(current_position[0] + i), str(current_position[1])])] = filler[i]
            else:
                current_canvas[' '.join(str(x) for x in current_position)] = current_filler

    return current_canvas, current_position

if __name__ == '__main__':
    # number, pattern, filler, prev_canvas, prev_cursor
    canvas, _ = canvas_code_to_string(5, 33715580, "*****")
    print(canvas_dict_to_string(canvas))
