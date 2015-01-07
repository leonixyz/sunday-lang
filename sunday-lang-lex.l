 /* EXAMPLES                                          */
 /* Ansi C                                            */
 /* http://www.lysator.liu.se/c/ANSI-C-grammar-l.html */


%option noyywrap
%{
#include <stdlib.h>
#include <string.h>
%}


 /* Basic tokens, used only for lex internal processing */
DIGIT   [0-9]
LETTER  [a-zA-Z]

 /* Tokens without associated values */
VAR     variable
IF      if
THEN    then
ELSE    else
WHILE   while
END     end

 /* Tokens with associated values */
NUM     {DIGIT}+(\.{DIGIT}+)?
ID      {LETTER}({LETTER}|{DIGIT})*


 /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%%
 /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */


 /* Skip blanks */
[ ]     {}

 /* Tokens without associated values */
{VAR}   {return VAR;}
{IF}    {return IF;}
{THEN}  {return THEN;}
{ELSE}  {return ELSE;}
{WHILE} {return WHILE;}
{END}   {return END;}
"("     {return '(';}
")"     {return ')';}
"="     {return '=';}
"+"     {return '+';}
"-"     {return '-';}
"*"     {return '*';}
"/"     {return '/';}
\n      {return '\n';}

 /* Tokens with associated values */
{NUM}   {
                yylval.value = atof(yytext);
                return NUM;
        }

{ID}    {
                yylval.lexeme = strdup(yytext);
                return ID;
        }


 /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%%
 /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */


