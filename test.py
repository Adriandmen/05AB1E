import re
import argparse
import traceback
import importlib

from os import listdir
from inspect import isfunction
from test.test_class.test_utils import TestException

# Global parameters
verbose_mode = False
name = None


def get_test_files(directory="test"):
    """
    Get all test files within a directory. Test files start with 'test_'
    and end with .py
    :param directory: The directory from which the tests will be found
    :return: A list of all tests files in import form (./test/one.py becomes test.one)
    """
    test_files = []

    for file in listdir(directory):
        if re.match("^test_.+?\.py$", file):
            test_files.append(directory + "." + file[:-3])

    return test_files


def run_test(test_func, module, test_count):
    """
    Runs a tests including printing the data and statistics about the current test
    :param test_func: The test function of the module which will be run
    :param module: The module in which the test exists
    :param test_count: The number that indicates which test this is
    :return: Return a boolean whether the test has succeeded
    """
    print("[#{1}] {0}: \t Running {2}".format(module.__name__, test_count, test_func.__name__))
    try:
        test_func()
        return True
    except TestException as e:
        if verbose_mode:
            traceback.print_exc()
        else:
            print(e)
    except Exception as e:
        if verbose_mode:
            traceback.print_exc()
        else:
            print("[ERROR] {} \n".format(e))

    return False


def run_tests(module):
    """
    Run all tests within a module
    :param module: The module from which all tests are run
    :return: A tuple containing the number of tests it has run and the number of
             successful tests that have been executed
    """
    test_count = 0
    success_count = 0

    print("Running tests in {}\n".format(module.__name__))

    # Loop through each object/function in the current module
    for func_name in dir(module):

        # If in single test mode, skip if not the correct test
        if name and func_name != name:
            continue

        # If it starts with [Tt]est or ends with [Tt]est
        if re.match("(^[tT]est|[tT]est$)", func_name):

            # Check if the object is a function
            # If it is a function, run it
            function = getattr(module, func_name)
            if isfunction(function):
                test_count += 1
                success_count += run_test(function, module, test_count)

    # Return the number of tests and number of successful tests
    return test_count, success_count


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('-v', '--verbose', help="Verbose mode", action="store_true")
    parser.add_argument('-n', '--name', type=str, nargs=1, help='Execute a particular test by name')

    # Parse arguments
    args = parser.parse_args()
    verbose_mode = args.verbose
    if args.name:
        name = args.name[0]

    print("\n"
          "Run python unit tests\n"
          "-------------------------------\n")

    modules = get_test_files()
    total_tests = 0
    successful_tests = 0

    for module in modules:
        module = importlib.import_module(module)
        test_count, success_count = run_tests(module)

        print("\n"
              "Successful tests: {0}/{1}\n\n"
              "-------------------------------\n".format(success_count, test_count))

        total_tests += test_count
        successful_tests += success_count

    print("A total of {} test(s) run with {} failure(s)".format(
        total_tests,
        total_tests - successful_tests
    ))

    exit(total_tests != successful_tests)
