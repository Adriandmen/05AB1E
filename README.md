# 05AB1E
A new (experimental) golfing language


For information about all the commands, goto _Info.txt_

*Sample programs:*

---------


Prints all prime numbers starting from 2:

    0[>Dpi=}]

---------

Prints the n-th Fibonacci number (0-indexed):
    
    1$<FDr+}

    
---------

*Huh wat lol?:*

A special feature from 05AB1E is that it doesn't necessarily have to take input by calling the input function.
For example. The `+` function adds up the last two items in the stack. Calling this function on an empty stack would ask for input twice, and uses these for the `+` function. This also applies to function:

Determines whether the number is prime or not:

    P
    
Another special feature is the `$` command, which is commonly used for sequences (as you can see in the Fibonacci program). This first pushes the number `1` and then pushes the user input.

---------

Note that this is an unstable language, with a lot of bugs. If you find any, or have any suggestions, feel free to contact me :)
