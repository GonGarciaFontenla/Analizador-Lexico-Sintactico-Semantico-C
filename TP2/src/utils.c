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
        printf(" %s: %d\n", identificadores[i].identificador, identificadores[i].contador);
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
        printf(" %s: longitud %d\n", literales[i].literal, literales[i].longitud);
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

    qsort(keyWords, cantidad_keywords, sizeof(t_key_word), comparar_keywords_por_palabra); // Primero ordeno por palabra reservada alfabeticamente
    qsort(keyWords, cantidad_keywords, sizeof(t_key_word), comparar_keywords_por_tipo); // Luego, una vez ordenado alfabeticamente, ordeno por tipo de reservada para facilitar la búsqueda

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

int comparar_keywords_por_tipo(const void* primero, const void* segundo) {
    const t_key_word* a = (const t_key_word*)primero; //Recasteos
    const t_key_word* b = (const t_key_word*)segundo;
    return a->type - b->type;
}

int comparar_keywords_por_palabra(const void* primero, const void* segundo) {
    const t_key_word* a = (const t_key_word*)primero;
    const t_key_word* b = (const t_key_word*)segundo;
    return strcmp(a->keyword, b->keyword);
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