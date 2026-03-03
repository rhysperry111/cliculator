; Define syscall params
%define SYS_READ  0
%define SYS_WRITE 1
%define FD_STDIN  0
%define FD_STDOUT 1

; strlen function
; Takes a pointer to a null-terminated string and returns its length
;  IN: rax:ptr:str
; OUT: rax:int
strlen:
    push    rbx
    mov     rbx, 0
.next:
    cmp     byte[rax], 0x00
    je      .end
    inc     rax
    inc     rbx
    jmp     .next
.end:
    mov     rax, rbx
    pop     rbx
    ret


; strin function
; Reads a string from stdin and stores it as a null-terminated string
;  IN: rax:ptr:str
strin:
    push    rax
    push    rdi
    push    rsi
    push    rcx
    push    rdx

    mov     rdx, 254 ; One less than buffer size to allow for null byte at end of string
    mov     rsi, rax
    mov     rdi, FD_STDIN
    mov     rax, SYS_READ
    syscall

    mov     byte[rsi+rax], 0x00 ; Add null byte to end

    pop     rdx
    pop     rcx
    pop     rsi
    pop     rdi
    pop     rax
    ret


; strout function
; Writes a null-terminated string pointed to by rax to stdout
;  IN: rax:ptr:str
strout:
    push    rax
    push    rdi
    push    rsi
    push    rcx
    push    rdx

    mov     rsi, rax
    call    strlen
    mov     rdx, rax
    mov     rax, SYS_WRITE
    mov     rdi, FD_STDOUT
    syscall

    pop     rdx
    pop     rcx
    pop     rsi
    pop     rdi
    pop     rax
    ret

; intout function
; Writes the integer at rax to stdout
;  IN: rax:int
intout:
    push    rsi
    push    rdx
    push    rcx
    push    rax
    push    0x0A ; Push newline so it will be at end of output
    mov     rcx, 1 ; Counter of how many bytes the output will be

.divAgain:
    inc     rcx
    mov     rdx, 0 ; Clear rdx because it gets messes up division
    mov     rsi, 10
    idiv    rsi
    add     rdx, 48
    push    rdx ; Push ascii equivalent of digit to stack for printing
    cmp     rax, 0
    jnz     .divAgain ; Divide again if there is a remainder

.printAgain:
    dec     rcx
    mov     rax, rsp
    call    strout
    pop     rax
    cmp     rcx, 0
    jnz     .printAgain ; Keep printing till everything popped

    pop     rax
    pop     rcx
    pop     rdx
    pop     rax
    ret
