

boot:boot.asm loader.asm kernel.asm
	nasm boot.asm -o boot.bin
	nasm loader.asm -o loader.bin
	nasm -f elf kernel.asm -o kernel.o
	gcc -c -m32 test.c -o test.o
	ld -s -m elf_i386 kernel.o test.o -o tem_kernel.o
	objcopy -O binary -R .note -R .comment  tem_kernel.o kernel
	dd if=boot.bin of=a.img conv=notrunc
	dd if=loader.bin of=a.img seek=1 count=4 conv=notrunc
	dd if=kernel of=a.img seek=5 conv=notrunc
	
clear:
	rm -f *.bin *.o
