# OneScriptAsmInterpreter
The interpreter of "1С:Предприятие" language writen on assembly

мда - команда мечты

# Compilation and linking
`nasm -f elf64 lexer.asm -o lexer.o`

`ld lexer.o -o lexer`
