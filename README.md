# Cliculator

A simple CLI calculator written in x86_64 Assembly (NASM) for Linux.

## Features

- `+` add
- `-` subtract
- `*` multiply
- `/` divide
- `^` power
- `()` brackets
- `!` exit

Integer arithmetic only. Basic expression and overflow error handling included.

## Build & Run

Using the provided script:

```bash
./run.sh
````

Or manually:

```bash
nasm -f elf64 main.asm -g
ld -m elf_x86_64 main.o -o main
./main
```

## Example

```text
-> 2 + 3
5
-> 2 * (4 + 1)
10
-> !
Thank you for using cliculator
```

## Project Structure

```
run.sh     # Build and run script
main.asm   # Calculator logic
io.asm     # Input/output utilities
```

Linux x86_64 only.
