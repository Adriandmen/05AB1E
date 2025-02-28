<p align="center"><a href="https://github.com/Adriandmen/05AB1E"><img src="https://i.sstatic.net/kUDMr.png"/></a></p>
<p align="center"><a href="https://github.com/Adriandmen/05AB1E/actions/workflows/workflow.yml"><img src="https://github.com/Adriandmen/05AB1E/actions/workflows/workflow.yml/badge.svg"/></a>&nbsp;&nbsp;<a href="https://codecov.io/gh/Adriandmen/05AB1E">
  <img src="https://codecov.io/gh/Adriandmen/05AB1E/branch/master/graph/badge.svg?token=gm5kwyV17u" />
</a></p>
<br>
<br>

## A short introduction

**05AB1E** is a golfing language. If the name **05AB1E** were interpreted as a hexadecimal number and converted to base64, it would result into "Base". I wanted to make a language which has an advantage in base conversion, but now it is more of a general-purpose language. The name 05AB1E can be pronounced in multiple ways, such as '_osabie_', '_osable_' or even '_usable_'.

You can try this language out yourself at: [Try it online!](http://osabie.tryitonline.net/). This interpreter is provided by [DennisMitchell](https://github.com/DennisMitchell).

A reference list containing all the commands/functions can be found at [_Info.txt_](https://github.com/Adriandmen/05AB1E/blob/master/docs/info.txt) or at the [_Commands Wiki page_](https://github.com/Adriandmen/05AB1E/wiki/Commands).

<br>

## What is a golfing language?

A golfing language is a language that specializes in [code golf](https://en.wikipedia.org/wiki/Code_golf). A code golf competition is a competition in which participants strive to achieve to solve the challenge in as few bytes as possible.

<br>

## Installation and execution

05AB1E is written in **Elixir** using the **Mix** build tool, which comes with Elixir.


### Installation

 1. Clone this repository (e.g. with `git clone https://github.com/Adriandmen/05AB1E.git`).
 2. Install **Elixir 1.9.0** or higher using one of the installation options [here](https://elixir-lang.org/install.html).
 3. Install the package manager **Hex** with `mix local.hex`.

### Compilation

 1. Retrieve/update all necessary dependencies using `mix deps.get` (if necessary).
 2. In the terminal, compile the project using `MIX_ENV=prod mix escript.build`. On **Windows** in the command prompt, compile with `set "MIX_ENV=prod" && mix escript.build`.
 
### Execution

After running the `build` command, a compiled binary file `osabie` will be generated. For example, running the file `test.abe` is done by running:
 
    escript osabie test.abe

Normally, an 05AB1E file ends with `.abe`, but any other file extension can also be used.

A more official way of running an 05AB1E program is by storing all the input in an inputs file. For example, if the inputs were to be stored in a file named `inputs`, the following way is the preferred way to run a program:

    escript osabie test.abe < inputs

If run without the inputs file, the 05AB1E program reads the input from the command line.

<br>

## Command-line flags

In addition, you can append the following arguments before running the 05AB1E file:

|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Argument&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|Information|
|--------|-----------|
|`-d` or `--debug`|Activates the **debug** flag. After each command is run, an update will be shown to _STDIN_ with the current command. |
|`--debug-stack` | Activates the **debug** flag and will print the current stack as well after each iteration. |
|`--debug-global-env` | Activates the **debug** flag and will print the global environment as well after each iteration. |
|`--debug-local-env` | Activates the **debug** flag and will print the local environment as well after each iteration. |
|`-c` or `--osabie`|Reads the file as a file with a **05AB1E** encoding. If this flag is not activated, the file will be read as a normal **UTF-8** file.| 
|`-t` or `--time`|Times the duration of executing the program. Given in seconds.|
|`--no-lazy` | Disables lazy evaluation where needed. This is done because lazy evaluation can interfere with the way and order how things are printed. |

**Note** that when debugging, the debug logs can become very weird and cluttered due to tail-call optimization and lazy evaluation.

<br>
  
## A quick tutorial

### The basics

A program in 05AB1E is just like any other program, it is stored in a file and then run with **osabie**. The interpreter will interpret the given file as 05AB1E code. A very easy to understand program is:

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


