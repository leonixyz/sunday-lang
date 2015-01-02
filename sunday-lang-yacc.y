%{

/* http://www.lysator.liu.se/c/ANSI-C-grammar-y.html */

#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
%}

/* values passed by lex */
%union {
        char* lexeme;
        double value;
}

%token VAR
%token IF
%token THEN
%token ELSE
%token WHILE
%token END
%token <lexeme> ID
%token <value>  NUM

%type <value> expr      /* expr has type double */

%left '-' '+'
%left '*' '/'
%right UMINUS
%left '='       /* used for assignments */


%start program  /* scope of the language */

%%
program
        : block program         {/* ??? */}
        ;

block
        : '(' stmtlist ')'     {/* ??? */}
        ;

stmtlist
        : stmt stmtlist         {/* ??? */}
        | stmt                  {/* ??? */}
        ;

stmt
        : assignment                    {/* ??? */}
        | IF expr THEN block else       {/* ??? */}
        | WHILE expr block END          {/* ??? */}
        ;

else
        : ELSE block END        {/* ??? */}
        | END                   {/* ??? */}
        ;

expr    
        : expr '+' expr           {$$ = $1 + $3;}
        | expr '-' expr           {$$ = $1 - $3;}
        | expr '*' expr           {$$ = $1 * $3;}
        | expr '/' expr           {$$ = $1 / $3;}
        | NUM                     {$$ = $1;}
        | ID                      {/* ??? */}
        | '-' expr %prec UMINUS   {$$ = -$2;}
        | '(' expr ')'            {$$ = $2;}
        ;

%%

#include "lex.yy.c"
