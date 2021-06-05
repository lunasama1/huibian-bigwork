
assume cs:code, ds:data
data segment
menu    db 'Score Management System',13,10;主菜单,13,10 -> CRLF
        db '1 -> Input',13,10;获取输入,并自动计算总成绩
        db '2 -> Print All Score',13,10;打印所有成绩(默认根据输入顺序)
        db '3 -> Inquire',13,10;查询
        db '4 -> Ascending Sort',13,10;将总成绩升序排列并打印
        db '5 -> Descending Sort',13,10;将总成绩降序排列并打印
        db '6 -> Segmentation',13,10;自动计算平均分,最高分,最低分,并进行分数段统计
        db '7 -> Quit',13,10;退出
        db 'Please input your choice without enter: ','$'
CRLF    db 13,10,'$'
error   db 13,10,'Your choice error,please input again',13,10,'$'
buffer  db 128
        db ?
        db 128 dup(?)
data ends
stack segment
    db 128 dup(0)
stack ends
code segment
;http://spike.scu.edu.au/~barry/interrupts.html
;http://bbc.nvg.org/doc/Master%20512%20Technical%20Guide/m512techb_int21.htm
main:
    mov ax,data
    mov ds,ax
    mov ax,stack
    mov ss,ax
    mov sp,128

main_loop:
    call main_menu
    call get_choice
    cmp al,'1'
    je Input
    cmp al,'7'
    je finish
    call get_choice_error
    jmp main_loop
Input:
    call get_str_input
    jmp main_loop
finish:
    mov ax,4c00h
    int 21h

;------

main_menu:;打印主菜单
    push bp
    mov bp,sp

    xor ax,ax
    mov ah,9;Function 09- Output character string
    mov dx,offset menu
    int 21h

    mov sp,bp
    pop bp
    ret

get_choice_error:
    push bp
    mov bp,sp
    
    xor ax,ax
    mov ah,9
    mov dx,offset error
    int 21h

    mov sp,bp
    pop bp
    ret

get_choice:;获取选项
    push bp
    mov bp,sp
    
    xor ax,ax
    mov ah,1;Function 1- Character input with echo
    int 21h

    mov ah,9
    mov dx,offset CRLF
    int 21h

    mov sp,bp
    pop bp
    ret

get_str_input:;获取成绩输入
    push bp
    mov bp,sp
    
    xor ax,ax
    mov ah,10;Function 0Ah - Buffered input
    mov dx,offset buffer;每一次输入的成绩都会将buffer中的内容重新覆盖
    int 21h

    mov sp,bp
    pop bp
    ret

code ends
end main