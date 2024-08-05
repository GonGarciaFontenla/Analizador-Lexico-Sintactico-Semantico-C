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

    if(conteo_identificadores == 0)
    {
        printf(" -\n");
    }else
    {
        // Recorre el arreglo de identificadores e imprime cada uno junto con su conteo
        for (int i = 0; i < conteo_identificadores; ++i) 
        {
            printf("%s: %d\n", identificadores[i].identificador, identificadores[i].contador);
        }
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
        printf("\n* Listado de palabras reservadas encontradas: \n -\n");
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

    if (conteo_operadores == 0) 
    {
        printf(" -\n");
    }else
    {
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
void agregar_constante(int constante) 
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
    constantes[conteo_constantes].valor = constante;
    conteo_constantes++;
}

void sumatoriaConstantes()
{
    int suma = 0;
    for (int i = 0; i < conteo_constantes; ++i) 
    {
        suma += constantes[i].valor;
    }
    printf("Total acumulado de sumar todas las constantes decimales: %d\n", suma);
}

void imprimir_constante() 
{
    // Imprime el encabezado del listado
    printf("\n* Listado de constantes enteras decimales: \n");

    if (conteo_constantes == 0)
    {
        printf(" -\n");
    }else
    {
        // Recorre el arreglo de constantes e imprime cada uno junto con su valor
        for (int i = 0; i < conteo_constantes; ++i) 
        {
            printf("%d: valor %d\n", constantes[i].valor, constantes[i].valor);
        }
    }
}

// Función para liberar la memoria
void liberar_constante() 
{
    free(constantes);
    constantes = NULL;
    conteo_constantes = 0;
    capacidad_constantes = 0;
}
//------------------------------------------------------------------------------------//

//----------------------------CONSTANTES REALES--------------------------//

void agregar_constante_real(float constante_real) 
{
    // Si no hay suficiente espacio, redimensiona el arreglo
    if (conteo_const_real == capacidad_const_real) 
    {
        capacidad_const_real = (capacidad_const_real == 0) ? 1 : capacidad_const_real * 2;
        const_real = realloc(const_real, capacidad_const_real * sizeof(float));
        if (const_real == NULL) 
        {
            fprintf(stderr, "Error de memoria al redimensionar el arreglo de constantes reales\n");
            exit(EXIT_FAILURE);
        }
    }
    
    // Añade el nuevo elemento al final del arreglo
    const_real[conteo_const_real] = constante_real;
    conteo_const_real++;
}


void imprimir_real() 
{
    // Imprime el encabezado del listado
    printf("\n* Listado de constantes reales: \n");

    if (conteo_const_real == 0)
    {
        printf(" -\n");
    }else
    {
        float parte_entera;
        float parte_mantisa;
        // Recorre el arreglo de constantes e imprime cada uno junto con su valor
        for (int i = 0; i < conteo_const_real; ++i) 
        {
            parte_entera = (int)const_real[i];
            parte_mantisa = modff(const_real[i], NULL);
        
            printf("%.1f: parte entera %.6f, mantisa %.6f \n", const_real[i], parte_entera, parte_mantisa);
        }
    }
}

void liberar_real() 
{
    free(const_real);
    const_real = NULL;
    conteo_const_real = 0;
    capacidad_const_real = 0;
}


//------------------------------------------------------------------------------------//

//----------------------------CONSTANTES ENTERAS (OCTALES)--------------------------//
// Función para añadir constante al arreglo
void agregar_octal(const char* valor_octal, int valor_decimal) 
{
    // Si no hay suficiente espacio, redimensiona el arreglo
    if (conteo_octal == capacidad_octal) 
    {
        capacidad_octal = (capacidad_octal == 0) ? 1 : capacidad_octal * 2;
        constOctal = realloc(constOctal, capacidad_octal * sizeof(Octal));
        if (constOctal == NULL) 
        {
            fprintf(stderr, "Error de memoria al redimensionar el arreglo de constantes\n");
            exit(EXIT_FAILURE);
        }
    }
    
    // Añade el nuevo elemento al final del arreglo
    constOctal[conteo_octal].valor_octal = strdup(valor_octal); 
    constOctal[conteo_octal].valor_decimal = valor_decimal;
    conteo_octal++;
}

void imprimir_octal() 
{
    // Imprime el encabezado del listado
    printf("\n* Listado de constantes entera octales: \n");

    if (conteo_octal == 0)
    {
        printf(" -\n"); 
    }else
    {
        // Recorre el arreglo de constantes e imprime cada uno junto con su valor
        for (int i = 0; i < conteo_octal; ++i) 
        {
            printf("%s: valor entero decimal %d\n", constOctal[i].valor_octal, constOctal[i].valor_decimal);
        }
    }
}

// Función para liberar la memoria
void liberar_octal() 
{
    for (int i = 0; i < conteo_octal; ++i) 
    {
        free(constOctal[i].valor_octal);
    }

    free(constOctal);
    constOctal = NULL;
    conteo_octal = 0;
    capacidad_octal = 0;
}
//------------------------------------------------------------------------------------//

//--------------------------CONSTANTES ENTERAS (HEXADECIMALES)------------------------//

// Función para añadir constante al arreglo
void agregar_hexa(const char* valor_hexa, int valor_decimal) 
{
    // Si no hay suficiente espacio, redimensiona el arreglo
    if (conteo_hexa == capacidad_hexa) 
    {
        capacidad_hexa = (capacidad_hexa == 0) ? 1 : capacidad_hexa * 2;
        constHexa = realloc(constHexa, capacidad_hexa * sizeof(Hexadecimal));
        if (constHexa == NULL) 
        {
            fprintf(stderr, "Error de memoria al redimensionar el arreglo de constantes\n");
            exit(EXIT_FAILURE);
        }
    }
    
    // Añade el nuevo elemento al final del arreglo
    constHexa[conteo_hexa].valor_hexa = strdup(valor_hexa); 
    constHexa[conteo_hexa].valor_decimal = valor_decimal;
    conteo_hexa++;
}

void imprimir_hexa() 
{
    // Imprime el encabezado del listado
    printf("\n* Listado de constantes entera hexadecimales: \n");

    if (conteo_hexa == 0)
    {
        printf(" -\n"); 
    }else
    {
        // Recorre el arreglo de constantes e imprime cada uno junto con su valor
        for (int i = 0; i < conteo_hexa; ++i) 
        {
            printf("%s: valor entero decimal %d\n", constHexa[i].valor_hexa, constHexa[i].valor_decimal);
        }
    }
}

// Función para liberar la memoria
void liberar_hexa() 
{
    for (int i = 0; i < conteo_hexa; ++i) 
    {
        free(constHexa[i].valor_hexa);
    }

    free(constHexa);
    constHexa = NULL;
    conteo_hexa = 0;
    capacidad_hexa = 0;
}

//------------------------------------------------------------------------------------//

//------------------------------------NO RECONOCIDAS----------------------------------//

void agregar_no_reconocida(const char *noToken) {
    No_Reconocidas *temporal = realloc(no_reconocidas, (cantidad_no_rec + 1)* sizeof(No_Reconocidas));
    if(!temporal) {
        printf("¡Error al agrandar el vector!");
        return;
    }

    no_reconocidas = temporal; // el puntero keyWords apunta a temporal

    no_reconocidas[cantidad_no_rec].noToken = strdup(noToken);
    no_reconocidas[cantidad_no_rec].linea = linea;
    no_reconocidas[cantidad_no_rec].columna = columna;
 
    cantidad_no_rec ++;
}

void imprimir_no_reconocidas() {
    if(!cantidad_no_rec) {
        printf("\n* Listado de cadenas no reconocidas: \n -\n");
        return;
    }

    int found = 0;
    printf("\n* Listado de cadenas no reconocidas: \n");
    for(int i = 0; i < cantidad_no_rec; i++) {
        printf("%s: linea %i, columna %i \n", no_reconocidas[i].noToken, no_reconocidas[i].linea, no_reconocidas[i].columna);
        found = 1;
    }

    if(!found) {
        printf("-\n");
        return;
    }
}

void liberar_no_reconocidas() {
    if(no_reconocidas) {
        for(int i = 0; i < cantidad_no_rec; i++) {
            free(no_reconocidas[i].noToken);
        }
        free(no_reconocidas);
        no_reconocidas = NULL;
    }
}

//-----------------------------------------------------------------------------------//