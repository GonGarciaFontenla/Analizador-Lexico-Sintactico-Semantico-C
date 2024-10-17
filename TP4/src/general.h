#ifndef GENERAL_H
#define GENERAL_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

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

typedef enum {
    STRING,   
    INT,
    NUMBER,
    ID,
    UNKNOWN
} TYPES; 

typedef struct {
    char* type;
    char* name;
    int line;
    int column;
} t_parameter;

typedef struct {
    char* name;
    int line;
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

typedef enum {
    FUNCTION,
    VARIABLE
} SYMBOL_TYPE;

typedef struct {
    SYMBOL_TYPE symbol;
    void* data; 
    char* identifier;
    int line;
    int column;
    int scope;
} t_symbol_table;

typedef struct {
    int line;
    int column;
    TYPES type;
    char* name;
} t_arguments;

typedef struct {
    TYPES type;
    union {
        int int_val;
        double double_val;
        char* string_val;
        char* id_val; // para identificadores
    } value;
} t_variable_value;

#define INICIO_CONTEO_LINEA 1
#define INICIO_CONTEO_COLUMNA 1

extern GenericNode* variable;
extern GenericNode* function;
extern GenericNode* error_list;
extern GenericNode* intokens;
extern GenericNode* sentencias;
extern GenericNode* semantic_errors;
extern GenericNode* symbol_table;
extern t_symbol_table* data_symbol;
extern t_token_unrecognised* data_intoken;
extern t_variable* data_variable;
extern t_function* data_function;
extern t_parameter data_parameter;
extern t_sent* data_sent;
extern t_error* new_error;
extern t_semantic_error* data_sem_error;
extern t_arguments* invocated_arguments;
extern TYPES current_symbol;

extern char* invalid_string;
extern int first_line_error;
extern int string_flag;
extern char* type_aux;
extern int semicolon_flag; 
extern int size_vec_arguments;
extern int position; 
extern int init_flag;

typedef int (*compare_element)(void* data, void* wanted); // Es un alias para llamar en la funcion fetch y que resulte mucho mas legible

void pausa(void);
void inicializarUbicacion(void);
void reinicializarUbicacion(void);
void init_structures();

// ToDo: Hay una manera de mejorar los free
// con un struct que tenga un union y un enum, pero lo dejamos para la entrega final, muy dificil de pensar ahora 
void free_list(GenericNode** head);
void free_all_lists(void);
void free_invocated_arguments();

int _asprintf(char **strp, const char *fmt, ...);
void add_sent(const char* tipo_sentencia, int line, int column);
void add_unrecognised_token(const char* intoken);
void add_sent(const char* tipo_sentencia, int line, int column);
void append_token(const char* token);
void add_argument(int line, int column, TYPES type);
void save_function(char* type, const char* return_type, const char* id);
char* concat_parameters(GenericNode* parameters);

void insert_sorted_node(GenericNode** list, void* new_data, size_t data_size, int (*compare)(const void*, const void*));
void insert_node(GenericNode** list, void* new_data, size_t data_size);
void insert_if_not_exists();
void insert_sem_error_different_symbol(int column);
void insert_sem_error_invocate_function(int line, int column, char* identifier, int quant_parameters);
void insert_sem_error_too_many_or_few_parameters(int line, int column, char* identifier, int quant_parameters);
void insert_sem_error_invalid_identifier(int line, int column, char* identifier);
void insert_symbol(SYMBOL_TYPE type);

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
int compare_ID_parameter(void* data, void* wanted);
int compare_void_function(void* data, void* wanted);
void compare_arguments(t_symbol_table* function);

void print_lists();
void print_semantic_errors(GenericNode* list);

t_symbol_table* get_element(SYMBOL_TYPE symbol_type, void* wanted, compare_element cmp);
int fetch_element(SYMBOL_TYPE sym, void* wanted, compare_element cmp);
int fetch_parameter(const char* wanted);
int fetch_type_parameter(t_function* function, char* wanted);

void handle_redeclaration(int redeclaration_line, int redeclaration_column, const char* identifier); 
void check_function_redeclaration(t_symbol_table* function, int redeclaration_line, int redeclaration_column, const char* identifier); 
void check_variable_redeclaration(t_symbol_table* variable, int line, int column, const char* id); 
void check_type_conflict(t_symbol_table* variable, int line, int column, const char* id); 
void check_assignation_types(t_variable_value declarator, t_variable_value initializer, int line, int column);
int check_type_match(const char* a, const char* b);

void reset_token_buffer();

void yerror(YYLTYPE ubicacion);

void* get_parameter(GenericNode* list, int index);
int get_quantity_parameters(GenericNode* list);
void add_parameter(TYPES validation_type);
void return_conflict_types(t_symbol_table* existing_symbol, int line, int column); 
void manage_conflict_types(int line, int column);
void manage_conflict_arguments(char* identifier); 

struct t_variable* getId(char* identificador) ;

#endif 