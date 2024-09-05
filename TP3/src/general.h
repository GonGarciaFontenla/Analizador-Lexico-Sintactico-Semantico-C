#ifndef GENERAL_H
#define GENERAL_H

/* En los archivos de cabecera (header files) (*.h) poner DECLARACIONES (evitar DEFINICIONES) de C, así como directivas de preprocesador */
/* Recordar solamente indicar archivos *.h en las directivas de preprocesador #include, nunca archivos *.c */

#define YYLTYPE YYLTYPE

extern FILE *yyin;

typedef struct YYLTYPE
{
    int first_line;
    int first_column;
    int last_line;
    int last_column;
} YYLTYPE;

typedef struct {
    char* sym_name; // Para los nombres de cada simbolo
    char* sym_type; // Tipo de variable
    int sym_line;
    int sym_column; 
} t_sym;

typedef struct Nodo {
    t_sym sym;
    struct Nodo* sig;
} Nodo;



#define INICIO_CONTEO_LINEA 1
#define INICIO_CONTEO_COLUMNA 1

extern Nodo* symbols;

void pausa(void);
void inicializarUbicacion(void);
void reinicializarUbicacion(void);

void append_sym(char* name, char* type, int line, int column); 
int find_sym(char* name); 
void free_symbols();

#endif