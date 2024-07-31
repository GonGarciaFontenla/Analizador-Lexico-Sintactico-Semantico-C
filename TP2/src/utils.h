#ifndef UTILS_H
#define UTILS_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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

extern Identifier *identificadores;
extern int conteo_identificadores;  
extern int capacidad_identificadores;

extern StringLiteral *literales;
extern int conteo_literales; 
extern int capacidad_literales;

extern t_key_word *keyWords;
extern int linea;
extern int columna;
extern int cantidad_keywords;

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


#endif