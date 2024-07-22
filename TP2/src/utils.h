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

extern int conteo_identificadores;
extern Identifier identificadores[1000];

extern int conteo_literales;
extern StringLiteral literales[1000];

int comparar_identificadores(const void *a, const void *b);
void imprimir_identificadores();
void agregar_identificador(const char *name);

void agregar_literal(const char *literal); 
int comparar_literales(const void *a, const void *b);  
void imprimir_literales(); 




#endif