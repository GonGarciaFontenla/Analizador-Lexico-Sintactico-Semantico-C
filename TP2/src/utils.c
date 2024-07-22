#include "utils.h"

//-----------------------------------IDENTIFICADORES-----------------------------------//

// Función para añadir un identificador al arreglo o incrementar su conteo si ya existe
void agregar_identificador(const char *name) 
{
    // Recorre el arreglo de identificadores
    for (int i = 0; i < conteo_identificadores; ++i) 
    {
        // Si encuentra el identificador, incrementa su conteo y retorna
        if (strcmp(identificadores[i].identificador, name) == 0) 
        {
            identificadores[i].contador++;
            return;
        }
    }

    // Si no encuentra el identificador, lo añade al final del arreglo
    identificadores[conteo_identificadores].identificador = strdup(name);
    identificadores[conteo_identificadores].contador = 1;
    conteo_identificadores++;
}

// Función de comparación para ordenar identificadores alfabéticamente
int comparar_identificadores(const void *a, const void *b) 
{
    return strcmp(((Identifier*)a)->identificador, ((Identifier*)b)->identificador);
}

// Función para imprimir los identificadores y sus conteos ordenados alfabéticamente
void imprimir_identificadores() 
{
    // Ordena el arreglo de identificadores usando la función de comparación
    qsort(identificadores, conteo_identificadores, sizeof(Identifier), comparar_identificadores);
    // Imprime el encabezado del listado
    printf("\n* Listado de identificadores encontrados: \n");
    // Recorre el arreglo de identificadores e imprime cada uno junto con su conteo
    for (int i = 0; i < conteo_identificadores; ++i) 
    {
        printf(" %s: %d\n", identificadores[i].identificador, identificadores[i].contador);
    }
}

//------------------------------------------------------------------------------------//

//-----------------------------------LITERAL CADENA-----------------------------------//

// Función para añadir un literal cadena al arreglo
void agregar_literal(const char *literal) 
{
    // Añade el literal al final del arreglo
    literales[conteo_literales].literal = strdup(literal);
    literales[conteo_literales].longitud = strlen(literal) - 2; // Restar 2 para eliminar las comillas dobles
    conteo_literales++;
}

// Función de comparación para ordenar literales por longitud y luego por orden de aparición
int comparar_literales(const void *a, const void *b) 
{
    StringLiteral *litA = (StringLiteral *)a;
    StringLiteral *litB = (StringLiteral *)b;
    
    if (litA->longitud != litB->longitud) {
        return litA->longitud - litB->longitud;
    } else {
        return 0; // Mantiene el orden de aparición si tienen la misma longitud
    }
}

// Función para imprimir los literales cadena y sus longitudes ordenados
void imprimir_literales() 
{
    if (conteo_literales == 0) {
        printf("\n* Listado de literales cadena encontrados:\n -\n");
        return;
    }
    // Ordena el arreglo de literales usando la función de comparación
    qsort(literales, conteo_literales, sizeof(StringLiteral), comparar_literales);
    // Imprime el encabezado del listado
    printf("\n* Listado de literales cadena encontrados: \n");
    // Recorre el arreglo de literales e imprime cada uno junto con su longitud
    for (int i = 0; i < conteo_literales; ++i) 
    {
        printf(" %s: longitud %d\n", literales[i].literal, literales[i].longitud);
    }
}

//------------------------------------------------------------------------------------//