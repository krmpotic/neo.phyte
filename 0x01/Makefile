NAME=popcount

$(NAME): $(NAME).asm
	nasm -f elf64 -o $(NAME).o $(NAME).asm
	ld -o $(NAME) $(NAME).o

clean:
	rm -f $(NAME).o $(NAME)

.PHONY: clean
