#include "utils.h"

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