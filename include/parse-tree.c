#include "parse-tree.h"

/*----------------------------------------------------------------------------*/

/* Size of a tnode structure (heavily used by malloc) */
const size_t TNODE_SIZE = sizeof (struct tnode);

/*----------------------------------------------------------------------------*/
void pt_debug_printn (struct tnode* n);//DEBUG

/* Helper function for pt_traverse. */
void pt_traverse_rec (struct tnode *n, FILE* f)
{
        /* Base case: leaf reached. */
        if (!n)
                return;        

        /* Some nodes doesn't contain text */
        if (n->txt) 
                fprintf (f, "%s ", n->txt); 
        
        /* Traverse depth-first */
        pt_traverse_rec (n->child, f);
        pt_traverse_rec (n->next, f);
}


/* Traverse a parse tree in depth-first. */
void pt_traverse (struct ptree *t, FILE* f)
{
        pt_traverse_rec (t->root, f);
}


/* Create a new branch having count-many children in an array */
struct tnode *pt_create_branch (char *ntype, struct tnode *nodes[], int size)
{
        if (size < 1)
                yyerror ("cannot add less than one node to the parse tree.");

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


/* Returns the strongest type between two operands. */
int get_strongest_type (struct tnode *n1, struct tnode *n2)
{
        int t1 = n1->type;
        int t2 = n2->type;
        
        if (t1 > t2)
                return t1;
        else
                return t2;
}
