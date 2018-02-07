from .test_class.test_utils import *
from lib.commands import ast_int_eval


def testIntEvalWithInt():
    value = 123
    result = ast_int_eval(123)

    assert_equals(value, 123)



