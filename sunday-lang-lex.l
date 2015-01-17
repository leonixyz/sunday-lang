%option noyywrap
%{
#include <stdlib.h>
#include <string.h>
#include "include/symbol-table.h"
#include "include/parse-tree.h"

/* Prototype for helper function defined later. */
struct tnode *get_tnode (char *str);
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
{TO}     { yylval.tnode = (struct tnode*) get_tnode ("=");     return TO;     }
{IF}     { yylval.tnode = (struct tnode*) get_tnode ("if");    return IF;     }
{THEN}   { yylval.tnode = (struct tnode*) get_tnode ("{");     return THEN;   }
{ELSE}   { yylval.tnode = (struct tnode*) get_tnode ("else");  return ELSE;   }
{WHILE}  { yylval.tnode = (struct tnode*) get_tnode ("while"); return WHILE;  }
{DO}     { yylval.tnode = (struct tnode*) get_tnode ("do");    return DO;     }
{END}    { yylval.tnode = (struct tnode*) get_tnode ("end");   return END;    }
{OPBR}   { yylval.tnode = (struct tnode*) get_tnode ("(");     return OPBR;   }
{CLBR}   { yylval.tnode = (struct tnode*) get_tnode (")");     return CLBR;   }
{EQUA}   { yylval.tnode = (struct tnode*) get_tnode ("==");    return EQUA;   }
{PLUS}   { yylval.tnode = (struct tnode*) get_tnode ("+");     return PLUS;   }
{MINU}   { yylval.tnode = (struct tnode*) get_tnode ("-");     return MINU;   }
{MULT}   { yylval.tnode = (struct tnode*) get_tnode ("*");     return MULT;   }
{DIVI}   { yylval.tnode = (struct tnode*) get_tnode ("/");     return DIVI;   }
{ID}     { yylval.tnode = (struct tnode*) get_tnode (yytext);  return ID;     }
{STRING} { yylval.tnode = (struct tnode*) get_tnode (yytext);  return STRING; }
{NUM}    { yylval.tnode = (struct tnode*) get_tnode (yytext);  return NUM;    }



 /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%%
 /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */



/* Returns a pointer to a tnode representing a string of the output language */
struct tnode *get_tnode (char * str)
{
        struct tnode *n = malloc (sizeof (struct tnode));
        n->txt = strdup (str);

        return n;
}

