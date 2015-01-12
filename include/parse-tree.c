#include "parse-tree.h"


void pt_traverse (struct ptree *t, FILE* f)
{
        pt_traverse_rec (t->root, f);
}


void pt_traverse_rec (struct tnode *n, FILE* f)
{
        if (!n)
                return;        

// UNCOMMENT FOR DEBUGGING
//        printf ("traversing node %d (str='%s', child=%d, next=%d)\n", n, n->txt, n->child, n->next);
        if (n->txt)                             // COMMENT OUT FOR DEBUGGING
                fprintf (f, "%s ", n->txt);     // COMMENT OUT FOR DEBUGGING
        
        pt_traverse_rec (n->child, f);
        pt_traverse_rec (n->next, f);
}

