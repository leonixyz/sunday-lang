sunday-lang: symbol-table.o
	flex -l sunday-lang-lex.l
	yacc -vd sunday-lang-yacc.y
	gcc -o sundayc y.tab.c symbol-table.o -ly 

sunday-lang-debug: symbol-table.o
	flex -l sunday-lang-lex.l
	yacc -vd sunday-lang-yacc.y
	gcc -g -o sundayc y.tab.c symbol-table.o -ly 

