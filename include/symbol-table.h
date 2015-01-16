#ifndef SUNDAYLANG_SYMBOL_TABLE
#define SUNDAYLANG_SYMBOL_TABLE

#include <stddef.h>

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/*                        Preprocessor constants.                            */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

#define FUNCTION_SYMBOL 0   /* TODO unused */
#define VARIABLE_SYMBOL 1

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/*                         Structures definitions.                           */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

/* A single simbol table's element. */
struct st_rec {
        char            *name;
        int             type;
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


#endif
