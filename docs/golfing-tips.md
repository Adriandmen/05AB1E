# 05AB1E Golfing Tips

Common patterns for code golf in 05AB1E. This guide assumes familiarity with the [code page](code-page.md).

## Stack and I/O

- Implicit input: `¼¼` reads two numbers without explicit `¿`
- Implicit output: the top of the stack is printed at end of program — you rarely need explicit print
- `»` joins the stack with newlines and prints — useful when you have multiple values to print

## Number tricks

| Goal | Bytes | Code |
|---|---|---|
| Push 100 | 1 | `т` |
| Push 1000 | 1 | `∞` (actually infinite list — use `®` for 1000) |
| Push 255 | 2 | `žs` |
| Increment | 1 | `>` |
| Decrement | 1 | `<` |
| Negate | 1 | `(` |
| Absolute value | 1 | `Ä` |

## String tricks

- `"abc"` can often be replaced with `"abc` (unclosed string still works)
- `.•...•` compressed string — compresses common word lists
- `S` splits a string to a list of characters cheaper than splitting explicitly

## List tricks

- `ï` convert to int — useful after string operations
- `ê` unique + sort — combines two operations in 1 byte
- `é` sort by length
- `Œ` all sublists (combinatorial explosion, use carefully)
- `ã` cartesian product
- `¨` remove last element (like `pop`)
- `¦` remove first element

## Looping patterns

```
# Standard range loop (0 to n-1):
NF  ← loop body

# Loop with index (0-indexed):
Ni  ← access index inside

# Map over list:
ε...}  ← element-wise map

# Filter:
ʒ...}  ← keep elements where condition is truthy
```

## Conditionals

```
# If/else:
i...ë...}

# Ternary (condition → value1, else value2):
i value1 ë value2 }
```

## Math shortcuts

- `Å½` — halve (same as `2÷`)  
- `n` — square
- `t` — square root
- `Ä` — absolute value
- `±` — bitwise NOT
- `L` — range `[1..n]`
- `ÅN` — nth prime

## Debugging

- `¿` — print without popping (peek)
- Wrap code in `•...•` to test subexpressions
- Use the [online interpreter](https://tio.run/) with 05AB1E selected
