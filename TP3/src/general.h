#ifndef GENERAL_H
#define GENERAL_H

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

typedef struct {
    int line;
    int column;
} location;

typedef struct {
    int line;
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
    char* type; // Si es declaracion o definicion
    t_parameter* parameters; // Es una sublista (array de parametros, guardar como string el tipo y el ID)
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

typedef struct GenericNode { // Estructura para reducir lógica repetida en los agregar //
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
    char *message;  // Campo para el mensaje del error
} t_error;


#define INICIO_CONTEO_LINEA 1
#define INICIO_CONTEO_COLUMNA 1

// extern Nodo* symbols;
extern GenericNode* statements_list;
extern GenericNode* variable;
extern GenericNode* function;
extern GenericNode* error_list;
extern GenericNode* intokens;
extern GenericNode* sentencias;
extern t_token_unrecognised* data_intoken;
extern t_variable* data_variable;
extern t_function* data_function;
extern t_parameter data_parameter;
extern t_sent* data_sent;
extern char token_buffer[];

void pausa(void);
void inicializarUbicacion(void);
void reinicializarUbicacion(void);
void init_structures();

void add_variable(char* variable_name);
void free_data_variable(t_variable* variable);
void add_function(char* function_name, char* function_type);
void free_list(GenericNode** list);
void free_parameters(t_parameter* param);
void add_sent(const char* tipo_sentencia, int line, int column);
void add_unrecognised_token(const char* intoken);
void yerror(YYLTYPE ubicacion);
void print_lists();
int compare_lines_columns(const void* a, const void* b);
void add_node(GenericNode** list, void* new_data, size_t data_size, int (*compare)(const void*, const void*));
// void free_lists(); TODO: hacer una funcion que free a todas las listas!


void reset_token_buffer();
void append_token(const char* token);


#endif