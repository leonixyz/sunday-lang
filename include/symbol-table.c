#include "symbol-table.h"


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


struct st_rec *st_lookup (struct st *table, char *name)
{
        if (!table->first) {
                if (!table->parent)
                        return NULL;
                else
                        return st_lookup (table->parent, name);
        }

        struct st_rec *current = table->first;

        while (strcmp (current->name, name) != 0 && current->next)
                current = current->next;

        if (!current->next)
                return st_lookup (table->parent, name);
        else
                return current;
}
