CC=gcc
LEX=flex
YACC=yacc
CFLAGS=-Iinclude
VERBOSE=--verbose

sunday-lang: include/symbol-table.o include/parse-tree.o
	$(LEX) -l sunday-lang-lex.l
	$(YACC) -vd sunday-lang-yacc.y $(VERBOSE)
	$(CC) -o sundayc y.tab.c include/symbol-table.o include/parse-tree.o -ly 

sunday-lang-debug: include/symbol-table.o include/parse-tree.o
	$(LEX) -l sunday-lang-lex.l
	$(YACC) -vd sunday-lang-yacc.y $(VERBOSE)
	$(CC) -g -o sundayc y.tab.c include/symbol-table.o include/parse-tree.o -ly 

clean:
	rm include/symbol-table.o include/parse-tree.o lex.yy.c y.tab.c y.tab.h y.output sundayc

