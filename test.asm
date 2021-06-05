assume cs:code
data segment
file                    db 'students.txt',0
file_handle             db ?,?;保存文件句柄,共两个字节
Profile_input           db 128;学生信息缓冲
                        db ?
                        db 128 dup(?),'$'
final_score_sort        db 256 dup(?);前两个??代表属于第几行,后两个??用于记录总成绩
final_score_integer     db ?,?;保存总成绩的整数部分
final_score_decimal     db ?,?;保存总成绩的小数部分
final_score_posi        db ?,?;保存从文件中读取出的总成绩的位置
total_number            db ?,?;保存学生总数
data ends
code segment
main:
    mov ax,data
    mov ds,ax

    call get_final_score_from_file
    call descending_sort
    call sort_print
    mov ax,4c00h
    int 21h

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
    lea si,total_number
    mov cx,word ptr ds:[si]
    lea bx,final_score_sort
sort_print_loop:
    mov ax,word ptr ds:[bx]
    push ax
    call set_current_file_position
    call read_file
    lea dx,Profile_input+2
    mov ah,9
    int 21h
    add bx,4
    loop sort_print_loop
    call close_file
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
    push dx

    lea si,file_handle
    mov bx,[si]
    lea si,Profile_input+2
    mov dx,si
    mov cx,128
    mov ah,3fh
    int 21h

    pop dx
    pop cx
    pop bx
    ret

close_file:;关闭文件
    lea si,file_handle
    mov bx,[si]
    mov ah,3eh
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
code ends
end main