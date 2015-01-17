#include "parse-tree.h"

/*----------------------------------------------------------------------------*/

/* Size of a tnode structure (heavily used by malloc) */
const size_t TNODE_SIZE = sizeof (struct tnode);

/*----------------------------------------------------------------------------*/

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


/* Helper function for pt_collapse_branch. */
int pt_collapse_branch_rec (struct tnode *n, char **array, int size_left)
{
        /* Base case: leaf reached. */
        if (!n)
                return size_left;

        /* Stop parsing in case of error. */
        if (!size_left) {
                yyerror ("an expression is too long to be evaluated; "
                                "split it into sub-expressions.");
                return -1;
        }

        /* Some nodes doesn't contain text. */
        if (n->txt) {
                *array++ = n->txt; 
        }

        /* Traverse the tree depht-first. */
        size_left = pt_collapse_branch_rec (n->child, array, --size_left);
        return pt_collapse_branch_rec (n->next, array, --size_left);
}


/* Collapse a branch of the parse tree to a string. */
char *pt_collapse_branch (struct tnode* root)
{
        /* Flat the tree into an array of pointers. */
        char **array = malloc (MAX_EXPR_LEN);
        pt_collapse_branch_rec (root, array, MAX_EXPR_LEN);

        /* Calculate the length of the concatenation of all strings. */
        char **p = array;
        int len;
        while (*p)
                len += strlen (*p++);

        /* Concatenate all strings in a single one. */
        char *string = calloc (1, len+1);
        p = array;
        while (*p)
                strcat (string, *p++);

        return string;
}


/* Create a new branch having count-many children in an array */
struct tnode *pt_create_branch (struct tnode *nodes[], int size)
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


