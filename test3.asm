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
press_enter_hint        db 'Please press enter to show more information',13,10,13,10,'$'
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
    call first_show
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
    cmp al,'1'
    je Input
    cmp al,'2'
    je Print_All_Score
    cmp al,'3'
    je Inquire
    cmp al,'4'
    je Ascending_Sort_and_Print
    cmp al,'5'
    je Descending_Sort_and_Print
    cmp al,'6'
    je Segmentation
    cmp al,'7'
    je finish
    call get_input_choice_error
    jmp main_loop

Input:
    call get_profile_input
    call get_final_score
    call save_score_in_file
    jmp main_loop

Print_All_Score:
    call clear_final_score
    call read_score_from_file
    jmp main_loop

Inquire:
    call print_inquire_menu
    call get_input_choice
    cmp al,'1'
    je Inquire_by_id
    cmp al,'2'
    je Inquire_by_name
    cmp al,'3'
    je main_loop
    call get_input_choice_error
    jmp Inquire

Inquire_by_id:
    call get_inquire_input;获得需匹配的字符串
    call print_crlf
    
    call get_inquire_input_length

    call Inquire_by_id_func
    jmp main_loop

Inquire_by_name:
    call get_inquire_input
    call print_crlf

    call get_inquire_input_length

    call Inquire_by_name_func
    jmp main_loop

Ascending_Sort_and_Print:
    call get_final_score_from_file
    call ascending_sort
    call sort_print
    jmp main_loop

Descending_Sort_and_Print:
    call get_final_score_from_file
    call descending_sort
    call sort_print
    jmp main_loop

Segmentation:
    call clear_score_segment_number
    call segment_func
    call print_segment
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


print_main_menu:;打印主菜单
    xor ax,ax
    mov ah,9;Function 09- Output character string
    lea dx,Main_menu
    int 21h
    ret


get_input_choice:;获取选项
    xor ax,ax
    mov ah,1;Function 1- Character input with echo
    int 21h
    call print_crlf
    ret


get_input_choice_error:;选项输入错误
    xor ax,ax
    mov ah,9
    lea dx,error
    int 21h
    ret


get_profile_input:;获取信息输入
    xor ax,ax
    mov ah,9
    lea dx,input_hint
    int 21h

    xor ax,ax
    mov ah,10;Function 0Ah - Buffered input
    lea dx,Profile_input;每一次输入的成绩都会将缓冲区中的内容重新覆盖
    int 21h
    ret


get_final_score:
    call convert_input_score_to_int;将输入的成绩进行转换
    call calculate_normal_score;计算40%的平时成绩
    call calculate_bigwork_score;计算60%的大作业成绩
    call calculate_final_score;计算总成绩
    ret


save_score_in_file:
    lea si,Profile_input+2
    push si
    lea si,Profile_input_length
    push si
    call get_buffer_length_to_cr
    call convert_int_to_char
    lea si,Profile_input+2
    push si
    lea si,Profile_input_length
    push si
    call get_buffer_length_to_cr
    lea si,Profile_input_length
    mov bx,[si]
    mov cx,127
    sub cx,bx
    lea si,Profile_input+1
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


read_score_from_file:
    xor ax,ax
    xor cx,cx;cx记录人数,用于计算平均分

    mov ah,9
    lea dx,Score_Sample
    int 21h

    call open_file
read_score_from_file_loop:
    call read_file
    cmp ax,0;EOF
    je read_score_from_file_finish

    mov ah,9
    lea dx,Profile_input+2
    int 21h
    inc cx
    call press_enter
    call get_final_score_posi
    call convert_final_score_to_int
    call get_max_final_score
    call get_min_final_score
    call add_all_final_score
    jmp read_score_from_file_loop
read_score_from_file_finish:
    call close_file
    lea si,total_number
    mov [si],cx
    call calculate_avg_score
    call print_max_min_avg_score
    ret


print_inquire_menu:
    xor ax,ax
    mov ah,9
    lea dx,Inquire_menu
    int 21h
    ret


get_inquire_input:
    xor ax,ax
    mov ah,9
    lea dx,inquire_input_hint
    int 21h

    xor ax,ax
    mov ah,10
    lea dx,Inquire_input
    int 21h
    ret


print_crlf:
    push ax
    xor ax,ax
    mov ah,9
    lea dx,CRLF
    int 21h
    pop ax
    ret


get_inquire_input_length:
    lea si,Inquire_input+2
    push si
    lea si,Inquire_input_length
    push si
    call get_buffer_length_to_cr
    lea si,Inquire_input_length
    dec word ptr ds:[si]
    ret


Inquire_by_id_func:;0154
    lea si,Inquire_fail_check
    mov word ptr ds:[si],0
    call open_file
get_id_from_file_loop:
    call read_file
    cmp ax,0;EOF
    je get_id_from_file_finish

    lea si,Profile_input+2
    push si;要输出的行
    push si;文本串位置
    mov cx,10
    push cx;文本串长度
    lea si,Inquire_input+2
    push si;模版串位置
    lea si,Inquire_input_length
    mov cx,word ptr ds:[si]
    push cx;模版串长度
    call Inquire_check
    jmp get_id_from_file_loop
get_id_from_file_finish:
    call close_file
    lea si,Inquire_fail_check
    mov cx,word ptr ds:[si]
    jcxz Inquire_by_id_fail_print
    jmp Inquire_by_id_fail_print_finish
Inquire_by_id_fail_print:
    mov ah,9
    lea dx,Inquire_fail
    int 21h
Inquire_by_id_fail_print_finish:
    ret


Inquire_by_name_func:
    lea si,Inquire_fail_check
    mov word ptr ds:[si],0
    call open_file
get_name_from_file_loop:
    call read_file
    cmp ax,0;EOF
    je get_name_from_file_finish

    lea si,Profile_input+2
    push si;要输出的行
    lea si,Profile_input+13
    push si;文本串位置
    call get_name_length_from_file
    push cx;文本串长度
    lea si,Inquire_input+2
    push si;模版串位置
    lea si,Inquire_input_length
    mov cx,word ptr ds:[si]
    push cx;模版串长度
    call Inquire_check
    jmp get_name_from_file_loop
get_name_from_file_finish:
    call close_file
    lea si,Inquire_fail_check
    mov cx,word ptr ds:[si]
    jcxz Inquire_by_name_fail_print
    jmp Inquire_by_name_fail_print_finish
Inquire_by_name_fail_print:
    mov ah,9
    lea dx,Inquire_fail
    int 21h
Inquire_by_name_fail_print_finish:
    ret


get_final_score_from_file:
    xor cx,cx
    lea bx,final_score_sort
    call open_file
get_final_score_loop:
    call read_file
    cmp ax,0;EOF
    je get_final_score_loop_finish
    call get_final_score_posi
    call convert_final_score_to_int
    lea si,final_score_integer
    mov ax,word ptr ds:[si]
    mov ah,10
    mul ah
    lea si,final_score_decimal
    add ax,word ptr ds:[si]
    mov word ptr ds:[bx],cx
    inc cx
    add bx,2
    mov word ptr ds:[bx],ax
    add bx,2
    jmp get_final_score_loop
get_final_score_loop_finish:
    lea si,total_number
    mov word ptr ds:[si],cx
    call close_file
    ret


ascending_sort:
    lea si,total_number
    mov cx,word ptr ds:[si]
    lea bx,final_score_sort
ascending_sort_loop1:
    xor si,si
    mov di,1
ascending_sort_loop2:
    mov ax,word ptr ds:[bx+si+2]
    mov dx,word ptr ds:[bx+si+6]
    cmp ax,dx
    jb ascending_sort_loop2_check
    mov word ptr ds:[bx+si+6],ax
    mov word ptr ds:[bx+si+2],dx
    mov ax,word ptr ds:[bx+si]
    mov dx,word ptr ds:[bx+si+4]
    mov word ptr ds:[bx+si],dx
    mov word ptr ds:[bx+si+4],ax
ascending_sort_loop2_check:
    add si,4
    inc di
    cmp di,cx
    jb ascending_sort_loop2
    loop ascending_sort_loop1
    ret


descending_sort:
    lea si,total_number
    mov cx,word ptr ds:[si]
    lea bx,final_score_sort
descending_sort_loop1:
    xor si,si
    mov di,1
descending_sort_loop2:
    mov ax,word ptr ds:[bx+si+2]
    mov dx,word ptr ds:[bx+si+6]
    cmp ax,dx
    ja descending_sort_loop2_check
    mov word ptr ds:[bx+si+6],ax
    mov word ptr ds:[bx+si+2],dx
    mov ax,word ptr ds:[bx+si]
    mov dx,word ptr ds:[bx+si+4]
    mov word ptr ds:[bx+si],dx
    mov word ptr ds:[bx+si+4],ax
descending_sort_loop2_check:
    add si,4
    inc di
    cmp di,cx
    jb descending_sort_loop2
    loop descending_sort_loop1
    ret


sort_print:
    call open_file
    mov cx,0
    lea bx,final_score_sort
sort_print_loop:
    mov ax,word ptr ds:[bx]
    push ax
    call set_current_file_position
    call read_file
    lea dx,Profile_input+2
    mov ah,9
    int 21h
    inc cx
    call press_enter
    add bx,4
    lea si,total_number
    cmp cx,word ptr ds:[si]
    jne sort_print_loop
    call close_file
    ret


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

;-----

press_enter:
    push ax
    push cx
    push dx
    xor dx,dx
    mov ax,cx
    mov cx,7
    div cx
    cmp dx,0
    je print_press_enter_hint
    jne press_enter_finish
print_press_enter_hint:
    xor ax,ax
    mov ah,9
    lea dx,press_enter_hint
    int 21h
press_enter_next_page:
    xor ax,ax
    mov ah,0
    int 16h
    cmp al,13
    je press_enter_finish
    jne press_enter_next_page
press_enter_finish:
    pop dx
    pop cx
    pop ax
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


Inquire_check:
    push bp
    mov bp,sp
    mov si,ss:[bp+10];文本串位置
    mov cx,ss:[bp+8];文本串长度
    mov di,ss:[bp+6];模版串位置
Inquire_find_posi:
    cmp cx,word ptr ss:[bp+4]
    jb Inquire_check_ret
    mov ah,byte ptr ds:[si]
    mov al,byte ptr ds:[di]
    cmp al,ah
    je Inquire_next_check
    inc si
    loop Inquire_find_posi
    jmp Inquire_check_ret
Inquire_next_check:
    push si
    push cx
    mov cx,ss:[bp+4];模版串长度
Inquire_check_loop:
    dec cx
    jcxz Inquire_print
    inc si
    inc di
    mov ah,byte ptr ds:[si]
    mov al,byte ptr ds:[di]
    cmp al,ah
    je Inquire_check_loop
    jne Inquire_check_finish
Inquire_check_finish:
    pop cx
    pop si
    inc si
    mov di,ss:[bp+6]
    dec cx
    jmp Inquire_find_posi
Inquire_print:
    lea si,Inquire_fail_check
    mov word ptr ds:[si],1
    mov ah,9
    mov dx,ss:[bp+12];要输出的行
    int 21h
Inquire_check_ret:
    mov sp,bp
    pop bp
    ret 10


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


get_name_length_from_file:
    xor cx,cx
    lea si,Profile_input+12
get_name_length_loop:
    inc si
    inc cx
    cmp byte ptr ds:[si],' '
    jne get_name_length_loop
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
    lea si,Profile_input+13
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
    lea si,Profile_input_length
    mov di,[si]
    lea si,Profile_input+1
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


get_buffer_length_to_cr:;读取缓冲区字符的长度到CR截止
    push bp
    mov bp,sp
    push cx
    push bx
    xor cx,cx
    xor bx,bx
    mov si,ss:[bp+6]
buffer_length_loop:
    mov bl,byte ptr ds:[si];获取输入的每一个字符
    inc cx;cx保存buffer的长度
    cmp bl,13;CR 回车符
    je save_buffer_length
    inc si
    jmp buffer_length_loop
save_buffer_length:
    mov si,ss:[bp+4]
    mov [si],cx

    pop bx
    pop cx
    mov sp,bp
    pop bp
    ret 4


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

write_file:;写入文件
    mov cx,128
    lea si,file_handle
    mov bx,[si]
    mov ah,40h
    lea dx,Profile_input+2
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


set_current_file_position:
    push bp
    mov bp,sp
    push ax
    push bx
    push cx
    push dx

    mov ax,128
    mov bx,word ptr ss:[bp+4]
    mul bx
    mov cx,dx
    mov dx,ax;确定要读取哪一行
    xor ax,ax
    mov ah,42h
    lea si,file_handle
    mov bx,[si]
    int 21h
    
    pop dx
    pop cx
    pop bx
    pop ax
    mov sp,bp
    pop bp
    ret 2

first_show:
    call refresh_screem
    mov ah,2;光标定位
    mov bh,0
    mov dh,5
    mov dl,12
    int 10h

    mov ax,data;输出welcome
    mov ds,ax
    mov dx,offset welcome
    mov ah,9
    int 21h

    mov ah,1;键盘输入，键入值在al
    int 21h

    call refresh_screem
    ret

refresh_screem:
    mov cx,25
    k:mov ax,data;输出多行空格
    mov ds,ax
    mov dx,offset blanket
    mov ah,9
    int 21h
    loop k
    ret

code ends
end main