false: false.asm
	nasm -f elf64 -o false.o false.asm
	ld -o false false.o

clean:
	rm -f false.o false

.PHONY: clean
