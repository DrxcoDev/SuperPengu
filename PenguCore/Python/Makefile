CC = gcc
CFLAGS = -Wall -std=c99

all: python_compiler

python_compiler: compiler.c lexer.c parser.c
	$(CC) $(CFLAGS) -o python_compiler compiler.c lexer.c parser.c

clean:
	rm -f python_compiler
