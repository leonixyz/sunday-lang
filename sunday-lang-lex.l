
%{
// http://www.lysator.liu.se/c/ANSI-C-grammar-l.html
%}

%option noyywrap
%{
#include <stdlib.h>
#include <string.h>
%}

DIGIT    [0-9]
LETTER   [a-zA-Z]

VAR     variable
IF      if
THEN    then
ELSE    else
WHILE   while
END     end

NUM     {DIGIT}+(\.{DIGIT}+)?
ID      {LETTER}({LETTER}|{DIGIT})*


%%

[ ]     { /* skip blanks */ }

{VAR}   {return VAR;}
{IF}    {return IF;}
{THEN}  {return THEN;}
{ELSE}  {return ELSE;}
{WHILE} {return WHILE;}
{END}   {return END;}

{NUM}   {yylval.value = atof(yytext);
        return NUM;}

{ID}    {yylval.lexeme = strdup(yytext);
        return ID;}

"("     {return '(';}
")"     {return ')';}
"="     {return '=';}
"+"     {return '+';}
"-"     {return '-';}
"*"     {return '*';}
"/"     {return '/';}
\n      {return '\n';}
  


%%
