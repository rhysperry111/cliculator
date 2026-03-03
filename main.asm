%include 'io.asm'

SECTION	.data
intro       db      "Welcome to cliculator - A cli calculator written in assembly.", 0x0A, 0x0A
            db      "Supported operations are:", 0x0A
            db      "  + add", 0x0A
            db      "  - subtract", 0x0A
            db      "  * multiply", 0x0A
            db      "  / divide", 0x0A
            db      "  ^ raise", 0x0A
            db      "  ! EXIT", 0x0A
            db      "Brackets () can be used to group certain operations in an expression although", 0x0A
            db       "multiplication before/after the brackets is NOT implied.", 0x0A, 0x0A
            db      "An operator not directly preceding or following a number is invalid.", 0x0A
            db      "The program will try its best to catch invalid expressions however behaviour in", 0x0A
            db      "such cases is ultimately undefined.", 0x0A, 0x00
outro       db      "Thank you for using cliculator", 0x0A, 0x00
prompt		db		"-> ", 0x00
experr		db		"EXPRESSION ERROR", 0x0A, 0x00
interr      db      "INTEGER ERROR", 0x0A, 0x00

SECTION	.bss
buffer		resb	255 ; Buffer to store data being input/output
firstnum    resq    1   ; Stores the first operand (which doubles as the total) while parsing
secondnum   resq    1   ; Stores the second operand as it is being parsed
nextop      resq    1   ; A pointer to the next mathematical operation that needs to be executed
brackets    resq    1   ; Simple counter to ensure brackets are matched

SECTION	.text
global	_start

_start:
    ; Show introduction
    mov     rax, intro
    call    strout
main:
    ; Make sure values are initialised correctly
    mov     qword[nextop], nothing
    mov     qword[secondnum], 0
    mov     qword[brackets], 0
    ; Show prompt and get input
    mov     rax, prompt
    call    strout
    mov     rax, buffer
    call    strin
    dec     rax
parse:
    ; Move to next character and get value
    inc     rax
    mov     rbx, 0x00
    mov     bl, byte[rax]
    ; Check for special characters and jump to respective setter functions
    cmp     rbx, '!'
    je      end
    cmp     rbx, 0x00
    je      output
    cmp     rbx, ' '
    je      parse
    cmp     rbx, 0x0A
    je      parse
    cmp     rbx, '+'
    je      setplus
    cmp     rbx, '-'
    je      setminus
    cmp     rbx, '*'
    je      setmultiply
    cmp     rbx, '/'
    je      setdivide
    cmp     rbx, '^'
    je      setraise
    cmp     rbx, '('
    je      setopenbracket
    cmp     rbx, ')'
    je      setclosebracket
    ; If not number or special character show error
    cmp     rbx, '0'
    jl      experror
    cmp     rbx, '9'
    jg      experror
    ; Parse as number by (denary) shifting secondnum left and adding current digit
    sub     rbx, '0'
    mov     rdx, 10
    push    rax
    mov     rax, qword[secondnum]
    mul     rdx
    jc      interror
    add     rax, rbx
    jc      interror
    mov     qword[secondnum], rax
    pop     rax
    jmp     parse


; Setter functions call the previous operation and set themselves as next
setplus:
    call    [nextop]
    mov     qword[nextop], plus
    jmp     parse

setminus:
    call    [nextop]
    mov     qword[nextop], minus
    jmp     parse

setmultiply:
    call    [nextop]
    mov     qword[nextop], multiply
    jmp     parse

setdivide:
    call    [nextop]
    mov     qword[nextop], divide
    jmp     parse

setraise:
    call    [nextop]
    mov     qword[nextop], raise
    jmp     parse

; Brackets don't have any associated operation but they need to push/pop values from stack
setopenbracket:
    inc     qword[brackets]
    push    qword[nextop]
    push    qword[firstnum]
    mov     qword[nextop], nothing
    jmp     parse

setclosebracket:
    mov     rdx, qword[brackets]
    cmp     rdx, 0
    je      experror
    dec     qword[brackets]
    call    [nextop]
    mov     rdx, qword[firstnum]
    mov     qword[secondnum], rdx
    pop     qword[firstnum]
    pop     qword[nextop]
    jmp     parse


; Operations do an operation on firstnum with secondnum as a parameter, then clear secondnum
nothing:
    mov     rdx, qword[secondnum]
    mov     qword[firstnum], rdx
    mov     qword[secondnum], 0
    ret

plus:
    mov     rdx, qword[secondnum]
    add     qword[firstnum], rdx
    jc      interror
    mov     qword[secondnum], 0
    ret

minus:
    mov     rdx, qword[secondnum]
    sub     qword[firstnum], rdx
    jc      interror
    mov     qword[secondnum], 0
    ret

multiply:
    push    rax
    mov     rax, qword[firstnum]
    mul     qword[secondnum]
    jc      interror
    mov     qword[firstnum], rax
    mov     qword[secondnum], 0
    pop     rax
    ret

divide:
    push    rax
    mov     rcx, qword[secondnum]
    cmp     rcx, 0 ; Clear rcx because it messes with division
    jz      interror
    mov     rax, qword[firstnum]
    mov     rdx, 0
    div     rcx
    jc      interror
    mov     qword[firstnum], rax
    mov     qword[secondnum], 0
    pop     rax
    ret

raise:
    push    rax
    mov     rbx, qword[secondnum]
    mov     rax, qword[firstnum]
    mov     rcx, rax
    cmp     qword[secondnum], 1
    je      .skip ; Raising to power one doesn't do anything
    cmp     qword[secondnum], 0
    je      .special ; Raising to zero must always result in 1
.mult:
    dec     rbx
    mul     rcx
    jc      interror
    cmp     rbx, 1
    jg      .mult
.skip:
    mov     qword[firstnum], rax
    mov     qword[secondnum], 0
    pop     rax
    ret
.special:
    mov     qword[firstnum], 1
    mov     qword[secondnum], 0
    pop     rax
    ret

; Expression error handler
experror:
    mov     eax, experr
    call    strout
    jmp     main

; Overlow error handler
interror:
    mov     eax, interr
    call    strout
    jmp     main


; Output handler
output:
    mov     rdx, qword[brackets]
    cmp     rdx, 0
    jne     experror
    call    [nextop]
    mov     rax, qword[firstnum]
    call    intout
    jmp     main


; Program exit
end:
    mov     rax, outro
    call    strout
    mov     rax, 0x3c
    mov     rdi, 0
    syscall