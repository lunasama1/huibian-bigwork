assume cs:code, ds:data
data segment
menu                    db 13,10
                        db 'Score Management System',13,10;主菜单,13,10 -> CRLF
                        db '1 -> Input',13,10;获取输入,并自动计算总成绩
                        db '2 -> Print All Score',13,10;打印所有成绩(默认根据输入顺序)可以加输入例子
                        db '3 -> Inquire',13,10;查询
                        db '4 -> Ascending Sort & Print',13,10;将总成绩升序排列并打印
                        db '5 -> Descending Sort & Print',13,10;将总成绩降序排列并打印
                        db '6 -> Segmentation',13,10;自动计算平均分,最高分,最低分,并进行分数段统计
                        db '7 -> Quit',13,10;退出
                        db 'Please input your choice without enter: ','$'
CRLF                    db 13,10,'$'
Score_Sample            db '    id    |    name    |  16x normal score  |  bigwork score  |  final score',13,10,'$'
input_hint              db 'Please input students profile: ',13,10,'$'
error                   db 13,10,'Your choice error,please input again',13,10,'$'
max_min_avg_score       db 'max:          min:          avg:          ',13,10,'$'
file                    db 'students.txt',0
file_handle             db ?,?;保存文件句柄,共两个字节
buffer                  db 128;输入缓冲
                        db ?
                        db 128 dup(?),'$'
buffer_length           db ?,?;保存缓冲区实际长度,共两个字节
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
    call main_menu
    call input_choice
    cmp al,'1'
    je Input
    cmp al,'2'
    je Print_All_Score
    ;cmp al,'6'
    ;je Segmentation
    cmp al,'7'
    je finish
    call input_choice_error
    jmp main_loop

Input:
    call get_score_input
    call get_final_score
    call save_score_in_file
    jmp main_loop

Print_All_Score:
    call clear_final_score
    xor ax,ax
    xor cx,cx;cx记录人数,用于计算平均分

    mov ah,9;打印成绩
    lea dx,Score_Sample
    int 21h

    call open_file
readline:
    call read_file
    cmp ax,0;EOF
    je readline_finish

    mov ah,9
    lea dx,buffer+2
    int 21h
    inc cx

    call get_final_score_posi
    call convert_final_score_to_int
    call get_max_final_score
    call get_min_final_score
    call add_all_final_score

    jmp readline
readline_finish:
    call close_file
    lea si,total_number
    mov [si],cx;写入偏移地址
    call calculate_avg_score
    call print_max_min_avg_score

    jmp main_loop

finish:
    mov ax,4c00h
    int 21h

;------

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


main_menu:;打印主菜单
    xor ax,ax
    mov ah,9;Function 09- Output character string
    lea dx,menu
    int 21h
    ret

input_choice:;获取选项
    xor ax,ax
    mov ah,1;Function 1- Character input with echo
    int 21h

    mov ah,9
    lea dx,CRLF;换行
    int 21h
    ret

input_choice_error:;选项输入错误
    xor ax,ax
    mov ah,9
    lea dx,error
    int 21h
    ret

get_score_input:;获取成绩输入
    xor ax,ax
    mov ah,9
    lea dx,input_hint
    int 21h

    xor ax,ax
    mov ah,10;Function 0Ah - Buffered input
    lea dx,buffer;每一次输入的成绩都会将buffer中的内容重新覆盖
    int 21h
    ret


get_final_score:
    call convert_input_score_to_int;将输入的成绩进行转换
    call calculate_normal_score;计算40%的平时成绩
    call calculate_bigwork_score;计算60%的大作业成绩
    call calculate_final_score;计算总成绩
    ret

save_score_in_file:
    call get_buffer_length_to_cr
    call convert_int_to_char
    call get_buffer_length_to_cr
    lea si,buffer_length
    mov bx,[si]
    mov cx,127
    sub cx,bx
    lea si,buffer+1
    add si,bx
add_space:
    mov byte ptr ds:[si],' '
    inc si
    loop add_space
    mov byte ptr ds:[si],13
    inc si
    mov byte ptr ds:[si],10
    call open_file
    call set_append_mode
    call write_file
    call close_file
    ret


clear_final_score:
    xor ax,ax
    lea si,final_score_decimal
    mov [si],ax
    lea si,final_score_integer
    mov [si],ax
    lea si,max_final_score_decimal
    mov [si],ax
    lea si,max_final_score_integer
    mov [si],ax
    lea si,avg_final_score_decimal
    mov [si],ax
    lea si,avg_final_score_integer
    mov [si],ax
    mov ax,0ffffh
    lea si,min_final_score_decimal
    mov [si],ax
    lea si,min_final_score_integer
    mov [si],ax
    ret

print_max_min_avg_score:
    lea di,max_final_score_integer
    mov ax,[di]
    lea si,max_min_avg_score+6
    push ax
    push si
    call dtoc
    mov byte ptr ds:[si],'.'
    inc si
    lea di,max_final_score_decimal
    mov ax,[di]
    push ax
    push si
    call dtoc
    mov byte ptr ds:[si],' '
    inc si
    mov byte ptr ds:[si],' '


    lea di,min_final_score_integer
    mov ax,[di]
    lea si,max_min_avg_score+20
    push ax
    push si
    call dtoc
    mov byte ptr ds:[si],'.'
    inc si
    lea di,min_final_score_decimal
    mov ax,[di]
    push ax
    push si
    call dtoc
    mov byte ptr ds:[si],' '
    inc si
    mov byte ptr ds:[si],' '


    lea di,avg_final_score_integer
    mov ax,[di]
    lea si,max_min_avg_score+34
    push ax
    push si
    call dtoc
    mov byte ptr ds:[si],'.'
    inc si
    lea di,avg_final_score_decimal
    mov ax,[di]
    push ax
    push si
    call dtoc
    mov byte ptr ds:[si],' '
    inc si
    mov byte ptr ds:[si],' '


    mov ah,9
    lea dx,max_min_avg_score
    int 21h

    ret



;数据处理
convert_input_score_to_int:;将输入的成绩转换为数值
    push ax
    push bx
    push cx
    push dx

    xor ax,ax
    mov cx,16
    xor dx,dx
    lea si,buffer+13
get_number_posi:
    mov bl,byte ptr ds:[si]
    inc si
    cmp bl,' '
    je convert_number
    jmp get_number_posi
convert_number:
    mov bl,byte ptr ds:[si]
    cmp bl,' '
    je add_all_normal_score
    cmp bl,13
    je save_bigwork_score
    and bl,00001111b;'0'->0
    mov ah,10
    mul ah;ax=al*10
    add al,bl;15=1*10+5
    inc si
    jmp convert_number
add_all_normal_score:
    add dx,ax
    inc si
    xor ax,ax
    dec cx
    jcxz save_normal_score
    jmp convert_number
save_normal_score:
    push si
    lea si,normal_score
    mov [si],dx;保存平时成绩
    pop si
    jmp convert_number
save_bigwork_score:
    lea si,bigwork_score
    mov [si],ax;保存大作业成绩
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret


calculate_normal_score:;40%的平时成绩 x/16*0.4=x/40
    push ax
    push bx
    push dx
;计算整数
    xor dx,dx
    lea si,normal_score
    mov ax,[si]
    mov bx,40
    div bx;ax=ax/40(商)   dx=ax%40(余数)
    lea si,normal_score_integer
    mov [si],ax;保存整数部分
;计算小数
    mov ax,dx
    xor dx,dx
    mov bx,10
    mul bx;ax=dx*10
    mov bx,40
    div bx;ax=ax/40(商)   dx=ax%40(余数)
    lea si,normal_score_decimal
    mov [si],ax;保存小数部分

    pop dx
    pop bx
    pop ax
    ret


calculate_bigwork_score:;60%的大作业成绩
    push ax
    push bx
    push dx

    xor dx,dx
    mov bx,6
    lea si,bigwork_score
    mov ax,[si]
    mul bx;ax=ax*6
    mov bx,10
    div bx;ax=ax/10(商)   dx=ax%10(余数)
    lea si,bigwork_score_integer
    mov [si],ax;保存整数部分
    lea si,bigwork_score_decimal
    mov [si],dx;保存小数部分,除10的余数直接就是小数

    pop dx
    pop bx
    pop ax
    ret


calculate_final_score:
    push ax
    push bx
    push cx
    push dx

    mov cx,10
    xor dx,dx
    lea si,normal_score_decimal
    mov ax,[si]
    lea si,bigwork_score_decimal
    mov bx,[si]
    add ax,bx
    div cx;ax=ax/10(商)   dx=ax%10(余数)
    lea si,final_score_decimal
    mov [si],dx
    lea si,normal_score_integer
    mov bx,[si]
    add ax,bx;小数进位
    lea si,bigwork_score_integer
    mov bx,[si]
    add ax,bx
    lea si,final_score_integer
    mov [si],ax

    pop dx
    pop cx
    pop bx
    pop ax
    ret


convert_int_to_char:
    lea si,buffer_length
    mov di,[si]
    lea si,buffer+1
    add si,di
    mov byte ptr ds:[si],' ';将回车替换成空格
    inc si
    lea di,final_score_integer;将整数部分转换成字符
    mov ax,[di]
    push ax
    push si
    call dtoc
    mov byte ptr ds:[si],'.';小数点
    inc si
    lea di,final_score_decimal;将小数部分转换成字符
    mov ax,[di]
    push ax
    push si
    call dtoc
    mov byte ptr ds:[si],13;CR
    ;inc si
    ;mov byte ptr ds:[si],10;LF
    ret


dtoc:
    push bp
    mov bp,sp
    mov si,ss:[bp+4]
    mov ax,ss:[bp+6]
    mov dx,0
    push dx
    mov bx,10
dtoc_loop:
    div bx;ax:商,dx:余数
    add dx,030h;0->'0'
    push dx;ascii入栈
    mov cx,ax
    jcxz dtoc_re
    mov dx,0
    jmp dtoc_loop
dtoc_re:;用栈将ascii倒序
    pop cx
    jcxz dtoc_ret
    mov byte ptr ds:[si],cl;移动到buffer中
    inc si
    jmp dtoc_re
dtoc_ret:
    mov sp,bp
    pop bp
    ret 4


get_final_score_posi:
    push ax
    push bx
    push cx
    push dx

    xor ax,ax
    mov cx,18
    xor dx,dx
    lea si,buffer+13
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


get_max_final_score:
    push ax
    push bx

    lea si,max_final_score_integer
    mov ax,[si]
    lea si,final_score_integer
    mov bx,[si]
    cmp ax,bx
    je cmp_max_final_score_decimal
    ja get_max_final_score_finish
    lea si,max_final_score_integer
    mov [si],bx
    lea si,final_score_decimal
    mov bx,[si]
    lea si,max_final_score_decimal
    mov [si],bx
    jmp get_max_final_score_finish
cmp_max_final_score_decimal:
    lea si,max_final_score_decimal
    mov ax,[si]
    lea si,final_score_decimal
    mov bx,[si]
    cmp ax,bx
    jnb get_max_final_score_finish
    lea si,max_final_score_decimal
    mov [si],bx
get_max_final_score_finish:
    pop bx
    pop ax
    ret


get_min_final_score:
    push ax
    push bx

    lea si,min_final_score_integer
    mov ax,[si]
    lea si,final_score_integer
    mov bx,[si]
    cmp ax,bx
    je cmp_min_final_score_decimal
    jb get_min_final_score_finish
    lea si,min_final_score_integer
    mov [si],bx
    lea si,final_score_decimal
    mov bx,[si]
    lea si,min_final_score_decimal
    mov [si],bx
    jmp get_min_final_score_finish
cmp_min_final_score_decimal:
    lea si,min_final_score_decimal
    mov ax,[si]
    lea si,final_score_decimal
    mov bx,[si]
    cmp ax,bx
    jna get_min_final_score_finish
    lea si,min_final_score_decimal
    mov [si],bx
get_min_final_score_finish:
    pop bx
    pop ax
    ret


add_all_final_score:
    push ax

    lea si,final_score_integer
    mov ax,[si]
    lea si,avg_final_score_integer
    add [si],ax

    lea si,final_score_decimal
    mov ax,[si]
    lea si,avg_final_score_decimal
    add [si],ax

    pop ax
    ret


calculate_avg_score:
    push ax
    push bx
    push dx

    lea si,total_number
    mov al,[si]
    mov ah,10
    mul ah
    mov [si],ax

    xor dx,dx
    mov bx,10
    lea si,avg_final_score_decimal
    mov ax,[si]
    div bx
    mov [si],dx

    lea si,avg_final_score_integer
    add ax,[si]

    xor dx,dx
    mul bx
    lea si,avg_final_score_decimal
    add ax,[si]
    adc dx,0
;计算整数
    lea si,total_number
    mov bx,[si]
    div bx
    lea si,avg_final_score_integer
    mov [si],ax
;计算小数
    mov ax,dx
    xor dx,dx
    mov bx,10
    mul bx
    lea si,total_number
    mov bx,[si]
    div bx
    lea si,avg_final_score_decimal
    mov [si],ax

    pop dx
    pop bx
    pop ax
    ret


;文件操作
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

read_file:
    push cx
    lea si,file_handle
    mov bx,[si]
    lea si,buffer+2
    mov dx,si
    mov cx,128
    mov ah,3fh
    int 21h
    pop cx
    ret

write_file:;写入文件
    ;lea si,buffer_length
    ;mov cx,[si]
    mov cx,128
    lea si,file_handle
    mov bx,[si]
    mov ah,40h
    lea dx,buffer+2
    int 21h
    ret

close_file:;关闭文件
    lea si,file_handle
    mov bx,[si]
    mov ah,3eh
    int 21h
    ret

set_append_mode:;将文件指针移动到末尾,即追加模式
    lea si,file_handle
    mov bx,[si]
    mov ah,42h
    mov al,2;origin of move 00h start of file 01h current file position 02h end of file
    xor cx,cx
    xor dx,dx
    int 21h
    ret

get_buffer_length_to_cr:;读取缓冲区字符的长度到CR截止
    push cx
    push bx
    xor cx,cx
    xor bx,bx
    lea si,buffer+2
buffer_length_loop:
    mov bl,byte ptr ds:[si];获取输入的每一个字符
    inc cx;cx保存buffer的长度
    cmp bl,13;CR 回车符
    je save_buffer_length
    inc si
    jmp buffer_length_loop
save_buffer_length:
    lea si,buffer_length
    mov [si],cx
    pop bx
    pop cx
    ret

code ends
end main