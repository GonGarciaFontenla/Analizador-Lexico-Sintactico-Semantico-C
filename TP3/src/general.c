/* En los archivos (*.c) se pueden poner tanto DECLARACIONES como DEFINICIONES de C, así como directivas de preprocesador */
/* Recordar solamente indicar archivos *.h en las directivas de preprocesador #include, nunca archivos *.c */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "general.h"

extern YYLTYPE yylloc;

Nodo* symbols = NULL;

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