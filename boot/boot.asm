;	boot.asm:将位于第二扇区长度为4个扇区的loader读入内存0x10000处
;并跳到0x10000处执行。

start:
	jmp 0x07c0:go
go:
	mov ax,cs    ;ax = cs = 0x07c0
	mov ds,ax
	mov ss,ax
	mov sp,0x400

load_system:
	mov dx,0x0000
	mov cx,0x0002
	mov ax,0x1000
	mov es,ax	  ;es = ax = 0x1000
	xor bx,bx
	mov ax,0x200 + SYSLEN	  ;AH - read, AL = sectors
	int 0x13
	jnc ok_load
die:
	mov ax,0xb800
	mov ds,ax
	mov byte [ds:0x00],'D'
	mov byte [ds:0x02],'i'
	mov byte [ds:0x04],'e'
	mov byte [ds:0x06],'!'
	cli
	hlt

ok_load:
	jmp 0x1000:0

SYSLEN	equ 4
	
	times 510-($-$$) db 0
	db 0x55,0xaa
