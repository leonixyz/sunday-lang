#include <string.h>
#include <stdio.h>
#include "symbol-table.h"

/*---------------------------------------------------------------------------*/

/* Symbol table entries types. */
const int TYPE_VOID   = 0;
const int TYPE_INT    = 1;
const int TYPE_REAL   = 2;
const int TYPE_STRING = 3;

/* Global pointer to the top of the symbol table's stack (defined in .y). */
extern struct st *st_stack_top;

/* Size of a symbol table's record. */
const size_t ST_REC_SIZE = sizeof (struct st_rec);

/*---------------------------------------------------------------------------*/

/* Insert a new record into a symbol table. */
void st_insert (struct st *table, struct st_rec *newrec)
{
        if (!table->first) {
                /* First symbol in the table. */
                table->first = newrec;
        }
        else {
                /* Iterate to the last position. */
                struct st_rec *current = table->first;
                while (current->next)
                        current = current->next;
                current->next = newrec;
        }
}


/* Set a type for a given symbol table's record. */
void st_settype (struct st_rec *symbol, int type)
{
        symbol->type = type;
}


/* Lookup for a record in the whole simbol table's stack. */
struct st_rec *st_lookup (struct st *table, char *name)
{
        /* Base case: the bottom of the stack was reached,
         * and the symbol wasn't found */
        if (!table)
                return NULL;

        /* Iterate over the current table. */
        struct st_rec *current = table->first;
        while (current){
                if (strcmp (current->name, name) == 0)
                        return current;
                current = current->next;
        }

        /* The symbol wasn't in the current table,
         * iterate over the parent table's entries. */
        return st_lookup (table->parent, name);
}


/* Lookup for a record only in the local simbol table. */
struct st_rec *st_lookup_local (struct st *table, char *name)
{
        /* Iterate over the current table. */
        struct st_rec *current = table->first;
        while (current){
                if (strcmp (current->name, name) == 0)
                        return current;
                current = current->next;
        }

        /* The symbol wasn't in the current table. */
        return NULL;
}


/* Free the memory for a given symbol table's entry. */
void st_rec_free (struct st_rec *todelete)
{
        free (todelete->name);
        free (todelete->value);
        /*TODO If new attributes are added to the struct st_rec,
         *     they have to be added also here to free all memory. */
        free (todelete);
}


/* Creates a new symbol table on top of the stack. */
void st_push ()
{
        struct st *newtab = calloc (1, sizeof (struct st));
        newtab->parent = st_stack_top;
        st_stack_top = newtab;
}


/* Pops a symbol table from top of the stack. */
void st_pop ()
{
        /* Update the pointer to the previous top of the stack. */
        struct st *todelete = st_stack_top;
        st_stack_top = todelete->parent;
        struct st_rec *current, *prev;
        
        /* Free the memory of all symbol table's entries. */
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


/* Flush the symbol table to a valid C string containing declarations. */
char *st_flush ()
{
        /*TODO This implementation is poor: the maximum size of all
         *     variables declarations into a block cannot be bounded */
        char *out = malloc (4096);

        /* Iterate over the symbol table's entries. */
        struct st_rec *current = st_stack_top->first;
        while (current) {
                /* Choose the right type identifier. */
                if (current->type == TYPE_VOID)
                        strcat (out, "void ");
                else if (current->type == TYPE_INT)
                        strcat (out, "int ");
                else if (current->type == TYPE_REAL)
                        strcat (out, "double ");
                else if (current->type == TYPE_STRING)
                        strcat (out, "char *");

                /* Declare the variable. */
                strcat (out, current->name);
                if (current->type == TYPE_STRING)
                        strcat (out, " = NULL");
                strcat (out, "; ");

                current = current->next;
        }

        return out;
}
