#ifndef GENERAL_H
#define GENERAL_H

/* En los archivos de cabecera (header files) (*.h) poner DECLARACIONES (evitar DEFINICIONES) de C, así como directivas de preprocesador */
/* Recordar solamente indicar archivos *.h en las directivas de preprocesador #include, nunca archivos *.c */

#define YYLTYPE YYLTYPE

#define INICIO_CONTEO_LINEA 1
#define INICIO_CONTEO_COLUMNA 1

extern FILE *yyin;

extern char* type;

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
    int linea;
    char* type; // Si es declaracion o definicion
    char** parameters; // Es una sublista (array de parametros, guardar como string el tipo y el ID)
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

typedef struct VariableNode {
    t_variable* variable;
    struct VariableNode* next;
} VariableNode;

typedef struct FunctionNode {
    t_function* function;
    struct FunctionNode* next;
} FunctionNode;

typedef struct StatementNode {
    t_statement* statement;
    struct StatementNode* next;
} StatementNode;

typedef struct UnrecognisedStructureNode {
    t_structure_unrecognised* structure;
    struct UnrecognisedStructureNode* next;
} UnrecognisedStructureNode;

typedef struct UnrecognisedTokenNode {
    t_token_unrecognised* token;
    struct UnrecognisedTokenNode* next;
} UnrecognisedTokenNode;

typedef struct GenericNode { // Estructura para reducir lógica repetida en los agregar //
    void* data;
    struct GenericNode* next;
} GenericNode;

<<<<<<< HEAD
#define INICIO_CONTEO_LINEA 1
#define INICIO_CONTEO_COLUMNA 1

// extern Nodo* symbols;
extern GenericNode* statements_list;
=======
extern GenericNode* variable;
extern t_variable* data_variable;
>>>>>>> 67b945135f842eeb2e0076d9b2c1ef28d0c73a26

void pausa(void);
void inicializarUbicacion(void);
void reinicializarUbicacion(void);
void init_structures();

/* Ejemplo: GenericNode* function = NULL (Para la lista que queremos); t_function* function_data = NULL; (Para los datos que queremos guardar)
   Agregamos datos a cada miembro de la estructura t_function de "function_data"
   add_node(&function, function_data, sizeof(t_function)); */ 
void add_node(GenericNode** list, void* new_data, size_t data_size); // Agregar a la lista de manera genérica //
<<<<<<< HEAD
void free_list(GenericNode** list);
void print_statements_list();
=======
void print_lists();
// void free_lists(); TODO: hacer una funcion que free a todas las listas!
>>>>>>> 67b945135f842eeb2e0076d9b2c1ef28d0c73a26
#endif