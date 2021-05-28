assume cs:code,ds:data

data segment
path_name db 'c:\students.txt',00
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

datas segment
namedata db 300 dup (0)
datas ends

datat segment
numberdata db 200 dup (0)
datat ends

dataf segment
markdata db 500 dup (0)
dataf ends

code segment

start:
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
je next

lea bx,codename;向文件写入stringa
mov [bx],ax
lea si,codename
mov ah,40h
lea dx,stringa
mov bx,[si]
mov cx,9h
int 21h

lea si,codename;关闭文件
mov ah,3fh
mov bx,[si]
int 21h

finend:mov ax,4c00h
int 21h

next:mov ah,2;光标定位
mov bh,0
mov dh,5
mov dl,12
int 10h

mov ax,data;输出error
mov ds,ax
mov dx,offset error
mov ah,9
int 21h

mov ax,4c00h
int 21h

code ends
end start