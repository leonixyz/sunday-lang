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

/*Get the right type translated (defined later in this file).*/
void get_type_string (char *declaration, int type);
%}


/* Print some additional information. */
%error-verbose


/* The lex variable yylval can only contain a tnode structure. */
%union {
        struct tnode *tnode;
}


/* Terminals. */
%token USE
%token <tnode> SET
%token <tnode> INT
%token <tnode> STR
%token <tnode> REAL
%token <tnode> TO
%token <tnode> IF
%token <tnode> THEN
%token <tnode> ELSE
%token <tnode> WHILE
%token <tnode> DO 
%token <tnode> END
%token <tnode> STRING
%token <tnode> ID
%token <tnode> INTN
%token <tnode> REALN
%token <tnode> OPBR 
%token <tnode> CLBR
%token <tnode> OPSQBR 
%token <tnode> CLSQBR
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
%type <tnode> type
%type <tnode> block
%type <tnode> stmtlist
%type <tnode> stmt
%type <tnode> functioncall
%type <tnode> arguments
%type <tnode> declarement
%type <tnode> assignment
%type <tnode> if
%type <tnode> else
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
        : type ID block
                {
                        /* Check the return type is consistent. */
                        if ($3->type != $1->type) {
                                char strerror[256] = "the following function's "
                                        "type is not consistent with its "
                                        "declaration: ";
                                strcat (strerror, $2->txt);
                                yyerror (strerror);
                                return;
                        }

                        /* Insert a new symbol table entry for the function. */
                        struct st_rec *fun = calloc (1, ST_REC_SIZE);
                        fun->name = strdup ($2->txt);
                        st_insert (st_stack_top, fun);
                        
                        /* Set function's declaration */
                        char fdeclar_txt[256];
                        get_type_string (fdeclar_txt, $1->type);
                        struct tnode *fdeclar = malloc (TNODE_SIZE);
                        fdeclar->txt = strcat (fdeclar_txt, $2->txt); 
                        fdeclar->txt = strcat (fdeclar_txt, " () "); 
                        
                        struct tnode *nodes[] = {fdeclar, $3};
                        $$ = pt_create_branch ("function", nodes, 2);
                }
        ;


/* Types. */
type
        : INT
                {       
                        struct tnode *nodes[] = {$1};
                        $$ = pt_create_branch ("type", nodes, 1);
                        $$->type = TYPE_INT;
                }

        | REAL
                {
                        struct tnode *nodes[] = {$1};
                        $$ = pt_create_branch ("type", nodes, 1);
                        $$->type = TYPE_REAL;
                }

        | STR
                {
                        struct tnode *nodes[] = {$1};
                        $$ = pt_create_branch ("type", nodes, 1);
                        $$->type = TYPE_STRING;
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

        | functioncall
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


/* Call to an arbitrary native C function. */
functioncall
        : ID OPSQBR arguments CLSQBR
                {
                        /* Correct brackets symbols. */
                        $2->txt[0] = '(';
                        $4->txt[0] = ')';
                        
                        struct tnode *nodes[] = {$1, $2, $3, $4};
                        $$ = pt_create_branch ("functioncall", nodes, 4);
                }
        ;


/* Arguments in a function call. */
arguments
        : expr
                {
                        $$ = $1; 
                }

        | arguments expr
                {
                        /* Put commas between the arguments. */
                        struct tnode *comma = malloc (TNODE_SIZE);
                        comma->txt = ", ";

                        struct tnode *nodes[] = {$1, comma, $2};
                        $$ = pt_create_branch ("arguments", nodes, 3);
                }
        ;


/* Variable declaration. */
declarement
        : USE type ID
                {
                        /* Check the variable wasn't already declared before. */
                        struct st_rec *var = st_lookup_local (st_stack_top, $3->txt);
                        if (var) {
                                char strerror[256] = "the following variable has been "
                                                "already declared: ";
                                strcat (strerror, $3->txt);
                                yyerror (strerror);
                                return;
                        }

                        /* Insert a new symbol table entry for the variable. */
                        var = calloc (1, ST_REC_SIZE);
                        var->name = strdup ($3->txt);
                        st_insert (st_stack_top, var);
                        st_settype (var, $2->type);
                        
                        /* An empty node is added to the parse tree because
                         * the actual declarations are automatically generated
                         * at the beginning of the scope during the reduction 
                         * of the related code fragment. */
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
                        
                        /* Check that the variable was declared the 
                         * way it's used. */
                        if (!var->type || var->type != $4->type) {
                                /* TODO Avoid potential buffer overflow. */
                                char strerror[256] = "the following variable's "
                                                "type is unconsistent with its "
                                                "actual use: ";
                                strcat (strerror, $2->txt);
                                yyerror (strerror);
                                return;
                        }

                        /*For type String, some extra effort is needed. */
                        if (var->type == TYPE_STRING) {
                                /* Allocate a string that will contain the 
                                 * original one, plus some extra characters.
                                 * 's' 't' 'r' 'd' 'u' 'p' '(' ')' '\0' */
                                char *newstr = calloc (1, strlen ($4->child->txt)+20);
                                strcat (newstr, "strdup(");
                                strcat (newstr, $4->child->txt);
                                strcat (newstr, ")");     /* '\0' 9th char */
                                free ($4->child->txt);
                                $4->child->txt = strdup (newstr);
                                /* Use $1 (normally empty) for free() the
                                 * pointer before assigning it (in case it's 
                                 * already used). Same allocation as above. */
                                char *newstr2 = calloc (1, strlen ($2->txt)+20);
                                strcat (newstr2, "free(");
                                strcat (newstr2, $2->txt);
                                strcat (newstr2, "); ");  /* '\0' 9th char */
                                free ($1->txt);
                                $1->txt = strdup (newstr2);
                        } 

                        st_settype (var, $4->type);
                        struct tnode *nodes[] = {$1, $2, $3, $4};
                        $$ = pt_create_branch ("assignment", nodes, 4);
                }
        ;


/* Statement if (else)? */
if
        : IF expr THEN { st_push ();} stmtlist else END
                {
                        if ($2->type != TYPE_INT) {
                                yyerror ("a test condition should only be of type integer");
                                return;
                        }

                        /* Allocate a new node containing all declarations. */
                        struct tnode *declarations = malloc (TNODE_SIZE);
                        declarations->txt = st_flush ();
                        st_pop ();

                        struct tnode *nodes[] = {$1, $2, $3, declarations, $5, $6, $7};
                        $$ = pt_create_branch ("if", nodes, 7);
                }
        ;


/* Optional else part of the if statement. */
else
        : /* Epsilon. */
                {
                        /* Do nothing. Allocate an empty node. */
                        $$ = calloc (1, TNODE_SIZE);
                }
        
        | ELSE { st_push ();} stmtlist
                {
                        /* Allocate a new node containing all declarations. */
                        struct tnode *declarations = malloc (TNODE_SIZE);
                        declarations->txt = st_flush ();
                        st_pop ();

                        struct tnode *nodes[] = {$1, declarations, $3};
                        $$ = pt_create_branch ("else", nodes, 3);
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


/* This function shall print a minimal list of libraries to include in the C 
 * code to let it work. */
void get_libraries (FILE *out)
{
        fprintf (out, "/* This code has been generated on sunday */\n");
        fprintf (out, "#include <stdio.h>\n");
        fprintf (out, "#include <math.h>\n");
        fprintf (out, "#include <ctype.h>\n");
        fprintf (out, "#include <stdlib.h>\n");
        fprintf (out, "#include <string.h>\n");
        fprintf (out, "#include <time.h>\n\n");
}


/* Get the right type declaration. */
void get_type_string (char *declaration, int type)
{
        if (type == TYPE_INT)
                strcpy (declaration, "int ");
        else if (type == TYPE_REAL)
                strcpy (declaration, "double ");
        else if (type == TYPE_STRING)
                strcpy (declaration, "char* ");
        else
                strcpy (declaration, "void ");
}


/* Give hints about parsing errors. */
int yyerror (const char *str)
{
        fprintf (stderr, "[row:%d] Parse error: %s\n\n",
                        yylineno, str);
        return -1;
}


/* Parse and print the output to destination file. */
int main (int argc, char *argv[])
{
        FILE* out = fopen ("a.out.c", "w");

        /* Basic error handling. */
        if (out==NULL) {
                fprintf (stderr, "Couldn't open output file.\n");
                return 1;
        }
 
        /* Allocate the global symbol table. */
        st_stack_top = malloc (sizeof (struct st));

        /* Allocate an empty parse tree. */
        parse_tree = malloc (sizeof (struct ptree));

        /* Include libraries. */
        get_libraries (out);

        /* Parse input. */
        yyparse ();

        /* Write output to file. */
        pt_traverse (parse_tree, out);
        fclose (out);

        /* Call GCC on the target. */
        popen ("gcc a.out.c", "r");
}


int mystrlen (char *str) { return strlen (str); };
