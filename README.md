# 05AB1E
A new (experimental) golfing language. If the name **05AB1E** was interpreted as a hexadecimal number and converted to base64, it would result into "Base". I wanted to make a language which has an advantage in base conversion, but now it more of an overall language.

You can try this language out yourself at: [Try it online!](05ab1e.tryitonline.net). This interpreter is provided by @DennisMitchell.

For information about all the commands, go to _Info.txt_


###Sample programs:


Prints all prime numbers starting from 2:

    0[>Dpi=}]

Of course, if this was really golfed, this would be `0[>Dpi=`, since brackets in the end are unnecessary

Prints the n-th Fibonacci number (0-indexed):
    
    1$<FDr+



###Huh wat lol?:

A special feature from 05AB1E is that it doesn't necessarily have to take input by calling the input function.
For example. The `+` function adds up the last two items in the stack. Calling this function on an empty stack would ask for input twice, and uses these for the `+` function. This also applies to function:

Determines whether the number is prime or not:

    p
    
Another special feature is the `$` command, which is commonly used for sequences (as you can see in the Fibonacci program). This first pushes the number `1` and then pushes the user input.

###Note:

Note that this is an unstable language, with a lot of bugs. If you find any, or have any suggestions, feel free to contact me :)
