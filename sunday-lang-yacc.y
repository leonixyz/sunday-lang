%{
#include <stdlib.h>     /* TODO revise includes when the work is over */ 
#include <string.h>     /*      to remove what is not necessary       */
#include <ctype.h>
#include <stdio.h>
#include "include/symbol-table.h"
#include "include/parse-tree.h"

/* Symbol table entry types (defined in symbol-table.h). */
extern const int TYPE_NOT_SET;  // 0
extern const int TYPE_VOID;     // 1
extern const int TYPE_INT;      // 2
extern const int TYPE_REAL;     // 2
extern const int TYPE_STRING;   // 3

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
%token <tnode> INT
%token <tnode> REAL
%token <tnode> TO
%token <tnode> IF
%token <tnode> THEN
%token <tnode> ELSE
%token <tnode> WHILE
%token <tnode> DO 
%token <tnode> END
%token <tnode> ID
%token <tnode> INTN
%token <tnode> REALN
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
%token <tnode> RETURN


/* Non-terminals. */
%type <tnode> program 
%type <tnode> function
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
        : function
                {
                        struct tnode *root = calloc (1, TNODE_SIZE);
                        struct tnode *nodes[] = {$1};
                        $$ = parse_tree->root = root = pt_create_branch ("program", nodes, 1);
                }
        
        | program function 
                {
                        struct tnode *root = calloc (1, TNODE_SIZE);
                        struct tnode *nodes[] = {$1, $2};
                        $$ = parse_tree->root = root = pt_create_branch ("program", nodes, 2);
                }
        ;


/* Function. */
function
        : INT ID block
                {
                        /* Check the return type is consistent. */
                        if ($3->type != TYPE_INT) {
                                char strerror[256] = "the following function's "
                                        "type is not consistent with the "
                                        "function's declaration: ";
                                strcat (strerror, $2->txt);
                                yyerror (strerror);
                                return;
                        }

                        /* Insert a new symbol table entry for the function. */
                        struct st_rec *fun = calloc (1, ST_REC_SIZE);
                        fun->name = strdup ($2->txt);
                        st_insert (st_stack_top, fun);
                        
                        /* Set function's declaration */
                        char fdeclar_txt[256] = "int ";
                        struct tnode *fdeclar = malloc (TNODE_SIZE);
                        fdeclar->txt = strcat (fdeclar_txt, $2->txt); 
                        fdeclar->txt = strcat (fdeclar_txt, " () "); 
                        
                        struct tnode *nodes[] = {fdeclar, $3};
                        $$ = pt_create_branch ("function", nodes, 2);
                }
        | REAL ID block
                {
                        /* Check the return type is consistent. */
                        if ($3->type != TYPE_REAL) {
                                char strerror[256] = "the following function's "
                                        "type is not consistent with the "
                                        "function's declaration: ";
                                strcat (strerror, $2->txt);
                                yyerror (strerror);
                                return;
                        }

                        /* Insert a new symbol table entry for the function. */
                        struct st_rec *fun = calloc (1, ST_REC_SIZE);
                        fun->name = strdup ($1->txt);
                        st_insert (st_stack_top, fun);
                        
                        /* Set function's declaration */
                        char fdeclar_txt[256] = "double ";
                        struct tnode *fdeclar = malloc (TNODE_SIZE);
                        fdeclar->txt = strcat (fdeclar_txt, $1->txt); 
                        fdeclar->txt = strcat (fdeclar_txt, " () "); 
                        
                        struct tnode *nodes[] = {fdeclar, $2};
                        $$ = pt_create_branch ("function", nodes, 2);
                }
        
        | STRING ID block
                {
                        /* Check the return type is consistent. */
                        if ($3->type != TYPE_STRING) {
                                char strerror[256] = "the following function's "
                                        "type is not consistent with the "
                                        "function's declaration: ";
                                strcat (strerror, $2->txt);
                                yyerror (strerror);
                                return;
                        }

                        /* Insert a new symbol table entry for the function. */
                        struct st_rec *fun = calloc (1, ST_REC_SIZE);
                        fun->name = strdup ($1->txt);
                        st_insert (st_stack_top, fun);
                        
                        /* Set function's declaration */
                        char fdeclar_txt[256] = "char *";
                        struct tnode *fdeclar = malloc (TNODE_SIZE);
                        fdeclar->txt = strcat (fdeclar_txt, $1->txt); 
                        fdeclar->txt = strcat (fdeclar_txt, " () "); 
                        
                        struct tnode *nodes[] = {fdeclar, $2};
                        $$ = pt_create_branch ("function", nodes, 2);
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
                        $$->type = $3->type;
                }
        ;


/* List of statements. */
stmtlist
        : stmt
                {
                        struct tnode *nodes[] = {$1};
                        $$ = pt_create_branch ("stmtlist", nodes, 1);
                        $$->type = $1->type;
                }

        | stmtlist stmt
                {
                        struct tnode *nodes[] = {$1, $2};
                        $$ = pt_create_branch ("stmtlist", nodes, 2);
                        $$->type = get_strongest_type ($1, $2);
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

        | RETURN expr
                {
                        /* Add an ending semicolon. */
                        struct tnode *semicolon = malloc (TNODE_SIZE);
                        semicolon->txt = ";";
                        
                        struct tnode *nodes[] = {$1, $2, semicolon};
                        $$ = pt_create_branch ("stmt", nodes, 3);
                        $$->type = $2->type;
                }
        ;


declarement
        : USE INT ID
                {
                        /* Insert a new symbol table entry for the variable. */
                        struct st_rec *var = calloc (1, ST_REC_SIZE);
                        var->name = strdup ($3->txt);
                        st_insert (st_stack_top, var);
                        st_settype (var, TYPE_INT);
                        
                        struct tnode *declarement = malloc (TNODE_SIZE);
                        struct tnode *nodes[] = {declarement};
                        $$ = pt_create_branch ("stmt", nodes, 1);
                }
        
       | USE REAL ID
                {
                        /* Insert a new symbol table entry for the variable. */
                        struct st_rec *var = calloc (1, ST_REC_SIZE);
                        var->name = strdup ($3->txt);
                        st_insert (st_stack_top, var);
                        st_settype (var, TYPE_REAL);
                        
                        struct tnode *declarement = malloc (TNODE_SIZE);
                        struct tnode *nodes[] = {declarement};
                        $$ = pt_create_branch ("stmt", nodes, 1);
                }
        
       | USE STRING ID
                {
                        /* Insert a new symbol table entry for the variable. */
                        struct st_rec *var = calloc (1, ST_REC_SIZE);
                        var->name = strdup ($3->txt);
                        st_insert (st_stack_top, var);
                        st_settype (var, TYPE_STRING);
                        
                        struct tnode *declarement = malloc (TNODE_SIZE);
                        struct tnode *nodes[] = {declarement};
                        $$ = pt_create_branch ("stmt", nodes, 1);
                }
        ;


/* Assignment statement. */
assignment
        : SET ID TO expr
                {
                        /* Get the symbol table entry for the variable. */
                        struct st_rec *var = st_lookup (st_stack_top, $2->txt);
                        if (!var) {
                                /* TODO Avoid potential buffer overflow. */
                                char strerror[128] = "the following variable "
                                                "has not been declared: ";
                                strcat (strerror, $2->txt);
                                yyerror (strerror);
                                return;
                        }
                        
                        /* Check that the variable was declared as a number. */
                        if (!var->type || var->type != $4->type) {
                                /* TODO Avoid potential buffer overflow. */
                                char strerror[256] = "the following variable's "
                                                "type is unconsistent with its "
                                                "actual use: ";
                                strcat (strerror, $2->txt);
                                yyerror (strerror);
                                return;
                        }

                        st_settype (var, $4->type);
                        struct tnode *nodes[] = {$2, $3, $4};
                        $$ = pt_create_branch ("assignment", nodes, 3);
                }
        ;


/* Statement if (else)? */
if
        : IF expr THEN stmtlist END
                {
                        if ($2->type != TYPE_INT) {
                                yyerror ("a test condition should only be of type integer");
                                return;
                        }
                        struct tnode *nodes[] = {$1, $2, $3, $4, $5};
                        $$ = pt_create_branch ("if", nodes, 5);
                }

        | IF expr THEN stmtlist ELSE stmtlist END
                {
                        if ($2->type != TYPE_INT) {
                                yyerror ("a test condition should only be of type integer");
                                return;
                        }
                        struct tnode *nodes[] = {$1, $2, $3, $4, $5, $6, $7};
                        $$ = pt_create_branch ("if", nodes, 7);
                }
        ;


/* While loop. */
while
        : { st_push (); } WHILE expr DO stmtlist END
                {
                        if ($3->type != TYPE_INT) {
                                yyerror ("a loop condition should only be of type integer");
                                return;
                        }
                        
                        /* Allocate a new node containing all declarations. */
                        struct tnode *declarations = malloc (TNODE_SIZE);
                        declarations->txt = st_flush ();
                        st_pop ();
                        
                        struct tnode *nodes[] = {$2, $3, $4, declarations, $5, $6};
                        $$ = pt_create_branch ("while", nodes, 6);
                }
        ;


/* Expression */
expr    
        : expr PLUS expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = pt_create_branch ("expr", nodes, 3);
                        $$->type = get_strongest_type ($1, $3);
                }

        | expr MINU expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = pt_create_branch ("expr", nodes, 3);
                        $$->type = get_strongest_type ($1, $3);
                }

        | expr MULT expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = pt_create_branch ("expr", nodes, 3);
                        $$->type = get_strongest_type ($1, $3);
                }

        | expr DIVI expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = pt_create_branch ("expr", nodes, 3);
                        $$->type = get_strongest_type ($1, $3);
                }

        | expr EQUA expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = pt_create_branch ("expr", nodes, 3);
                        $$->type = TYPE_INT;
                }

        | expr GT expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = pt_create_branch ("expr", nodes, 3);
                        $$->type = TYPE_INT;
                }

        | expr LT expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = pt_create_branch ("expr", nodes, 3);
                        $$->type = TYPE_INT;
                }

        | expr GOE expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = pt_create_branch ("expr", nodes, 3);
                        $$->type = TYPE_INT;
                }

        | expr LOE expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = pt_create_branch ("expr", nodes, 3);
                        $$->type = TYPE_INT;
                }

        | MINU expr %prec UMINUS
                {
                        struct tnode *nodes[] = {$1, $2};
                        $$ = pt_create_branch ("expr", nodes, 2);
                        $$->type = $2->type;
                }

        | OPBR expr CLBR
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = pt_create_branch ("expr", nodes, 3);
                        $$->type == get_strongest_type ($1, $3);        
                }

        | INTN
                {
                        struct tnode *nodes[] = {$1};
                        $$ = pt_create_branch ("expr", nodes, 1);
                        $$->type = TYPE_INT;
                }

        | REALN
                {
                        struct tnode *nodes[] = {$1};
                        $$ = pt_create_branch ("expr", nodes, 1);
                        $$->type = TYPE_REAL;
                }

        | STRING
                {
                        struct tnode *nodes[] = {$1};
                        $$ = pt_create_branch ("expr", nodes, 1);
                        $$->type = TYPE_STRING;
                }

        | ID
                {
                        /* Get the associated variable. */
                        struct st_rec *var = st_lookup (st_stack_top, $1->txt);
                        if (!var) {
                                char strerror[256] = "the following variable "
                                                "has not been declared: ";
                                strcat (strerror, $1->txt);
                                yyerror (strerror);
                                return;
                        } 

                        struct tnode *nodes[] = {$1};
                        $$ = pt_create_branch ("expr", nodes, 1);
                        $$->type = var->type;
                } 
        ;



/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */



#include "lex.yy.c"


/* Give hints about parsing errors. */
int yyerror (const char *str)
{
        fprintf (stderr, "[row:%d] Parse error: %s\n\n",
                        yylineno, str);
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
