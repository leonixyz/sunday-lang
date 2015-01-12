#include "parse-tree.h"


void pt_traverse (struct ptree *t, FILE* f)
{
        pt_traverse_rec (t->root, f);
}


void pt_traverse_rec (struct tnode *n, FILE* f)
{
        if (!n)
                return;        

        if (n->txt) 
                fprintf (f, "%s ", n->txt); 
        
        pt_traverse_rec (n->child, f);
        pt_traverse_rec (n->next, f);
}


struct tnode *create_branch (struct tnode *nodes[], int size)
{
        if (size < 1)
                yyerror ("Cannot add less than one node to the parse tree.");

        int i;
        struct tnode *current;
        struct tnode *newroot;
        
        /* Create a root. */
        newroot = calloc (1, TNODE_SIZE);

        /* Attach the first child to the root. */
        newroot->child = nodes[0];
        current = newroot->child;
        
        /* Attach the other children to the root. */
        for (i = 1; i < size; i++) {
                current->next = nodes[i];
                current = current->next;
        }
 
        return newroot;
}


