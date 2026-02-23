


global _start
global token_stream
global ts_pos
default rel

section .bss
buffer      resb 16384
token_buf   resb 2048

token_stream   resb 65536
ts_pos         resq 1
out_fd  resq 1

; ===== SYMBOL TABLE =====

MAX_IDS     equ 512
MAX_ID_LEN  equ 128

sym_count   resq 1
sym_table   resb MAX_IDS * MAX_ID_LEN

section .data
filename    db "input.os",0

; ===== ошибки =====

err_unknown     db "LEXICAL ERROR: unknown symbol",10
len_err_unknown equ $-err_unknown

err_string      db "LEXICAL ERROR: unterminated string",10
len_err_string  equ $-err_string

err_comment     db "LEXICAL ERROR: unterminated comment",10
len_err_comment equ $-err_comment

err_date        db "LEXICAL ERROR: unterminated date literal",10
len_err_date    equ $-err_date

err_number     db "LEXICAL ERROR: invalid number format",10
len_err_number equ $-err_number



; ===== типы токенов =====
t_id    db "<ID: "     ; 5
l_id    equ $-t_id

t_kw    db "<KW: "
l_kw    equ $-t_kw

t_num   db "<NUM: "
l_num   equ $-t_num

t_str   db "<STR: "
l_str   equ $-t_str

t_op    db "<OP: "
l_op    equ $-t_op

t_sep   db "<SEP: "
l_sep   equ $-t_sep

t_dir   db "<DIR: "
l_dir   equ $-t_dir

t_pp    db "<PP: "
l_pp    equ $-t_pp

suffix  db ">",10
l_suf   equ $-suffix

t_date  db "<DATE: "
l_date  equ $-t_date


; ===== КЛЮЧЕВЫЕ СЛОВА =====

kw_esli:
    db 0xD0,0x95,0xD1,0x81,0xD0,0xBB,0xD0,0xB8
len_kw_esli equ $-kw_esli

kw_togda:
    db 0xD0,0xA2,0xD0,0xBE,0xD0,0xB3,0xD0,0xB4,0xD0,0xB0
len_kw_togda equ $-kw_togda

kw_inache:
    db 0xD0,0x98,0xD0,0xBD,0xD0,0xB0,0xD1,0x87,0xD0,0xB5
len_kw_inache equ $-kw_inache

kw_konec_esli:
    db 0xD0,0x9A,0xD0,0xBE,0xD0,0xBD,0xD0,0xB5,0xD1,0x86
    db 0xD0,0x95,0xD1,0x81,0xD0,0xBB,0xD0,0xB8
len_kw_konec_esli equ $-kw_konec_esli

kw_istina:
    db 0xD0,0x98,0xD1,0x81,0xD1,0x82,0xD0,0xB8,0xD0,0xBD,0xD0,0xB0
len_kw_istina equ $-kw_istina

kw_lozh:
    db 0xD0,0x9B,0xD0,0xBE,0xD0,0xB6,0xD1,0x8C
len_kw_lozh equ $-kw_lozh

kw_neopr:
    db 0xD0,0x9D,0xD0,0xB5,0xD0,0xBE,0xD0,0xBF,0xD1,0x80
    db 0xD0,0xB5,0xD0,0xB4,0xD0,0xB5,0xD0,0xBB,0xD0,0xB5
    db 0xD0,0xBD,0xD0,0xBE
len_kw_neopr equ $-kw_neopr

kw_i:
    db 0xD0,0x98
len_kw_i equ $-kw_i

kw_ili:
    db 0xD0,0x98,0xD0,0xBB,0xD0,0xB8
len_kw_ili equ $-kw_ili

kw_ne:
    db 0xD0,0x9D,0xD0,0xB5
len_kw_ne equ $-kw_ne

kw_inache_esli:
    db 0xD0,0x98,0xD0,0xBD,0xD0,0xB0,0xD1,0x87,0xD0,0xB5
    db 0xD0,0x95,0xD1,0x81,0xD0,0xBB,0xD0,0xB8
len_kw_inache_esli equ $-kw_inache_esli

kw_dlya:
    db 0xD0,0x94,0xD0,0xBB,0xD1,0x8F
len_kw_dlya equ $-kw_dlya

kw_po:
    db 0xD0,0x9F,0xD0,0xBE
len_kw_po equ $-kw_po

kw_cikl:
    db 0xD0,0xA6,0xD0,0xB8,0xD0,0xBA,0xD0,0xBB
len_kw_cikl equ $-kw_cikl

kw_konec_cikla:
    db 0xD0,0x9A,0xD0,0xBE,0xD0,0xBD,0xD0,0xB5,0xD1,0x86
    db 0xD0,0xA6,0xD0,0xB8,0xD0,0xBA,0xD0,0xBB,0xD0,0xB0
len_kw_konec_cikla equ $-kw_konec_cikla

kw_poka:
    db 0xD0,0x9F,0xD0,0xBE,0xD0,0xBA,0xD0,0xB0
len_kw_poka equ $-kw_poka

kw_prervat:
    db 0xD0,0x9F,0xD1,0x80,0xD0,0xB5,0xD1,0x80,0xD0,0xB2
    db 0xD0,0xB0,0xD1,0x82,0xD1,0x8C
len_kw_prervat equ $-kw_prervat

kw_vozvrat:
    db 0xD0,0x92,0xD0,0xBE,0xD0,0xB7,0xD0,0xB2,0xD1,0x80
    db 0xD0,0xB0,0xD1,0x82
len_kw_vozvrat equ $-kw_vozvrat

kw_funkciya:
    db 0xD0,0xA4,0xD1,0x83,0xD0,0xBD,0xD0,0xBA,0xD1,0x86
    db 0xD0,0xB8,0xD1,0x8F
len_kw_funkciya equ $-kw_funkciya

kw_konec_funkcii:
    db 0xD0,0x9A,0xD0,0xBE,0xD0,0xBD,0xD0,0xB5,0xD1,0x86
    db 0xD0,0xA4,0xD1,0x83,0xD0,0xBD,0xD0,0xBA,0xD1,0x86
    db 0xD0,0xB8,0xD0,0xB8
len_kw_konec_funkcii equ $-kw_konec_funkcii

kw_novyi:
    db 0xD0,0x9D,0xD0,0xBE,0xD0,0xB2,0xD1,0x8B,0xD0,0xB9
len_kw_novyi equ $-kw_novyi

kw_kazhdogo:
    db 0xD0,0x9A,0xD0,0xB0,0xD0,0xB6,0xD0,0xB4,0xD0,0xBE
    db 0xD0,0xB3,0xD0,0xBE
len_kw_kazhdogo equ $-kw_kazhdogo

kw_iz:
    db 0xD0,0x98,0xD0,0xB7
len_kw_iz equ $-kw_iz

kw_znach:
    db 0xD0,0x97,0xD0,0xBD,0xD0,0xB0,0xD1,0x87
len_kw_znach equ $-kw_znach

kw_massiv:
    db 0xD0,0x9C,0xD0,0xB0,0xD1,0x81,0xD1,0x81,0xD0,0xB8,0xD0,0xB2
len_kw_massiv equ $-kw_massiv

kw_struktura:
    db 0xD0,0xA1,0xD1,0x82,0xD1,0x80,0xD1,0x83,0xD0,0xBA
    db 0xD1,0x82,0xD1,0x83,0xD1,0x80,0xD0,0xB0
len_kw_struktura equ $-kw_struktura

kw_soobshit:
    db 0xD0,0xA1,0xD0,0xBE,0xD0,0xBE,0xD0,0xB1
    db 0xD1,0x89,0xD0,0xB8,0xD1,0x82,0xD1,0x8C
len_kw_soobshit equ $-kw_soobshit

kw_procedura:
    db 0xD0,0x9F,0xD1,0x80,0xD0,0xBE,0xD1,0x86
    db 0xD0,0xB5,0xD0,0xB4,0xD1,0x83,0xD1,0x80
    db 0xD0,0xB0
len_kw_procedura equ $-kw_procedura

kw_konec_procedury:
    db 0xD0,0x9A,0xD0,0xBE,0xD0,0xBD,0xD0,0xB5,0xD1,0x86
    db 0xD0,0x9F,0xD1,0x80,0xD0,0xBE,0xD1,0x86
    db 0xD0,0xB5,0xD0,0xB4,0xD1,0x83,0xD1,0x80
    db 0xD1,0x8B
len_kw_konec_procedury equ $-kw_konec_procedury

kw_popytka:
    db 0xD0,0x9F,0xD0,0xBE,0xD0,0xBF,0xD1,0x8B
    db 0xD1,0x82,0xD0,0xBA,0xD0,0xB0
len_kw_popytka equ $-kw_popytka

kw_iskl:
    db 0xD0,0x98,0xD1,0x81,0xD0,0xBA,0xD0,0xBB
    db 0xD1,0x8E,0xD1,0x87,0xD0,0xB5,0xD0,0xBD
    db 0xD0,0xB8,0xD0,0xB5
len_kw_iskl equ $-kw_iskl

kw_konec_popytki:
    db 0xD0,0x9A,0xD0,0xBE,0xD0,0xBD,0xD0,0xB5,0xD1,0x86
    db 0xD0,0x9F,0xD0,0xBE,0xD0,0xBF,0xD1,0x8B
    db 0xD1,0x82,0xD0,0xBA,0xD0,0xB8
len_kw_konec_popytki equ $-kw_konec_popytki

kw_perem:
    db 0xD0,0x9F,0xD0,0xB5,0xD1,0x80,0xD0,0xB5,0xD0,0xBC
len_kw_perem equ $-kw_perem

kw_export:
    db 0xD0,0xAD,0xD0,0xBA,0xD1,0x81,0xD0,0xBF
    db 0xD0,0xBE,0xD1,0x80,0xD1,0x82
len_kw_export equ $-kw_export

kw_prodolzhit:
    db 0xD0,0x9F,0xD1,0x80,0xD0,0xBE,0xD0,0xB4
    db 0xD0,0xBE,0xD0,0xBB,0xD0,0xB6
    db 0xD0,0xB8,0xD1,0x82,0xD1,0x8C
len_kw_prodolzhit equ $-kw_prodolzhit

kw_vozvrat_znach:
    db 0xD0,0x92,0xD0,0xBE,0xD0,0xB7,0xD0,0xB2
    db 0xD1,0x80,0xD0,0xB0,0xD1,0x82
    db 0xD0,0x97,0xD0,0xBD,0xD0,0xB0,0xD1,0x87
    db 0xD0,0xB5,0xD0,0xBD,0xD0,0xB8,0xD1,0x8F
len_kw_vozvrat_znach equ $-kw_vozvrat_znach


; ===== ТАБЛИЦА =====

kw_table:
    dq kw_esli, len_kw_esli
    dq kw_togda, len_kw_togda
    dq kw_inache, len_kw_inache
    dq kw_konec_esli, len_kw_konec_esli
    dq kw_istina, len_kw_istina
    dq kw_lozh, len_kw_lozh
    dq kw_neopr, len_kw_neopr
    dq kw_i, len_kw_i
    dq kw_ili, len_kw_ili
    dq kw_ne, len_kw_ne
	dq kw_inache_esli, len_kw_inache_esli
    dq kw_dlya, len_kw_dlya
    dq kw_po, len_kw_po
    dq kw_cikl, len_kw_cikl
    dq kw_konec_cikla, len_kw_konec_cikla
    dq kw_poka, len_kw_poka
    dq kw_prervat, len_kw_prervat
    dq kw_vozvrat, len_kw_vozvrat
    dq kw_funkciya, len_kw_funkciya
    dq kw_konec_funkcii, len_kw_konec_funkcii
    dq kw_novyi, len_kw_novyi
    dq kw_kazhdogo, len_kw_kazhdogo
    dq kw_iz, len_kw_iz
	dq kw_znach, len_kw_znach
    dq kw_massiv, len_kw_massiv
    dq kw_struktura, len_kw_struktura
    dq kw_soobshit, len_kw_soobshit
    dq kw_procedura, len_kw_procedura
    dq kw_konec_procedury, len_kw_konec_procedury
    dq kw_popytka, len_kw_popytka
    dq kw_iskl, len_kw_iskl
    dq kw_konec_popytki, len_kw_konec_popytki
    dq kw_perem, len_kw_perem
    dq kw_export, len_kw_export
    dq kw_prodolzhit, len_kw_prodolzhit
    dq kw_vozvrat_znach, len_kw_vozvrat_znach

    dq 0,0

section .text

_start:

; open
    mov rax,2
    mov rdi,filename
    xor rsi,rsi
    syscall
    mov r12,rax

; read
    mov rax,0
    mov rdi,r12
    mov rsi,buffer
    mov rdx,16384
    syscall
    mov r13,rax

    xor r14,r14 
    mov qword [ts_pos],0

    mov qword [sym_count],0

; ======================
; ОСНОВНОЙ ЦИКЛ
; ======================

main_loop:
    cmp r14,r13
    jge exit

    mov al,[buffer+r14]

; whitespace
    cmp al,' '
    je next
    cmp al,10
    je next
    cmp al,9
    je next

; // комментарий
    cmp al,'/'
    jne check_block
    cmp byte [buffer+r14+1],'/'
    je comment_line

check_block:
    cmp al,'/'
    jne check_string
    cmp byte [buffer+r14+1],'*'
    je comment_block

; строка
check_string:
    cmp al,'"'
    je state_string

; директива &
    cmp al,'&'
    je state_directive

; препроцессор #
    cmp al,'#'
    je state_preproc

; дата

    cmp al,39
    je state_date

; число
    cmp al,'0'
    jl check_id
    cmp al,'9'
    jle state_number

check_id:
; UTF-8 или латиница
    cmp al,'A'
    jl check_lower_main
    cmp al,'Z'
    jle state_identifier

    check_lower_main:
    cmp al,'a'
    jl check_utf
    cmp al,'z'
    jle state_identifier


check_utf:
    cmp al,0xD0
    jl check_op
    cmp al,0xD1
    jle state_identifier

check_op:
; операторы
    cmp al,'>'
    je state_operator
    cmp al,'<'
    je state_operator
    cmp al,'='
    je state_operator
    cmp al,'+'
    je state_operator
    cmp al,'-'
    je state_operator
    cmp al,'*'
    je state_operator
    cmp al,'/'
    je state_operator

; разделители
    cmp al,'('
    je state_sep
    cmp al,')'
    je state_sep
    cmp al,';'
    je state_sep
    cmp al,','
    je state_sep
    cmp al,'.'
    je state_sep
    cmp al,'['
    je state_sep
    cmp al,']'
    je state_sep

; если дошли сюда — символ не распознан
    mov rsi,err_unknown
    mov rdx,len_err_unknown
    call print_error

next:
    inc r14
    jmp main_loop

; ======================
; COMMENT LINE
; ======================

comment_line:
    add r14,2
cloop:
    cmp r14,r13
    jge main_loop
    cmp byte [buffer+r14],10
    je main_loop
    inc r14
    jmp cloop

; ======================
; COMMENT BLOCK
; ======================

comment_block:
    add r14,2
cb_loop:
    cmp r14,r13
    jge comment_error
    cmp byte [buffer+r14],'*'
    jne cb_next
    cmp byte [buffer+r14+1],'/'
    je cb_end
cb_next:
    inc r14
    jmp cb_loop
cb_end:
    add r14,2
    jmp main_loop

comment_error:
    mov rsi,err_comment
    mov rdx,len_err_comment
    call print_error


; ======================
; IDENTIFIER
; ======================

state_identifier:
    xor rcx,rcx

id_loop:
    cmp r14,r13
    jge id_done

    mov al,[buffer+r14]

; цифры
    cmp al,'0'
    jl check_upper
    cmp al,'9'
    jle id_copy

check_upper:
; A-Z
    cmp al,'A'
    jl check_lower
    cmp al,'Z'
    jle id_copy

check_lower:
; a-z
    cmp al,'a'
    jl id_utf
    cmp al,'z'
    jle id_copy

id_utf:
; UTF-8 кириллица
    cmp al,0xD0
    jl id_done
    cmp al,0xD1
    jg id_done

    mov bl,[buffer+r14]
    mov [token_buf+rcx],bl
    inc rcx
    inc r14
    mov bl,[buffer+r14]
    mov [token_buf+rcx],bl
    inc rcx
    inc r14
    jmp id_loop

id_copy:
    mov [token_buf+rcx],al
    inc rcx
    inc r14
    jmp id_loop

id_done:
    cmp rcx,0
    je main_loop
    call check_keyword
    jmp main_loop


; ======================
; DATE
; ======================

state_date:
    xor rcx,rcx
    inc r14

date_loop:
    cmp r14,r13
    jge date_error

    mov al,[buffer+r14]
    cmp al,39
    je date_done

    mov [token_buf+rcx],al
    inc rcx
    inc r14
    jmp date_loop

date_done:
    inc r14
    mov rsi,t_date
    mov rdx,l_date
    call print_token
    jmp main_loop

date_error:
    mov rsi,err_date
    mov rdx,len_err_date
    call print_error


; ======================
; NUMBER (с экспонентой)
; ======================

state_number:
    xor rcx,rcx        ; индекс token_buf
    xor r15,r15        ; была ли точка
    xor r8,r8          ; была ли экспонента

num_loop:
    cmp r14,r13
    jge num_done

    mov al,[buffer+r14]

    ; ---------- ТОЧКА ----------
    cmp al,'.'
    jne check_e

    cmp r15,1
    je number_error        ; вторая точка -> ошибка

    cmp r8,1
    je number_error        ; точка после E запрещена

    mov r15,1

    mov [token_buf+rcx],al
    inc rcx
    inc r14

    ; после точки обязана быть цифра
    cmp r14,r13
    jge number_error

    mov al,[buffer+r14]
    cmp al,'0'
    jl number_error
    cmp al,'9'
    jg number_error

    jmp num_loop


; ---------- ЭКСПОНЕНТА ----------
check_e:
    cmp al,'E'
    je exp_part
    cmp al,'e'
    je exp_part

    ; ---------- ЦИФРЫ ----------
    cmp al,'0'
    jl num_done
    cmp al,'9'
    jg num_done

    mov [token_buf+rcx],al
    inc rcx
    inc r14
    jmp num_loop


exp_part:
    cmp r8,1
    je number_error        ; вторая экспонента

    mov r8,1

    mov [token_buf+rcx],al
    inc rcx
    inc r14

    cmp r14,r13
    jge number_error       ; ничего после E

    mov al,[buffer+r14]

    ; знак?
    cmp al,'+'
    je exp_sign
    cmp al,'-'
    je exp_sign

    ; если не знак — должна быть цифра
    cmp al,'0'
    jl number_error
    cmp al,'9'
    jg number_error

    jmp num_loop


exp_sign:
    mov [token_buf+rcx],al
    inc rcx
    inc r14

    cmp r14,r13
    jge number_error

    mov al,[buffer+r14]
    cmp al,'0'
    jl number_error
    cmp al,'9'
    jg number_error

    jmp num_loop


; ---------- УСПЕШНО ----------
num_done:
    mov rsi,t_num
    mov rdx,l_num
    call print_token
    jmp main_loop


; ---------- ОШИБКА ----------
number_error:
    mov rsi,err_number
    mov rdx,len_err_number
    call print_error

; ======================
; STRING
; ======================

state_string:
    xor rcx,rcx
    inc r14
str_loop:
    cmp r14,r13
    jge string_error
    mov al,[buffer+r14]
    cmp al,'"'
    je str_check
    mov [token_buf+rcx],al
    inc rcx
    inc r14
    jmp str_loop

str_check:
    cmp byte [buffer+r14+1],'"'
    jne str_done
    mov byte [token_buf+rcx],'"'
    inc rcx
    add r14,2
    jmp str_loop

str_done:
    inc r14
    mov rsi,t_str
    mov rdx,l_str
    call print_token
    jmp main_loop

string_error:
    mov rsi,err_string
    mov rdx,len_err_string
    call print_error


; ======================
; OPERATOR
; ======================

state_operator:
    mov al,[buffer+r14]
    mov [token_buf],al
    mov rcx,1

    cmp al,'>'
    je op_gt
    cmp al,'<'
    je op_lt

    inc r14
    mov rsi,t_op
    mov rdx,l_op
    call print_token
    jmp main_loop

op_gt:
    cmp byte [buffer+r14+1],'='
    jne op_simple
    mov byte [token_buf+1],'='
    mov rcx,2
    inc r14
    jmp op_emit

op_lt:
    cmp byte [buffer+r14+1],'='
    je op_lte
    cmp byte [buffer+r14+1],'>'
    je op_ne
    jmp op_simple

op_lte:
    mov byte [token_buf+1],'='
    mov rcx,2
    inc r14
    jmp op_emit

op_ne:
    mov byte [token_buf+1],'>'
    mov rcx,2
    inc r14
    jmp op_emit

op_simple:
    inc r14

op_emit:
    inc r14
    mov rsi,t_op
    mov rdx,l_op
    call print_token
    jmp main_loop


; ======================
; SEPARATOR
; ======================

state_sep:
    mov al,[buffer+r14]
    mov [token_buf],al
    mov rcx,1
    inc r14
    mov rsi,t_sep
    mov rdx,l_sep
    call print_token
    jmp main_loop

; ======================
; DIRECTIVE &
; ======================

state_directive:
    xor rcx,rcx
dir_loop:
    cmp r14,r13
    jge dir_done
    mov al,[buffer+r14]
    cmp al,' '
    je dir_done
    cmp al,10
    je dir_done
    mov [token_buf+rcx],al
    inc rcx
    inc r14
    jmp dir_loop
dir_done:
    mov rsi,t_dir
    mov rdx,l_dir
    call print_token
    jmp main_loop

; ======================
; PREPROCESSOR #
; ======================

state_preproc:
    xor rcx,rcx
pp_loop:
    cmp r14,r13
    jge pp_done
    mov al,[buffer+r14]
    cmp al,' '
    je pp_done
    cmp al,10
    je pp_done
    mov [token_buf+rcx],al
    inc rcx
    inc r14
    jmp pp_loop
pp_done:
    mov rsi,t_pp
    mov rdx,l_pp
    call print_token
    jmp main_loop

; ======================
; CHECK KEYWORD (таблица)
; ======================

check_keyword:
    mov rbx,kw_table
kw_next:
    mov r8,[rbx]
    mov r9,[rbx+8]
    cmp r8,0
    je not_kw
    cmp rcx,r9
    jne kw_skip

    xor r10,r10
kw_cmp:
    cmp r10,rcx
    je is_kw
    mov al,[token_buf+r10]
    mov dl,[r8+r10]
    cmp al,dl
    jne kw_skip
    inc r10
    jmp kw_cmp

kw_skip:
    add rbx,16
    jmp kw_next

is_kw:
    mov rsi,t_kw
    mov rdx,l_kw
    call print_token
    ret

not_kw:
    call get_identifier_id     ; rax = номер ID

    ; конвертация в строку (простая, безопасная)

    mov rbx,rax
    xor rcx,rcx

    ; максимум 3 цифры достаточно
    mov rdx,0
    mov r8,10

conv_loop:
    xor rdx,rdx
    div r8
    add dl,'0'
    mov [token_buf+rcx],dl
    inc rcx
    test rax,rax
    jnz conv_loop

    ; реверс
    mov rsi,0
    mov rdi,rcx
    dec rdi

rev_loop:
    cmp rsi,rdi
    jge rev_done
    mov al,[token_buf+rsi]
    mov bl,[token_buf+rdi]
    mov [token_buf+rsi],bl
    mov [token_buf+rdi],al
    inc rsi
    dec rdi
    jmp rev_loop

rev_done:
    mov rsi,t_id
    mov rdx,l_id
    call print_token
    ret

; =====================================
; GET OR ADD IDENTIFIER
; rcx = длина
; token_buf = имя
; возвращает rax = ID (1..N)
; =====================================

get_identifier_id:
    push rbx
    push rsi
    push rdi
    push r8
    push r9
    push r10

    mov r8,[sym_count]        ; количество ID
    xor r9,r9                 ; индекс = 0

search_loop:
    cmp r9,r8
    jge add_new

    ; адрес текущей строки
    mov rax,r9
    imul rax,MAX_ID_LEN
    lea rsi,[sym_table+rax]

    ; сравниваем строки
    xor r10,r10

cmp_loop:
    cmp r10,rcx
    je check_end
    mov al,[rsi+r10]
    mov bl,[token_buf+r10]
    cmp al,bl
    jne next_id
    inc r10
    jmp cmp_loop

check_end:
    ; если в таблице дальше 0 — значит длина совпала
    cmp byte [rsi+r10],0
    jne next_id

    ; найдено
    mov rax,r9
    inc rax
    jmp done

next_id:
    inc r9
    jmp search_loop

; ---------- добавить новый ----------

add_new:
    mov r9,[sym_count]

    ; если переполнение — просто возвращаем 0
    cmp r9,MAX_IDS
    jge overflow

    mov rax,r9
    imul rax,MAX_ID_LEN
    lea rdi,[sym_table+rax]

    xor r10,r10
copy_loop:
    cmp r10,rcx
    je copy_done
    mov al,[token_buf+r10]
    mov [rdi+r10],al
    inc r10
    jmp copy_loop

copy_done:
    mov byte [rdi+r10],0

    inc r9
    mov [sym_count],r9

    mov rax,r9
    jmp done

overflow:
    xor rax,rax

done:
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rbx
    ret

; ======================
; PRINT
; ======================

print_token:
    push rcx
    push rsi
    push rdx

    mov rbx,[ts_pos]

; ---- копируем префикс (<ID: и т.п.) ----
    mov r8,rdx            ; длина префикса
copy_prefix:
    cmp r8,0
    je copy_token
    mov al,[rsi]
    mov [token_stream+rbx],al
    inc rsi
    inc rbx
    dec r8
    jmp copy_prefix

; ---- копируем сам токен ----
copy_token:
    mov r8,rcx
    mov rsi,token_buf
copy_token_loop:
    cmp r8,0
    je copy_suffix
    mov al,[rsi]
    mov [token_stream+rbx],al
    inc rsi
    inc rbx
    dec r8
    jmp copy_token_loop

; ---- копируем ">\n" ----
copy_suffix:
    mov rsi,suffix
    mov r8,l_suf
copy_suf_loop:
    cmp r8,0
    je done_copy
    mov al,[rsi]
    mov [token_stream+rbx],al
    inc rsi
    inc rbx
    dec r8
    jmp copy_suf_loop

done_copy:
    mov [ts_pos],rbx

    pop rdx
    pop rsi
    pop rcx
    ret
print_error:
    ; записываем ошибку в token_stream
    mov rbx,[ts_pos]
    mov r8,rdx

copy_err:
    cmp r8,0
    je err_written
    mov al,[rsi]
    mov [token_stream+rbx],al
    inc rsi
    inc rbx
    dec r8
    jmp copy_err

err_written:
    mov [ts_pos],rbx

    ; теперь выводим весь поток в консоль
    mov rax,1
    mov rdi,1
    mov rsi,token_stream
    mov rdx,[ts_pos]
    syscall

    ; и только потом завершаем
    mov rax,60
    mov rdi,1
    syscall
exit:
    mov rax,1
    mov rdi,1
    mov rsi,token_stream
    mov rdx,[ts_pos]
    syscall

    mov rax,60
    xor rdi,rdi
    syscall