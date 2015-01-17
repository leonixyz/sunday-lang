%{
#include <stdlib.h>     /* TODO revise includes when the work is over */ 
#include <string.h>     /*      to remove what is not necessary       */
#include <ctype.h>
#include <stdio.h>
#include "include/symbol-table.h"
#include "include/parse-tree.h"

/* Symbol table entries types defined in symbol-table.h file. */
extern const TYPE_NOT_SET;   // 0
extern const TYPE_FUNCTION;  // 1
extern const TYPE_NUMVAR;    // 2
extern const TYPE_STRVAR;    // 3

/* Global constant defined in parse-tree.h file */
extern const int TNODE_SIZE;

/* Global constant defined in simbol-table.h file */
extern const int ST_REC_SIZE;

/* Parse tree at the end of parsing. */
struct ptree *parse_tree;

/* Create the global symbol table on top of the stack. */
struct st *st_stack_top;

/* Prototypes. */
struct st_rec;
%}


/* Print some additional information. */
%error-verbose


/* We only pass tnode structures into yylval. */
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


/* Declarement of typed non-terminals. */
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
        : program block 
                {
                        struct tnode *root = calloc (1, TNODE_SIZE);
                        struct tnode *nodes[] = {$1, $2};
                        $$ = parse_tree->root = root = create_branch(nodes, 2);
                }
         
        | block
                {
                        struct tnode *root = calloc (1, TNODE_SIZE);
                        struct tnode *nodes[] = {$1};
                        $$ = parse_tree->root = root = create_branch(nodes, 1);
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
                        $$ = create_branch (nodes, 3);
                }
        ;


/* List of statements. */
stmtlist
        : stmtlist stmt
                {
                        struct tnode *nodes[] = {$1, $2};
                        $$ = create_branch(nodes, 2);
                }

        | stmt
                {
                        struct tnode *nodes[] = {$1};
                        $$ = create_branch(nodes, 1);
                }
        ;


/* Single statement. */
stmt
        : declaration
                {
                        struct tnode *nodes[] = {$1};
                        $$ = create_branch(nodes, 1);
                }
        
        | assignment
                {
                        struct tnode *nodes[] = {$1};
                        $$ = create_branch(nodes, 1);
                }

        | if
                {
                        struct tnode *nodes[] = {$1};
                        $$ = create_branch(nodes, 1);
                }

        | while
                {
                        struct tnode *nodes[] = {$1};
                        $$ = create_branch(nodes, 1);
                }

        | expr
                {
                        struct tnode *nodes[] = {$1};
                        $$ = create_branch(nodes, 1);
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
                        struct st_rec *var = st_lookup (st_stack_top, $3->txt);
                        if (!var) {
                                /* TODO check potential buffer overflow if the
                                 *      variable name is too long */
                                char strerror[128] = "the following variable"
                                                " has not been declared: ";
                                strcat (strerror, $3->txt);
                                yyerror (strerror);
                                return;
                        }

                        if (var->type && var->type != TYPE_NUMVAR) {
                                /* TODO check potential buffer overflow if the
                                 *      variable name is too long */
                                char strerror[256] = "the following variable "
                                                "has been declared as a "
                                                "string but it's used as "
                                                "a number: ";
                                strcat (strerror, $3->txt);
                                yyerror (strerror);
                                return;
                        }

                        st_settype (var, TYPE_NUMVAR);
                        /*TODO DEBUG HERE */
                        fprintf (stderr, "\n\n\n\n\nthe string is:%s\n\n\n\n",$5->txt);
                        var->value = strdup ($5->txt);
                        struct tnode *nodes[] = {$3, $4, $5};
                        $$ = create_branch(nodes, 3);
                }

        | SET VAR ID TO STRING
                {
                        struct st_rec *var = st_lookup (st_stack_top, $3->txt);
                        if (!var) {
                                /* TODO check potential buffer overflow if the
                                 *      variable name is too long */
                                char strerror[128] = "the following variable"
                                                " has not been declared: ";
                                strcat (strerror, $3->txt);
                                yyerror (strerror);
                                return;
                        }

                        if (var->type && var->type != TYPE_STRVAR) {
                                /* TODO check potential buffer overflow if the
                                 *      variable name is too long */
                                char strerror[256] = "the following variable "
                                                "has been declared as a"
                                                "number but it's used as "
                                                "a string: ";
                                strcat (strerror, $3->txt);
                                yyerror (strerror);
                                return;
                        }

                        st_settype (var, TYPE_STRVAR);
                        var->value = strdup ($5->txt);
                        struct tnode *nodes[] = {$3, $4, $5};
                        $$ = create_branch(nodes, 3);
                }
        ;


/* Statement if (else)? */
if
        : IF expr THEN stmtlist END
                {
                        struct tnode *nodes[] = {$1, $2, $3, $4, $5};
                        $$ = create_branch(nodes, 5);
                }

        | IF expr THEN stmtlist ELSE stmtlist END
                {
                        struct tnode *nodes[] = {$1, $2, $3, $4, $5, $6, $7};
                        $$ = create_branch(nodes, 7);
                }
        ;


/* While loop. */
while
        : WHILE expr DO stmtlist END
                {
                        struct tnode *nodes[] = {$1, $2, $3, $4, $5};
                        $$ = create_branch(nodes, 5);
                }
        ;


/* Expression */
expr    
        : expr PLUS expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = create_branch(nodes, 3);
                }

        | expr MINU expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = create_branch(nodes, 3);
                }

        | expr MULT expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = create_branch(nodes, 3);
                }

        | expr DIVI expr
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = create_branch(nodes, 3);
                }

        | MINU expr %prec UMINUS
                {
                        struct tnode *nodes[] = {$1, $2};
                        $$ = create_branch(nodes, 2);
                }

        | OPBR expr CLBR
                {
                        struct tnode *nodes[] = {$1, $2, $3};
                        $$ = create_branch(nodes, 3);
                }

        | NUM
                {
                        struct tnode *nodes[] = {$1};
                        $$ = create_branch(nodes, 1);
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
//        fprintf (stderr, "\n\n%s\n\n", st_debug (st_stack_top));
}


/* Parse and print the output to destination file. */
int main ()
{
        st_stack_top = malloc (sizeof (struct st));
        parse_tree = malloc (sizeof (struct ptree));
        yyparse ();
        pt_traverse (parse_tree, stdout);
}
