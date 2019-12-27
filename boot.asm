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

; Get the count of dice.
; Only one keystroke is read.
; Understands hex.
    xor ah, ah
    int 0x16

; Print the count of dice.
    mov ah, 0xe
    int 0x10

; Store the count as a number.
    sub al, 48
    put diceCount, al

; A blank line (to be eye candy).
    mov al, lf
    mov ah, 0xe
    int 0x10

    mov al, cr
    int 0x10

; The count of dice we've already rolled in this iteration.
    xor bl, bl

; Seed PRNG with the system time.
    xor ah, ah
    int 0x1a
    put prngState, dx

ioLoop:
; Print the prompt.
    mov al, lf
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
    mov [totalScore+base], 0

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
; Zero out the counter of rolled dice.
@@: xor bl, bl

; Print total score.
    mov ah, 0xe
    mov al, [totalScore+base]
    add al, 48
    int 0x10

; Wait for a keypress to continue.
    xor ah, ah
    int 0x16

    jmp ioLoop

; Data.
prngState  rw 1
totalScore rb 1
diceCount  rb 1
greeting   db \
    "<==DICE TOWER OS==>",lf,lf,cr, \
    "Enter the dice count.",lf,cr, \
    "Then press any key to roll them.", \
    lf,lf,cr,"Dice count:",0

; Magic.
rb 510-$
dw 0xaa55
