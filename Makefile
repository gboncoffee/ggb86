os_image32.img: bios_x86 kernel32
	cat $^ > $@
	truncate $@ -s 16K

bios_x86: bios_x86.s
	nasm -f bin $^ -o $@

kernel32: kernel_entry32.o kernel32.o
	ld -m elf_i386 -o $@ -Ttext 0x1000 $^ --oformat binary

kernel_entry32.o: kernel_entry32.s
	nasm -f elf32 $^ -o $@

kernel32.o: kernel32.c
	gcc -m32 -fno-pic -ffreestanding -c $^ -o $@

clean:
	-rm *.o os_image32.img bios_x86 kernel32
