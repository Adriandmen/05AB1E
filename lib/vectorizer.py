from lib.commands import *

def vectorized_evaluation(a, b, function, pre_function=None):
    """
    Uses the given function in the form of a lambda and produces a vectorized result if
    at least one of the items is an iterable value. Otherwise, it evaluates it as normal.
    :param a: The first value for the function
    :param b: The second value for the function
    :param function: A 2-arity lambda used for the function
    :param pre_function: A function that is called before vectorization (optional)
    :return: A value or array of values depending on a and b
    """

    try:
        if pre_function is not None:
            if type(a) is list:
                a = [apply_safe(pre_function, x) if type(x) is not list else x for x in a]
            else:
                a = apply_safe(pre_function, a)

            if type(b) is list:
                b = [apply_safe(pre_function, x) if type(x) is not list else x for x in b]
            else:
                b = apply_safe(pre_function, b)

        # When both are lists
        if type(a) is list and type(b) is list:

            # Get the minimum and maximum of both lists in order to prevent index errors
            vector_range = min(len(a), len(b))
            max_range = max(len(a), len(b))
            vectorized_result = []

            # Compute the function for all in range elements
            for index in range(0, vector_range):
                vectorized_result.append(apply_safe(function, a[index], b[index]))

            # Append all out of range elements without being processed
            for index in range(vector_range, max_range):
                if len(a) == max_range:
                    vectorized_result.append(a[index])
                else:
                    vectorized_result.append(b[index])

            return vectorized_result

        # When only type a is a list
        elif type(a) is list and type(b) is not list:

            vectorized_result = []
            for element in a:
                vectorized_result.append(
                    vectorized_evaluation(element, b, function, pre_function)
                )

            return vectorized_result

        # When only type b is a list
        elif type(a) is not list and type(b) is list:

            vectorized_result = []
            for element in b:
                vectorized_result.append(
                    vectorized_evaluation(a, element, function, pre_function)
                )

            return vectorized_result

        return apply_safe(function, a, b)

    except:
        if type(a) is list and type(b) is not list:
            vectorized_result = []
            for element in a:
                vectorized_result.append(
                    vectorized_evaluation(element, b, function, pre_function)
                )
            return vectorized_result
        elif type(a) is not list and type(b) is list:
            vectorized_result = []
            for element in b:
                vectorized_result.append(
                    vectorized_evaluation(a, element, function, pre_function)
                )
            return vectorized_result

        raise Exception


def single_vectorized_evaluation(a, function, pre_function=None):

    try:
        if pre_function is not None:
            if type(a) is list:
                a = [apply_safe(pre_function, x) if type(x) is not list else x for x in a]
            else:
                a = apply_safe(pre_function, a)

        if type(a) is list:
            vectorized_result = []
            for element in a:
                vectorized_result.append(
                    single_vectorized_evaluation(element, function, pre_function)
                )

            return vectorized_result

        return apply_safe(function, a)
    except:
        if type(a) is list:
            vectorized_result = []
            for element in a:
                vectorized_result.append(
                    single_vectorized_evaluation(element, function, pre_function)
                )
            return vectorized_result

        raise Exception

# Vectorized aggregation
# The "function" argument takes a function(accumulator, value), where:
#   * accumulator is the result of previously aggregated values
#   * value is the current value to aggregate
# 
# The accumulator value is the starting value of the aggregation, usually
# it's a neutral value.
# If not provided, the starting point will be the first value to pass the
# pre_function check without an exception been raised
def vectorized_aggregator(a, function, pre_function=None, accumulator=None):
    result = accumulator
    sublists = []
    values = []

    if pre_function is None:
        pre_function = lambda a: a

    if type(a) is not list:
        a = [a]

    for i in a:
        if type(i) is list:
            sublists.append(i)
        else:
            try:
                i = pre_function(i)
                if result is None:
                    result = i
                else:
                    values.append(i)
            except:
                pass

    for i in values:
        try:
            result = function(result, i)
        except:
            pass

    if len(sublists):
        subresults = [vectorized_aggregator(i, function, pre_function, accumulator) for i in sublists]

        if len(values):
            result = [result] + subresults
        else:
            result = subresults

    return result
