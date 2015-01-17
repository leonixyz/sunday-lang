#include <string.h>
#include <stdio.h>
#include "symbol-table.h"

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/*                                 Constants.                                */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

/* Symbol table entries types. */
const TYPE_NOT_SET  = 0;
const TYPE_FUNCTION = 1;
const TYPE_NUMVAR   = 2;
const TYPE_STRVAR   = 3;
/* Extern data/constants. */
extern struct st *st_stack_top;
const int ST_REC_SIZE = sizeof (struct st_rec);

void st_insert (struct st *table, struct st_rec *newrec)
{
        if (!table->first) {
                table->first = newrec;
        }
        else {
                struct st_rec *current = table->first;
                while (current->next)
                        current = current->next;
                current->next = newrec;
        }
}


void st_settype (struct st_rec *symbol, int type)
{
        symbol->type = type;
}


struct st_rec *st_lookup (struct st *table, char *name)
{
        if (!table)
                return NULL;

        struct st_rec *current = table->first;
        while (current){
                if (strcmp (current->name, name) == 0)
                        return current;
                current = current->next;
        }

        return st_lookup (table->parent, name);
}

void st_rec_free (struct st_rec *todelete)
{
        free (todelete->name);
        /*TODO add deletion of other attributes if the struct st_rec changes */
        free (todelete);
}


void st_push ()
{
        struct st *newtab = calloc (1, sizeof (struct st));
        newtab->parent = st_stack_top;
        st_stack_top = newtab;
}


void st_pop ()
{
        struct st *todelete = st_stack_top;
        st_stack_top = todelete->parent;
        struct st_rec *current, *prev;
        
        if (todelete->first) {
                current = todelete->first;
                while (current->next) {
                        prev = current;
                        current = current->next;
                        st_rec_free (prev);
                }
                st_rec_free (current);
        }
        free (todelete);
}


char *st_flush ()
{
        /*TODO this implementation is poor */
        char *out = malloc (512);
        struct st_rec *current = st_stack_top->first;
        while (current) {
                if (current->type == TYPE_NUMVAR)
                        strcat (out, "double ");
                else if (current->type == TYPE_STRVAR)
                        strcat (out, "char * ");
                else if (current->type == TYPE_NOT_SET)
                        continue; /* optimization! skip unused variables */

                strcat (out, current->name);
                strcat (out, "; ");
                current = current->next;
        }

        return out;
}


void st_debug (struct st *tab)
{
        fprintf (stderr, "\nCurrent symbol table: %d\n", tab);
        if (!tab)
                return;

        struct st_rec *current = tab->first;
        while (current) {
                fprintf (stderr, "entry: %d\n", current);
                fprintf (stderr, "name: %s\n", current->name);
                fprintf (stderr, "type: %d\n", current->type);
                fprintf (stderr, "valu: %s\n", current->value);
                fprintf (stderr, "next %d\n\n", current->next);
                current = current->next;
        }
        st_debug (tab->parent);
}
