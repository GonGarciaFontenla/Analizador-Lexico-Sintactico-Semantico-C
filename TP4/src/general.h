#ifndef GENERAL_H
#define GENERAL_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* En los archivos de cabecera (header files) (*.h) poner DECLARACIONES (evitar DEFINICIONES) de C, así como directivas de preprocesador */
/* Recordar solamente indicar archivos *.h en las directivas de preprocesador #include, nunca archivos *.c */

#define YYLTYPE YYLTYPE

#define INICIO_CONTEO_LINEA 1
#define INICIO_CONTEO_COLUMNA 1

extern FILE *yyin;

extern char* current_type;

typedef struct YYLTYPE
{
    int first_line;
    int first_column;
    int last_line;
    int last_column;
} YYLTYPE;

typedef struct GenericNode {                // Estructura para reducir lógica repetida en los agregar //
    void* data;
    struct GenericNode* next;
} GenericNode;

typedef struct {                            // A pesar de ser solo un campo, que podríamos haber laburado con un vector de char's, usamos una lista para seguir con la misma esencia con la que venimos trabajando
    char* msg;                              // Mensaje de X error semántico
} t_semantic_error;

typedef struct {
    int line;
    int column;
    char* type;
    char* variable;
} t_variable;

typedef struct {
    char* type;
    char* name;
} t_parameter;

typedef struct {
    char* name;
    int line;
    int column;
    char* type;                             // Si es declaracion o definicion
    GenericNode* parameters;                
    char* return_type;
} t_function;

typedef struct {
    int line;
    char* structure;
} t_structure_unrecognised;

typedef struct {
    int line;
    int column;
    char* token;
} t_token_unrecognised;

typedef struct {
    char* type;
    int line;
    int column;
} t_sent;

typedef struct {
    int line;
    char *message;                          // Campo para el mensaje del error
} t_error;



#define INICIO_CONTEO_LINEA 1
#define INICIO_CONTEO_COLUMNA 1

extern GenericNode* variable;
extern GenericNode* function;
extern GenericNode* error_list;
extern GenericNode* intokens;
extern GenericNode* sentencias;
extern GenericNode* semantic_errors;
extern t_token_unrecognised* data_intoken;
extern t_variable* data_variable;
extern t_function* data_function;
extern t_parameter data_parameter;
extern t_sent* data_sent;
extern t_error* new_error;
extern t_semantic_error* data_sem_error;

extern char* invalid_string;
extern int first_line_error;

typedef int (*compare_element)(void* data, void* wanted); // Es un alias para llamar en la funcion fetch y que resulte mucho mas legible

void pausa(void);
void inicializarUbicacion(void);
void reinicializarUbicacion(void);
void init_structures();

// ToDo: Hay una manera de mejorar los free
// con un struct que tenga un union y un enum, pero lo dejamos para la entrega final, muy dificil de pensar ahora 
void free_list(GenericNode** head);
void free_all_lists(void);

void add_sent(const char* tipo_sentencia, int line, int column);
void add_unrecognised_token(const char* intoken);
void add_sent(const char* tipo_sentencia, int line, int column);
void append_token(const char* token);
void save_function(const char* type, const char* return_type, const char* id);
char* concat_parameters(GenericNode* parameters);

void insert_sorted_node(GenericNode** list, void* new_data, size_t data_size, int (*compare)(const void*, const void*));
void insert_node(GenericNode** list, void* new_data, size_t data_size);
void insert_if_not_exists(GenericNode** variable_list, GenericNode* function_list, t_variable* data_variable);
void insert_sem_error_different_symbol();
void insert_sem_error_invocate_function(int line, int column, const char* identifier, int quant_parameters);
void insert_sem_error_too_many_or_few_parameters(int line, int column, const char* identifier, int quant_parameters);
void insert_sem_error_invalid_identifier(int line, int column, const char* identifier);

int compare_lines(const void* a, const void* b);
int compare_ID_variable(void* data, void* wanted);
int compare_ID_and_type_variable(void* data, void* wanted);
int compare_ID_and_different_type_functions(void* data, void* wanted);
int compare_ID_between_variable_and_function(void* data, void* wanted);
int compare_ID_in_declaration_or_definition(void* data, void* wanted);
int compare_ID_and_diff_type_variable(void* data, void* wanted);
int compare_variable_and_parameter(void* data, void* wanted);
int compare_char_and_ID_function(void* data, void* wanted);
int compare_char_and_ID_variable(void* data, void* wanted);

void print_lists();
void print_semantic_errors(GenericNode* list);

void* get_element(GenericNode* list, void* wanted, compare_element cmp);
int fetch_element(GenericNode* list, void* wanted, compare_element cmp);

void handle_redeclaration(int redeclaration_line, int redeclaration_column, const char* identifier); 

void reset_token_buffer();

void yerror(YYLTYPE string);

int get_quantity_parameters(GenericNode* list);

#endif