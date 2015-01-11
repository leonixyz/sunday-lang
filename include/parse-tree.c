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
}

