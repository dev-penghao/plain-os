all:clear boot/boot.bin init/init.o image


boot/boot.bin:boot/boot.asm boot/loader.asm
	nasm boot/boot.asm -o boot/boot.bin
	nasm boot/loader.asm -o boot/loader.bin

init/init.o:
	make -C init

image:
	#ld -s -m elf_i386 init/init.o -o system.o
	cp init/init.o system.o
	objcopy -O binary -R .note -R .comment  system.o system.bin
	dd if=boot/boot.bin of=a.img conv=notrunc
	dd if=boot/loader.bin of=a.img seek=1 count=4 conv=notrunc
	dd if=system.bin of=a.img seek=5 conv=notrunc
	
clear:
	rm -f boot/*.bin system.bin system.o
	make clear -C init
