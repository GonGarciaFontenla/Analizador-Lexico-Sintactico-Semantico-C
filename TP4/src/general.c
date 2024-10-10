/* En los archivos (*.c) se pueden poner tanto DECLARACIONES como DEFINICIONES de C, así como directivas de preprocesador */
/* Recordar solamente indicar archivos *.h en las directivas de preprocesador #include, nunca archivos *.c */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "general.h"

extern YYLTYPE yylloc;
extern char *yytext; 

extern int yyleng;
char* invalid_string;
t_error* new_error = NULL;

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

char* token_buffer = NULL;  // Buffer dinámico para almacenar los tokens
int token_buffer_pos = 0;   // Posición actual en el buffer
int token_buffer_size = 0;  // Tamaño actual del buffer

void reset_token_buffer() {
    if (token_buffer) {
        token_buffer[0] = '\0';  // Resetea el buffer
    }
    token_buffer_pos = 0;
}

// Función para agregar un token al buffer dinámico
void append_token(const char* token) {
    int len = strlen(token);
    if (!token_buffer || token_buffer_pos + len + 2 > token_buffer_size) {  // Si el buffer es nulo o no hay suficiente espacio, se debe reasignar memoria
        token_buffer_size = token_buffer_size + len + 2;  // +2 para el espacio y el terminador nulo
        char* new_buffer = (char*)realloc(token_buffer, token_buffer_size);
        if (!new_buffer) {
            printf("Error al asignar memoria para token_buffer");
            exit(EXIT_FAILURE);
        }
        token_buffer = new_buffer;
    }

    // Agregar un espacio si el buffer ya tiene contenido
    if (token_buffer[0] != '\0') {
        strcat(token_buffer, " ");
        token_buffer_pos++;
    }

    // Agregar el nuevo token
    strcat(token_buffer, token);
    token_buffer_pos += len;
}

void yerror(YYLTYPE ubicacion) {
    // Asignar memoria para el nuevo error
    t_error *new_error = (t_error *)malloc(sizeof(t_error));
    if (!new_error) {
        printf("Error al asignar memoria para el nuevo error");
        exit(EXIT_FAILURE);
    }

    new_error->line = ubicacion.first_line;

    new_error->message = (char*)malloc(token_buffer_pos + 1);  // +1 para el terminador nulo
    if (!new_error->message) {
        printf("Error al asignar memoria para el mensaje de error");
        exit(EXIT_FAILURE);
    }

    strncpy(new_error->message, token_buffer, token_buffer_pos + 1);

    insert_node(&error_list, new_error, sizeof(t_error));
}

void free_token_buffer() {
    if (token_buffer) {
        free(token_buffer);
        token_buffer = NULL;
    }
}

void save_function(char* type, const char* return_type, const char* id) {
    data_function->return_type = strdup(return_type);
    data_function->name = strdup(id);
    data_function->type = type;
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

    t_parameter* data_parameter = (t_parameter*)malloc(sizeof(t_parameter));
    if(!data_parameter) {
        printf("Error al asignar memoria para data_parameter\n");
        exit(EXIT_FAILURE);
    }
    data_parameter->name = NULL;
    data_parameter->type = NULL;

    data_intoken = (t_token_unrecognised*)malloc(sizeof(t_token_unrecognised));
    if(!data_intoken) {
        printf("Error al asignar memoria para data_intoken");
        exit(EXIT_FAILURE);
    }
    data_intoken->column = 0;
    data_intoken->line = 0;
    data_intoken->token = NULL;

    data_sem_error = (t_semantic_error*)malloc(sizeof(t_semantic_error));
    if(!data_sem_error) {
        printf("Error al asignar memoria para data_sem_error");
        exit(EXIT_FAILURE);
    }
    data_sem_error->msg = NULL;

    data_sent = (t_sent*)malloc(sizeof(t_sent));
    if (!data_sent) {
        printf("Error al asignar memoria para data_sent");
        exit(EXIT_FAILURE);
    }
    data_sent->column = 0;
    data_sent->line = 0;

    data_symbol = (t_symbol_table*)malloc(sizeof(t_symbol_table));
    if(!data_symbol) {
        printf("Error al asignar memoria para data_symbol");
        exit(EXIT_FAILURE);
    }
    data_symbol->column = 0;
    data_symbol->line = 0;
    data_symbol->scope = 0;
    data_symbol->symbol = 0;
    data_symbol->identifier = NULL;
    data_symbol->data = NULL;

    new_error = (t_error*)malloc(sizeof(t_error));
    if (!new_error) {
        printf("Error al asignar memoria para el nuevo error!\n");
        exit(EXIT_FAILURE);
    }
    new_error->line = 0;
    new_error->message = NULL; // Inicializa el puntero message a NULL
    
    invalid_string = (char*)malloc(1);
    if (!invalid_string) {
        printf("Error al asignar memoria para invalid_string\n");
        return;
    }
    invalid_string[0] = '\0';
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
        printf("Error al asignar memoria para el tipo de sentencia en %i:%i", line, column);
        exit(EXIT_FAILURE);
    }
    data_sent->line = line;
    data_sent->column = column;
    insert_sorted_node(&sentencias, data_sent, sizeof(t_sent), compare_lines);
}

void insert_sorted_node(GenericNode** list, void* new_data, size_t data_size, int (*compare)(const void*, const void*)) {
    GenericNode* new_node = (GenericNode*)malloc(sizeof(GenericNode));
    if (!new_node) {
        printf("Error al asignar memoria para el nuevo nodo");
        exit(EXIT_FAILURE);
    }
    new_node->data = malloc(data_size);
    if (!new_node->data) {
        printf("Error al asignar memoria para los datos del nuevo nodo");
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
        printf("Error al asignar memoria para el nuevo nodo");
        exit(EXIT_FAILURE);
    }

    new_node->data = malloc(data_size);
    if (!new_node->data) {
        printf("Error al asignar memoria para los datos del nuevo nodo");
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

void print_lists() { // Printear todas las listas aca, PERO REDUCIR LA LOGICA HACIENDO UN PRINT PARTICULAR GENERICO
    int found = 0;

    printf("* Listado de variables declaradas (tipo de dato y numero de linea):\n");

    if(variable) {
        GenericNode* aux = variable;
        while(aux) {
            t_variable* temp = (t_variable*)aux->data;
            printf("%s: %s, linea %i, columna %i \n", temp->variable, temp->type, temp->line, temp->column);
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
                        printf(strcmp(param->name, "") == 0 ? "%s" : "%s %s", param->type, param->name);
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
                printf("void");
            }
            printf(", retorna: %s, linea %i \n", temp->return_type, temp->line);
            aux = aux->next;
            found = 1;
        }
    }

    if(!found) {
        printf("-\n");
    }

    printf("\n");
    found = 0;


    printf("* Listado de errores semanticos:\n");
    print_semantic_errors(semantic_errors);

    found = 0;
    printf("\n");
    printf("* Listado de errores sintacticos:\n");
    if (error_list) {
        GenericNode* temp = error_list;
        while (temp) {
            t_error* err = (t_error*) temp->data;
            printf("\"%s\": linea %d\n", err->message, err->line);
            temp = temp->next;
            found = 1;
        }
    }  

    if(!found) {
        printf("-\n");
    }

    found = 0;
    printf("\n");

    printf("* Listado de errores lexicos:\n");
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

    // printf("* Si\n");
    // if(symbol_table) {
    //     GenericNode* aux = symbol_table;
    //     while(aux) {
    //         t_symbol_table* auxx = (t_symbol_table*)aux->data;
    //         if(auxx->symbol == 0) {
    //             t_function* func = (t_function*) auxx->data;
    //             printf("%i:%i: ID: %s - Symbol: %i - Ret: %s - Name: %s\n", auxx->line, auxx->column, auxx->identifier, auxx->symbol, func->return_type, func->name);
                
    //         }
    //         aux = aux -> next;
    //     }
    // }

}

void print_semantic_errors(GenericNode* list) {
    if(list) {
        GenericNode* aux = list;
        while(aux) {
            t_semantic_error* aux_error = (t_semantic_error*)aux->data;
            printf("%s\n", aux_error->msg);
            aux = aux->next;
        }
        printf("\n");
    }
}

void free_list(GenericNode** head) { // ToDo: hay memory leaks, los free no estan pensados para sublistas
    GenericNode* temp;
    while (*head) {
        temp = *head;
        *head = (*head)->next;
        free(temp->data);
        free(temp);
    }
    *head = NULL; // Evita referencias a memoria liberada
}

void free_all_lists() { 
    free_list(&variable);
    free_list(&function);
    free_list(&error_list);
    free_list(&intokens);
    free_list(&sentencias);
}

int compare_lines(const void* a, const void* b) {
    const t_sent* sent_a = (const t_sent*)a;
    const t_sent* sent_b = (const t_sent*)b;

    return sent_a->line - sent_b->line;
}
                                    
int fetch_element(SYMBOL_TYPE symbol, void* wanted, compare_element cmp) {
    GenericNode* current = symbol_table;
    while (current) {
        t_symbol_table* sym = (t_symbol_table*)current->data;
        if(sym->symbol == symbol) {
            if (cmp(sym->data, wanted) == 1) { 
                return 1;
            }
        }
        current = current->next;
    }
    return 0;
}

int fetch_parameter(const char* wanted) {
    GenericNode* current = data_function->parameters; 
    while (current) {
        t_parameter* param = (t_parameter*)current->data;
        if(param && param->name) {
            if (strcmp(param->name, wanted) == 0) { 
                return 1; 
            }
        }
        current = current->next;  
    }
    return 0; 
}

int get_quantity_parameters(GenericNode* list) {
    GenericNode* aux = list;
    int quantity = 0;
    while(aux) {
        t_parameter* temp = (t_parameter*)aux -> data;
        if(temp && strcmp(temp->type, "void") == 0) {
            quantity --;
        }
        quantity ++;
        aux = aux -> next;
    }
    return quantity;
}

// Busca una variable que ÚNICAMENTE tenga el mismo IDENTIFICADOR que la trackeada
int compare_ID_variable(void* data, void* wanted) {
    t_variable* var_data = (t_variable*)data;
    t_variable* data_wanted = (t_variable*)wanted;
    return strcmp(var_data->variable, data_wanted->variable) == 0;
}

// Busca un IDENTIFICADOR NO declarado en los parametros de las invocaciones (ToDo: fijarse si se puede acoplar con el compare de arriba)
int compare_ID_parameter(void* data, void* wanted) {
    t_variable* var_data = (t_variable*)data;
    char* data_wanted = (char*)wanted;
    return strcmp(var_data->variable, data_wanted) == 0;
}

// Busca una funcion con el mismo IDENTIFICADOR que la trackeada pero con distinto tipo
int compare_ID_and_different_type_functions(void* data, void* wanted) {
    t_function* function_var = (t_function*)data;
    t_function* data_wanted = (t_function*)wanted;
    if(strcmp(function_var->return_type, data_wanted->return_type) != 0)
        return strcmp(function_var->name, data_wanted->name) == 0;
    return 0;
}

// Busca una variable en la lista de variables declaradas que tenga mismo IDENTIFICADOR y distinto tipo
int compare_ID_and_diff_type_variable(void* data, void* wanted) {
    t_variable* var_data = (t_variable*)data;
    t_variable* data_wanted = (t_variable*)wanted;

    return strcmp(var_data->variable, data_wanted->variable) == 0 &&
           strcmp(var_data->type, data_wanted->type) != 0;
}

// Busca una variable en la lista de variables declaradas que tenga mismo tipo y IDENTIFICADOR que la trackeada
int compare_ID_and_type_variable(void* data, void* wanted) {
    t_variable* var_data = (t_variable*)data;
    t_variable* data_wanted = (t_variable*)wanted;

    return strcmp(var_data->variable, data_wanted->variable) == 0 &&
           strcmp(var_data->type, data_wanted->type) == 0;
}

// Busca el IDENTIFICADOR de la variable pasada por parametro en la lista de funciones
int compare_ID_between_variable_and_function(void* data, void* wanted) {
    t_function* function_var = (t_function*)data;
    t_variable* data_wanted = (t_variable*)wanted;
    return strcmp(function_var->name, data_wanted->variable) == 0;
}

// Busca un IDENTIFICADOR x en la lista de funciones
int compare_char_and_ID_function(void* data, void* wanted) {
    t_function* function_var = (t_function*)data;
    char* data_wanted = (char*)wanted;
    return strcmp(function_var->name, data_wanted) == 0;
}

// Busca un IDENTIFICADOR x en la lista de variables
int compare_char_and_ID_variable(void* data, void* wanted) {
    t_variable* data_var = (t_variable*)data;
    char* data_wanted = (char*)wanted;
    return strcmp(data_var->variable, data_wanted) == 0;
}

// Busca el IDENTIFICADOR de la variable pasada por parametro en la lista de funciones DEFINIDAS O DECLARADAS (difiere por definicion y declaracion)
int compare_ID_in_declaration_or_definition(void* data, void* wanted) { 
    t_function* function_var = (t_function*)data;
    t_function* data_wanted = (t_function*)wanted;
    return (strcmp(function_var->type, data_wanted->type) == 0 && 
            strcmp(function_var->name, data_wanted->name) == 0);
}

// Busca el IDENTIFICADOR de la variable en los parametros de la funcion
int compare_variable_and_parameter(void* data, void* wanted) {
    t_parameter* data_param = (t_parameter*)data;
    t_variable* data_wanted = (t_variable*)wanted;
    return strcmp(data_param->name, data_wanted->variable) == 0;
}

int compare_void_function(void* data, void* wanted) {
    t_function* data_func = (t_function*)data;
    char* data_wanted = (char*)wanted;
    return strcmp(data_func->name, data_wanted) == 0 && strcmp(data_func->return_type, "void") == 0;
}

void insert_if_not_exists() {
    if (!fetch_element(VARIABLE, data_variable, compare_ID_variable) &&
        !fetch_element(FUNCTION, data_variable, compare_ID_between_variable_and_function)) {
        insert_node(&variable, data_variable, sizeof(t_variable));
        insert_symbol(VARIABLE);
    }
}

char* concat_parameters(GenericNode* parameters) {
    char* string_parameters = malloc(1);
    string_parameters[0] = '\0';

    GenericNode* aux = parameters;
    while (aux) {
        t_parameter* param = (t_parameter*) aux->data;

        size_t new_size = strlen(string_parameters) + strlen(param->type) + 3; // El +3 es para el caracter vacio, la coma y el espacio
        string_parameters = realloc(string_parameters, new_size);

        strcat(string_parameters, param->type);
        aux = aux -> next;
        if(aux) {
            strcat(string_parameters, ", ");
        }
    }

    return string_parameters;
}

void insert_symbol(SYMBOL_TYPE symbol_type) {
    data_symbol->symbol = symbol_type;
    switch (data_symbol->symbol) {
        case FUNCTION:
            data_symbol->identifier = strdup(data_function->name);
            data_symbol->data = malloc(sizeof(t_function));
            if (!data_symbol->data) {
                printf("Error allocating memory for data_symbol->data\n");
                exit(EXIT_FAILURE);
            }
            memcpy(data_symbol->data, data_function, sizeof(t_function));
            break;

        case VARIABLE:
            data_symbol->identifier = strdup(data_variable->variable);
            data_symbol->data = malloc(sizeof(t_variable));
            if (!data_symbol->data) {
                printf("Error allocating memory for data_symbol->data\n");
                exit(EXIT_FAILURE);
            }
            memcpy(data_symbol->data, data_variable, sizeof(t_variable));
            break;

        default:
            printf("Unknown symbol type\n");
            break;
    }

    insert_node(&symbol_table, data_symbol, sizeof(t_symbol_table));
}

t_symbol_table* get_element(SYMBOL_TYPE symbol_type, void* wanted, compare_element cmp) {
    GenericNode* current = symbol_table;
    while (current) {
        t_symbol_table* aux = (t_symbol_table*)current->data;
        if(aux->symbol == symbol_type) {
            if (cmp(aux->data, wanted) == 1) {
                return aux;
            }
        }
        current = current->next;
    }
    return NULL;
}
//TO DO: comentamos todo porque nos falla la función '_asprintf'
void insert_sem_error_different_symbol(int column) {
    t_symbol_table* existing_symbol = get_element(FUNCTION, data_function, compare_ID_and_different_type_functions);
    if(existing_symbol) {
        t_function* existing_function = (t_function*)existing_symbol->data;
        if(existing_function) {
            char* new_parameters = concat_parameters(data_function -> parameters);
            char* old_parameters = concat_parameters(existing_function -> parameters);
            _asprintf(&data_sem_error->msg, "%i:%i: Conflicto de tipos para '%s'; la ultima es de tipo '%s(%s)'\nNota: la declaracion previa de '%s' es de tipo '%s(%s)': %i:%i",
                    data_function->line, column, data_function->name,
                    data_function->return_type, new_parameters, existing_function->name, 
                    existing_function->return_type, old_parameters,
                    existing_symbol->line, existing_symbol->column);
            insert_node(&semantic_errors, data_sem_error, sizeof(t_semantic_error));
        }
    }
}

void insert_sem_error_invocate_function(int line, int column, char* identifier, int quant_parameters) {
    if(!fetch_element(FUNCTION, data_function, compare_ID_and_different_type_functions)) {
        _asprintf(&data_sem_error -> msg, "%i:%i: Funcion '%s' sin declarar", line, column, identifier);
        insert_node(&semantic_errors, data_sem_error, sizeof(t_semantic_error));
    } else if(!fetch_element(FUNCTION, identifier, compare_char_and_ID_function)) {
        insert_sem_error_invalid_identifier(line, column, identifier);
    } else if(fetch_element(FUNCTION, identifier, compare_char_and_ID_function)) {
        insert_sem_error_too_many_or_few_parameters(line, column, identifier, quant_parameters);
    }
}

void insert_sem_error_invalid_identifier(int line, int column, char* identifier) {
    t_symbol_table* existing_symbol = get_element(VARIABLE, identifier, compare_char_and_ID_variable);
    if(existing_symbol) {
        _asprintf(&data_sem_error -> msg, "%i:%i: El objeto invocado '%s' no es una funcion o un puntero a una funcion\nNota: declarado aqui: %i:%i",
                line, column, identifier, 
                existing_symbol -> line, existing_symbol -> column);
        insert_node(&semantic_errors, data_sem_error, sizeof(t_semantic_error));
    }
}

void insert_sem_error_too_many_or_few_parameters(int line, int column, char* identifier, int quant_parameters) {
    t_symbol_table* existing_symbol = get_element(FUNCTION, identifier, compare_char_and_ID_variable);
    if(existing_symbol) {
        t_function* existing_function = (t_function*)existing_symbol->data;

        if(get_quantity_parameters(existing_function -> parameters) > quant_parameters) {
            _asprintf(&data_sem_error -> msg, "%i:%i: Insuficientes argumentos para la funcion '%s'\nNota: declarado aqui: %i:%i",
                    line, column, identifier,
                    existing_symbol->line, existing_symbol->column);
            insert_node(&semantic_errors, data_sem_error, sizeof(t_semantic_error));
        } else if(get_quantity_parameters(existing_function -> parameters) < quant_parameters) {
            _asprintf(&data_sem_error -> msg, "%i:%i: Demasiados argumentos para la funcion '%s'\nNota: declarado aqui: %i:%i",
                    line, column, identifier,
                    existing_symbol->line, existing_symbol->column);
            insert_node(&semantic_errors, data_sem_error, sizeof(t_semantic_error));
        }
    }
}

void handle_redeclaration(int redeclaration_line, int redeclaration_column, const char* identifier) {
    t_symbol_table* existing_symbol = get_element(FUNCTION, data_variable, compare_ID_between_variable_and_function); // Si no encuentra, asigna null, por ende no hace falta reinicializar en las demas

    if (existing_symbol) {
        check_function_redeclaration(existing_symbol, redeclaration_line, redeclaration_column, identifier);
        return;
    }

    existing_symbol = get_element(VARIABLE, data_variable, compare_ID_and_type_variable);

    if (existing_symbol) {
        check_variable_redeclaration(existing_symbol, redeclaration_line, redeclaration_column, identifier);
        return;
    }
    
    existing_symbol = get_element(VARIABLE, data_variable, compare_ID_and_diff_type_variable);
    if (existing_symbol) {
        check_type_conflict(existing_symbol, redeclaration_line, redeclaration_column, identifier);
    }
}

void check_function_redeclaration(t_symbol_table* symbol, int line, int column, const char* id) {
    t_function* existing_function = (t_function*)symbol->data;
    _asprintf(&data_sem_error->msg, "%i:%i: '%s' redeclarado como un tipo diferente de simbolo\nNota: la declaracion previa de '%s' es de tipo '%s': %i:%i", 
            line, column, id, 
            existing_function->name, existing_function->return_type, 
            symbol->line, symbol->column);
    insert_node(&semantic_errors, data_sem_error, sizeof(t_semantic_error));
}

void check_variable_redeclaration(t_symbol_table* symbol, int line, int column, const char* id) {
    t_variable* existing_variable = (t_variable*)symbol->data;
    _asprintf(&data_sem_error->msg, "%i:%i: Redeclaracion de '%s'\nNota: la declaracion previa de '%s' es de tipo '%s': %i:%i", 
            line, column, id,
            existing_variable->variable, existing_variable->type,
            existing_variable->line, existing_variable->column);
    insert_node(&semantic_errors, data_sem_error, sizeof(t_semantic_error));
}

void check_type_conflict(t_symbol_table* symbol, int line, int column, const char* id) {
    t_variable* existing_variable = (t_variable*)symbol->data;
    _asprintf(&data_sem_error->msg, "%i:%i: Conflicto de tipos para '%s'; la ultima es de tipo '%s'\nNota: la declaracion previa de '%s' es de tipo '%s': %i:%i",
            line, column, id,
            data_variable->type, existing_variable->variable, 
            existing_variable->type, existing_variable->line, 
            existing_variable->column);
    insert_node(&semantic_errors, data_sem_error, sizeof(t_semantic_error));
}

// //add_parameter
// int invocated_arguments_size = 0;

// void add_parameter(TYPES validation_type) {
//     invocated_arguments = (int*)realloc(invocated_arguments, (invocated_arguments_size + 1) * sizeof(TYPES));
//     if(invocated_arguments == NULL){
//         printf("Error al asignar memoria para invocated_arguments\n");
//         exit(EXIT_FAILURE);
//     }
    
//     switch(validation_type) {
//         case NUMBER: 
//             invocated_arguments[invocated_arguments_size] = NUMBER;
//             break; 
//         case STRING:
//             invocated_arguments[invocated_arguments_size] = STRING;
//             break;
//         default: 
//             break;
//         }
//         invocated_arguments_size++;
// }

// void compare_arguments(t_symbol_table* existing_symbol) {
//     t_function* existing_function = (t_function*)existing_symbol->data;
//     GenericNode* aux = existing_function->parameters;
//     int quantity_parameters = get_quantity_parameters(aux);
//     for(int i = 0; i < quantity_parameters && aux; i++) {
//         t_parameter* param = (t_parameter*)aux->data;
//         if(param && param->name) {
//             TYPES type = invocated_arguments[i];
//             switch(type) {
//                 case STRING:
//                     if(param->validation_type != STRING) {
//                         __asprintf(&data_sem_error->msg, "%i:%i: Incompatibilidad de tipos para el argumento %i de '%s'\nNota: se esperaba '%s' pero el argumento es de tipo 'char*': %i:%i",
//                                 yylloc.first_line, yylloc.first_column, i, existing_function->name, param->type,
//                                 existing_symbol->line, existing_symbol->column);
//                         insert_node(&semantic_errors, data_sem_error, sizeof(t_semantic_error));
//                     }
//                     break;
//                 case NUMBER:
//                     if(param->validation_type != NUMBER) {
//                         printf("CAGASTE!");
//                     }
//                     break;
//                 default:
//                     printf("Nada válido");
//                     break;
//             }
//         }
//         aux = aux->next;
//     }
// }




// struct t_variable* getId(char* identificador) {
//     GenericNode* nodo_aux = variable;
//     t_variable* var = nodo_aux->data;

//     while (var != NULL && strcmp(identificador, var->variable) != 0) {
//         nodo_aux = nodo_aux->next;
//         var = nodo_aux->data;
//     }
//     if(var != NULL){
//         return var;
//     }else{
//         return NULL;
//     }
// }
struct t_variable* getId(char* identificador) {
    GenericNode* nodo_aux = variable; // Asegúrate de que 'variable' esté inicializado correctamente
    t_variable* var;
    // Iterar a través de la lista enlazada
    while (nodo_aux != NULL) {
        var = nodo_aux->data; // Obtener el dato del nodo actual

        // Comprobar si 'var' no es NULL y comparar
        if (var != NULL && strcmp(identificador, var->variable) == 0) {
            return var; // Retornar la variable si hay coincidencia
        }

        nodo_aux = nodo_aux->next; // Mover al siguiente nodo
    }

    // Si no se encontró el identificador, retornar NULL
    return NULL;
}

int _asprintf(char **strp, const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    
    // Calcula el tamaño de la cadena resultante
    int size = _vscprintf(fmt, args) + 1;  // +1 para el terminador nulo
    
    if (size <= 0) {
        va_end(args);
        return -1;  // Error al calcular el tamaño
    }
    
    // Asigna memoria
    *strp = (char *)malloc(size);
    if (*strp == NULL) {
        va_end(args);
        return -1;  // Error al asignar memoria
    }
    
    // Genera la cadena formateada
    vsnprintf(*strp, size, fmt, args);
    
    va_end(args);
    return size - 1;  // Devuelve la longitud de la cadena sin contar el terminador nulo
}
