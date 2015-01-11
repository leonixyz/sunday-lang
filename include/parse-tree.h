#ifndef SUNDAYLANG_PARSETREE
#define SUNDAYLANG_PARSETREE

#include <stdio.h>

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


/* Traverse a parse tree in depth-first. */
void pt_traverse (struct ptree *t, FILE* f);

/* Recursive helper function for pt_traverse. */
void pt_traverse_rec (struct tnode *n, FILE* f);

#endif
