from .test_class.test_utils import *
from lib.statements import *


def testIfOnlyStatement():

    code_block = "123i456}789"
    if_statement, else_statement, remaining = get_statements(code_block=code_block, is_if_command=True)

    assert_equals(if_statement, "123i456}789")
    assert_equals(else_statement, "")
    assert_equals(remaining, "")


def testIfOnlyWithNestedElseStatement():

    code_block = "123i45ë6}789"
    if_statement, else_statement, remaining = get_statements(code_block=code_block, is_if_command=True)

    assert_equals(if_statement, "123i45ë6}789")
    assert_equals(else_statement, "")
    assert_equals(remaining, "")


def testIfAndElseWithMultipleNestedStatements():

    code_block = "101i102i103ë104i105ë106}107ë108i109ë5}6ë112"
    if_statement, else_statement, remaining = get_statements(code_block=code_block, is_if_command=True)

    assert_equals(if_statement, "101i102i103ë104i105ë106}107ë108i109ë5}6")
    assert_equals(else_statement, "112")
    assert_equals(remaining, "")


def testEndOfIfAndElse():

    code_block = "123i456ë789}000ë111}222"
    if_statement, else_statement, remaining = get_statements(code_block=code_block, is_if_command=True)

    assert_equals(if_statement, "123i456ë789}000")
    assert_equals(else_statement, "111")
    assert_equals(remaining, "222")


def testStatementsWithNormalStrings():

    for char in ['"', '‘', '’', '“', '”']:

        code_block = "123{0}i123{0}456ë789".format(char)
        if_statement, else_statement, remaining = get_statements(code_block=code_block, is_if_command=True)

        assert_equals(if_statement, "123{0}i123{0}456".format(char))
        assert_equals(else_statement, "789")
        assert_equals(remaining, "")


def testStatementsWithTwoCharDelimiters():

    for char in [".", "Å", "ž", "'", "λ"]:

        code_block = "123{0}\"i123ë456ë789".format(char)

        if_statement, else_statement, remaining = get_statements(code_block=code_block, is_if_command=True)

        assert_equals(if_statement, "123{0}\"i123ë456".format(char))
        assert_equals(else_statement, "789")
        assert_equals(remaining, "")


def testStatementsWithOneCharDelimitedStrings():

    delimiters = ["'", '„', '…']
    words = ['"', 'ÅÅ', 'i']

    combos = [[x for x in words],
              [x + y for x in words for y in words],
              [x + y + z for x in words for y in words for z in words]]

    code_block = "123{0}{1}456ë789"

    for delimiter in range(0, len(delimiters)):
        curr_delimiter = delimiters[delimiter]
        word_combos = combos[delimiter]

        for word in word_combos:
            curr_block = code_block.format(curr_delimiter, word)

            if_statement, else_statement, remaining = get_statements(code_block=curr_block, is_if_command=True)

            assert_equals(if_statement, "123{0}{1}456".format(curr_delimiter, word))
            assert_equals(else_statement, "789")
            assert_equals(remaining, "")


def testStatementsWithForLoopAndElse():

    code_block = "123Fi456ë789ë789"
    if_statement, else_statement, remaining = get_statements(code_block=code_block, is_if_command=True)

    assert_equals(if_statement, "123Fi456ë789")
    assert_equals(else_statement, "789")
    assert_equals(remaining, "")


def testStatementsWithForLoopClosingBracket():

    code_block = "123iF456}789ë101ë102"
    if_statement, else_statement, remaining = get_statements(code_block=code_block, is_if_command=True)

    assert_equals(if_statement, "123iF456}789ë101")
    assert_equals(else_statement, "102")
    assert_equals(remaining, "")


def testStatementsWithNestedBlockAndIfStatements():

    code_block = "123iF456µ55i83ë867ë789ë555"
    if_statement, else_statement, remaining = get_statements(code_block=code_block, is_if_command=True)

    assert_equals(if_statement, "123iF456µ55i83ë867ë789")
    assert_equals(else_statement, "555")
    assert_equals(remaining, "")


def testStatementsWithNestedBlockStatements():

    code_block = "F456µ55i83ë867ë789"
    if_statement, else_statement, remaining = get_statements(code_block=code_block, is_if_command=True)

    assert_equals(if_statement, "F456µ55i83ë867")
    assert_equals(else_statement, "789")
    assert_equals(remaining, "")


def testRemainingWithNoElse():

    code_block = "123µ56}7}890"
    if_statement, else_statement, remaining = get_statements(code_block=code_block, is_if_command=True)

    assert_equals(if_statement, "123µ56}7")
    assert_equals(else_statement, "")
    assert_equals(remaining, "890")


def testRemainingWithInfiniteBracket():

    code_block = "123µ56}7i45µ122]890"
    if_statement, else_statement, remaining = get_statements(code_block=code_block, is_if_command=True)

    assert_equals(if_statement, "123µ56}7i45µ122")
    assert_equals(else_statement, "")
    assert_equals(remaining, "890")


def testRemainingWithElseAndInfiniteBracket():

    code_block = "123µ56}7i45µ12ë2]890"
    if_statement, else_statement, remaining = get_statements(code_block=code_block, is_if_command=True)

    assert_equals(if_statement, "123µ56}7i45µ12ë2")
    assert_equals(else_statement, "")
    assert_equals(remaining, "890")


def testRemainingWithBlockStatement():

    code_block = "123F456µ789}101}102}103"

    block_statement, remaining = get_statements(code_block=code_block)

    assert_equals(block_statement, "123F456µ789}101}102")
    assert_equals(remaining, "103")


def testIfStatementsInBlockStatement():

    code_block = "123i456ë789i987ë101}102}103}104"

    block_statement, remaining = get_statements(code_block=code_block)

    assert_equals(block_statement, "123i456ë789i987ë101}102}103")
    assert_equals(remaining, "104")
