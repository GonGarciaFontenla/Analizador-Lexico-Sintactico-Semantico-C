/* En los archivos (*.c) se pueden poner tanto DECLARACIONES como DEFINICIONES de C, así como directivas de preprocesador */
/* Recordar solamente indicar archivos *.h en las directivas de preprocesador #include, nunca archivos *.c */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "general.h"

extern YYLTYPE yylloc;
extern char *yytext; 

extern int yyleng;


char token_buffer[1024];  // Buffer para almacenar los tokens involucrados
int token_buffer_pos = 0; // Posición actual en el buffer

void reset_token_buffer() {
    token_buffer[0] = '\0';  // Resetea el buffer
    token_buffer_pos = 0;
}

void append_token(const char* token) {
    int len = strlen(token);
    if (token_buffer_pos + len < sizeof(token_buffer)) {
        if(token_buffer[0] != '\0'){ // Esto es solo para que se guarde con espacios y no quede tipo "j=a"
            strcat(token_buffer, " ");
            token_buffer_pos ++;
        }
        strcat(token_buffer, token);
        token_buffer_pos += len;
    }
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

    data_sent = (t_sent*)malloc(sizeof(t_sent));
    if (!data_sent) {
        ("Error al asignar memoria para data_sent");
        exit(EXIT_FAILURE);
    }
    data_sent->column = 0;
    data_sent->line = 0;
}

void add_unrecognised_token(const char* intoken) {
    data_intoken -> token = strdup(intoken);
    data_intoken -> line = yylloc.first_line;
    data_intoken -> column = yylloc.first_column;
    insert_node(&intokens, data_intoken, sizeof(t_token_unrecognised));
}

void add_sent(const char* tipo_sentencia, int line, int column) {
    data_sent->type = strdup(tipo_sentencia);
    if (!data_sent->type) {
        ("Error al asignar memoria para el tipo de sentencia");
        exit(EXIT_FAILURE);
    }
    data_sent->line = line;
    data_sent->column = column;
    insert_sorted_node(&sentencias, data_sent, sizeof(t_sent), compare_lines);
}

void insert_sorted_node(GenericNode** list, void* new_data, size_t data_size, int (*compare)(const void*, const void*)) {
    GenericNode* new_node = (GenericNode*)malloc(sizeof(GenericNode));
    if (!new_node) {
        ("Error al asignar memoria para el nuevo nodo");
        exit(EXIT_FAILURE);
    }
    new_node->data = malloc(data_size);
    if (!new_node->data) {
        ("Error al asignar memoria para los datos del nuevo nodo");
        exit(EXIT_FAILURE);
    }
    memcpy(new_node->data, new_data, data_size);
    new_node->next = NULL;

    if (!(*list) || compare(new_data, (*list)->data) <= 0) {
        new_node->next = *list;
        *list = new_node;
        return;
    }

    GenericNode* current = *list;
    while (current->next != NULL && compare(new_data, current->next->data) > 0) {
        current = current->next;
    }
    new_node->next = current->next;
    current->next = new_node;
} 


void insert_node(GenericNode** list, void* new_data, size_t data_size) {
    GenericNode* new_node = (GenericNode*)malloc(sizeof(GenericNode));
    if (!new_node) {
        ("Error al asignar memoria para el nuevo nodo");
        exit(EXIT_FAILURE);
    }

    new_node->data = malloc(data_size);
    if (!new_node->data) {
        ("Error al asignar memoria para los datos del nodo");
        free(new_node);
        exit(EXIT_FAILURE);
    }
    memcpy(new_node->data, new_data, data_size);
    new_node->next = NULL;

    if (!(*list)) {
        *list = new_node;
        return;
    }

    GenericNode* current = *list;
    while (current->next) {
        current = current->next;
    }
    current->next = new_node;
}

// void yerror(int columnaInicial, int columnaFinal) {
//     t_error *new_error = (t_error *)malloc(sizeof(t_error));
//     if (!new_error) {
//         ("Error al asignar memoria para el nuevo error");
//         exit(EXIT_FAILURE);
//     }

//     new_error->line = yylloc.first_line; 

//     size_t length = columnaFinal - columnaInicial; //Calculo el length del mensaje
    
//     new_error->message = (char *)malloc(length + 1);
//     if (!new_error->message) {
//         ("Error al asignar memoria para el mensaje del error");
//         free(new_error);
//         exit(EXIT_FAILURE);
//     }

//     strncpy(new_error->message, yytext + (columnaInicial - yylloc.first_column), length);
//     new_error->message[length] = '\0'; //Aseguro cadena nula
    
//     add_node(&error_list, new_error, sizeof(t_error), compare_lines_columns);
// }

void yerror(YYLTYPE ubicacion){
    t_error *new_error = (t_error *)malloc(sizeof(t_error));
    if (!new_error) {
        ("Error al asignar memoria para el nuevo error");
        exit(EXIT_FAILURE);
    }

    new_error->line = ubicacion.first_line;
    new_error->message = (char*)malloc(sizeof(token_buffer));

    strncpy(new_error->message, token_buffer, token_buffer_pos + 1);
    
    insert_node(&error_list, new_error, sizeof(t_error));
}


void print_lists() { // Printear todas las listas aca, PERO REDUCIR LA LOGICA HACIENDO UN PRINT PARTICULAR GENERICO
    int found = 0;

    printf("* Listado de variables declaradas (tipo de dato y numero de linea): \n");

    if(variable) {
        GenericNode* aux = variable;
        while(aux) {
            t_variable* temp = (t_variable*)aux->data;
            printf("%s: %s, linea %i\n", temp->variable, temp->type, temp->line);
            aux = aux->next;
            found = 1;
        }
    }

    if(!found) {
        printf("-\n");
    }

    found = 0;
    printf("\n");

    printf("* Listado de funciones declaradas o definidas:\n");
    if(function) {
        GenericNode* aux = function;
        while(aux) {
            t_function* temp = (t_function*)aux->data;
            printf("%s: %s, input: ", temp->name, temp->type);
            if (temp->parameters) {
                GenericNode* aux2 = (GenericNode*) temp->parameters;
                while (aux2) {
                    t_parameter* param = (t_parameter*)aux2->data;
                    if (param->type && param->name) {
                        printf("%s %s", param->type, param->name);
                    } else if (param->type){
                        printf("%s", param->type);
                    } else {
                        printf("Tipo de parametro nulo");
                    }
                    aux2 = aux2->next;
                    
                    if (aux2) {
                        printf(", ");
                    }
                }
            } else {
                printf("Ningun parametro");
            }
            printf(", retorna: %s, linea %i\n", temp->return_type, temp->line);
            aux = aux->next;
            found = 1;
        }
    }

    if(!found) {
        printf("-\n");
    }

    printf("\n");
    found = 0;

    printf("* Listado de sentencias indicando tipo, numero de linea y de columna:\n");
    if(sentencias) {
        GenericNode* aux = sentencias;
        while (aux)
        {
            t_sent* temp = (t_sent*)aux->data;
            printf("%s: linea %i, columna %i\n", temp->type, temp->line, temp->column);
            aux = aux->next;
            found = 1;
        }
    }

    if(!found) {
        printf("-\n");
    }
    
    found = 0;
    printf("\n");
    printf("* Listado de estructuras sintacticas no reconocidas:\n");
    if (error_list) {
        GenericNode* temp = error_list;
        while (temp) {
            t_error* err = (t_error*) temp->data;
            printf("\"%s\": linea: %d \n", err->message, err->line);
            // printf("Error en la linea %d: %s\n", err->line, err->message);
            temp = temp->next;
            found = 1;
        }
    }  

    if(!found) {
        printf("-\n");
    }

    found = 0;
    printf("\n");

    printf("* Listado de cadenas no reconocidas:\n");
    if(intokens) {
        GenericNode* aux = intokens;
        while(aux) {
            t_token_unrecognised* aux_intoken = (t_token_unrecognised*)aux->data;
            printf("%s: linea %i, columna %i\n", aux_intoken->token, aux_intoken->line, aux_intoken->column);
            aux = aux->next;
            found = 1;
        }
        printf("\n");
    }

    if(!found) {
        printf("-\n");
    }

}

void free_list() {

}

int compare_lines(const void* a, const void* b) {
    const t_sent* sent_a = (const t_sent*)a;
    const t_sent* sent_b = (const t_sent*)b;

    return sent_a->line - sent_b->line;
}
