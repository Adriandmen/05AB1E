# Basic data types
<p align="center">Next tutorial: <a href="https://github.com/Adriandmen/05AB1E/blob/master/docs/md-documentation/loops.md">Loops</a></p>

<br>

05AB1E knows the following basic data types:

 - [Integers](#integers)
 - [Strings](#strings)
 - [Lists](#lists)

More complex data types, like floats or complex numbers, are also supported but to a lesser extent.

## Integers

Integers are one of the most important data types in 05AB1E. They are required to do all kinds of mathematical operations. Integers in 05AB1E are easily represented by the numbers `0123456789`. For example, if you want to push the number `45`, you just place `45` in the program. [Try it online!](https://tio.run/##MzBNTDJM/f/fxPT/fwA "05AB1E – Try It Online")

Note that the integers that are pushed in 05AB1E are actually **strings**. This is because integers and numeric strings are **equal types** in 05AB1E. When performing integer operations on the strings, it casts them to integers. When performing string operations on integers, it casts them to strings. Normally, 05AB1E automatically detects when to use strings or integers. When you want to explicitly cast them to strings or ints, you can use `ï` (cast to int) or `§` (cast to string).

For example, the following two programs push _the exact same variable_:

    "001122"
    001122

As you can see, **leading zeroes** are also preserved. To push two different numbers after one another, we just place a no-op in between like this:

    5 6

Now, our stack looks like this `[5, 6]`, for which we can add any mathematical operation. [Try it online!](https://tio.run/##MzBNTDJM/f/fVMFM@/9/AA "05AB1E – Try It Online")

<br>

## Strings

A string is a sequence of characters. The most common method to create a string is using the `"`-quote. This way, we can create any string we would like to make. For example, a `Hello, World!` string could be constructed like this:

    "Hello, World!"

Which is also a full program that outputs `Hello, World!`. [Try it online!](https://tio.run/##MzBNTDJM/f9fySM1JydfRyE8vygnRVHp/38A "05AB1E – Try It Online")

Note that when you have a string at the end of a program, you can leave out the end-quote. This means that the following program is also a valid `Hello, World`-program:

    "Hello, World!

<br>

## Lists

Lists are also very important in 05AB1E. They suppress the use of long for-loops and iterators due to the fact that almost every command _vectorizes_ on lists. There is no possible way to create a list in the middle of the program, simply due to the fact that it is almost always possible to bypass this in a shorter way.

Lists can contain all basic data types and can be inputted as such. To create a list of single-digits, you can use the code snippet `<digits>S`:

    1234S

This leaves `['1', '2', '3', '4']` on the stack. [Try it online!](https://tio.run/##MzBNTDJM/f/f0MjYJPj/fwA "05AB1E – Try It Online") 

Another possiblity is to use the `<string of code points>Ç` snippet. For example, take a look at the following program:

    "abcd"Ç
    
This gives us the following list: `[97, 98, 99, 100]`. [Try it online!](https://tio.run/##MzBNTDJM/f9fKTEpOUXpcPv//wA "05AB1E – Try It Online") There definitely are more ways to make these kind of lists, these are just some examples for inspiration.
