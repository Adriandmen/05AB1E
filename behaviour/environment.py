
class Environment:

    def __init__(self):
        self.x = 1
        self.y = 2
        self.z = 3
        self.c = -1
        self.range_variable = 0
        self.string_variable = ""
        self.current_canvas = {}
        self.current_cursor = [0, 0]


class GlobalEnvironment:

    def __init__(self):
        self.has_printed = False
        self.recent_inputs = []
        self.counter_variable = 0
        self.global_array = []
        self.zero_division = False
