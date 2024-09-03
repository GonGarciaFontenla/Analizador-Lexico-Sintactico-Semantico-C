%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "general.h"
#include "parser.tab.h"

#define LINEA_INICIAL 1
#define COLUMNA_INICIAL 1
%}

%option noyywrap
%option noinput
%x tokenNoReconocido

SUFIJO_ENTERO ([uU]?[lL]{0,2}|[lL]{0,2}[uU]?)?
SUFIJO_REAL ([eE][+-]?[0-9]+)?[fFlL]?
DIGITO_DECIMAL [0-9]
DIGITO_OCTAL [0-7]
DIGITO_HEXA [0-9a-fA-F]
ESCAPE_SIMPLE [abfnrtv\\\'\"\?]

%%

[1-9]{DIGITO_DECIMAL}*{SUFIJO_ENTERO} {
    yylloc.last_column += yyleng;
    yylval.int_type = strtoul(yytext, NULL,10); 
    return CONSTANTE;
}

0{DIGITO_OCTAL}*{SUFIJO_ENTERO} {
    yylloc.last_column += yyleng;
    yylval.int_type = (int) strtoul(yytext, NULL, 10); 
    return CONSTANTE;
}

0[xX]{DIGITO_HEXA}+{SUFIJO_ENTERO} {
    yylloc.last_column += yyleng;
    yylval.int_type = (int) strtoul(yytext, NULL, 10); 
    return CONSTANTE;
}

[0-9]+\.[0-9]*{SUFIJO_REAL} {
    yylloc.last_column += yyleng;
    yylval.double_type = strtod(yytext, NULL); 
    return CONSTANTE; 
}

\.[0-9]+{SUFIJO_REAL} {
    yylloc.last_column += yyleng;
    yylval.double_type = strtod(yytext, NULL); 
    return CONSTANTE; 
}

[0-9]+{SUFIJO_REAL} {
    yylloc.last_column += yyleng;
    yylval.double_type = strtod(yytext, NULL); 
    return CONSTANTE; 
}

char|int|float|double { 
    yylloc.last_column += yyleng;
    yylval.string_type = strdup(yytext);
    return TIPO;
}


void|short|long|unsigned|signed {
    yylloc.last_column += yyleng;
    yylval.string_type = strdup(yytext);
    return PALABRA_RESERVADA;
}

if|else|while|for|do|switch|case|default|break|continue|return|goto {
    yylloc.last_column += yyleng;
    yylval.string_type = strdup(yytext);
    return PALABRA_RESERVADA;
}

sizeof|typedef|static|extern|auto|register|volatile|const|enum|struct|union {
    yylloc.last_column += yyleng;
    yylval.string_type = strdup(yytext);
    return PALABRA_RESERVADA;
}

[_a-zA-Z][_a-zA-Z0-9]* {
    yylloc.last_column += yyleng;
    yylval.string_type = strdup(yytext); 
    return IDENTIFICADOR;
}

'[^\\\']' {
    yylloc.last_column += yyleng;
    yylval.char_type = yytext[1];  
    return CONSTANTE; 
}

'\\{ESCAPE_SIMPLE}' {
    yylloc.last_column += yyleng;
    yylval.char_type = yytext[1];  
    return CONSTANTE; 
}

'\\{DIGITO_OCTAL}{1,3}' {
    yylloc.last_column += yyleng;
    yylval.char_type = (char)strtol(yytext+1, NULL, 8);  
    return CONSTANTE; 
}

'\\x{DIGITO_HEXA}+' {
    yylloc.last_column += yyleng;
    yylval.char_type = (char)strtol(yytext+2, NULL, 16);  
    return CONSTANTE; 
}

\"([^\\\"\n]|\\{ESCAPE_SIMPLE}|\\{DIGITO_OCTAL}{1,3}|\\x{DIGITO_HEXA}+)*\" {
    yylloc.last_column += yyleng;
    yylval.string_type = strdup(yytext); 
    return LITERAL_CADENA; 
}

"+" { return '+'; }
"-" { return '-'; }
"*" { return '*'; }
"/" { return '/'; }
"%" { return '%'; }
"=" { return '='; }
"+=" { return ADD_ASSIGN; }
"-=" { return SUB_ASSIGN; }
"*=" { return MUL_ASSIGN; }
"/=" { return DIV_ASSIGN; }
"%=" { return MOD_ASSIGN; }
"==" { return EQ; }
"!=" { return NEQ; }
"<" { return '<'; }
">" { return '>'; }
"<=" { return LE; }
">=" { return GE; }
"&&" { return AND; }
"||" { return OR; }
"!" { return '!'; }
"&" { return '&'; }
"|" { return '|'; }
"^" { return '^'; }
"~" { return '~'; }
"<<" { return LEFT_SHIFT; }
">>" { return RIGHT_SHIFT; }
"(" { return '('; }
")" { return ')'; }
"[" { return '['; }
"]" { return ']'; }
"{" { return '{'; }
"}" { return '}'; }
";" { return ';'; }
"," { return ','; }
"." { return '.'; }
"->" { return PTR_OP; }
"++" { return INC_OP; }
"--" { return DEC_OP; }

[ \t]+ { /* Ignora espacios en blanco */ }

\n {
    yylloc.first_line = yylloc.last_line += yyleng; 
    yylloc.first_column = yylloc.last_column = COLUMNA_INICIAL;
    return '\n';
}

[^ \t\n] {
    /* Ignora caracteres desconocidos */
}

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
        fprintf(stderr, "Token no reconocido: %s\n", yytext);
        BEGIN(INITIAL);
    }
}

%%