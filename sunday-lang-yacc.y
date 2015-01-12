%{
#include <stdlib.h>     /* TODO revise includes when the work is over */ 
#include <string.h>     /*      to remove what is not necessary       */
#include <ctype.h>
#include <stdio.h>
#include "include/symbol-table.h"
#include "include/parse-tree.h"

struct tnode *get_new_root(struct tnode *nodes[], int count);

/* Current root of the parse tree used during parsing. */
struct tnode *root;

/* Size of a tnode structure (heavily used for malloc) */
const int TNODE_SIZE = sizeof (struct tnode);
%}


/* Print some additional information */
%error-verbose


/* Fields passed by lex into struct yylval. */
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
        : block program
                {
                        struct tnode *nodes[] = {$1, $2};
                        root = get_new_root(nodes, 2);
                        $$ = root;
                }
        
        | block
                {
                        struct tnode *nodes[] = {$1};
                        root = get_new_root(nodes, 1);
                        $$ = root;
                }

        ;


/* Code block. */
block
        : OPBR stmtlist CLBR
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        root = get_new_root(nodes, 3);
                        $$ = root;
                }
        ;


/* List of statements. */
stmtlist
        : stmt stmtlist
                {
                        struct tnode *nodes[] = {$1, $2};
                        root = get_new_root(nodes, 2);
                        $$ = root;
                }

        | stmt
                {
                        struct tnode *nodes[] = {$1};
                        root = get_new_root(nodes, 1);
                        $$ = root;
                }
        ;


/* Single statement. */
stmt
        : assignment
                {
                        struct tnode *nodes[] = {$1};
                        root = get_new_root(nodes, 1);
                        $$ = root;
                }

        | if
                {
                        struct tnode *nodes[] = {$1};
                        root = get_new_root(nodes, 1);
                        $$ = root;
                }

        | while
                {
                        struct tnode *nodes[] = {$1};
                        root = get_new_root(nodes, 1);
                        $$ = root;
                }

        | expr
                {
                        struct tnode *nodes[] = {$1};
                        root = get_new_root(nodes, 1);
                        $$ = root;
                }
        ;


/* Assignment statement. */
assignment
        : SET VAR ID TO expr
                {
                        struct tnode *nodes[] = {$3, $4, $5};
                        root = get_new_root(nodes, 3);
                        $$ = root;
                }

        | SET VAR ID TO STRING
                {
                        struct tnode *nodes[] = {$3, $4, $5};
                        root = get_new_root(nodes, 3);
                        $$ = root;
                }
        ;


/* Statement if (else)? */
if
        : IF expr THEN stmtlist END
                {
                        struct tnode *nodes[] = {$1, $2, $3, $4, $5};
                        root = get_new_root(nodes, 5);
                        $$ = root;
                }

        | IF expr THEN stmtlist ELSE stmtlist END
                {
                        struct tnode *nodes[] = {$1, $2, $3, $4, $5, $6, $7};
                        root = get_new_root(nodes, 7);
                        $$ = root;
                }
        ;


/* While loop. */
while
        : WHILE expr DO stmtlist END
                {
                        struct tnode *nodes[] = {$1, $2, $3, $4, $5};
                        root = get_new_root(nodes, 5);
                        $$ = root;
                }
        ;


/* Expression */
expr    
        : expr PLUS expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        root = get_new_root(nodes, 3);
                        $$ = root;
                }

        | expr MINU expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        root = get_new_root(nodes, 3);
                        $$ = root;
                }

        | expr MULT expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        root = get_new_root(nodes, 3);
                        $$ = root;
                }

        | expr DIVI expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        root = get_new_root(nodes, 3);
                        $$ = root;
                }

        | MINU expr %prec UMINUS
                {
                        struct tnode *nodes[] = {$1, $2};
                        root = get_new_root(nodes, 2);
                        $$ = root;
                }

        | OPBR expr CLBR
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        root = get_new_root(nodes, 3);
                        $$ = root;
                }

        | NUM
                {
                        struct tnode *nodes[] = {$1};
                        root = get_new_root(nodes, 1);
                        $$ = root;
                }
        ;



/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */



#include "lex.yy.c"


/* Dynamically add nodes (coming from lex) to a new parse tree root. */
struct tnode *get_new_root (struct tnode *nodes[], int size)
{
        if (size < 1)
                yyerror ("Cannot add less than one node to the parse tree.");

        int i;
        struct tnode *current;
        struct tnode *newroot;
        
        /* Create a new root. */
        newroot = calloc (1, TNODE_SIZE);

        /* Set the first child of the new root. */
        newroot->child = nodes[0];
        current = newroot->child;
        
        /* Set the other children of the new root. */
        for (i = 1; i < size; i++) {
                current->next = nodes[i];
                current = current->next;
        }
 
        return newroot;
}


/* Give hints about parsing errors. */
int yyerror (const char *str)
{
        fprintf (stderr, "Parse error: %s\n", str);
}


/* Parse and print the output to destination file. */
int main ()
{
        yyparse ();
        struct ptree *t;
        t = malloc (sizeof (struct ptree));
        t->root = root;
        pt_traverse (t, stdout);
}
