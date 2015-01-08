CC=gcc
LEX=flex
YACC=yacc
CFLAGS=-Iinclude

sunday-lang: include/symbol-table.o include/parse-tree.o
	$(LEX) -l sunday-lang-lex.l
	$(YACC) -vd sunday-lang-yacc.y
	$(CC) -o sundayc y.tab.c include/symbol-table.o include/parse-tree.o -ly 

sunday-lang-debug: include/symbol-table.o include/parse-tree.o
	$(LEX) -l sunday-lang-lex.l
	$(YACC) -vd sunday-lang-yacc.y
	$(CC) -g -o sundayc y.tab.c include/symbol-table.o include/parse-tree.o -ly 

