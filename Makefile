sunday-lang:
	flex -l sunday-lang-lex.l
	yacc -vd sunday-lang-yacc.y
	gcc y.tab.c -ly 

