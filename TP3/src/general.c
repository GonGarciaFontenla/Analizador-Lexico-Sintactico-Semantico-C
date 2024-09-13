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

void init_structures() { // Iniciar todas las estructuras
    data_variable = (t_variable*)malloc(sizeof(t_variable));
    if (data_variable == NULL) {
        printf("Error al asignar memoria para data_variable\n");
        exit(EXIT_FAILURE);
    }
    data_variable->line = 0;

    data_function = (t_function*)malloc(sizeof(t_function));
    if (data_function == NULL) {
        printf("Error al asignar memoria para data_function\n");
        exit(EXIT_FAILURE);
    }
    data_function->line = 0;

}

void add_node(GenericNode** list, void* new_data, size_t data_size) { // Agregar a la lista genericamente
    GenericNode* new_node = (GenericNode*)malloc(sizeof(GenericNode)); // Reservamos memoria para cada nodo //
    new_node->data = malloc(data_size);

    memcpy(new_node->data, new_data, data_size);

    new_node->next = NULL; // El nodo se agrega al final, segun orden de aparicion

    if (*list == NULL) {
        *list = new_node;
        return;
    }

    GenericNode* current = *list;
    while (current->next != NULL) {
        current = current->next; 
    }

    current->next = new_node;
}

void print_lists() { // Printear todas las listas aca, PERO REDUCIR LA LOGICA HACIENDO UN PRINT PARTICULAR GENERICO
    if(variable) {
        GenericNode* aux = variable;
        while(aux) {
            t_variable* temp = (t_variable*)aux->data;
            printf("%s: %s, linea %i\n", temp->variable, temp->type, temp->line);
            aux = aux->next;
        }
    }

    if(function) {
        GenericNode* aux = function;
        while(aux) {
            t_function* temp = (t_function*)aux->data;
            printf("%s: %s, input: ", temp->name, temp->type);
            if (temp->parameters) {
                GenericNode* aux2 = temp->parameters;
                while (aux2) {
                    t_parameter* param = (t_parameter*)aux2->data;
                    if (param->type && param->name) {
                        printf("%s %s", param->type, param->name);
                    } else {
                        printf("Tipo o nombre de parámetro nulo");
                    }
                    aux2 = aux2->next;
                    
                    if (aux2) {
                        printf(", ");
                    }
                }
            } else {
                printf("Ningún parámetro");
            }
            printf(", retorna: %s, linea %i\n", temp->return_type, temp->line);
            aux = aux->next;
        }
    }
}

// void add_variable(char* variable_name) { 
//     data_variable->variable = strdup(variable_name);
//     data_variable->type = strdup(current_type);  // Copiar el tipo de la variable actual
//     data_variable->line = yylloc.first_line;  // Guardar la línea donde fue declarada

//     // Agregar la variable a la lista
//     add_node(&variable, data_variable, sizeof(t_variable));
// }

void free_data_variable(t_variable* variable) {
    if(variable) {
        free(variable->type);
        free(variable->variable);
    }
    free(variable);
    variable = NULL;
}

void free_parameters(t_parameter* param) {
    if (param) {
        free(param->type);
        free(param->name);
        free(param);
    }
}


//void add_function(char* function_name, char* function_type) {
//    data_function->name = strdup(function_name);
//    data_function->type = strdup(function_type); 
//    data_function->line = yylloc.first_line;  // Corregir, guarda la linea donde cierra el }
//    // parametros
//    data_function->return_type = strdup(function_type);

//    add_node(&function, data_function, sizeof(t_function));
//}

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

// void print_statements_list() {
//     StatementNode* nodo_actual = statements_list;
//     printf("* Listado de sentencias indicando tipo, numero de linea y de columna:\n");
//     while (nodo_actual != NULL) {
//         t_statement* stmt = nodo_actual->statement;
//         if (stmt != NULL) {
//             printf("%s: linea %d, columna %d\n",stmt->type, stmt->location->line, stmt->location->column);
//         } else {
//             printf("Sentencia vacía.\n");
//         }
//         nodo_actual = nodo_actual->next;
//     }
// }

