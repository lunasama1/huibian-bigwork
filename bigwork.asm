assume cs:code,ds:data

data segment
path_name db 'c:\123.txt',00
error db 'sorry.there is something error','$'
stringa db 'i like it','$'
codename db 10 dup(0)
buffer db 13 dup(0)
welcome db 'welcome to exam management system','$'
second db '1.enter your mark 2.read all message 3.exit','$'
source db 'name:','$'
source2 db 'number:','$'
source3 db 'mark:','$'
source4 db 'press 1 to continue or press 0 to leave','$'
blanket db 0ah,'$'
data ends

dataname segment
namedata db 300 dup (0)
dataname ends

datanumber segment
numberdata db 200 dup (0)
datanumber ends

datamark segment
markdata db 500 dup (0)
datamark ends

code segment

start:call refresh_screem
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

mov ax,data;创造文件123.txt，可以覆盖创造
mov ds,ax
mov ah,3ch
mov cx,00
lea dx,path_name
int 21h
jnb secondmenu
jmp next

secondmenu:
    call refresh_screem
    mov ah,2;光标定位
    mov bh,0
    mov dh,5
    mov dl,2
    int 10h

    mov ax,data;输出二级菜单
    mov ds,ax
    mov dx,offset second
    mov ah,9
    int 21h

    mov ah,2;光标定位
    mov bh,0
    mov dh,12
    mov dl,0
    int 10h

    mov ah,1;键盘输入，键入值在al
    int 21h

    cmp al,31h;判断跳转
    je inputch

    cmp al,32h
    je output

    cmp al,33h
    je final_end

    lea si,codename;关闭文件
    mov ah,3fh
    mov bx,[si]
    int 21h
    jnb final_end
    jmp next

    final_end:mov ax,4c00h
    int 21h

    output:mov ax,4c00h
    int 21h

    inputch:call refresh_screem
    mov ah,2;光标定位
    mov bh,0
    mov dh,9
    mov dl,0
    int 10h

    mov ax,data;输出'name:'
    mov ds,ax
    mov dx,offset source
    mov ah,9
    int 21h

    mov ah,0ah;键盘输入，键入值在namedata
    lea dx,namedata
    int 21h

    call keyup
    mov ax,data;输出'number:'
    mov ds,ax
    mov dx,offset source2
    mov ah,9
    int 21h

    mov ah,0ah;键盘输入，键入值在numberdata
    lea dx,numberdata
    int 21h

    call keyup
    mov ax,data;输出'mark:'
    mov ds,ax
    mov dx,offset source3
    mov ah,9
    int 21h

    mov ah,0ah;键盘输入，键入值在markdata
    lea dx,markdata
    int 21h

    call keyup
    mov ax,data;输出'press 1 to continue or press 0 to leave'
    mov ds,ax
    mov dx,offset source4
    mov ah,9
    int 21h

    mov ah,1;键盘输入，键入值在al
    int 21h

    cmp al,31h
    je inputch
    jmp secondmenu

    keyup:mov ax,data;输出空格
    mov ds,ax
    mov dx,offset blanket
    mov ah,9
    int 21h
    ret

    refresh_screem:mov cx,25
    k:mov ax,data;输出多行空格
    mov ds,ax
    mov dx,offset blanket
    mov ah,9
    int 21h
    loop k
    ret

next:mov ah,2;光标定位
mov bh,0
mov dh,5
mov dl,12
int 10h

mov ax,data;输出welcome
mov ds,ax
mov dx,offset error
mov ah,9
int 21h

mov ax,4c00h
int 21h

code ends
end start