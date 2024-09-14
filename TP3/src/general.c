/* En los archivos (*.c) se pueden poner tanto DECLARACIONES como DEFINICIONES de C, así como directivas de preprocesador */
/* Recordar solamente indicar archivos *.h en las directivas de preprocesador #include, nunca archivos *.c */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "general.h"

extern YYLTYPE yylloc;
extern int yylineno;
extern char *yytext; 

extern int yyleng;

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
    if (!data_variable) {
        printf("Error al asignar memoria para data_variable\n");
        exit(EXIT_FAILURE);
    }
    data_variable->line = 0;
    data_variable->type = NULL;      
    data_variable->variable = NULL;

    data_function = (t_function*)malloc(sizeof(t_function));
    if (!data_function) {
        printf("Error al asignar memoria para data_function\n");
        exit(EXIT_FAILURE);
    }
    data_function->name = NULL;      
    data_function->line = 0;
    data_function->type = NULL;
    data_function->parameters = NULL;
    data_function->return_type = NULL;

    data_intoken = (t_token_unrecognised*)malloc(sizeof(t_token_unrecognised));
    if(!data_intoken) {
        printf("Error al asignar memoria para data_intoken");
        exit(EXIT_FAILURE);
    }
    data_intoken->column = 0;
    data_intoken->line = 0;
    data_intoken->token = NULL;
}

void add_sent(const char* tipo_sentencia) {
    // Asignar memoria para la nueva sentencia
    data_sent = (t_sent*)malloc(sizeof(t_sent));
    if (data_sent == NULL) {
        perror("Error al asignar memoria para data_sent");
        exit(EXIT_FAILURE);
    }

    // Inicializar los campos de data_sent
    data_sent->type = strdup(tipo_sentencia);
    if (data_sent->type == NULL) {
        perror("Error al asignar memoria para el tipo de sentencia");
        exit(EXIT_FAILURE);
    }
    data_sent->line = yylloc.first_line;
    data_sent->column = yylloc.first_column;

    // Agregar la sentencia a la lista
    add_node(&sentencias, data_sent, sizeof(t_sent));
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


// void yyerror(const char *msg) {
//     t_error *new_error = (t_error *)malloc(sizeof(t_error));
//     if (!new_error) {
//         perror("Error allocating memory");
//         exit(EXIT_FAILURE);
//     }

//     // Asigna la línea y las columnas
//     new_error->line = yylloc.first_line;
//     new_error->col_start = yylloc.first_column;
//     new_error->col_end = yylloc.last_column;

//     // Copia el mensaje del texto actual
//     size_t length = yyleng;  // Usa yyleng para obtener la longitud del token actual
//     new_error->message = (char *)malloc(length + 1);
//     if (!new_error->message) {
//         perror("Error allocating memory");
//         free(new_error);
//         exit(EXIT_FAILURE);
//     }

//     // Copia el texto del token directamente desde yytext
//     strncpy(new_error->message, yytext, length);
//     new_error->message[length] = '\0';  // Asegura la cadena nula al final

//     // Agrega el nuevo error a la lista de errores
//     add_node(&error_list, new_error, sizeof(t_error));
// }

void print_lists() { // Printear todas las listas aca, PERO REDUCIR LA LOGICA HACIENDO UN PRINT PARTICULAR GENERICO
    printf("\n");
    if(variable) {
        GenericNode* aux = variable;
        printf("* Listado de variables declaradas (tipo de dato y numero de linea):\n");
        while(aux) {
            t_variable* temp = (t_variable*)aux->data;
            printf("%s: %s, linea %i\n", temp->variable, temp->type, temp->line);
            aux = aux->next;
        }
    }
    printf("\n");

    if(function) {
        GenericNode* aux = function;
        printf("* Listado de funciones declaradas o definidas:\n");
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

    printf("\n");

    if(sentencias)
    {
        GenericNode* aux = sentencias;
        printf("* Listado de sentencias indicando tipo, numero de linea y de columna:\n");
        while (aux)
        {
            t_sent* temp = (t_sent*)aux->data;
            printf("%s: linea %i, columna %i\n", temp->type, temp->line, temp->column);
            aux = aux->next;
        }
    }

    printf("\n");
    
    if(intokens) {
        GenericNode* aux = intokens;
        printf("* Listado de cadenas no reconocidas:\n");
        while(aux) {
            t_token_unrecognised* aux_intoken = (t_token_unrecognised*)aux->data;
            printf("%s: linea %i, columna %i\n", aux_intoken->token, aux_intoken->line, aux_intoken->column);
            aux = aux->next;
        }
    }

}

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

void add_unrecognised_token(const char* intoken) {
    data_intoken -> token = strdup(intoken);
    data_intoken -> line = yylloc.first_line;
    data_intoken -> column = yylloc.first_column;
    add_node(&intokens, data_intoken, sizeof(t_token_unrecognised));
}


