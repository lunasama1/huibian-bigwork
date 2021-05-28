assume cs:code

data segment
db 'Welcome to masm!',0
data ends

code segment
start:mov dh,8
mov dl,3
mov cl,2
mov ax,data
mov ds,ax
mov si,0
call show_str
mov ax,4c00h
int 21h

show_str:
mov ax,0b800h
mov es,ax
mov al,160
mul dh
mov dh,0
add ax,dx
mov bx,ax
mov ah,cl

k:
mov cl,ds:[si]
mov ch,0
jcxz ok
mov al,cl
mov es:[bx-1],ax
inc bx
inc bx
inc si
jmp short k

ok:ret
code ends
end start