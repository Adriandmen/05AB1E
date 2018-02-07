class TestException(Exception):
    pass


def assert_equals(actual, expected, message=""):
    if expected == actual:
        pass
    else:
        message = message if message else "Expected {} but got {}".format(expected, actual)
        raise TestException("[FAIL] {} \n".format(message))


def assert_true(actual, message=""):
    if actual is True:
        pass
    else:
        message = message if message else "Expected {} to be true".format(actual)
        raise TestException("[FAIL] {} \n".format(message))


def assert_false(actual, message=""):
    if actual is False:
        pass
    else:
        message = message if message else "Expected {} to be true".format(actual)
        raise TestException("[FAIL] {} \n".format(message))
