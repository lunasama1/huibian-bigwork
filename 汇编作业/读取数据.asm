assume cs:code, ds:data

data segment
path_name db 'c:\students.txt',00
codename db 16 dup(0)
buffer db 200 dup(0)
data ends

code segment
main:mov ax,data
mov ds,ax

call open

mov ax,4c00h
int 21h

open:mov ah,3dh;打开文件
mov al,00h;只读
lea dx,path_name
int 21h
mov bx,offset codename
mov [bx],ax

mov di,0
mov cx,0
push cx
push di
read:mov si,offset codename
mov ah,3fh
mov dx,offset buffer
add dx,di;计算偏移
mov bx,[si]
mov cx,1h
int 21h;到此为读取一个字符至buffer
mov bx,dx
mov cx,ds:[bx]
cmp cl,0dh
je check;判断是否为0d结尾如是则跳转判断
inc di
jmp read

check:mov ah,3fh
inc di
mov dx,offset buffer
add dx,di
mov bx,[si]
mov cx,1h
int 21h;继续读取一个字符至buffer

pop bx
pop cx
inc cx
sub di,bx
mov ax,di
mov bl,16
div bl
mov ah,0
add cx,ax

push cx;计算偏移
mov bx,dx
mov ax,ds:[bx]
cmp al,0ah
je addmove

close:lea si,codename
mov bx,[si]
mov ah,3eh
int 21h
pop ax
ret

addmove:mov al,cl
mov cl,16
mul cl
mov di,ax
push di
jmp read

mainend:mov ax,4c00h
int 21h

code ends
end main