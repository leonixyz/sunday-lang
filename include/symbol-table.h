#ifndef SUNDAYLANG_SYMBOL_TABLE
#define SUNDAYLANG_SYMBOL_TABLE

#include <stddef.h>
#include <stdlib.h>


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/*                         Structures definitions.                           */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

/* A single simbol table's element. */
struct st_rec {
        char            *name;
        int             type;
        char            *value;
        struct st_rec   *next;
};

/* The simbol table itself. */
struct st {
        struct st       *parent;
        struct st_rec   *first;
};

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/*                        Functions declarations.                            */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

/* Insert a new record into a symbol table. */
void st_insert (struct st *table, struct st_rec *newrec);

/* Lookup for a record in the whole simbol table's stack. */
struct st_rec *st_lookup (struct st *table, char *name);

/* Creates a new symbol table on top of the stack. */
void st_push ();

/* Pops a symbol table from top of the stack. */
void st_pop ();

/* Flush the symbol table to a valid C string containing declarations. */
char *st_flush();


#endif
