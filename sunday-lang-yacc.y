%{
#include <stdlib.h>     /* TODO revise includes when the work is over */ 
#include <string.h>     /*      to remove what is not necessary       */
#include <ctype.h>
#include <stdio.h>
#include "include/symbol-table.h"
#include "include/parse-tree.h"


/* Size of a tnode structure (heavily used by malloc) */
const int TNODE_SIZE = sizeof (struct tnode);

/* Parse tree at the end of parsing. */
struct ptree *parse_tree;
%}


/* Print some additional information. */
%error-verbose


/* We only pass tnode structures into yylval. */
%union {
        struct tnode *tnode;
}


/* Terminals. */
%token <tnode> SET
%token <tnode> VAR
%token <tnode> TO
%token <tnode> IF
%token <tnode> THEN
%token <tnode> ELSE
%token <tnode> WHILE
%token <tnode> DO 
%token <tnode> END
%token <tnode> ID
%token <tnode> NUM
%token <tnode> STRING
%token <tnode> OPBR 
%token <tnode> CLBR
%token <tnode> EQUA
%token <tnode> PLUS
%token <tnode> MINU
%token <tnode> MULT
%token <tnode> DIVI


/* Declarement of typed non-terminals. */
%type <tnode> program 
%type <tnode> block
%type <tnode> stmtlist
%type <tnode> stmt
%type <tnode> assignment
%type <tnode> if
%type <tnode> while
%type <tnode> expr


/* Declarements of operators in increasing order of precedence. */
%left EQUA
%left MINU PLUS
%left MULT DIVI
%right UMINUS


/* Definition of the scope of the language. */
%start program



/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */



/* Scope of the language. */
program
        : program block 
                {
                        struct tnode *root = calloc (1, TNODE_SIZE);
                        struct tnode *nodes[] = {$1, $2};
                        $$ = parse_tree->root = root = create_branch(nodes, 2);
                }
        
        | block
                {
                        struct tnode *root = calloc (1, TNODE_SIZE);
                        struct tnode *nodes[] = {$1};
                        $$ = parse_tree->root = root = create_branch(nodes, 1);
                }

        ;


/* Code block. */
block
        : OPBR stmtlist CLBR
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = create_branch(nodes, 3);
                }
        ;


/* List of statements. */
stmtlist
        : stmtlist stmt
                {
                        struct tnode *nodes[] = {$1, $2};
                        $$ = create_branch(nodes, 2);
                }

        | stmt
                {
                        struct tnode *nodes[] = {$1};
                        $$ = create_branch(nodes, 1);
                }
        ;


/* Single statement. */
stmt
        : assignment
                {
                        struct tnode *nodes[] = {$1};
                        $$ = create_branch(nodes, 1);
                }

        | if
                {
                        struct tnode *nodes[] = {$1};
                        $$ = create_branch(nodes, 1);
                }

        | while
                {
                        struct tnode *nodes[] = {$1};
                        $$ = create_branch(nodes, 1);
                }

        | expr
                {
                        struct tnode *nodes[] = {$1};
                        $$ = create_branch(nodes, 1);
                }
        ;


/* Assignment statement. */
assignment
        : SET VAR ID TO expr
                {
                        struct tnode *nodes[] = {$3, $4, $5};
                        $$ = create_branch(nodes, 3);
                }

        | SET VAR ID TO STRING
                {
                        struct tnode *nodes[] = {$3, $4, $5};
                        $$ = create_branch(nodes, 3);
                }
        ;


/* Statement if (else)? */
if
        : IF expr THEN stmtlist END
                {
                        struct tnode *nodes[] = {$1, $2, $3, $4, $5};
                        $$ = create_branch(nodes, 5);
                }

        | IF expr THEN stmtlist ELSE stmtlist END
                {
                        struct tnode *nodes[] = {$1, $2, $3, $4, $5, $6, $7};
                        $$ = create_branch(nodes, 7);
                }
        ;


/* While loop. */
while
        : WHILE expr DO stmtlist END
                {
                        struct tnode *nodes[] = {$1, $2, $3, $4, $5};
                        $$ = create_branch(nodes, 5);
                }
        ;


/* Expression */
expr    
        : expr PLUS expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = create_branch(nodes, 3);
                }

        | expr MINU expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = create_branch(nodes, 3);
                }

        | expr MULT expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = create_branch(nodes, 3);
                }

        | expr DIVI expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = create_branch(nodes, 3);
                }

        | MINU expr %prec UMINUS
                {
                        struct tnode *nodes[] = {$1, $2};
                        $$ = create_branch(nodes, 2);
                }

        | OPBR expr CLBR
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = create_branch(nodes, 3);
                }

        | NUM
                {
                        struct tnode *nodes[] = {$1};
                        $$ = create_branch(nodes, 1);
                }
        ;



/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */



#include "lex.yy.c"


/* Give hints about parsing errors. */
int yyerror (const char *str)
{
        fprintf (stderr, "Parse error: %s\n", str);
}


/* Parse and print the output to destination file. */
int main ()
{
        parse_tree = malloc (sizeof (struct ptree));
        yyparse ();
        pt_traverse (parse_tree, stdout);
}
