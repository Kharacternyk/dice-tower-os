macro put destination*, source* {
    mov [destination+base], source
}

macro get destination*, source* {
    mov destination, [source+base]
}