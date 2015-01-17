%{
#include <stdlib.h>     /* TODO revise includes when the work is over */ 
#include <string.h>     /*      to remove what is not necessary       */
#include <ctype.h>
#include <stdio.h>
#include "include/symbol-table.h"
#include "include/parse-tree.h"

#define Nprog   1
#define Nblock  2
#define Nstmtls 3
#define Nstmt   4
#define Ndeclar 5
#define Nassign 6
#define Nif     7
#define Nwhile  8
#define Nexpr   9
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
%token <tnode> PLUS
%token <tnode> MINU
%token <tnode> MULT
%token <tnode> DIVI


/* Non-terminals. */
%type <tnode> program 
%type <tnode> block
%type <tnode> stmtlist
%type <tnode> stmt
%type <tnode> declaration
%type <tnode> assignment
%type <tnode> if
%type <tnode> while
%type <tnode> expr


/* Declarements of operators in increasing order of precedence. */
%left EQUA
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
                        $$ = parse_tree->root = root = pt_create_branch (nodes, 1);
                        $$->ntype = Nprog;
                }
        
        | program block 
                {
                        struct tnode *root = calloc (1, TNODE_SIZE);
                        struct tnode *nodes[] = {$1, $2};
                        $$ = parse_tree->root = root = pt_create_branch (nodes, 2);
                        $$->ntype = Nprog;
                }
        ;


/* Code block. */
block
        : { st_push (); } OPBR stmtlist CLBR
                {
                        /* Allocate a new node containing all declarations. */
                        struct tnode *declarations = malloc (TNODE_SIZE);
                        declarations->txt = st_flush ();
                        declarations->ntype = Ndeclar;
                        st_pop ();

                        /* Correct the translated symbols. */
                        $2->txt[0] = '{';
                        $4->txt[0] = '}';

                        struct tnode *nodes[] = {$2, declarations, $3, $4};
                        $$ = pt_create_branch (nodes, 4);
                        $$->ntype = Nblock;
                }
        ;


/* List of statements. */
stmtlist
        : stmt
                {
                        struct tnode *semicolon = malloc (TNODE_SIZE);
                        semicolon->txt = ";";
                        
                        struct tnode *nodes[] = {$1, semicolon};
                        $$ = pt_create_branch (nodes, 2);
                        $$->ntype = Nstmtls;
                }

        | stmtlist stmt
                {
                        struct tnode *semicolon = malloc (TNODE_SIZE);
                        semicolon->txt = ";";
                        
                        struct tnode *nodes[] = {$1, $2, semicolon};
                        $$ = pt_create_branch (nodes, 3);
                        $$->ntype = Nstmtls;
                }
        ;


/* Single statement. */
stmt
        : /* declaration
                {
                        struct tnode *nodes[] = {$1};
                        $$ = pt_create_branch (nodes, 1);
                        $$->ntype = Nstmt;
                }
        
        |*/ assignment
                {
                        struct tnode *nodes[] = {$1};
                        $$ = pt_create_branch (nodes, 1);
                        $$->ntype = Nstmt;
                }

        | if
                {
                        struct tnode *nodes[] = {$1};
                        $$ = pt_create_branch (nodes, 1);
                        $$->ntype = Nstmt;
                }

        | while
                {
                        struct tnode *nodes[] = {$1};
                        $$ = pt_create_branch (nodes, 1);
                        $$->ntype = Nstmt;
                }

        | expr
                {
                        struct tnode *nodes[] = {$1};
                        $$ = pt_create_branch (nodes, 1);
                        $$->ntype = Nstmt;
                }
        ;


/* Variable declaration. */
declaration
        : USE VAR ID
                {
                        struct st_rec *newrec = calloc (1, ST_REC_SIZE);
                        newrec->name = strdup ($3->txt);
                        st_insert (st_stack_top, newrec);
                }
        ;


/* Assignment statement. */
assignment
        : SET VAR ID TO expr
                {
                        /* Get the symbol table entry for the variable. */
                        struct st_rec *var = st_lookup (st_stack_top, $3->txt);
                        if (!var) {
                               var = calloc (1, ST_REC_SIZE);
                               var->name = strdup ($3->txt);
                               st_insert (st_stack_top, var);
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
                        
                        /* Update the symbol table. */
                        st_settype (var, TYPE_NUMVAR);
                        var->value = pt_collapse_branch ($5);

                        struct tnode *nodes[] = {$3, $4, $5};
                        $$ = pt_create_branch (nodes, 3);
                        $$->ntype = Nassign;
                }

        | SET VAR ID TO STRING
                {
                        /* Get the symbol table entry for the variable. */
                        struct st_rec *var = st_lookup (st_stack_top, $3->txt);
                        if (!var) {
                               var = calloc (1, ST_REC_SIZE);
                               var->name = strdup ($3->txt);
                               st_insert (st_stack_top, var);
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

                        /* Update the symbol table. */
                        st_settype (var, TYPE_STRVAR);
                        var->value = pt_collapse_branch ($5);

                        struct tnode *nodes[] = {$3, $4, $5};
                        $$ = pt_create_branch (nodes, 3);
                        $$->ntype = Nassign;
                }
        ;


/* Statement if (else)? */
if
        : IF expr THEN stmtlist END
                {
                        struct tnode *nodes[] = {$1, $2, $3, $4, $5};
                        $$ = pt_create_branch (nodes, 5);
                        $$->ntype = Nif;
                }

        | IF expr THEN stmtlist ELSE stmtlist END
                {
                        struct tnode *nodes[] = {$1, $2, $3, $4, $5, $6, $7};
                        $$ = pt_create_branch (nodes, 7);
                        $$->ntype = Nif;
                }
        ;


/* While loop. */
while
        : WHILE expr DO stmtlist END
                {
                        struct tnode *nodes[] = {$1, $2, $3, $4, $5};
                        $$ = pt_create_branch (nodes, 5);
                        $$->ntype = Nwhile;
                }
        ;


/* Expression */
expr    
        : expr PLUS expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = pt_create_branch (nodes, 3);
                        $$->ntype = Nexpr;
                }

        | expr MINU expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = pt_create_branch (nodes, 3);
                        $$->ntype = Nexpr;
                }

        | expr MULT expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = pt_create_branch (nodes, 3);
                        $$->ntype = Nexpr;
                }

        | expr DIVI expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = pt_create_branch (nodes, 3);
                        $$->ntype = Nexpr;
                }

        | MINU expr %prec UMINUS
                {
                        struct tnode *nodes[] = {$1, $2};
                        $$ = pt_create_branch (nodes, 2);
                        $$->ntype = Nexpr;
                }

        | OPBR expr CLBR
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = pt_create_branch (nodes, 3);
                        $$->ntype = Nexpr;
                }

        | NUM
                {
                        struct tnode *nodes[] = {$1};
                        $$ = pt_create_branch (nodes, 1);
                        $$->ntype = Nexpr;
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
