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
mov [diceCount], al

; Print the count of dice.
; That's enough for today.
; Remove later.
mov ah, 0xe
add al, 48
int 0x10

jmp $

; Data.
diceCount rb 1
greeting  db "DICE TOWER",lf,cr,"Dice count:",lf,cr

; Magic.
rb 510-$
dw 0xaa55