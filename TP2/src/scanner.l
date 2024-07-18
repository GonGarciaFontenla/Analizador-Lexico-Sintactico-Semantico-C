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

{DIGITO_DECIMAL}+{SUFIJO_ENTERO}\b { printf("\nEncontre una constante entera decimal: %s\n", yytext); }
0{DIGITO_OCTAL}+{SUFIJO_ENTERO}\b { printf("\nEncontre una constante entera octal: %s\n", yytext); }
0[xX]{DIGITO_HEXA}+{SUFIJO_ENTERO}\b { printf("\nEncontre una constante entera hexadecimal: %s\n", yytext); }

[0-9]+\.[0-9]*{SUFIJO_REAL}\b { printf("\nEncontre una constante real: %s\n", yytext); }
\.[0-9]+{SUFIJO_REAL}\b { printf("\nEncontre una constante real: %s\n", yytext); }
[0-9]+{SUFIJO_REAL} { printf("\nEncontre una constante real: %s\n", yytext); }

[_a-zA-Z][_a-zA-Z0-9]* { printf("\nEncontre un identificador: %s\n", yytext); }

'[^\\\']' { printf("\nEncontre un caracter simple: %s\n", yytext); }

'\\{ESCAPE_SIMPLE}' { printf("\nEncontre una secuencia de escape simple: %s\n", yytext); }
'\\{DIGITO_OCTAL}{1,3}' { printf("\nEncontre una secuencia de escape octal: %s\n", yytext); }
'\\x{DIGITO_HEXA}+' { printf("\nEncontre una secuencia de escape hexadecimal: %s\n", yytext); }

\"([^\\\"\n]|\\{ESCAPE_SIMPLE}|\\{DIGITO_OCTAL}{1,3}|\\x{DIGITO_HEXA}+)*\" { printf("\nEncontre un literal cadena: %s\n", yytext); }

int|float|double|char|void|short|long|unsigned|signed {printf("\nEncontre una palabra reservada: %s\n", yytext);}

if|else|while|for|do|switch|case|default|break|continue|return|goto { printf("\nEncontre una palabra reservada: %s\n", yytext); }

sizeof|typedef|static|extern|auto|register|volatile|const|enum|struct|union { printf("\nEncontre una palabra reservada: %s\n", yytext); }

\+\+|\-\-|\+|\-|\*|\/|\% { printf("\nEncontre un operador aritmético: %s\n", yytext); }

\&\&|\|\||\! { printf("\nEncontre un operador lógico: %s\n", yytext); }

\=\=|\!\=|\<\=|\>\=|\<|\> { printf("\nEncontre un operador de comparación: %s\n", yytext); }

\=|\+\=|\-\=|\*\=|\/\=|\%\= { printf("\nEncontre un operador de asignación: %s\n", yytext); }

[\(\)\[\]\{\}\,\;\:\.\?\-\>] { printf("\nEncontre un caracter de puntuación: %s\n", yytext); }

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
