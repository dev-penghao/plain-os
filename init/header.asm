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
	mov gs,ax
	call set_idt
	call main
	jmp	$	;main应该永远都不会退出，如果真的退出那就无限循环

set_gdt:
	
	
	ret

set_idt:
	ret

dumb_interrupt:
	ret

hlt:
	hlt
	ret

gdt:
	dd 0,0	;NULL!
	
	dd 0x0000ffff,0x00cf9200 ;date seg=0,lim=4GB sel=0x0008 全局数据段
	dd 0x0800ffff,0x00cf9a01 ;code seg=0x10800,lim=1MB sel=0x0010 内核代码段
	Descriptor 0B8000h, 0ffffh, DA_DRW | DA_DPL0	; 显存首地址
	Descriptor dumb_interrupt,0xffff,DA_386IGate | DA_DPL0
	
	dw 0,0,0,0
	;低————>高
	;段界限，段基地址

gdt_48:
	dw $-gdt-1	;gdt表描述符个数-1
	dd gdt	;32位gdt基地址

idt:
	dd 0
