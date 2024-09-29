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

typedef enum {
    BINARY_OPERAND_TYPE_ERROR,               // Control de tipos de datos simples para la operación *
    UNDECLARED_ID,                          // Validación de otros operadores binarios y unarios (opcional)
    DOUBLE_DECLARATION_DIFF_SYMBOLS,        // Doble declaración de símbolos (mismo ID en una funcion y en una variable)
    DOUBLE_DECLARATION_DIFF_TYPES,          // Doble declaración de funciones con conflicto de tipos
    DOUBLE_DECLARATION,                     // Doble declaracion de mismo tipo y simbolo
    INEXISTENT_ID_FUNCTION,                 // Llamar a una funcion que no esta declarada
    INVALID_USE_FUNCTION,                   // Uso de una variable como si fuese una funcion
    INSUFFICIENT_ARGUMENTS,                 // Pasar menos argumentos de los necesarios
    TOO_MANY_ARGUMENTS,                     // Pasar mas argumentos de los necesarios
    CONFLICTING_TYPE_ARGUMENTS,             // Argumentos que no coinciden con el tipo de la funcion
    RETURN_IN_VOID_FUCTION,                 // Retornando en funciones void
    CONFLICTING_TYPES_ASSIGNATION,          // Asignacion que no corresponde al tipo de dato 
    DOUBLE_ASSIGNATION_CONST_VAR,           // Reasignacion a un objeto de tipo 'const'
    INVALID_L_VALUE_MODIFIER,               // No respeta L value modificable
    INEXISTENT_RETURN,                      // En funcion que requiere return, no se retorna
    CONFLICTING_TYPES_RETURN_FUNCTION       // Lo que se retorna no coincide con el tipo de la funcion
} SEMANTIC_ERROR_TYPE;

typedef struct {
    SEMANTIC_ERROR_TYPE error_type;         // Tipo de error (enum)
    int line;                               // Línea donde ocurrió el error
    int column;                             // Columna donde ocurrió el error
} t_semantic_error;


typedef struct YYLTYPE
{
    int first_line;
    int first_column;
    int last_line;
    int last_column;
} YYLTYPE;

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
    char* type;                             // Si es declaracion o definicion
    t_parameter* parameters;                // Es una sublista (array de parametros, guardar como string el tipo y el ID)
    char* return_type;
} t_function;

typedef struct {
    int line;
    int column;
    char* type;
} t_statement;

typedef struct {
    int line;
    char* structure;
} t_structure_unrecognised;

typedef struct {
    int line;
    int column;
    char* token;
} t_token_unrecognised;

typedef struct GenericNode {                // Estructura para reducir lógica repetida en los agregar //
    void* data;
    struct GenericNode* next;
} GenericNode;

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

extern GenericNode* statements_list;
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
extern t_semantic_error* new_semantic_error;

extern char* invalid_string;
extern int first_line_error;


typedef int (*compare_element)(void* data, char* wanted); // Es un alias para llamar en la funcion fetch y que resulte mucho mas legible

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

void insert_sorted_node(GenericNode** list, void* new_data, size_t data_size, int (*compare)(const void*, const void*));
void insert_node(GenericNode** list, void* new_data, size_t data_size);
int fetch_element(GenericNode* list, void* wanted, compare_element cmp);
int compare_ID_variable(void* data, void* wanted);
int compare_ID_function(void* data, void* wanted);
int compare_def_dec_functions(void* data, void* wanted);
int compare_types(void* data, void* wanted);
void insert_if_not_exists(GenericNode** variable_list, GenericNode* function_list, t_variable* data_variable);

void print_lists();

int compare_lines(const void* a, const void* b);

void reset_token_buffer();

void yerror(YYLTYPE string);

void validate_binary_multiplication(const char* operand1, const char* operand2, YYLTYPE location); 
void add_semantic_error(SEMANTIC_ERROR_TYPE error_type, const char* identifier, YYLTYPE ubicacion); 
const char* get_type_of_identifier(const char* identifier);
int is_identifier(const char* operand);


#endif