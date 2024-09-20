#ifndef UTILS_H
#define UTILS_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

// Funciones y estructuras ...

typedef struct {
    char *identificador;
    int contador;
} Identifier;

typedef struct {
    char *literal;
    int longitud;
} StringLiteral;

typedef enum {
    TIPO_DATO,
    TIPO_CONTROL,
    OTROS
} typeKeyWord;

typedef struct {
    int line;
    int column;
    char* keyword;
    typeKeyWord type;
} t_key_word;

typedef struct {
    char* operador;
    int apariciones;
} Operator;

typedef struct {
    int valor; 
} Constantes; 

typedef struct {
    char* valor_octal; 
    int valor_decimal; 
} Octal;

typedef struct {
    char* valor_hexa; 
    int valor_decimal; 
} Hexadecimal;

typedef struct {
    char *caracter;
    int cont;
} Caracter;

typedef struct {
    char* noToken;
    int linea;
    int columna;
} No_Reconocidas;


extern int linea;
extern int columna;

extern Identifier *identificadores;
extern int conteo_identificadores;  
extern int capacidad_identificadores;

extern StringLiteral *literales;
extern int conteo_literales; 
extern int capacidad_literales;

extern t_key_word *keyWords;
extern int cantidad_keywords;

extern Operator *operadores;
extern int conteo_operadores;  
extern int capacidad_operadores;

extern Constantes *constantes;
extern int conteo_constantes;
extern int capacidad_constantes;

extern Octal *constOctal;
extern int conteo_octal;
extern int capacidad_octal;

extern Hexadecimal *constHexa;
extern int conteo_hexa;
extern int capacidad_hexa;

extern float *const_real;
extern int conteo_const_real;
extern int capacidad_const_real;

extern Caracter *caracteres;
extern int conteo_caracter;
extern int capacidad_caracter; 
extern int contador_orden;

extern No_Reconocidas *no_reconocidas;
extern int cantidad_no_rec;


// Identificadores //
int comparar_identificadores(const void *a, const void *b);
void imprimir_identificadores();
void agregar_identificador(const char *name);
void liberar_identificadores(); 

// Literales Cadenas //
void agregar_literal(const char *literal); 
int comparar_literales(const void *a, const void *b);  
void imprimir_literales(); 
void liberar_literales();

// Palabras Reservadas //
void agregar_keyword(const char *keyword, typeKeyWord tipo);
void liberar_keywords();
void imprimir_keywords();


// Operadores y Puntuacion //
void agregar_operador(const char *op);
void imprimir_operadores();
void liberar_operadores();

// Constantes decimales //
void agregar_constante(int constante);
void imprimir_constante();
void sumatoriaConstantes();
void liberar_constante(); 

// Constantes octales //
void agregar_octal(const char* valor_octal, int valor_decimal); 
void imprimir_octal(); 
void liberar_octal(); 

// Constantes hexadecimales //
void agregar_hexa(const char* valor_hexa, int valor_decimal); 
void imprimir_hexa(); 
void liberar_hexa(); 

// Constantes reales //
void agregar_constante_real(float constante_real);
void imprimir_real();
void liberar_real(); 

// Constantes caracter //
void agregar_caracter(const char *caract);
void imprimir_caracter();
void liberar_caracter(); 

// No Reconocidas //
void agregar_no_reconocida(const char*);
void imprimir_no_reconocidas();
void liberar_no_reconocidas();

#endif