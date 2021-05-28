assume cs:codesg

datasg segment 
	db "Beginner's All-purpose Symbolic Instruction Code.",0
datasg ends

codesg segment
start:mov ax,datasg
mov ds,ax
mov si,0
mov cx,48
call letterc

mov ax,4c00h
int 21h

letterc:push cx
mov cl,byte ptr ds:[si]
mov ch,0
jcxz ok
mov bx,97
cmp cx,bx
jnb bigger
step:pop cx
dec cx
inc si
jmp letterc

bigger:sub byte ptr ds:[si],20h
jmp step

ok:pop cx
ret

codesg ends
end start