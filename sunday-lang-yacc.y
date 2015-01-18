%{
#include <stdlib.h>     /* TODO revise includes when the work is over */ 
#include <string.h>     /*      to remove what is not necessary       */
#include <ctype.h>
#include <stdio.h>
#include "include/symbol-table.h"
#include "include/parse-tree.h"

/* Symbol table entry types (defined in symbol-table.h). */
extern const int TYPE_NOT_SET;  // 0
extern const int TYPE_FUNCTION; // 1
extern const int TYPE_NUMVAR;   // 2
extern const int TYPE_STRVAR;   // 3

/* Size of a tnode structure (defined in parse-tree.h). */
extern const size_t TNODE_SIZE;

/* Size of a symbol table record (defined in simbol-table.h). */
extern const size_t ST_REC_SIZE;

/* Parse tree (defined in parse-tree.h). */
struct ptree *parse_tree;

/* Symbol table record (defined in symbol-table.h). */
struct st_rec;

/* Global pointer to the top of the stack of the symbol tables. */
struct st *st_stack_top;
%}


/* Print some additional information. */
%error-verbose


/* The lex variable yylval can only contain a tnode structure. */
%union {
        struct tnode *tnode;
}


/* Terminals. */
%token <tnode> USE
%token <tnode> SET
%token <tnode> VAR
%token <tnode> TO
%token <tnode> IF
%token <tnode> THEN
%token <tnode> ELSE
%token <tnode> WHILE
%token <tnode> DO 
%token <tnode> END
%token <tnode> ID
%token <tnode> NUM
%token <tnode> STRING
%token <tnode> OPBR 
%token <tnode> CLBR
%token <tnode> EQUA
%token <tnode> GT
%token <tnode> LT
%token <tnode> GOE
%token <tnode> LOE
%token <tnode> PLUS
%token <tnode> MINU
%token <tnode> MULT
%token <tnode> DIVI


/* Non-terminals. */
%type <tnode> program 
%type <tnode> block
%type <tnode> stmtlist
%type <tnode> stmt
%type <tnode> declarement
%type <tnode> assignment
%type <tnode> if
%type <tnode> while
%type <tnode> expr


/* Declarements of operators in increasing order of precedence. */
%left EQUA GT LT GOE LOE
%left MINU PLUS
%left MULT DIVI
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
                        struct tnode *root = calloc (1, TNODE_SIZE);
                        struct tnode *nodes[] = {$1};
                        $$ = parse_tree->root = root = pt_create_branch ("program", nodes, 1);
                }
        
        | program block 
                {
                        struct tnode *root = calloc (1, TNODE_SIZE);
                        struct tnode *nodes[] = {$1, $2};
                        $$ = parse_tree->root = root = pt_create_branch ("program", nodes, 2);
                }
        ;


/* Code block. */
block
        : { st_push (); } OPBR stmtlist CLBR
                {
                        /* Allocate a new node containing all declarations. */
                        struct tnode *declarations = malloc (TNODE_SIZE);
                        declarations->txt = st_flush ();
                        st_pop ();

                        /* Correct the translated symbols. */
                        $2->txt[0] = '{';
                        $4->txt[0] = '}';

                        struct tnode *nodes[] = {$2, declarations, $3, $4};
                        $$ = pt_create_branch ("block", nodes, 4);
                }
        ;


/* List of statements. */
stmtlist
        : stmt
                {
                        struct tnode *nodes[] = {$1};
                        $$ = pt_create_branch ("stmtlist", nodes, 1);
                }

        | stmtlist stmt
                {
                        struct tnode *nodes[] = {$1, $2};
                        $$ = pt_create_branch ("stmtlist", nodes, 2);
                }
        ;


/* Single statement. */
stmt
        : declarement
                {
                        struct tnode *nodes[] = {$1};
                        $$ = pt_create_branch ("stmt", nodes, 1);
                }
        
        | assignment
                {
                        /* Add an ending semicolon. */
                        struct tnode *semicolon = malloc (TNODE_SIZE);
                        semicolon->txt = ";";
                        
                        struct tnode *nodes[] = {$1, semicolon};
                        $$ = pt_create_branch ("stmt", nodes, 2);
                }

        | if
                {
                        struct tnode *nodes[] = {$1};
                        $$ = pt_create_branch ("stmt", nodes, 1);
                }

        | while
                {
                        struct tnode *nodes[] = {$1};
                        $$ = pt_create_branch ("stmt", nodes, 1);
                }

        | expr
                {
                        /* Add an ending semicolon. */
                        struct tnode *semicolon = malloc (TNODE_SIZE);
                        semicolon->txt = ";";
                        
                        struct tnode *nodes[] = {$1, semicolon};
                        $$ = pt_create_branch ("stmt", nodes, 2);
                }
        ;


declarement
        : USE VAR ID
                {
                        /* Insert a new symbol table entry for the variable. */
                        struct st_rec *var = calloc (1, ST_REC_SIZE);
                        var->name = strdup ($3->txt);
                        st_insert (st_stack_top, var);
                        
                        struct tnode *declarement = malloc (TNODE_SIZE);
                        struct tnode *nodes[] = {declarement};
                        $$ = pt_create_branch ("stmt", nodes, 1);
                }
        ;


/* Assignment statement. */
assignment
        : SET VAR ID TO expr
                {
                        /* Get the symbol table entry for the variable. */
                        struct st_rec *var = st_lookup (st_stack_top, $3->txt);
                        if (!var) {
                                /* TODO Avoid potential buffer overflow. */
                                char strerror[128] = "the following variable "
                                                "has not been declared: ";
                                strcat (strerror, $3->txt);
                                yyerror (strerror);
                                return;
                        }
                        
                        /* Check that the variable was declared as a number. */
                        if (var->type && var->type != TYPE_NUMVAR) {
                                /* TODO Avoid potential buffer overflow. */
                                char strerror[256] = "the following variable "
                                                "has been declared as a "
                                                "string but it's used as "
                                                "a number: ";
                                strcat (strerror, $3->txt);
                                yyerror (strerror);
                                return;
                        }
                        else {
                                st_settype (var, TYPE_NUMVAR);
                        }

                        /*
                        var->value = pt_collapse_branch ($5);
                        $5->child = NULL;
                        $5->next = NULL;
                        $5->txt = var->value;
                        */

                        struct tnode *nodes[] = {$3, $4, $5};
                        $$ = pt_create_branch ("assignment", nodes, 3);
                }

        | SET VAR ID TO STRING
                {
                        /* Get the symbol table entry for the variable. */
                        struct st_rec *var = st_lookup (st_stack_top, $3->txt);
                        if (!var) {
                                /* TODO Avoid potential buffer overflow. */
                                char strerror[128] = "the following variable "
                                                "has not been declared: ";
                                strcat (strerror, $3->txt);
                                yyerror (strerror);
                                return;
                        }

                        if (var->type && var->type != TYPE_STRVAR) {
                                /* TODO Avoid potential buffer overflow. */
                                char strerror[256] = "the following variable "
                                                "has been declared as a"
                                                "number but it's used as "
                                                "a string: ";
                                strcat (strerror, $3->txt);
                                yyerror (strerror);
                                return;
                        }
                        else {
                                st_settype (var, TYPE_STRVAR);
                        }

                        struct tnode *nodes[] = {$3, $4, $5};
                        $$ = pt_create_branch ("assignment", nodes, 3);
                }
        ;


/* Statement if (else)? */
if
        : IF expr THEN stmtlist END
                {
                        /* Create surrounding brackets for expr. */
                        struct tnode *opbr, *clbr;
                        opbr = calloc (1, TNODE_SIZE);
                        opbr->txt = strdup ("(");
                        clbr = calloc (1, TNODE_SIZE);
                        clbr->txt = strdup (")");

                        struct tnode *nodes[] = {$1, opbr, $2, clbr, $3, $4, $5};
                        $$ = pt_create_branch ("if", nodes, 7);
                }

        | IF expr THEN stmtlist ELSE stmtlist END
                {
                        /* Create surrounding brackets for expr. */
                        struct tnode *opbr, *clbr;
                        opbr = calloc (1, TNODE_SIZE);
                        opbr->txt = strdup ("(");
                        clbr = calloc (1, TNODE_SIZE);
                        clbr->txt = strdup (")");

                        struct tnode *nodes[] = {$1, opbr, $2, clbr, $3, $4, $5, $6, $7};
                        $$ = pt_create_branch ("if", nodes, 9);
                }
        ;


/* While loop. */
while
        : WHILE expr DO stmtlist END
                {
                        struct tnode *nodes[] = {$1, $2, $3, $4, $5};
                        $$ = pt_create_branch ("while", nodes, 5);
                }
        ;


/* Expression */
expr    
        : expr PLUS expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = pt_create_branch ("expr", nodes, 3);
                }

        | expr MINU expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = pt_create_branch ("expr", nodes, 3);
                }

        | expr MULT expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = pt_create_branch ("expr", nodes, 3);
                }

        | expr DIVI expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = pt_create_branch ("expr", nodes, 3);
                }

        | expr EQUA expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = pt_create_branch ("expr", nodes, 3);
                }

        | expr GT expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = pt_create_branch ("expr", nodes, 3);
                }

        | expr LT expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = pt_create_branch ("expr", nodes, 3);
                }

        | expr GOE expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = pt_create_branch ("expr", nodes, 3);
                }

        | expr LOE expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = pt_create_branch ("expr", nodes, 3);
                }

        | MINU expr %prec UMINUS
                {
                        struct tnode *nodes[] = {$1, $2};
                        $$ = pt_create_branch ("expr", nodes, 2);
                }

        | OPBR expr CLBR
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = pt_create_branch ("expr", nodes, 3);
                }

        | NUM
                {
                        struct tnode *nodes[] = {$1};
                        $$ = pt_create_branch ("expr", nodes, 1);
                }

        | ID
                {
                        struct tnode *nodes[] = {$1};
                        $$ = pt_create_branch ("expr", nodes, 1);
                } 
        ;



/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */



#include "lex.yy.c"


/* Give hints about parsing errors. */
int yyerror (const char *str)
{
        fprintf (stderr, "Parse error: %s\n", str);
        return -1;
}


/* Parse and print the output to destination file. */
int main ()
{
        /* TODO Parse input parameters to set a custom output file. */
        FILE* outfile = stdout;
        
        /* Allocate the global symbol table. */
        st_stack_top = malloc (sizeof (struct st));

        /* Allocate an empty parse tree. */
        parse_tree = malloc (sizeof (struct ptree));

        /* Parse input. */
        yyparse ();

        /* Write output to file. */
        pt_traverse (parse_tree, outfile);
}
