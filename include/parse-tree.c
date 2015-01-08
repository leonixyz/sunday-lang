#include "parse-tree.h"


void pt_traverse (struct ptree *t, FILE* f)
{
        pt_traverse_rec (t->root, f);
}


void pt_traverse_rec (struct tnode *n, FILE* f)
{
        if (!n)
                return;

        fprintf (f, "%s ", n->txt);
}


void pt_add (struct tnode *parent, struct tnode* new_child)
{
        if (!parent->child) {
               parent->child = new_child; 
               return;
        }

        struct tnode *current = parent->child;

        while (current->next)
                current = current->next;

        current->next = new_child;
}
