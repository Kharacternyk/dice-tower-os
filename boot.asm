format binary

BASE = 0x7c00; That's where code is loaded by BIOS.
LF   = 10    ; Line feed.
CR   = 13    ; Carriage return.
B    = 219   ; Full block.
S    = 32    ; Space.

macro _put destination*, source* {
    mov [destination+BASE], source
}

macro _get destination*, source* {
    mov destination, [source+BASE]
}

; Print the greeting and the instructions.
    xor si, si
    mov ah, 0xe
    _get al, greeting

@@: int 0x10
    inc si
    _get al, greeting+si
    cmp al, 0
    jne @b

; A blank line (to be eye candy).
    mov al, LF
    mov ah, 0xe
    int 0x10

    mov al, CR
    int 0x10

; Seed PRNG with the system time.
    xor ah, ah
    int 0x1a
    _put prngState, dx

ioLoop:
; Zero out the count of dice we've already rolled in this iteration.
    xor bl, bl

; Get the count of dice.
; Only one keystroke is read.
    xor ah, ah
    int 0x16

; If a space is received, do not alter the dice count.
    cmp al, S
    je @f

; Otherwise try to parse a number.
    sub al, '1'
    cmp al, 9
    ja ioLoop
    inc al
    _put diceCount, al

; Print the prompt.
@@: mov al, LF
    mov ah, 0xe
    times 2 int 0x10

    mov al, CR
    int 0x10

    mov al, '>'
    times 3 int 0x10

    mov al, S
    int 0x10
; Zero out the total score.
    _put totalScore, 0

prngLoop:
; Setup for the roll.
    _get ax, prngState
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
    _put prngState, ax

; Get reminder by 6.
    shr ax, 8
    mov cl, 6
    div cl
    mov al, ah
    inc al
    add byte [totalScore+BASE], al

; Store the score
    movzx si, bl
    _put si+scores, al

; Print the score.
    add al, '0'
    mov ah, 0xe
    int 0x10

; Print a space.
    mov al, S
    mov ah, 0xe
    int 0x10

; Check whether we've rolled all dice.
    inc bl
    cmp bl, [diceCount+BASE]
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
    _get al, totalScore
    div cl

    mov cl, ah
    add cl, '0'
    mov dl, al
    add dl, '0'

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

macro _fill5cell {
    xor si, si
@@: mov al, B
    times 5 int 0x10
    mov al, S
    int 0x10
    inc si
    movzx bx, [diceCount+BASE]
    cmp si, bx
    jl @b
}
macro _newLine {
    mov al, LF
    int 0x10
    mov al, CR
    int 0x10
}
    _newLine
    _fill5cell
    _newLine

    xor bl, bl

    visualLoop:
        movzx si, bl
        imul si, si, 6*3 ;go to the needed row.
        add si, texture  ;go to the needed texture.

        xor cl, cl
    @@: movzx di, cl
        movzx di, [scores+di+BASE]
        dec di
        imul di, di, 3
        add di, BASE
        add di, si

        mov al, B
        int 0x10
        mov al, [di]
        int 0x10
        mov al, [di+1]
        int 0x10
        mov al, [di+2]
        int 0x10
        mov al, B
        int 0x10
        mov al, S
        int 0x10

        inc cl
        cmp cl, [diceCount+BASE]
        jl @b

        _newLine
        inc bl
        cmp bl, 3
        jl visualLoop

    _fill5cell 
    jmp ioLoop

; Data.
greeting    db \
    LF,LF,"DICE TOWER OS",LF,LF,CR, 0

texture  db B,B,B, B,B,S, B,B,S, S,B,S, S,B,S, S,B,S, \
            B,S,B, B,B,B, B,S,B, B,B,B, B,S,B, S,B,S, \
            B,B,B, S,B,B, S,B,B, S,B,S, S,B,S, S,B,S

; Reserved space.
scores      rb 9
prngState   rw 1
totalScore  rb 1
diceCount   rb 1

; Magic.
rb 510-$
dw 0xaa55
