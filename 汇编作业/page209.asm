assume cs:codesg,ds:datasg

datasg segment
db 10 dup (0)
datasg ends

codesg segment
start:mov ax,12666
mov bx,datasg
mov ds,bx
mov si,4
call dtoc

mov dh,8
mov dl,3
mov cl,2

call show_str

mov ax,4c00H
int 21h

dtoc:
mov dx,0
mov cx,10
div cx
mov cx,ax
add dl,30h
mov byte ptr ds:[si],dl
dec si
jcxz ok
jmp short  dtoc

show_str:mov ax,datasg
mov ds,ax
mov si,0
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
codesg ends

end start


判断符号
mov word ptr cx,bx:[0]
cmp cx,0
je jiahao
mov es:[si],61
inc si
mov word ptr bx:[0],0