%{
#include <stdio.h>
#include <stdlib.h>
#define DEBUG

//-------------------------------IDENTIFICADORES-------------------------------//

// Estructura para almacenar un identificador y su conteo
typedef struct {
    char *identificador;
    int contador;
} Identifier;

// Arreglo para almacenar hasta 1000 identificadores
Identifier identificadores[1000];
int conteo_identificadores = 0;

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

//-----------------------------------------------------------------------------------------//

%}

SUFIJO_ENTERO ([uU]?[lL]{0,2}|[lL]{0,2}[uU]?)?
SUFIJO_REAL ([eE][+-]?[0-9]+)?[fFlL]?
DIGITO_DECIMAL [0-9]
DIGITO_OCTAL [0-7]
DIGITO_HEXA [0-9a-fA-F]
ESCAPE_SIMPLE [abfnrtv\\\'\"\?]

%pointer
%option noyywrap

%%

[1-9]{DIGITO_DECIMAL}*{SUFIJO_ENTERO} { printf("\nEncontré una constante entera decimal: %s\n", yytext); }
0{DIGITO_OCTAL}*{SUFIJO_ENTERO} { printf("\nEncontré una constante entera octal: %s\n", yytext); }
0[xX]{DIGITO_HEXA}+{SUFIJO_ENTERO} { printf("\nEncontré una constante entera hexadecimal: %s\n", yytext); }


[0-9]+\.[0-9]*{SUFIJO_REAL} { printf("\nEncontré una constante real: %s\n", yytext); }
\.[0-9]+{SUFIJO_REAL} { printf("\nEncontré una constante real: %s\n", yytext); }
[0-9]+{SUFIJO_REAL} { printf("\nEncontré una constante real: %s\n", yytext); }


int|float|double|char|void|short|long|unsigned|signed { printf("\nEncontré una palabra reservada: %s\n", yytext); }
if|else|while|for|do|switch|case|default|break|continue|return|goto { printf("\nEncontré una palabra reservada: %s\n", yytext); }
sizeof|typedef|static|extern|auto|register|volatile|const|enum|struct|union { printf("\nEncontré una palabra reservada: %s\n", yytext); }


'[^\\\']' { printf("\nEncontré un caracter simple: %s\n", yytext); }
'\\{ESCAPE_SIMPLE}' { printf("\nEncontré una secuencia de escape simple: %s\n", yytext); }
'\\{DIGITO_OCTAL}{1,3}' { printf("\nEncontré una secuencia de escape octal: %s\n", yytext); }
'\\x{DIGITO_HEXA}+' { printf("\nEncontré una secuencia de escape hexadecimal: %s\n", yytext); }


\"([^\\\"\n]|\\{ESCAPE_SIMPLE}|\\{DIGITO_OCTAL}{1,3}|\\x{DIGITO_HEXA}+)*\" { printf("\nEncontré un literal cadena: %s\n", yytext); }   


[_a-zA-Z][_a-zA-Z0-9]* { agregar_identificador(yytext); }


\+\+|\-\-|\+|\-|\*|\/|\% { printf("\nEncontré un operador aritmético: %s\n", yytext); }
\&\&|\|\||\! { printf("\nEncontré un operador lógico: %s\n", yytext); }
\=\=|\!\=|\<\=|\>\=|\<|\> { printf("\nEncontré un operador de comparación: %s\n", yytext); }
\=|\+\=|\-\=|\*\=|\/\=|\%\= { printf("\nEncontré un operador de asignación: %s\n", yytext); }
[\(\)\[\]\{\}\,\;\:\.\?\-\>] { printf("\nEncontré un carácter de puntuación: %s\n", yytext); }


[ \t\n] ; // Ignorar espacios en blanco


. { printf("\nCaracter no reconocido: %s\n", yytext); }

%%

int main(int argc, char *argv[]) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            printf("Error abriendo el archivo de entrada");
            return EXIT_FAILURE;
        }
    } else {
        yyin = stdin;
    }

    yylex();

    if (yyin != stdin) 
        fclose(yyin);

    imprimir_identificadores(); 

    return EXIT_SUCCESS;
}