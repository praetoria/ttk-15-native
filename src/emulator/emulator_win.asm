[section .data]
[BITS 64]
    instr: dq NOP,STORE,LOAD,IN,OUT,INV,INV,INV,\
            INV,INV,INV,INV,INV,INV,INV,INV,\
            INV,ADD,SUB,MUL,DIV,MOD,AND,OR,\
            XOR,SHL,SHR,NOT,SHRA,INV,INV,COMP,\
            JUMP,JNEG,JZER,JPOS,JNNEG,JNZER,JNPOS,JLES,\
            JEQU,JGRE,JNLES,JNEQU,JNGRE,INV,INV,INV,\
            INV,CALL,EXIT,PUSH,POP,PUSHR,POPR,INV,\
            INV,INV,INV,INV,INV,INV,INV,INV,\
            INV,INV,INV,INV,INV,INV,INV,INV,\
            INV,INV,INV,INV,INV,INV,INV,INV,\
            INV,INV,INV,INV,INV,INV,INV,INV,\
            INV,INV,INV,INV,INV,INV,INV,INV,\
            INV,INV,INV,INV,INV,INV,INV,INV,\
            INV,INV,INV,INV,INV,INV,INV,INV,\
            SVC
; functions to get data from registers
regjumptable: dq reg0,reg1,reg2,reg3,reg4,reg5,reg6,reg7
; functions to put data into registers
toregjumptable: dq toreg0,toreg1,toreg2,toreg3,toreg4,toreg5,toreg6,toreg7
;   the ttk-15 binary goes here
data: incbin "a.out.b15",4 ; we skip the 4 byte header
; relative stackptr
stackptr equ $-data
stack times 1024 dd 0
stdinhandle dq 0
stdouthandle dq 0
[section .text align 16]
[default rel]
global WinMain
; esi is a representation of flags GEL in ttk machine
; r14d is the frame pointer (sp)
; r15d is the stack pointer (fp)
; r8 - r13 are r0-r5
; edx is used for the right hand operand. a.k.a address part + index register
; edi is used for the left hand operand, which is always a register
; ax contains the instruction, mode, register and index register values
extern GetStdHandle
extern WriteFile
extern ReadFile
extern ExitProcess

WinMain:
    ; get handle to stdin
    sub rsp,0x20
    mov rcx,-11
    call GetStdHandle
    add rsp,0x20
    mov [stdouthandle], rax
    mov rcx,-10
    call GetStdHandle
    add rsp,0x20
    mov [stdinhandle], rax
    ; initialize stackptr
    xor ecx,ecx
    xor ebx,ebx
    xor ebp,ebp
    mov r14,stackptr
    shr r14d,2
    nextinstr:
    ; get instructions
    mov eax,dword [ecx*0x4+data]
    ; address part to dx
    movzx edx, ax
    shr eax,16
    jmp get_index_register
    index_register_recieved:
    add edx,edi
    ; check mode
    ; mode = 2
    test eax,0x10
    jnz mode_2
    ; mode = 1
    test eax,0x08
    jnz mode_1
    jmp mode_end
    mode_2:
        mov edx,dword [data+edx*0x4]
    mode_1:
        mov edx,dword [data+edx*0x4]
    mode_end:
    movzx ebx,ah
    inc ecx
    ; execute instruction
    ; set edi to contain register value
    jmp get_register
    register_recieved:
    jmp [instr+rbx*8]
    instruction_done:
    ; move value from edi to register
    jmp put_register
    register_put:
    jmp nextinstr
    ; exit 0
    end:
    xor ecx,ecx
    sub rsp,0x20
    call ExitProcess
;;;;;;;;;;;;;;;;;;;;;
print_number:
    push rax
    push rcx
    push rsi
    push r8
    push r9
    push r10
    push r11
    push r15
    push rdi
    mov eax,edi
    xor r15d,r15d
    cmp edi,0
    jnl positive
        not edi
        inc edi
        mov r15d,1
    positive:
    mov ecx,11
    sub rsp,16
    mov edi,10
    mov byte [rsp+12],0xd
    mov byte [rsp+13],0xa
    print_number_loop:
        xor edx,edx
        div edi
        add edx,48
        mov [rsp+rcx],dl
        dec ecx
        test eax,eax
        jne print_number_loop
    mov byte [rsp+rcx],'-'
    push 0
    sub ecx,r15d
    mov r9,rsp
    mov r8,13
    sub r8,rcx
    lea rdx,[rsp+rcx+9]
    mov rcx,[stdouthandle]
    sub rsp,0x20
    call WriteFile
    add rsp,16+0x28
    pop rdi
    pop r15
    pop r11
    pop r10
    pop r9
    pop r8
    pop rsi
    pop rcx
    pop rax
    ret
get_register:
    push rax
    shr eax,0x5
    and eax,0x7
    call [regjumptable+rax*0x8]
    pop rax
    jmp register_recieved
get_index_register:
    push rax
    and eax,0x7
    ;; this is needed to get pop work
    mov ebp, eax
    test eax,eax
    je no_index
        call [regjumptable+rax*0x8]
        pop rax
        jmp index_register_recieved
    no_index:
        xor edi,edi
        pop rax
        jmp index_register_recieved
put_register:
    shr eax,0x5
    and eax,0x7
    call [toregjumptable+rax*0x8]
    jmp register_put
;; get contents of register
reg0:
    mov edi,r8d
    ret
reg1:
    mov edi,r9d
    ret
reg2:
    mov edi,r10d
    ret
reg3:
    mov edi,r11d
    ret
reg4:
    mov edi,r12d
    ret
reg5:
    mov edi,r13d
    ret
reg6:
    mov edi,r14d
    ret
reg7:
    mov edi,r15d
    ret
;; put contents to register
toreg0:
    mov r8d,edi
    ret
toreg1:
    mov r9d,edi
    ret
toreg2:
    mov r10d,edi
    ret
toreg3:
    mov r11d,edi
    ret
toreg4:
    mov r12d,edi
    ret
toreg5:
    mov r13d,edi
    ret
toreg6:
    mov r14d,edi
    ret
toreg7:
    mov r15d,edi
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TTK-15 instructions
;;;;;;;;;;;;;;;;;;;;;;;;;;;
NOP:
    jmp instruction_done
STORE:
    mov dword [data+edx*0x4],edi
    jmp instruction_done
LOAD:
    mov edi, edx
    jmp instruction_done
KBD equ 1
STDIN equ 6
IN:
    cmp rdx,KBD
    je IN_KBD
    cmp rdx,STDIN
    je IN_STDIN
    jmp instruction_done
    IN_KBD:
        ;; todo reading from KBD let's you have an integer interpreted from ascii in the register
        jmp instruction_done
    ;; reading from STDIN, you get an ascii value in the register
    IN_STDIN:
        xor edi,edi
        push rax
        push rcx
        push rsi
        push r8
        push r9
        push r10
        push r11
        push r15
        push rdi
        mov rdx,rsp
        push 0
        mov r9,rsp
        push 0
        mov r8,0x1
        mov rcx,[stdinhandle]
        sub rsp,0x20
        call ReadFile
        add rsp,0x30
        pop rdi
        pop r15
        pop r11
        pop r10
        pop r9
        pop r8
        pop rsi
        pop rcx
        pop rax
        jmp instruction_done
CRT equ 0
STDOUT equ 7
OUT:
    cmp rdx,CRT
    je OUT_CRT
    cmp rdx,STDOUT
    je OUT_STDOUT
    jmp instruction_done
    OUT_CRT:
        call print_number
        jmp instruction_done
    OUT_STDOUT:
        push rax
        push rcx
        push rsi
        push r8
        push r9
        push r10
        push r11
        push r15
        push rdi
        mov rdx,rsp
        push 0
        mov r9,rsp
        mov r8,0x1
        push 0
        sub rsp,0x20
        mov rcx,[stdouthandle]
        call WriteFile
        add rsp,0x30
        pop rdi
        pop r15
        pop r11
        pop r10
        pop r9
        pop r8
        pop rsi
        pop rcx
        pop rax
        jmp instruction_done
ADD:
    add edi,edx
    jmp instruction_done
SUB:
    sub edi,edx
    jmp instruction_done
MUL:
    push rax
    mov eax,edi
    mul edx
    mov edi,eax
    pop rax
    jmp instruction_done
DIV:
    push rax
    mov eax, edi
    mov edi,edx
    xor edx,edx
    div edi
    mov edi,eax
    pop rax
    jmp instruction_done
MOD:
    push rax
    mov eax, edi
    mov edi,edx
    xor edx,edx
    div edi
    mov edi,edx
    pop rax
    jmp instruction_done
AND:
    and edi,edx
    jmp instruction_done
OR:
    or edi,edx
    jmp instruction_done
XOR:
    xor edi,edx
    jmp instruction_done
SHL:
    push rcx
    mov ecx,edx
    shl edi,cl
    pop rcx
    jmp instruction_done
SHR:
    push rcx
    mov ecx,edx
    shr edi,cl
    pop rcx
    jmp instruction_done
NOT:
    xor edi,0xffffffff
    jmp instruction_done
SHRA:
    push rcx
    mov ecx,edx
    sar edi,cl
    pop rcx
    jmp instruction_done
COMP:
    xor esi,esi
    mov esi,edi
    sub esi,edx
    jmp instruction_done
JUMP:
    mov ecx,edx
    jmp instruction_done
JNEG:
    cmp edi,0x0
    jnl instruction_done
    mov ecx,edx
    jmp instruction_done
JZER:
    cmp edi,0x0
    jnz instruction_done
    mov ecx,edx
    jmp instruction_done
JPOS:
    cmp edi,0x0
    jng instruction_done
    mov ecx,edx
    jmp instruction_done
JNNEG:
    cmp edi,0x0
    jl instruction_done
    mov ecx,edx
    jmp instruction_done
JNZER:
    cmp edi,0x0
    jz instruction_done
    mov ecx,edx
    jmp instruction_done
JNPOS:
    cmp edi,0x0
    jg instruction_done
    mov ecx,edx
    jmp instruction_done
JLES:
    cmp esi,0x0
    jnl instruction_done
    mov ecx,edx
    jmp instruction_done
JEQU:
    cmp esi,0x0
    jne instruction_done
    mov ecx,edx
    jmp instruction_done
JGRE:
    cmp esi,0x0
    jng instruction_done
    mov ecx,edx
    jmp instruction_done
JNLES:
    cmp esi,0x0
    jl instruction_done
    mov ecx,edx
    jmp instruction_done
JNEQU:
    cmp esi,0x0
    je instruction_done
    mov ecx,edx
    jmp instruction_done
JNGRE:
    cmp esi,0x0
    jg instruction_done
    mov ecx,edx
    jmp instruction_done
CALL:
    ; pushing values
    mov dword [edi*4+data+4],ecx
    mov dword [edi*4+data+8],r15d
    add edi,0x2
    ; make new frame pointer
    mov r15d,edi
    mov ecx,edx
    jmp instruction_done
EXIT:
    ; popping values
    sub edi,0x2
    mov ecx,dword [edi*4+data+4]
    mov r15d,dword [edi*4+data+8]
    sub edi,edx
    jmp instruction_done
PUSH:
    add edi,0x1
    mov dword [edi*4+data],edx
    jmp instruction_done
POP:
    push rdi
    mov edi,dword [edi*4+data]
    test rbp,rbp
    je POP_NOTHING
    call [toregjumptable+rbp*0x8]
    POP_NOTHING:
    pop rdi
    sub edi,0x1
    jmp instruction_done
PUSHR:
    mov [edi*4+data+4],r8d
    mov [edi*4+data+8],r9d
    mov [edi*4+data+12],r10d
    mov [edi*4+data+16],r11d
    mov [edi*4+data+20],r12d
    mov [edi*4+data+24],r13d
    add edi,6
    jmp instruction_done
POPR:
    sub edi,6
    mov r8d,[edi*4+data+4]
    mov r9d,[edi*4+data+8]
    mov r10d,[edi*4+data+12]
    mov r11d,[edi*4+data+16]
    mov r12d,[edi*4+data+20]
    mov r13d,[edi*4+data+24]
    jmp instruction_done
HALT equ 0x0B
DBG equ 0xBB
SVC:
    ; halt 
    cmp edx,HALT
    je end
    cmp edx,DBG
    je check_debug
    jmp instruction_done
    check_debug:
        push rax
        mov eax,r9d
        mov rax, [gs:rax] ; x64 PEB
        movzx r9d,byte [rax+0x2]
        pop rax
INV:
    jmp instruction_done
