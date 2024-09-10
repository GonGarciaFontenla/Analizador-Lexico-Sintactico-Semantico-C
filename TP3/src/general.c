/* En los archivos (*.c) se pueden poner tanto DECLARACIONES como DEFINICIONES de C, así como directivas de preprocesador */
/* Recordar solamente indicar archivos *.h en las directivas de preprocesador #include, nunca archivos *.c */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "general.h"

extern YYLTYPE yylloc;
GenericNode* statements_list = NULL;
// Nodo* symbols = NULL;

void pausa(void)
{
    printf("Presione ENTER para continuar...\n");
    getchar();
}

void inicializarUbicacion(void)
{
    yylloc.first_line = yylloc.last_line = INICIO_CONTEO_LINEA;
    yylloc.first_column = yylloc.last_column = INICIO_CONTEO_COLUMNA;
}

void reinicializarUbicacion(void)
{
    yylloc.first_line = yylloc.last_line;
    yylloc.first_column = yylloc.last_column;
}

void add_node(GenericNode** list, void* new_data, size_t data_size) {
    GenericNode* new_node = (GenericNode*)malloc(sizeof(GenericNode)); // Reservamos memoria para cada nodo //
    new_node->data = malloc(data_size);

    memcpy(new_node->data, new_data, data_size);

    new_node->next = *list;
    *list = new_node;
}

void free_list(GenericNode** list) {
    GenericNode* nodo_actual = *list;
    GenericNode* nodo_siguiente = NULL;

    while (nodo_actual != NULL) {
        nodo_siguiente = nodo_actual->next;
        free(nodo_actual->data);
        free(nodo_actual);
        nodo_actual = nodo_siguiente;
    }
    *list = NULL;
}

void print_statements_list() {
    StatementNode* nodo_actual = statements_list;
    printf("* Listado de sentencias indicando tipo, numero de linea y de columna:\n");
    while (nodo_actual != NULL) {
        t_statement* stmt = nodo_actual->statement;
        if (stmt != NULL) {
            printf("%s: linea %d, columna %d\n",stmt->type, stmt->location->line, stmt->location->column);
        } else {
            printf("Sentencia vacía.\n");
        }
        nodo_actual = nodo_actual->next;
    }
}

