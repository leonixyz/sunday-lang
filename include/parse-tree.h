#ifndef SUNDAYLANG_PARSETREE
#define SUNDAYLANG_PARSETREE

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* The maximum amount of nodes in the parse tree that an expression can use. */
#define MAX_EXPR_LEN    512

/*----------------------------------------------------------------------------*/

/* Yacc function prototype (used to raise parse errors). */
int yyerror (const char *strerror);

/* Size of a tnode structure (heavily used by malloc). */
extern const size_t TNODE_SIZE;

/*----------------------------------------------------------------------------*/

/* A parse tree. */
struct ptree {
        struct tnode *root;
};

/* A node of a parse tree */
struct tnode {
        char *txt;
        struct tnode *child;
        struct tnode *next;
};

/*----------------------------------------------------------------------------*/

/* Traverse a parse tree in depth-first. */
void pt_traverse (struct ptree *t, FILE* f);

/* Collapse a branch into a string. */
char *pt_collapse_branch (struct tnode *n);

/* Create a new branch having count-many children in an array */
struct tnode *pt_create_branch (char *ntype, struct tnode *nodes[], int count);


#endif
