format binary

base equ 0x7c00; That's where code is loaded by BIOS.
lf   equ 10    ; Line feed.
cr   equ 13    ; Carriage return.

; Print the greeting and the instructions.
xor si, si
mov ah, 0xe
mov al, byte [greeting+base]

greetingPrintLoop:
    int 0x10
    inc si
    mov al, [greeting+base+si]
    cmp al, 0
    jne greetingPrintLoop

; Get a count of dice.
; Only one keystroke is read.
; Understands hex.
xor ah, ah
int 0x16
sub al, 48
mov [diceCount+base], al

; Seed PRNG with the system time.
xor ah, ah
int 0x1a
mov ax, dx

mainLoop:
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

    push ax

; Get reminder by 6.
    shr ax, 8
    mov cl, 6
    div cl
    mov al, ah

; Print the random char.
    add al, 49
    mov ah, 0xe
    int 0x10

; Wait for the keystroke to continue.
    xor ah, ah
    int 0x16

    pop ax
    mov dx, ax
    jmp mainLoop

; Data.
diceCount rb 1
greeting  db "DICE TOWER",lf,cr,"Dice count:",lf,cr

; Magic.
rb 510-$
dw 0xaa55