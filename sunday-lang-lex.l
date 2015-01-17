%option noyywrap
%{
#include <stdlib.h>
#include <string.h>
#include "include/symbol-table.h"
#include "include/parse-tree.h"

/* Prototype for helper function defined later. */
struct tnode *get_tnode (int ntype, char *str);
%}


 /* Basic tokens, used only for lex internal processing */
DIGIT   [0-9]
LETTER  [a-zA-Z]

 /* Tokens without associated values */
USE     use
SET     set
VAR     variable
TO      to
IF      if
THEN    then
ELSE    else
WHILE   while
DO      do
END     end
OPBR    \(
CLBR    \)
EQUA    =
PLUS    \+
MINU    -
MULT    \*
DIVI    \/

 /* Tokens with associated values */
NUM     {DIGIT}+(\.{DIGIT}+)?
ID      {LETTER}({LETTER}|{DIGIT})*
STRING  "([^"]|\\")*"



 /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%%
 /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */



 /* Skip blanks and newlines */
[ \n]    {}

 /* Tokens without associated tnode */
{USE}    { return USE; }
{SET}    { return SET; }
{VAR}    { return VAR; }
 
 /* Tokens with associated tnode */
{TO}     { yylval.tnode = (struct tnode*) get_tnode (TO, "=");     return TO;  }
{IF}     { yylval.tnode = (struct tnode*) get_tnode (IF, "if");    return IF;  }
{THEN}   { yylval.tnode = (struct tnode*) get_tnode (THEN, "{");   return THEN;}
{ELSE}   { yylval.tnode = (struct tnode*) get_tnode (ELSE, "else");return ELSE;}
{WHILE}  { yylval.tnode = (struct tnode*) get_tnode (WHILE, "while");return WHILE;}
{DO}     { yylval.tnode = (struct tnode*) get_tnode (DO, "do");    return DO;  }
{END}    { yylval.tnode = (struct tnode*) get_tnode (END, "end");  return END; }
{OPBR}   { yylval.tnode = (struct tnode*) get_tnode (OPBR, "(");   return OPBR;}
{CLBR}   { yylval.tnode = (struct tnode*) get_tnode (CLBR, ")");   return CLBR;}
{EQUA}   { yylval.tnode = (struct tnode*) get_tnode (EQUA, "==");  return EQUA;}
{PLUS}   { yylval.tnode = (struct tnode*) get_tnode (PLUS, "+");   return PLUS;}
{MINU}   { yylval.tnode = (struct tnode*) get_tnode (MINU, "-");   return MINU;}
{MULT}   { yylval.tnode = (struct tnode*) get_tnode (MULT, "*");   return MULT;}
{DIVI}   { yylval.tnode = (struct tnode*) get_tnode (DIVI, "/");   return DIVI;}
{ID}     { yylval.tnode = (struct tnode*) get_tnode (ID, yytext);  return ID;  }
{STRING} { yylval.tnode = (struct tnode*) get_tnode (STRING, yytext);return STRING;}
{NUM}    { yylval.tnode = (struct tnode*) get_tnode (NUM, yytext); return NUM; }



 /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%%
 /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */



/* Returns a pointer to a tnode representing a string of the output language */
struct tnode *get_tnode (int ntype, char * str)
{
        struct tnode *n = malloc (sizeof (struct tnode));
        n->txt = strdup (str);
        n->ntype = ntype;

        return n;
}

