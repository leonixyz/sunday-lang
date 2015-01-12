#ifndef SUNDAYLANG_SYMBOL_TABLE
#define SUNDAYLANG_SYMBOL_TABLE


#define FUN 0   /* TODO unused */
#define VAR 1

/* A single simbol table's element. */
struct record {
        char *name;
        int type;
        struct record *next;
}

/* The simbol table itself. */
struct st {
        struct st *parent;
        struct record *first;
}

/* Insert a new record into a symbol table. */
void st_insert (struct st *table, struct record *new);

/* Lookup for a record. */
struct record *st_lookup (struct st *table, char *name);


#endif
