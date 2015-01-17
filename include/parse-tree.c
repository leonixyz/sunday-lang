#include "parse-tree.h"

#define Tuse    258
#define Tset    259
#define Tvar    260
#define Tto     261
#define Tif     262
#define Tthen   263
#define Telse   264
#define Twhile  265
#define Tdo     266
#define Tend    267
#define Topbr   271
#define Tclbr   272
#define Tequa   273
#define Tplus   274
#define Tminu   275
#define Tmult   276
#define Tdivi   277
#define Tid     268
#define Tstring 270
#define Tnum    269

#define Nprog   1
#define Nblock  2
#define Nstmtls 3
#define Nstmt   4
#define Ndeclar 5
#define Nassign 6
#define Nif     7
#define Nwhile  8
#define Nexpr   9

/*----------------------------------------------------------------------------*/

/* Size of a tnode structure (heavily used by malloc) */
const size_t TNODE_SIZE = sizeof (struct tnode);

/*----------------------------------------------------------------------------*/

void print_node (struct tnode *n)//DEBUG
{//DEBUG
        printf ("\n\nnode#\t%d\n", n);//DEBUG
        printf ("str:\t%s\n", n->txt);//DEBUG
        printf ("next:\t%d\n", n->next);//DEBUG
        printf ("child:\t%d\n", n->child);//DEBUG
        switch (n->ntype) {//DEBUG
        case Tuse://DEBUG
                printf("type:\tuse");//DEBUG
                break;//DEBUG
//DEBUG
        case Tset://DEBUG
                printf("type:\tset");//DEBUG
                break;//DEBUG
//DEBUG
        case Tvar://DEBUG
                printf("type:\tvar");//DEBUG
                break;//DEBUG
//DEBUG
        case Tto://DEBUG
                printf("type:\tto");//DEBUG
                break;//DEBUG
//DEBUG
        case Tif:
                printf("type:\tif");//DEBUG
                break;//DEBUG
//DEBUG
        case Tthen://DEBUG
                printf("type:\tthen");//DEBUG
                break;//DEBUG
//DEBUG
        case Telse://DEBUG
                printf("type:\telse");//DEBUG
                break;//DEBUG
//DEBUG
        case Twhile://DEBUG
                printf("type:\twhile");//DEBUG
                break;//DEBUG
//DEBUG
        case Tdo://DEBUG
                printf("type:\tdo");//DEBUG
                break;//DEBUG
//DEBUG
        case Tend://DEBUG
                printf("type:\tend");//DEBUG
                break;//DEBUG
//DEBUG
        case Topbr://DEBUG
                printf("type:\topbr");//DEBUG
                break;//DEBUG
//DEBUG
        case Tclbr://DEBUG
                printf("type:\tclbr");//DEBUG
                break;//DEBUG
//DEBUG
        case Tequa://DEBUG
                printf("type:\tequa");//DEBUG
                break;//DEBUG;
//DEBUG
        case Tplus://DEBUG
                printf("type:\tplus");//DEBUG
                break;//DEBUG
//DEBUG
        case Tminu://DEBUG
                printf("type:\tminu");//DEBUG
                break;//DEBUG
//DEBUG
        case Tmult://DEBUG
                printf("type:\tmult");//DEBUG
                break;//DEBUG
//DEBUG
        case Tdivi://DEBUG
                printf("type:\tdivi");//DEBUG
                break;//DEBUG
//DEBUG
        case Tid://DEBUG
                printf("type:\tid");//DEBUG
                break;//DEBUG
//DEBUG
        case Tstring://DEBUG
                printf("type:\tstring");//DEBUG
                break;//DEBUG
//DEBUG
        case Tnum://DEBUG
                printf("type:\tnum");//DEBUG
                break;//DEBUG
//DEBUG
        case Nprog://DEBUG
                printf("type:\tprogram");//DEBUG
                break;//DEBUG
//DEBUG
        case Nblock://DEBUG
                printf("type:\tblock");//DEBUG
                break;//DEBUG
//DEBUG
        case Nstmtls://DEBUG
                printf("type:\tstatement list");//DEBUG
                break;//DEBUG
//DEBUG
        case Nstmt://DEBUG
                printf("type:\tstatement");//DEBUG
                break;//DEBUG
//DEBUG
        case Ndeclar://DEBUG
                printf("type:\tdeclaration");//DEBUG
                break;//DEBUG
//DEBUG
        case Nassign://DEBUG
                printf("type:\tassignment");//DEBUG
                break;//DEBUG
//DEBUG
        case Nif://DEBUG
                printf("type:\tif");//DEBUG
                break;//DEBUG
//DEBUG
        case Nwhile://DEBUG
                printf("type:\twhile");//DEBUG
                break;//DEBUG
//DEBUG
        case Nexpr://DEBUG
                printf("type:\texpression");//DEBUG
                break;//DEBUG
//DEBUG
        default://DEBUG
                printf("TYPE %d\n", n->ntype);
        }//DEBUG
}//DEBUG

/* Helper function for pt_traverse. */
void pt_traverse_rec (struct tnode *n, FILE* f)
{
        /* Base case: leaf reached. */
        if (!n)
                return;        

        //print_node (n);//DEBUG
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


