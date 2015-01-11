%{
#include <stdlib.h>     /* TODO revise includes when the work is over */ 
#include <string.h>     /*      to remove what is not necessary       */
#include <ctype.h>
#include <stdio.h>
#include "include/symbol-table.h"
#include "include/parse-tree.h"

/* Current root of the parse tree used during parsing. */
struct tnode *root;

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
        : block
                {
                        struct tnode *newroot = malloc (sizeof (struct tnode));
                        newroot->child = $1;
                        root = newroot;
                }

        | block program
                {
                        struct tnode *newroot = malloc (sizeof (struct tnode));
                        newroot->child = $1;
                        newroot->child->next = $2;
                        root = newroot;
                }
        ;


/* Code block. */
block
        : OPBR stmtlist CLBR
                {
                        struct tnode *newroot = malloc (sizeof (struct tnode));
                        newroot->child = $1;
                        newroot->child->next = $2;
                        newroot->child->next->next = $3;
                        root = newroot;
                }
        ;


/* List of statements. */
stmtlist
        : stmtlist stmt 
                {
                        struct tnode *newroot = malloc (sizeof (struct tnode));
                        newroot->child = $1;
                        newroot->child->next = $2;
                        root = newroot;
                }

        | stmt
                {
                        struct tnode *newroot = malloc (sizeof (struct tnode));
                        newroot->child = $1;
                        root = newroot;
                }
        ;


/* Single statement. */
stmt
        : assignment
                {
                        struct tnode *newroot = malloc (sizeof (struct tnode));
                        newroot->child = $1;
                        root = newroot;
                }

        | if
                {
                        struct tnode *newroot = malloc (sizeof (struct tnode));
                        newroot->child = $1;
                        root = newroot;
                }

        | while
                {
                        struct tnode *newroot = malloc (sizeof (struct tnode));
                        newroot->child = $1;
                        root = newroot;
                }

        | expr
                {
                        struct tnode *newroot = malloc (sizeof (struct tnode));
                        newroot->child = $1;
                        root = newroot;
                }
        ;


/* Assignment statement. */
assignment
        : SET VAR ID TO expr
                {
                        struct tnode *newroot = malloc (sizeof (struct tnode));
                        newroot->child = $3;
                        newroot->child->next = $4;
                        newroot->child->next->next = $5;
                        root = newroot;
                }

        | SET VAR ID TO STRING
                {
                        struct tnode *newroot = malloc (sizeof (struct tnode));
                        newroot->child = $3;
                        newroot->child->next = $4;
                        newroot->child->next->next = $5;
                        root = newroot;
                }
        ;


/* Statement if (else)? */
if
        : IF expr THEN stmtlist END
                {
                        struct tnode *newroot = malloc (sizeof (struct tnode));
                        newroot->child = $1;
                        newroot->child->next = $2;
                        newroot->child->next->next = $3;
                        newroot->child->next->next->next = $4;
                        newroot->child->next->next->next->next = $5;
                        root = newroot;
                }

        | IF expr THEN stmtlist ELSE stmtlist END
                {
                        struct tnode *newroot = malloc (sizeof (struct tnode));
                        newroot->child = $1;
                        newroot->child->next = $2;
                        newroot->child->next->next = $3;
                        newroot->child->next->next->next = $4;
                        newroot->child->next->next->next->next = $5;
                        newroot->child->next->next->next->next->next = $6;
                        newroot->child->next->next->next->next->next->next = $7;
                        root = newroot;
                }
        ;


/* While loop. */
while
        : WHILE expr DO stmtlist END
                {
                        struct tnode *newroot = malloc (sizeof (struct tnode));
                        newroot->child = $1;
                        newroot->child->next = $2;
                        newroot->child->next->next = $3;
                        newroot->child->next->next->next = $4;
                        newroot->child->next->next->next->next = $5;
                        root = newroot;
                }
        ;


/* Expression */
expr    
        : expr PLUS expr
                {
                        struct tnode *newroot = malloc (sizeof (struct tnode));
                        newroot->child = $1;
                        newroot->child->next = $2;
                        newroot->child->next->next = $3;
                        root = newroot;
                }

        | expr MINU expr
                {
                        struct tnode *newroot = malloc (sizeof (struct tnode));
                        newroot->child = $1;
                        newroot->child->next = $2;
                        newroot->child->next->next = $3;
                        root = newroot;
                }

        | expr MULT expr
                {
                        struct tnode *newroot = malloc (sizeof (struct tnode));
                        newroot->child = $1;
                        newroot->child->next = $2;
                        newroot->child->next->next = $3;
                        root = newroot;
                }

        | expr DIVI expr
                {
                        struct tnode *newroot = malloc (sizeof (struct tnode));
                        newroot->child = $1;
                        newroot->child->next = $2;
                        newroot->child->next->next = $3;
                        root = newroot;
                }

        | MINU expr %prec UMINUS
                {
                        struct tnode *newroot = malloc (sizeof (struct tnode));
                        newroot->child = $1;
                        newroot->child->next = $2;
                        root = newroot;
                }

        | OPBR expr CLBR
                {
                        struct tnode *newroot = malloc (sizeof (struct tnode));
                        newroot->child = $1;
                        newroot->child->next = $2;
                        newroot->child->next->next = $3;
                        root = newroot;
                }

        | NUM
                {
                        struct tnode *newroot = malloc (sizeof (struct tnode));
                        newroot->child = $1;
                        root = newroot;
                }
        ;


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */


#include "lex.yy.c"


int yyerror (const char *str)
{
        fprintf (stderr, "Parse error: %s\n", str);
}


int main ()
{
        yyparse ();
        struct ptree *t;
        t = malloc (sizeof (struct ptree));
        t->root = root;
        pt_traverse (t, stdout);
}
