CC=gcc
LEX=flex
YACC=yacc
CFLAGS=-Iinclude
VERBOSE=--verbose

# Build the compiler
sunday-lang: include/symbol-table.o include/parse-tree.o
	$(LEX) -l sunday-lang-lex.l
	$(YACC) -vd sunday-lang-yacc.y
	$(CC) -o sundayc y.tab.c include/symbol-table.o include/parse-tree.o -ly 

# Build the compiler with debug info
sunday-lang-debug:
	$(CC) -g -c -o include/symbol-table.o include/symbol-table.c
	$(CC) -g -c -o include/parse-tree.o include/parse-tree.c
	$(LEX) -l sunday-lang-lex.l
	$(YACC) -vd sunday-lang-yacc.y $(VERBOSE)
	$(CC) -g -o sundayc y.tab.c include/symbol-table.o include/parse-tree.o -ly 

# Install the compiler
install:
	cp sundayc /usr/bin

# Clean compiled objects
clean:
	rm include/symbol-table.o include/parse-tree.o lex.yy.c y.tab.c y.tab.h y.output sundayc

