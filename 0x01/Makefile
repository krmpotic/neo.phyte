targets = coffee popcount popcount2

all: $(targets)

$(targets): %: %.asm
	nasm -f elf64 -o $@.o $@.asm
	ld -o $@ $@.o

clean:
	rm -f *.o
	rm -f $(targets)

.PHONY: all clean
