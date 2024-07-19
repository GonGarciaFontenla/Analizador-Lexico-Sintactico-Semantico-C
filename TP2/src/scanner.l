%{
#include <stdio.h>
#include <stdlib.h>
#define DEBUG
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

[0-9]+\.[0-9]*{SUFIJO_REAL}\b { printf("\nEncontré una constante real: %s\n", yytext); }
\.[0-9]+{SUFIJO_REAL}\b { printf("\nEncontré una constante real: %s\n", yytext); }
[0-9]+{SUFIJO_REAL}\b { printf("\nEncontré una constante real: %s\n", yytext); }

[_a-zA-Z][_a-zA-Z0-9]* { printf("\nEncontré un identificador: %s\n", yytext); }

'[^\\\']' { printf("\nEncontré un caracter simple: %s\n", yytext); }

'\\{ESCAPE_SIMPLE}' { printf("\nEncontré una secuencia de escape simple: %s\n", yytext); }
'\\{DIGITO_OCTAL}{1,3}' { printf("\nEncontré una secuencia de escape octal: %s\n", yytext); }
'\\x{DIGITO_HEXA}+' { printf("\nEncontré una secuencia de escape hexadecimal: %s\n", yytext); }

\"([^\\\"\n]|\\{ESCAPE_SIMPLE}|\\{DIGITO_OCTAL}{1,3}|\\x{DIGITO_HEXA}+)*\" { printf("\nEncontré un literal cadena: %s\n", yytext); }

int|float|double|char|void|short|long|unsigned|signed { printf("\nEncontré una palabra reservada: %s\n", yytext); }

if|else|while|for|do|switch|case|default|break|continue|return|goto { printf("\nEncontré una palabra reservada: %s\n", yytext); }

sizeof|typedef|static|extern|auto|register|volatile|const|enum|struct|union { printf("\nEncontré una palabra reservada: %s\n", yytext); }

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

    return EXIT_SUCCESS;
}

