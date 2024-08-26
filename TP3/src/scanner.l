%{

#include <stdio.h>
#include "general.h"

#include "parser.tab.h"

#define LINEA_INICIAL 1
#define COLUMNA_INICIAL 1


%}
%pointer
%option noyywrap
%x tokenNoReconocido

SUFIJO_ENTERO ([uU]?[lL]{0,2}|[lL]{0,2}[uU]?)?
SUFIJO_REAL ([eE][+-]?[0-9]+)?[fFlL]?
DIGITO_DECIMAL [0-9]
DIGITO_OCTAL [0-7]
DIGITO_HEXA [0-9a-fA-F]
ESCAPE_SIMPLE [abfnrtv\\\'\"\?]
OPERADORES \[|\]|\{|\}|\(|\)|\*|,|:|;|=|\.|#|&|\+|-|~|!|\/|%|<|>|\^|\?|(\.\.\.)|(->)|(\+\+)|(--)|(<<)|(>>)|(<=)|(>=)|(==)|(!=)|(&&)|(\|\|)|(\*=)|(\/=)|(%=)|(\+=)|(-=)|(<<=)|(>>=)|(&=)|(\^=)|(\|=)|(##)

%%

[1-9]{DIGITO_DECIMAL}*{SUFIJO_ENTERO} {}
0{DIGITO_OCTAL}*{SUFIJO_ENTERO} {}
0[xX]{DIGITO_HEXA}+{SUFIJO_ENTERO} {}


[0-9]+\.[0-9]*{SUFIJO_REAL} {}
\.[0-9]+{SUFIJO_REAL} {}
[0-9]+{SUFIJO_REAL} {}


int|float|double|char|void|short|long|unsigned|signed {}
if|else|while|for|do|switch|case|default|break|continue|return|goto {}
sizeof|typedef|static|extern|auto|register|volatile|const|enum|struct|union {}


'[^\\\']' {}
'\\{ESCAPE_SIMPLE}' {}
'\\{DIGITO_OCTAL}{1,3}' {}
'\\x{DIGITO_HEXA}+' {}


\"([^\\\"\n]|\\{ESCAPE_SIMPLE}|\\{DIGITO_OCTAL}{1,3}|\\x{DIGITO_HEXA}+)*\" {}   


[_a-zA-Z][_a-zA-Z0-9]* {}


{OPERADORES} {}


[ \t]+ {}


\n {}


[^ \t\n] {}
<tokenNoReconocido>{
    <<EOF>> {
        BEGIN(INITIAL);
    }
    " "|\t|\n {
        yyless(0);
        BEGIN(INITIAL);
    }
    [^ \t\n]+ {
        agregar_no_reconocida(yytext);
        columna += yyleng;
        BEGIN(INITIAL);
    }
}

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