sunday-lang: symbol-table.o
	flex -l sunday-lang-lex.l
	yacc -vd sunday-lang-yacc.y
	gcc -o sundayc y.tab.c symbol-table.o -ly 

