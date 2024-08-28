%{

#include <stdio.h>
#include <stdlib.h>
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

[1-9]{DIGITO_DECIMAL}*{SUFIJO_ENTERO} {
    yylloc.last_column += yyleng;
    yylval.int_type = strtoul(yytext, NULL,0); 
    return ENTERO;
}
0{DIGITO_OCTAL}*{SUFIJO_ENTERO} {
    yylloc.last_column += yyleng;
    yylval.int_type = (int) strtoul(yytext, NULL, 0); 
    return ENTERO;
}
0[xX]{DIGITO_HEXA}+{SUFIJO_ENTERO} {
    yylloc.last_column += yyleng;
    yylval.int_type = (int) strtoul(yytext, NULL, 0); 
    return ENTERO;
}

[0-9]+\.[0-9]*{SUFIJO_REAL} {
    yylloc.last_column += yyleng;
    yylval.double_type = strtod(yytext, NULL); 
    return NUM; 
}
\.[0-9]+{SUFIJO_REAL} {
    yylloc.last_column += yyleng;
    yylval.double_type = strtod(yytext, NULL); 
    return NUM; 
}
[0-9]+{SUFIJO_REAL} {
    yylloc.last_column += yyleng;
    yylval.double_type = strtod(yytext, NULL); 
    return NUM; 
}


int|float|double|char|void|short|long|unsigned|signed {
    yylloc.last_column += yyleng;
    return PALABRA_RESERVADA;
}
if|else|while|for|do|switch|case|default|break|continue|return|goto {
    yylloc.last_column += yyleng;
    return PALABRA_RESERVADA;
}
sizeof|typedef|static|extern|auto|register|volatile|const|enum|struct|union {
    yylloc.last_column += yyleng;
    return PALABRA_RESERVADA;
}


'[^\\\']' {
    yylloc.last_column += yyleng;
    return CONSTANTE; 
}
'\\{ESCAPE_SIMPLE}' {
    yylloc.last_column += yyleng;
    return CONSTANTE; 
}
'\\{DIGITO_OCTAL}{1,3}' {
    yylloc.last_column += yyleng;
    return CONSTANTE; 
}
'\\x{DIGITO_HEXA}+' {
    yylloc.last_column += yyleng;
    return CONSTANTE; 
}


\"([^\\\"\n]|\\{ESCAPE_SIMPLE}|\\{DIGITO_OCTAL}{1,3}|\\x{DIGITO_HEXA}+)*\" {
    yylloc.last_column += yyleng;
    yylval.string_type = strdup(yytext); 
    return LITERAL_CADENA; 
}   


[_a-zA-Z][_a-zA-Z0-9]* {
    yylloc.last_column += yyleng;
    yylval.string_type = yytext; 
    return IDENTIFICADOR;
}


{OPERADORES} {yylloc.last_column += yyleng; return yytext[0];} 


[ \t]+ {yylloc.first_column = yylloc.last_column += yyleng;}


\n {
    yylloc.first_line = yylloc.last_line += yyleng; 
    yylloc.first_column = yylloc.last_column = INICIO_CONTEO_COLUMNA;
    return '\n';
  }


[^ \t\n] {}
<tokenNoReconocido>{
    <<EOF>> {
        fprintf(stderr, "\n");
        BEGIN(INITIAL);
    }
    " "|\t|\n {
        yyless(0);
        fprintf(stderr, "\n");
        BEGIN(INITIAL);
    }
    [^ \t\n]+ {
        yylloc.last_column += yyleng;
        fprintf(stderr, "%s\n", yytext);
        BEGIN(INITIAL);
    }
}

%%