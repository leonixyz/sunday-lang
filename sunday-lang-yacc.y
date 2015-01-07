/*
 *  EXAMPLES
 *
 *  Snail (simple language, good for looking at the grammar)
 *  http://www.cs.rpi.edu/~moorthy/courses/modcomp/projects/project2/project2.pdf
 *
 *  Symbol table example
 *  http://dinosaur.compilertools.net/bison/bison_5.html#SEC29
 *
 *  Ansi C (very complex, useful for optimizations)
 *  http://www.lysator.liu.se/c/ANSI-C-grammar-y.html
 *
 */


%{
#include <stdlib.h>     /* TODO revise includes when the work is over */ 
#include <string.h>     /*      to remove what is not necessary       */
#include <ctype.h>
#include <stdio.h>
#include "symbol-table.h"

/* Global string containing the final output. */
char *output = "";
%}


/* Fields passed by lex into struct yylval. */
%union {
        char* lexeme;
        double value;
}


/* Terminals. */
%token SET
%token VAR
%token TO
%token IF
%token THEN
%token ELSE
%token WHILE
%token DO 
%token END
%token <lexeme> ID
%token <value>  NUM
%token <lexeme> STRING

/* Declarements of typed non-terminals. */
%type <value> expr


/* Declarements of operators in increasing order of precedence. */
%left '='
%left '-' '+'
%left '*' '/'
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
                        /* Base case: the scope of the language has been
                         * reached. The output has to be redirected to a
                         * file or to stdout.
                         */
                        printf ("%s", output);
                }

        | block program
                {
                        /* TODO */
                }
        ;


/* Code block. */
block
        : '(' stmtlist ')'
                {
                        /* TODO */
                }
        ;


/* List of statements. */
stmtlist
        : stmtlist stmt 
                {
                        /* TODO */
                }

        | stmt
                {
                        /* TODO */
                }
        ;


/* Single statement. */
stmt
        : assignment
                {
                        /* TODO */
                }

        | if
                {
                        /* TODO */
                }

        | while
                {
                        /* TODO */
                }

        | expr
                {
                        /* TODO */
                }
        ;


/* Assignment statement. */
assignment
        : SET VAR ID TO expr
                {
                        /* TODO */
                }

        | SET VAR ID TO STRING
                {
                        /* TODO */
                }
        ;


/* Statement if (else)? */
if
        : IF expr THEN stmtlist END
                {
                        /* TODO */
                }

        | IF expr THEN stmtlist ELSE stmtlist END
                {
                        /* TODO */
                }
        ;


/* While loop. */
while
        : WHILE expr DO stmtlist END
                {
                        /* TODO */
                }
        ;


/* Expression */
expr    
        : functioncall
                {
                        /* TODO */
                }
        
        | expr '+' expr
                {
                        /* TODO */
                }

        | expr '-' expr
                {
                        /* TODO */
                }

        | expr '*' expr
                {
                        /* TODO */
                }

        | expr '/' expr
                {
                        /* TODO */
                }

        | '-' expr %prec UMINUS
                {
                        /* TODO */
                }

        | '(' expr ')'
                {
                        /* TODO */
                }

        | NUM
                {
                        char str[80];
                        sprintf (str, "%lf", $1)
                        strcat (output, str);
                }

        | ID
                {
                        strcat (output, $1);
                }
        
        | STRING
                {
                        strcat (output, $1);
                }

        | STRING expr
                {
                        /* TODO */
                }
        ;


/* A Function call to an existent C function */
prefix
        : ID EXPR
                {
                        $1 ($2);
                }
        ;


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */


#include "lex.yy.c"
