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

void append_sym(char* name, char* type, int line, int column) {
    Nodo* new_node = (Nodo*)malloc(sizeof(Nodo));
    new_node->sym.sym_name = strdup(name);
    new_node->sym.sym_type = strdup(type);
    new_node->sym.sym_line = line;
    new_node->sym.sym_column = column;
    new_node->sig = symbols;
    symbols = new_node;
}


int find_sym(char* name) {
    Nodo* aux = symbols;
    while(aux) { // Mientras ambos no apunten a NULL
    if(strcmp(aux -> sym.sym_name, name) == 0) { // Se puede usar "!" para obviar el == 0, pero se me hace menos expresivo
    return 1; // Se encontro uwu
    }
    aux = aux -> sig;
    }
    return 0; // No encontrado ;c
}

void free_symbols() {
    Nodo* current = symbols;
    Nodo* next;

    while (current) {
    next = current->sig;
    free(current->sym.sym_name);
    free(current->sym.sym_type);
    free(current);
    current = next;
    }

    symbols = NULL;
}
