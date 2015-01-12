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


void pt_print_node (struct tnode *n)
{
        if (n)
                printf ("%d\nstr='%s'\nchild=%d\nnext=%d\n\n",
                        n,
                        n->txt,
                        n->child,
                        n->next);
}
