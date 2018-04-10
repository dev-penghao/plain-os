%include "pm.inc"

extern main

[section .text]	; 代码在此

global _start	; 导出 _start
global hlt
_start:	; 跳到这里来的时候，我们假设 gs 指向显存
	lgdt [ds:gdt_48]
	mov ax,0x0008
	mov ds,ax
	mov es,ax
	mov fs,ax
	mov ax,0x0020
	mov gs,ax
	call set_idt
	call main
	int 0x80
	jmp $

set_idt:
	cli
	lidt [ds:idt_48]
	call init8259A
	ret

init8259A:
	mov al,0x11
	out 0x20,al
	call io_delay

	out 0xa0,al
	call io_delay

	mov al,0x20
	out 0x21,al
	call io_delay

	mov al,0x28
	out 0xa1,al
	call io_delay

	mov al,0x04
	out 0x21,al
	call io_delay

	mov al,0x02
	out 0xa1,al
	call io_delay

	mov al,0x01
	out 0x21,al
	call io_delay

	out 0xa1,al
	call io_delay

	mov al,1111_1110b
	out 0x21,al
	call io_delay

	mov al,1111_1111b
	out 0xa1,al
	call io_delay

	ret

io_delay:
	nop
	nop
	nop
	nop
	ret

hlt:
	hlt
	ret

_intruppt:
intruppt equ _intruppt-$$
	mov ah,0x0c
	mov al,'!'
	mov [gs:0],ax
	ret

gdt:
	dd 0,0	;NULL!
	dd 0x0000ffff,0x00cf9200 ;date seg=0,lim=4GB sel=0x0008 全局数据段
	Descriptor 0x10800, 0xffff, DA_CR|DA_32
	dd 0x0800ffff,0x00cf9a01 ;code seg=0x10800,lim=1MB sel=0x0010 内核代码段
	Descriptor 0B8000h, 0ffffh, DA_DRW | DA_DPL0	; 显存首地址
	;低————>高
	;段界限，段基地址

gdt_48:
	dw $-gdt-1	;gdt表描述符个数-1
	dd gdt	;32位gdt基地址

idt:
	%rep 255
		Gate 0x0018,intruppt,0,DA_386IGate
	%endrep

idt_48:
	dw $-idt-1
	dd idt
