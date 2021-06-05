assume cs:code, ds:data
data segment
Main_menu               db 13,10
                        db 'Score Management System',13,10;主菜单,13,10 -> CRLF
                        db '1 -> Input',13,10;获取输入,并自动计算总成绩
                        db '2 -> Print All Score',13,10;打印所有成绩(默认根据输入顺序)
                        db '3 -> Inquire',13,10;查询
                        db '4 -> Ascending Sort & Print',13,10;将总成绩升序排列并打印
                        db '5 -> Descending Sort & Print',13,10;将总成绩降序排列并打印
                        db '6 -> Segmentation',13,10;自动计算平均分,最高分,最低分,并进行分数段统计
                        db '7 -> Quit',13,10;退出
                        db 'Please input your choice without enter: ','$'
Inquire_menu            db 13,10
                        db '1 -> Inquire by id',13,10
                        db '2 -> Inquire by name',13,10
                        db '3 -> exit menu',13,10
                        db 'Please input your choice without enter: ','$'
CRLF                    db 13,10,'$'
Inquire_fail            db 'Inquire fail,please try again!!!',13,10,'$'
Score_Sample            db '    id    |    name    |  16x normal score  |  bigwork score  |  final score',13,10,'$'
input_hint              db 'Please input students profile like ',13,10
                        db '201905xxxx zhangsan 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17',13,10,'$'
inquire_input_hint      db 'Please input keywords: ','$'
press_enter_hint        db 'Please press enter to show next page',13,10,13,10,'$'
error                   db 13,10,'Your choice error,please input again',13,10,'$'
max_min_avg_score       db 'max:          min:          avg:          ',13,10,'$'
score_segment1          db '90-100:          ',13,10,'$'
score_segment2          db '80-89:           ',13,10,'$'
score_segment3          db '60-79:           ',13,10,'$'
score_segment4          db '0-59:            ',13,10,'$'
file                    db 'students.txt',0
welcome                 db 'welcome to exam management system',13,10
                        db '            this system is developed by luojinkun and moliangfei',13,10
                        db '            you can enter any key to continue','$'
blanket                 db 0ah,'$'
file_handle             db ?,?;保存文件句柄,共两个字节
Profile_input           db 128;学生信息缓冲
                        db ?
                        db 128 dup(?),'$'
Profile_input_length    db ?,?;保存学生信息的实际长度,共两个字节
final_score_sort        db 256 dup(?);前两个??代表属于第几行,后两个??用于记录总成绩
Inquire_input           db 32;输入查询缓冲
                        db ?
                        db 32 dup(?),'$'
Inquire_input_length    db ?,?;保存输入查询的实际长度,共两个字节
Inquire_fail_check      db ?,?;记录是否查询成功
normal_score            db ?,?;保存平时成绩(未平均)
bigwork_score           db ?,?;保存大作业成绩
normal_score_integer    db ?,?;保存40%平时成绩的整数部分
normal_score_decimal    db ?,?;保存40%平时成绩的小数部分
bigwork_score_integer   db ?,?;保存60%大作业成绩的整数部分
bigwork_score_decimal   db ?,?;保存60%大作业成绩的小数部分
final_score_integer     db ?,?;保存总成绩的整数部分
final_score_decimal     db ?,?;保存总成绩的小数部分
final_score_posi        db ?,?;保存从文件中读取出的总成绩的位置
max_final_score_integer db ?,?;保存最高分的整数部分
max_final_score_decimal db ?,?;保存最高分的小数部分
min_final_score_integer db ?,?;保存最低分的整数部分
min_final_score_decimal db ?,?;保存最低分的小数部分
total_number            db ?,?;保存学生总数
avg_final_score_integer db ?,?;保存平均分的整数部分
avg_final_score_decimal db ?,?;保存平均分的小数部分
score_segment1_number   db ?,?;记录90-100的人数
score_segment2_number   db ?,?;记录80-89的人数
score_segment3_number   db ?,?;记录60-79的人数
score_segment4_number   db ?,?;记录0-60的人数
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
    xor ax,ax
    xor si,si

    call file_init
main_loop:
    call print_main_menu
    call get_input_choice
    cmp al,'6'
    je Segmentation
    cmp al,'7'
    je finish
    jmp main_loop

Segmentation:
    call clear_score_segment_number
    call segment_func
    call print_segment
    jmp main_loop

clear_score_segment_number:
    push cx
    mov cx,8
    lea si,score_segment1_number
clear_score_segment_loop:
    mov byte ptr ds:[si],0
    inc si
    loop clear_score_segment_loop
    
    pop cx
    ret

segment_func:
    call open_file
Segmentation_loop:
    call read_file
    cmp ax,0;EOF
    je Segmentation_loop_finish
    call get_final_score_posi
    call convert_final_score_to_int
    call divide_segments
    jmp Segmentation_loop
Segmentation_loop_finish:
    call close_file
    ret

read_file:
    push bx
    push cx
    lea si,file_handle
    mov bx,[si]
    lea si,Profile_input+2
    mov dx,si
    mov cx,128
    mov ah,3fh
    int 21h
    pop cx
    pop bx
    ret

get_final_score_posi:
    push ax
    push bx
    push cx
    push dx

    xor ax,ax
    mov cx,18
    xor dx,dx
    lea si,Profile_input+13
get_final_score_posi_loop:
    mov bl,byte ptr ds:[si]
    inc si
    cmp bl,' '
    je check_final_score_posi
    jmp get_final_score_posi_loop
check_final_score_posi:
    dec cx
    jcxz get_final_score_posi_finish
    jmp get_final_score_posi_loop
get_final_score_posi_finish:
    lea di,final_score_posi
    mov [di],si

    pop dx
    pop cx
    pop bx
    pop ax
    ret

convert_final_score_to_int:
    push ax
    push cx

    xor ax,ax
    mov ch,10
    lea di,final_score_posi
    mov si,[di]

convert_integer:
    mov cl,byte ptr ds:[si]
    inc si
    cmp cl,'.'
    je convert_integer_finish
    and cl,00001111b;'0'->0
    mul ch
    add al,cl
    jmp convert_integer
convert_integer_finish:
    lea di,final_score_integer
    mov [di],ax
    xor ax,ax
convert_decimal:
    mov cl,byte ptr ds:[si]
    inc si
    cmp cl,' '
    je convert_decimal_finish
    and cl,00001111b;'0'->0
    mul ch
    add al,cl
    jmp convert_decimal
convert_decimal_finish:
    lea di,final_score_decimal
    mov [di],ax

    pop cx
    pop ax
    ret

print_segment:
    push ax

    lea si,score_segment1_number
    mov ax,[si]
    lea di,score_segment1+10
    push ax
    push di
    call dtoc
    mov byte ptr ds:[si],' '
    inc si
    mov byte ptr ds:[si],' '
    mov ah,9
    lea dx,score_segment1
    int 21h


    lea si,score_segment2_number
    mov ax,[si]
    lea di,score_segment2+10
    push ax
    push di
    call dtoc
    mov byte ptr ds:[si],' '
    inc si
    mov byte ptr ds:[si],' '
    mov ah,9
    lea dx,score_segment2
    int 21h

    lea si,score_segment3_number
    mov ax,[si]
    lea di,score_segment3+10
    push ax
    push di
    call dtoc
    mov byte ptr ds:[si],' '
    inc si
    mov byte ptr ds:[si],' '
    mov ah,9
    lea dx,score_segment3
    int 21h

    lea si,score_segment4_number
    mov ax,[si]
    lea di,score_segment4+10
    push ax
    push di
    call dtoc
    mov byte ptr ds:[si],' '
    inc si
    mov byte ptr ds:[si],' '
    mov ah,9
    lea dx,score_segment4
    int 21h
    
    pop ax
    ret

divide_segments:
    push ax
    lea si,final_score_integer
    mov ax,[si]
    cmp ax,90
    jnb segment1
    cmp ax,80
    jnb segment2
    cmp ax,60
    jnb segment3
    lea si,score_segment4_number
    inc word ptr ds:[si]
    jmp divide_segments_finish
segment1:
    lea si,score_segment1_number
    inc word ptr ds:[si]
    jmp divide_segments_finish
segment2:
    lea si,score_segment2_number
    inc word ptr ds:[si]
    jmp divide_segments_finish
segment3:
    lea si,score_segment3_number
    inc word ptr ds:[si]
    jmp divide_segments_finish
divide_segments_finish:
    pop ax
    ret

file_init:;文件初始化
    call open_file
    cmp al,2;返回al=2,说明文件不存在
    je nofile
    jmp closefile
nofile:
    call create_file
closefile:
    call close_file
    ret

print_main_menu:;打印主菜单
    xor ax,ax
    mov ah,9;Function 09- Output character string
    lea dx,Main_menu
    int 21h
    ret

create_file:;创建文件
    mov ah,3ch;create file
    mov cx,00
    lea dx,file
    int 21h
    lea si,file_handle
    mov [si],ax;保存文件句柄
    ret

open_file:;打开文件
    mov ah,3dh
    mov al,2
    lea dx,file
    int 21h
    lea si,file_handle
    mov [si],ax;保存文件句柄
    ret


get_input_choice:;获取选项
    xor ax,ax
    mov ah,1;Function 1- Character input with echo
    int 21h
    call print_crlf
    ret

close_file:;关闭文件
    lea si,file_handle
    mov bx,[si]
    mov ah,3eh
    int 21h
    ret


finish:
    mov ax,4c00h
    int 21h

code ends
end main