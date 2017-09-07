# Loops and iterators

<p align="center">Previous tutorial: <a href="https://github.com/Adriandmen/05AB1E/blob/master/docs/md-documentation/basic-data-types.md">Basic data types</a></p>

<br>

Loops are very important to repeat a specific command or a set of commands multiple times. 05AB1E currently has the following loops:

## Current loops and iterators

 - [`F`-loop](#f-loop), ranges from **0** to **n - 1**.
 - [`G`-loop](#g-loop), ranges from **1** to **n - 1**.
 - [`ƒ`-loop](#ƒ-loop), ranges from **0** to **n**.
 - [`[`-loop](#-loop), ranges from **0** to **infinity**. Also known as an infinite loop.
 - [`v`-iterator](#v-iterator), iterates over each element
 - [`µ`-loop](#µ-loop), loops until the counter value equals **n**

--------------

## `F`-loop

- **Arity**: 1 
- **Syntax**: `<num> F <code> }`

| Parameter | Description |
| --------- | ----------- |
| **`<num>`** | An integer or a string representation of an integer |
| **`<code>`** | An 05AB1E code snippet |

The most common loop that is used in 05AB1E. Ranges from **0** to **n - 1** with `N` as the _index variable_. The following example sum:

    4FNO}
    
    4F         # For N in range(0, 4)         --> this will iterate through [0, 1, 2, 3].
      N        #   Push the current index (N) --> N = 0 in the first run, N = 1 in the second, etc.
       O       #   Sum the entire stack
        }      # Close the for loop           --> The code after this will be run as any other normal code.
  
What this will do is sum the following (index) numbers: **0** + **1** + **2** + **3** = 6. [Try it online!](https://tio.run/##MzBNTDJM/f/fxM3Pv/b/fwA "05AB1E – Try It Online")

**Tip**: Whenever the closing bracket is at the end of the file, you can remove the bracket. The EOF acts like an infinite closing bracket.


------------------

## `G`-loop

- **Arity**: 1 
- **Syntax**: `<num> G <code> }`

| Parameter | Description |
| --------- | ----------- |
| **`<num>`** | An integer or a string representation of an integer |
| **`<code>`** | An 05AB1E code snippet |

A loop very similar to the `F`-loop, but starts at **1** rather than 0. Ranges from **1** to **n - 1** with `N` as the _index variable_.

------------------

## `ƒ`-loop

- **Arity**: 1 
- **Syntax**: `<num> ƒ <code> }`

| Parameter | Description |
| --------- | ----------- |
| **`<num>`** | An integer or a string representation of an integer |
| **`<code>`** | An 05AB1E code snippet |

Also a loop very similar to the `F`-loop, but end at **n** rather than n - 1. Ranges from **0** to **n** with `N` as the _index variable_.

------------------

## `[`-loop

- **Arity**: 0
- **Syntax**: `[ <code> ]`

| Parameter | Description |
| --------- | ----------- |
| **`<code>`** | An 05AB1E code snippet |

Also known as an infinite loop. Ranges from **0** till **infinity**. To break out of the loop, you can use the `#` (break if true). This would convert the infinite loop to a loop similar like a while(condition) loop. Uses `N` as the _index variable_.

For example, if we want to print all numbers until `N` is 10, we can do the following:

    [N,N10Q#
    
    [             # Start the infinite loop
     N,           #   Print N with a newline
       N10Q       #   Check if N equals 10
           #      #   If true: break out of the loop

This prints the numbers 0, 1, 2, ..., 9, 10. [Try it online!](https://tio.run/##MzBNTDJM/f8/2k/Hz9AgUPn/fwA "05AB1E – Try It Online")

-------------------

## `v`-iterator

- **Arity**: 1
- **Syntax**: `<object> v <code> }`

| Parameter | Description |
| --------- | ----------- |
| **`<object>`** | An object with type _int_, _str_ or _list_ |
| **`<code>`** | An 05AB1E code snippet |

Iterates through each element/character of the object. Uses `N` as the current _index number_ and `y` as the current _element_. Acts in the same way as the `F`-loop.

For example, if we want to enumerate each character in the string `abcdef` and print it like this: `<char>: <index>`, we can do something like this:

    "abcdef"vy?": "?N,

    "abcdef"               # Push the string 'abcdef' onto the stack
            v              # Iterate through each element in that string and do the following:
             y?            #   Print the current character without a newline
               ": "?       #   Print the string ': ' without a newline
                    N,     #   Print the current index number with a newline

Let's check it out: [Try it online!](https://tio.run/##MzBNTDJM/f9fKTEpOSU1Tams0l7JSkHJ3k/n/38A "05AB1E – Try It Online")

-------------------

## `µ`-loop

- **Arity**: 1
- **Syntax**: `<num> µ <code> }`

| Parameter | Description |
| --------- | ----------- |
| **`<num>`** | An integer or a string representation of an integer |
| **`<code>`** | An 05AB1E code snippet |

Loops until the counter variable reaches the provided `<num>` value.  

The counter variable starts at 0, and can be modified using the following commands:

- `¼`: increments the counter variable
- `½`: pop a, and increments the counter variable if a is true (a == 1)

**Tip:** 05AB1E automatically puts a `½` command at the end of the provided `<code>` if it doesn't contain a counter modifying command

