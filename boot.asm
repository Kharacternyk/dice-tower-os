format binary

include 'constants.inc'
include 'macro.inc'

; Print the greeting and the instructions.
    xor si, si
    mov ah, 0xe
    get al, greeting

@@: int 0x10
    inc si
    get al, greeting+si
    cmp al, 0
    jne @b

; A blank line (to be eye candy).
    mov al, lf
    mov ah, 0xe
    int 0x10

    mov al, cr
    int 0x10

; Seed PRNG with the system time.
    xor ah, ah
    int 0x1a
    put prngState, dx

ioLoop:
; Zero out the count of dice we've already rolled in this iteration.
    xor bl, bl

; Get the count of dice.
; Only one keystroke is read.
    xor ah, ah
    int 0x16

; If a space is received, do not alter the dice count.
    cmp al, 32
    je @f

; Otherwise try to parse a number.
    sub al, 49
    cmp al, 9
    ja ioLoop
    inc al
    put diceCount, al

; Print the prompt.
@@: mov al, lf
    mov ah, 0xe
    int 0x10
    int 0x10

    mov al, cr
    int 0x10

    mov al, '>'
    int 0x10

    mov al, ' '
    int 0x10
; Zero out the total score.
    put totalScore, 0

prngLoop:
; Setup for the roll.
    get ax, prngState
    mov dx, ax

; The PRNG itself.
; The 16-bit xorshift algorithm.
    shl dx, 7
    xor ax, dx
    mov dx, ax

    shr dx, 9
    xor ax, dx
    mov dx, ax

    shl dx, 8
    xor ax, dx

; Save the state.
    put prngState, ax

; Get reminder by 6.
    shr ax, 8
    mov cl, 6
    div cl
    mov al, ah
    inc al
    add byte [totalScore+base], al

; Store the score
    movzx si, bl
    put si+scores, al

; Print the score.
    add al, 48
    mov ah, 0xe
    int 0x10

; Print a space.
    mov al, ' '
    mov ah, 0xe
    int 0x10

; Check whether we've rolled all dice.
    inc bl
    cmp bl, [diceCount+base]
    jnb @f

    jmp prngLoop

; We have rolled all dice.
; Print the total score.
@@: mov ah, 0xe
    mov al, ':'
    int 0x10

; Two digits are supported as for now.
; Should be enough since we allow only 9 dices or less.
; 6*9 < 100
    mov cl, 10
    xor ah, ah
    get al, totalScore
    div cl

    mov cl, ah
    add cl, 48
    mov dl, al
    add dl, 48

    mov ah, 0xe
    mov al, dl
    cmp al, '0'
    je @f
    int 0x10
@@: mov al, cl
    int 0x10

; Print the visualization.
    mov ah, 0xe
    xor bh, bh

macro fill5cell {
    xor si, si
@@: mov al, b
    times 5 int 0x10
    mov al, ' '
    int 0x10
    inc si
    movzx bx, [diceCount+base]
    cmp si, bx
    jl @b
}
macro newLine {
    mov al, lf
    int 0x10
    mov al, cr
    int 0x10
}
    newLine
    newLine
    fill5cell
    newLine

    xor bl, bl

    visualLoop:
        movzx si, bl
        imul si, si, 6*3
        add si, texture

        xor cl, cl
    @@: movzx di, cl
        movzx di, [scores+di+base]
        dec di
        imul di, di, 3
        add di, base
        add di, si

        mov al, b
        int 0x10
        mov al, [di]
        int 0x10
        mov al, [di+1]
        int 0x10
        mov al, [di+2]
        int 0x10
        mov al, b
        int 0x10
        mov al, ' '
        int 0x10

        inc cl
        cmp cl, [diceCount+base]
        jl @b

        newLine
        inc bl
        cmp bl, 3
        jl visualLoop

    fill5cell

    jmp ioLoop

; Data.
scores      rb 9
prngState   rw 1
totalScore  rb 1
diceCount   rb 1

greeting    db \
    "DICE TOWER OS",lf,lf,cr, \
    "Number keys change the count of dice. Space rolls.",lf,cr,0

texture  db b,b,b, b,b,s, b,b,s, s,b,s, s,b,s, s,b,s, \
            b,s,b, b,b,b, b,s,b, b,b,b, b,s,b, s,b,s, \
            b,b,b, s,b,b, s,b,b, s,b,s, s,b,s, s,b,s

; Magic.
rb 510-$
dw 0xaa55
