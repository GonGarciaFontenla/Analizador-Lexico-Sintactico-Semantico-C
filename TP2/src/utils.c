#include "utils.h"
#include <string.h>

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

    // Si no hay suficiente espacio, redimensiona el arreglo
    if (conteo_identificadores == capacidad_identificadores) 
    {
        capacidad_identificadores = (capacidad_identificadores == 0) ? 1 : capacidad_identificadores * 2;
        identificadores = realloc(identificadores, capacidad_identificadores * sizeof(Identifier));
        if (identificadores == NULL) 
        {
            fprintf(stderr, "Error de memoria al redimensionar el arreglo de identificadores\n");
            exit(EXIT_FAILURE);
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
        printf("%s: %d\n", identificadores[i].identificador, identificadores[i].contador);
    }
}

// Función para liberar la memoria
void liberar_identificadores() 
{
    for (int i = 0; i < conteo_identificadores; ++i) 
    {
        free(identificadores[i].identificador);
    }
    free(identificadores);
    identificadores = NULL;
    conteo_identificadores = 0;
    capacidad_identificadores = 0;
}

//------------------------------------------------------------------------------------//

//-----------------------------------LITERAL CADENA-----------------------------------//

// Función para añadir un literal cadena al arreglo
void agregar_literal(const char *literal) 
{
    if (conteo_literales == capacidad_literales) 
    {
        capacidad_literales = (capacidad_literales == 0) ? 1 : capacidad_literales * 2;
        literales = realloc(literales, capacidad_literales * sizeof(StringLiteral));
        if (literales == NULL) 
        {
            fprintf(stderr, "Error de memoria al redimensionar el arreglo de literales\n");
            exit(EXIT_FAILURE);
        }
    }
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
        printf("%s: longitud %d\n", literales[i].literal, literales[i].longitud);
    }
}

void liberar_literales() 
{
    for (int i = 0; i < conteo_literales; ++i) 
    {
        free(literales[i].literal);
    }
    free(literales);
    literales = NULL;
    conteo_literales = 0;
    capacidad_literales = 0;
}

//------------------------------------------------------------------------------------//


//--------------------------------PALABRAS RESERVADAS--------------------------------//

void agregar_keyword(const char *keyword, typeKeyWord tipo) {
    t_key_word *temporal = realloc(keyWords, (cantidad_keywords + 1)* sizeof(t_key_word));
    if(!temporal) {
        printf("¡Error al agrandar el vector!");
        return;
    }

    keyWords = temporal; // el puntero keyWords apunta a temporal

    keyWords[cantidad_keywords].keyword = strdup(keyword);
    keyWords[cantidad_keywords].type = tipo;
    keyWords[cantidad_keywords].line = linea;
    keyWords[cantidad_keywords].column = columna;
 
    cantidad_keywords ++;
}

void imprimir_keywords() {
    if(!cantidad_keywords) {
        printf("\n* Listado de palabras reservadas encontradas: \n-");
        return;
    }

    printf("\n* Listado de palabras reservadas (tipos de dato):\n");
    int found = 0;
    for (int i = 0; i < cantidad_keywords; i++) {
        if (keyWords[i].type == TIPO_DATO) {
            printf("%s: linea %d, columna %d\n", keyWords[i].keyword, keyWords[i].line, keyWords[i].column);
            found = 1;
        }
    }
    if (!found) 
        {
            printf("-\n");
        }

    printf("\n* Listado de palabras reservadas (estructuras de control):\n");
    found = 0;
    for (int i = 0; i < cantidad_keywords; i++) {
        if (keyWords[i].type == TIPO_CONTROL) {
            printf("%s: linea %d, columna %d\n", keyWords[i].keyword, keyWords[i].line, keyWords[i].column);
            found = 1;
        }
    }
    if (!found) 
    {
        printf("-\n");
    }

    printf("\n* Listado de palabras reservadas (otros):\n");
    found = 0;
    for (int i = 0; i < cantidad_keywords; i++) {
        if (keyWords[i].type == OTROS) {
            printf("%s: linea %d, columna %d\n", keyWords[i].keyword, keyWords[i].line, keyWords[i].column);
            found = 1; 
        }
    }
    if (!found) 
    {
        printf("-\n");
    }
}

void liberar_keywords() {
    if(keyWords) {
        for(int i = 0; i < cantidad_keywords; i++) {
            free(keyWords[i].keyword);
        }
        free(keyWords);
        keyWords = NULL;
    }   
}

//------------------------------------------------------------------------------------//


//-------------------------------OPERADORES Y PUNTUACION-----------------------------//

void agregar_operador(const char *op)
{
    // Verifica si ya existe el operador en el arreglo
    for(int i = 0; i < conteo_operadores; i++)
    {
        if(strcmp(operadores[i].operador, op) == 0)
        {
            operadores[i].apariciones++;
            return;
        }
    }

    // Agranda el arreglo
    if(conteo_operadores == capacidad_operadores)
    {
        capacidad_operadores = (capacidad_operadores == 0) ? 1 : capacidad_operadores * 2;
        operadores = realloc(operadores, capacidad_operadores * sizeof(Operator));
        if(operadores == NULL)
        {
            fprintf(stderr, "Error de memoria al redimensionar el arreglo de operadores\n");
            exit(EXIT_FAILURE);
        }
    }

    // Agrega el nuevo operador al final, no hace falta reordenar
    operadores[conteo_operadores].operador = strdup(op);
    operadores[conteo_operadores].apariciones = 1;
    conteo_operadores++;
}


void imprimir_operadores()
{
    printf("\n* Listado de operadores/caracteres de puntuacion:\n");
    for(int i = 0; i < conteo_operadores; i++)
    {
        if(operadores[i].apariciones == 1)
        {
            printf("%s: aparece %d vez\n", operadores[i].operador, operadores[i].apariciones);
        }
        else 
        {
            printf("%s: aparece %d veces\n", operadores[i].operador, operadores[i].apariciones);
        }
        
    }
}

void liberar_operadores()
{
    for (int i = 0; i < conteo_operadores; ++i)
    {
        free(operadores[i].operador);
    }
    free(operadores);
    operadores = NULL;
    conteo_operadores = 0;
    capacidad_operadores = 0;
}

//------------------------------------------------------------------------------------//

//----------------------------CONSTANTES ENTERAS (DECIMALES)--------------------------//
// Función para añadir constante al arreglo
void agregar_constante(const char *constante) 
{
    // Si no hay suficiente espacio, redimensiona el arreglo
    if (conteo_constantes == capacidad_constantes) 
    {
        capacidad_constantes = (capacidad_constantes == 0) ? 1 : capacidad_constantes * 2;
        constantes = realloc(constantes, capacidad_constantes * sizeof(Constantes));
        if (constantes == NULL) 
        {
            fprintf(stderr, "Error de memoria al redimensionar el arreglo de constantes\n");
            exit(EXIT_FAILURE);
        }
    }
    
    // Añade el nuevo elemento al final del arreglo
    constantes[conteo_constantes].constantes = strdup(constante);
    conteo_constantes++;
}

void sumatoriaConstantes()
{
    int suma = 0;
    for (int i = 0; i < conteo_constantes; ++i) 
    {
        suma += constantes[i].valor;
    }
    printf("Total acumulado de sumar todas las constantes decimales:: %d\n", suma);
}

void imprimir_constante() 
{
    // Imprime el encabezado del listado
    printf("\n* Listado de constantes enteras decimales: \n");
    // Recorre el arreglo de constantes e imprime cada uno junto con su valor
   for (int i = 0; i < conteo_constantes; ++i) 
    {
        printf("%s: valor %s\n", constantes[i].constantes, constantes[i].constantes);
    }
}

// Función para liberar la memoria
void liberar_constante() 
{
    for (int i = 0; i < conteo_constantes; ++i) 
    {
        free(constantes[i].constantes);
    }
    free(constantes);
    constantes = NULL;
    conteo_constantes = 0;
    capacidad_constantes = 0;
}
//------------------------------------------------------------------------------------//

