targets = hello_world

all: $(targets)

$(targets): %: %.asm
	nasm -f elf64 -o $@.o $@.asm
	ld -o $@ $@.o

clean:
	rm -f *.o
	rm -f *.out
	rm -f $(targets)

.PHONY: all clean hello
