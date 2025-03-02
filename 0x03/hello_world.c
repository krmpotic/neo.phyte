#include <unistd.h>

int main() {
	char* hello = "HELLO WORLD!";
	write(2, hello, 12);
}
