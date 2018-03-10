

boot:boot.asm loader.asm kernel.asm
	nasm boot.asm -o boot.bin
	nasm loader.asm -o loader.bin
	nasm kernel.asm -o kernel
	#nasm -f elf kernel.asm -o kernel.o
	#ld -s -m elf_i386 -Ttext 0x30400 kernel.o -o kernel.ld	#‘-s’选项意为“strip all”
	#objcpy -O binary -R .note -R .comment  kernel.ld kernel
	dd if=boot.bin of=a.img conv=notrunc
	dd if=loader.bin of=a.img seek=1 count=4 conv=notrunc
	dd if=kernel of=a.img seek=5 conv=notrunc
	
clear:
	rm -f boot.bin loader.bin kernel.o kernel.ld kernel
