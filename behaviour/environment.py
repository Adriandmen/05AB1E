
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

    def clone(self):
        clone_env = Environment()
        clone_env.x = self.x
        clone_env.y = self.y
        clone_env.z = self.z
        clone_env.c = self.c
        clone_env.range_variable = self.range_variable
        clone_env.string_variable = self.string_variable
        clone_env.current_canvas = self.current_canvas
        clone_env.current_cursor = self.current_cursor

        return clone_env


class GlobalEnvironment:

    def __init__(self):
        self.has_printed = False
        self.recent_inputs = []
        self.counter_variable = 0
        self.global_array = []
        self.zero_division = False
