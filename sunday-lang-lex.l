 /* EXAMPLES                                          */
 /* Ansi C                                            */
 /* http://www.lysator.liu.se/c/ANSI-C-grammar-l.html */


%option noyywrap
%{
#include <stdlib.h>
#include <string.h>
#include "include/symbol-table.h"
%}


 /* Basic tokens, used only for lex internal processing */
DIGIT   [0-9]
LETTER  [a-zA-Z]

 /* Tokens without associated values */
SET     set
VAR     variable
TO      to
IF      if
THEN    then
ELSE    else
WHILE   while
DO      do
END     end

 /* Tokens with associated values */
NUM     {DIGIT}+(\.{DIGIT}+)?
ID      {LETTER}({LETTER}|{DIGIT})*
STRING  "([^"]|\\")*"

 /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%%
 /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */


 /* Skip blanks and newlines */
[ \n]     {}

 /* Tokens without associated values */
{SET}   {return SET;}
{VAR}   {return VAR;}
{TO}    {return TO;}
{IF}    {return IF;}
{THEN}  {return THEN;}
{ELSE}  {return ELSE;}
{WHILE} {return WHILE;}
{DO}    {return DO;}
{END}   {return END;}
"("     {return '(';}
")"     {return ')';}
"="     {return '=';}
"+"     {return '+';}
"-"     {return '-';}
"*"     {return '*';}
"/"     {return '/';}

 /* Tokens with associated values */
{NUM}    {yylval.value = atof (yytext);return NUM;}
{ID}     {yylval.lexeme = strdup (yytext);return ID;}
{STRING} {yylval.lexeme = strdup (yytext);return STRING;}


 /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%%
 /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */



