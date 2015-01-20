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

 /* Tokens with associated values */
RETURN  return
USE     use
INT     integer
REAL    real
SET     set
TO      to
IF      if
THEN    then
ELSE    else
WHILE   while
DO      do
END     end
OPBR    \(
CLBR    \)
OPSQBR  \[
CLSQBR  \]
EQUA    =
GT      >
LT      <
GOE     >=
LOE     <=
PLUS    \+
MINU    -
MULT    \*
DIVI    \/

INTN    {DIGIT}+
REALN   {DIGIT}+\.{DIGIT}+
STRING  L?\"(\\.|[^\\"])*\"
ID      {LETTER}({LETTER}|{DIGIT})*



 /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%%
 /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */



 /* Skip blanks and newlines */
[ \n]    {}

 /* Tokens without associated tnode */
{USE}    { return USE; }
{SET}    { return SET; }
 
 /* Tokens with associated tnode */
{RETURN} { yylval.tnode = (struct tnode*) get_tnode ("return");  return RETURN;}
{INT}    { yylval.tnode = (struct tnode*) get_tnode ("int");     return INT;   }
{REAL}   { yylval.tnode = (struct tnode*) get_tnode ("double");  return REAL;  }
{TO}     { yylval.tnode = (struct tnode*) get_tnode ("=");       return TO;    }
{IF}     { yylval.tnode = (struct tnode*) get_tnode ("if (");    return IF;    }
{THEN}   { yylval.tnode = (struct tnode*) get_tnode (") {");     return THEN;  }
{ELSE}   { yylval.tnode = (struct tnode*) get_tnode ("} else {");return ELSE;  }
{WHILE}  { yylval.tnode = (struct tnode*) get_tnode ("while ("); return WHILE; }
{DO}     { yylval.tnode = (struct tnode*) get_tnode (") {");     return DO;    }
{END}    { yylval.tnode = (struct tnode*) get_tnode ("}");       return END;   }
{OPBR}   { yylval.tnode = (struct tnode*) get_tnode ("(");       return OPBR;  }
{CLBR}   { yylval.tnode = (struct tnode*) get_tnode (")");       return CLBR;  }
{OPSQBR} { yylval.tnode = (struct tnode*) get_tnode ("[");       return OPSQBR;}
{CLSQBR} { yylval.tnode = (struct tnode*) get_tnode ("]");       return CLSQBR;}
{EQUA}   { yylval.tnode = (struct tnode*) get_tnode ("==");      return EQUA;  }
{GT}     { yylval.tnode = (struct tnode*) get_tnode (">");       return GT;    }
{LT}     { yylval.tnode = (struct tnode*) get_tnode ("<");       return LT;    }
{GOE}    { yylval.tnode = (struct tnode*) get_tnode (">=");      return GOE;   }
{LOE}    { yylval.tnode = (struct tnode*) get_tnode ("<=");      return LOE;   }
{PLUS}   { yylval.tnode = (struct tnode*) get_tnode ("+");       return PLUS;  }
{MINU}   { yylval.tnode = (struct tnode*) get_tnode ("-");       return MINU;  }
{MULT}   { yylval.tnode = (struct tnode*) get_tnode ("*");       return MULT;  }
{DIVI}   { yylval.tnode = (struct tnode*) get_tnode ("/");       return DIVI;  }
{ID}     { yylval.tnode = (struct tnode*) get_tnode (yytext);    return ID;    }
{STRING} { yylval.tnode = (struct tnode*) get_tnode (yytext);    return STRING;}
{INTN}   { yylval.tnode = (struct tnode*) get_tnode (yytext);    return INTN;  }
{REALN}  { yylval.tnode = (struct tnode*) get_tnode (yytext);    return REALN; }



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

