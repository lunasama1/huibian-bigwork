assume cs:code, ds:data

data segment
path_name db 'c:\students.txt',00
codename db 10 dup(0)
buffer db 128 dup(0)
data ends

;stack segment
;buffer db 128 dup(0)
;stack ends

code segment
main:mov ax,data
mov ds,ax

mov ah,3dh;打开文件
mov al,00h
lea dx,path_name
int 21h
lea bx,codename
mov [bx],ax

lea si,codename
mov ah,3fh
lea dx,buffer
mov bx,[si]
mov cx,13h
int 21h

lea si,codename
mov ah,3eh
mov bx,[si]
int 21h

mov ax,4c00h
int 21h

code ends
end main