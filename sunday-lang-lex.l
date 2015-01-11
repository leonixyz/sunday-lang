%option noyywrap
%{
#include <stdlib.h>
#include <string.h>
#include "include/symbol-table.h"
#include "include/parse-tree.h"
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
[ \n]   {}

 /* Tokens without associated tnode */
{SET}    {return SET;}
{VAR}    {return VAR;}
 
 /* Tokens with associated tnode */
{TO}     {struct tnode *n = malloc (sizeof (struct tnode)); n->txt = "=";     yylval.tnode = n; return TO;}
{IF}     {struct tnode *n = malloc (sizeof (struct tnode)); n->txt = "if";    yylval.tnode = n; return IF;}
{THEN}   {struct tnode *n = malloc (sizeof (struct tnode)); n->txt = "{";     yylval.tnode = n; return THEN;}
{ELSE}   {struct tnode *n = malloc (sizeof (struct tnode)); n->txt = "else";  yylval.tnode = n; return ELSE;}
{WHILE}  {struct tnode *n = malloc (sizeof (struct tnode)); n->txt = "while"; yylval.tnode = n; return WHILE;}
{DO}     {struct tnode *n = malloc (sizeof (struct tnode)); n->txt = "{";     yylval.tnode = n; return DO;}
{END}    {struct tnode *n = malloc (sizeof (struct tnode)); n->txt = "}";     yylval.tnode = n; return END;}
{OPBR}   {struct tnode *n = malloc (sizeof (struct tnode)); n->txt = "{";     yylval.tnode = n; return OPBR;}
{CLBR}   {struct tnode *n = malloc (sizeof (struct tnode)); n->txt = "}";     yylval.tnode = n; return CLBR;}
{EQUA}   {struct tnode *n = malloc (sizeof (struct tnode)); n->txt = "==";    yylval.tnode = n; return EQUA;}
{PLUS}   {struct tnode *n = malloc (sizeof (struct tnode)); n->txt = "+";     yylval.tnode = n; return PLUS;}
{MINU}   {struct tnode *n = malloc (sizeof (struct tnode)); n->txt = "-";     yylval.tnode = n; return MINU;}
{MULT}   {struct tnode *n = malloc (sizeof (struct tnode)); n->txt = "*";     yylval.tnode = n; return MULT;}
{DIVI}   {struct tnode *n = malloc (sizeof (struct tnode)); n->txt = "/";     yylval.tnode = n; return DIVI;}
{ID}     {struct tnode *n = malloc (sizeof (struct tnode)); n->txt = yytext;  yylval.tnode = n; return ID;}
{STRING} {struct tnode *n = malloc (sizeof (struct tnode)); n->txt = yytext;  yylval.tnode = n; return STRING;}
{NUM}    {char s[32]; sprintf (s, "%lf", yytext); struct tnode *n = malloc (sizeof (struct tnode)); n->txt = s; yylval.tnode = n; return NUM;}



 /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%%
 /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */



