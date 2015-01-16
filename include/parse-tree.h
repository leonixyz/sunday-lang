#ifndef SUNDAYLANG_PARSETREE
#define SUNDAYLANG_PARSETREE

#include <stdio.h>
#include <stdlib.h>

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/*                      Prototypes and external things.                      */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

/* Yacc function used in create_branch. */
int yyerror (const char *strerror);

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/*                           Structure definitions                           */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

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

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/*                                   Constants.                              */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

/* Size of a tnode structure (heavily used by malloc) */
extern const int TNODE_SIZE;

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/*                           Functions declarations.                         */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

/* Traverse a parse tree in depth-first. */
void pt_traverse (struct ptree *t, FILE* f);

/* Recursive helper function for pt_traverse. */
void pt_traverse_rec (struct tnode *n, FILE* f);

/* Create a new branch having count-many children in an array */
struct tnode *create_branch (struct tnode *nodes[], int count);


#endif
