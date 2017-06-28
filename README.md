<p align="center"><a href="https://github.com/Adriandmen/05AB1E"><img src="https://i.stack.imgur.com/kUDMr.png"/></a></p>
<p align="center"><a href="https://travis-ci.org/Adriandmen/05AB1E"><img src="https://travis-ci.org/Adriandmen/05AB1E.svg?branch=master"/></a></p>
<br>
<br>

## A short introduction

**05AB1E** is a golfing language. If the name **05AB1E** was interpreted as a hexadecimal number and converted to base64, it would result into "Base". I wanted to make a language which has an advantage in base conversion, but now it is more of an overall language.

You can try this language out yourself at: [Try it online!](http://05ab1e.tryitonline.net/). This interpreter is provided by [DennisMitchell](https://github.com/DennisMitchell).

All existing commands can be found at [_Info.txt_](https://github.com/Adriandmen/05AB1E/blob/master/docs/info.txt)

<br>

## So, what exactly is a golfing language?

A golfing language is a language that specializes in [code golf](https://en.wikipedia.org/wiki/Code_golf). That is a kind of programming competition where you strive to achieve the shortest byte count from all the participating languages.

<br>

## What does a program look like?

### The basics

A program in 05AB1E is just like any other program, it is stored in a file and then run with **05AB1E.py**. The python file will interpret the given file as 05AB1E code. A very easy to understand program is:

    "Hello, World!"

Which can be tried [here](http://05ab1e.tryitonline.net/#code=IkhlbGxvLCBXb3JsZCEi&input=). This is a normal `Hello, World!` program. Of course, the last quotation mark is a bit redundant, so we can actually leave that out. The interpreter will **automatically** complete the string. That means that the following program:

    "Hello, World!

is also a valid `Hello, World!` program.

### Stack memory

05AB1E uses a stack memory model. That means that everything will be operated using the stack. For example, if we want to multiply 2 different numbers, let's say **4** and **5**, we can do the following in pseudo-stack language:

    PUSH 4
    PUSH 5
    MULTIPLY

After the first **two** commands, the top two elements of the stack are `4` and `5`. The multiply command _consumes_ two elements and produces one in return. So, after the multiply command, the stack only contains the number `20`. So, how do we do this in 05AB1E?

To push an integer, just place any arbitrary integer in the progam. For example, if we want to push the number **4**, this would be our program:

    4

05AB1E will scan the literal up till no more digits are found and pushes that onto the stack. To push a new number, just add another number after the first number, separated by a no-op (like a space). For example:

    4 15

This pushes the numbers **4** and **15**. To multiply both numbers, just add the multiply command (or any other command from [Info.txt](https://github.com/Adriandmen/05AB1E/blob/master/docs/info.txt)):

    4 15*

You can try that [here](http://05ab1e.tryitonline.net/#code=NCAxNSo&input=). You can see that it outputs `60`.

### Stack memory - part 2

We now have a basic understanding of the stack model, we can continue to what exactly gets printed. Normally, when **nothing** is printed, the top of the stack gets printed. In the following example:

    1 2 3 4 5

only the number **5** gets printed. If something else gets printed before the program terminates, the top of the stack is not printed automatically anymore.

Now you have a basic understanding of how 05AB1E works! Tutorials will be added soon...

<br>

## How do I use it?

05AB1E is originally written in **Python 3**. That means that you need to have Python 3.4 or a later version in order to use this. 05AB1E doesn't make use of any external libraries outside the normal Python package, so Python 3.4 is the _only_ thing you need.

Create a new file where you want to store your program in (like `test.abe`). Normally, an 05AB1E file ends with `.abe`, but any other file extension can also be used. To run it, do the following:

    [path to Python 3] [path to osabie.py] [path to 05AB1E program]
    
For example:

    > python34.exe osabie.py test.abe
    
Or a more official way (whereas `inputs` is a file with all inputs):

    > python34.exe oasbie.py test.abe < inputs
    
If run without the inputs file, the 05AB1E program reads the input from STDIN.

In addition, you can append the following arguments before running the 05AB1E file:

|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Argument&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|Information|
|--------|-----------|
|`-d` or `--debug`|Activates the **debug** flag. After each command is run, an update will be shown to _STDIN_ with the current stack, current command and additionally subprograms for loops, etc.|
|`-s` or `--safe`|Activates the **safe** mode. Web access, file access and commmands that can potentially harm a system will be restricted and skipped while executing the file.|
|`-c` or `--osabie`|Reads the file as a file with a **05AB1E** encoding. If this flag is not activated, the file will be read as a normal **UTF-8** file.|
|`-t` or `--time`|Times the duration of executing the program. Given in seconds.|
|`-e` or `--eval`|Evaluates the given string as 05AB1E code.|
