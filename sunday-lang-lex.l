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
[ \n]    {}

 /* Tokens without associated tnode */
{SET}    { return SET; }
{VAR}    { return VAR; }
 
 /* Tokens with associated tnode */
{TO}     { yylval.tnode = get_tnode ("=");       return TO;     }
{IF}     { yylval.tnode = get_tnode ("if");      return IF;     }
{THEN}   { yylval.tnode = get_tnode ("{");       return THEN;   }
{ELSE}   { yylval.tnode = get_tnode ("else");    return ELSE;   }
{WHILE}  { yylval.tnode = get_tnode ("while");   return WHILE;  }
{DO}     { yylval.tnode = get_tnode ("do");      return DO;     }
{END}    { yylval.tnode = get_tnode ("end");     return END;    }
{OPBR}   { yylval.tnode = get_tnode ("(");       return OPBR;   }
{CLBR}   { yylval.tnode = get_tnode (")");       return CLBR;   }
{EQUA}   { yylval.tnode = get_tnode ("==");      return EQUA;   }
{PLUS}   { yylval.tnode = get_tnode ("+");       return PLUS;   }
{MINU}   { yylval.tnode = get_tnode ("-");       return MINU;   }
{MULT}   { yylval.tnode = get_tnode ("*");       return MULT;   }
{DIVI}   { yylval.tnode = get_tnode ("/");       return DIVI;   }
{ID}     { yylval.tnode = get_tnode (yytext);    return ID;     }
{STRING} { yylval.tnode = get_tnode (yytext);    return STRING; }
{NUM}    { yylval.tnode = get_tnode (yytext);    return NUM;    }



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

