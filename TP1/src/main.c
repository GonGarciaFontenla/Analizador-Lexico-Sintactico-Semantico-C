#include <stdlib.h> //Bibliotecas portables : )
#include <stdio.h> //Bibliotecas portables : )

#define CANT_ESTADOS 7
#define CANT_SIMBOLOS 6 

// Definición de los estados del AFD
typedef enum {
    Q0, // 0
    Q1, // 1 
    Q2, // 2
    Q3, // 3
    Q4, // 4
    Q5, // 5
    Q6 // 6
} t_estado;

typedef enum {
    CERO,
    UNO_AL_SIETE, // Representa los números del 1 al 7
    OCHO_AL_NUEVE, // Representa los números del 8 al 9
    AF_af, // Representa los caracteres hexadecimales de 'a' a 'f' en minúsculas y en mayúsculas
    Xx, // Representa el carácter 'x' y 'X'
    INVALIDO
} t_caracter;

#define ESTADO_INICIAL Q0
#define ESTADO_FINAL_OCTAL Q1, Q5
#define ESTADO_FINAL_DECIMAL Q2
#define ESTADO_FINAL_HEXADECIMAL Q4
#define ESTADO_RECHAZO Q6
#define CENTINELA ','

// Definición de la tabla de transiciones
int tabla_transiciones[CANT_ESTADOS][CANT_SIMBOLOS] = {
    {Q1, Q2, Q2, Q6, Q6, Q6},
    {Q5, Q5, Q6, Q6, Q3, Q6},
    {Q2, Q2, Q2, Q6, Q6, Q6},
    {Q4, Q4, Q4, Q4, Q6, Q6},
    {Q4, Q4, Q4, Q4, Q6, Q6},
    {Q5, Q5, Q6, Q6, Q6, Q6},
    {Q6, Q6, Q6, Q6, Q6, Q6}
};

t_estado char_to_enum(char c){
    switch (c) {
        case '0': 
            return CERO;
        case '1': case '2': case '3': case '4': case '5': case '6': case '7': 
            return UNO_AL_SIETE;
        case '8': case '9': 
            return OCHO_AL_NUEVE;
        case 'a': case 'b': case 'c': case 'd': case 'e': case 'f': 
        case 'A': case 'B': case 'C': case 'D': case 'E':case 'F': 
            return AF_af;
        case 'x': case 'X': 
            return Xx;
        default:
            return INVALIDO;
            break;
    }
}

// Lee caracter a caracter y aplica la funcion de transición hasta encontrar un centinela o EOF, después empieza de nuevo con el siguiente lexema
void lexer(FILE* input, FILE* output) {
    char c;
    int estado = ESTADO_INICIAL;
    while((c = fgetc(input)) != EOF){
        if(c != CENTINELA){
            fputc(c, output);
            estado = tabla_transiciones[estado][char_to_enum(c)];
        }
        else{ 
            fputs("    ", output);
            if(estado == ESTADO_FINAL_DECIMAL)
            {
                fputs("DECIMAL\n", output);
            }
            else if(estado == ESTADO_FINAL_HEXADECIMAL)
            {
                fputs("HEXADECIMAL\n", output);
            }
            else if(estado == ESTADO_RECHAZO)
            {
                fputs("NO RECONOCIDA\n", output);
            }
            else
            {
                fputs("OCTAL\n", output);
            }
            estado = ESTADO_INICIAL;
        }
    }
    fputs("    ", output);
        if(estado == ESTADO_FINAL_DECIMAL)
        {
            fputs("DECIMAL\n", output);
        }
        else if(estado == ESTADO_FINAL_HEXADECIMAL)
        {
            fputs("HEXADECIMAL\n", output);
        }
        else if(estado == ESTADO_RECHAZO)
        {
            fputs("NO RECONOCIDA\n", output);
        }
        else
        {
            fputs("OCTAL\n", output);
        }
}

int main(char* argv[]) {

    FILE* inputFile = fopen("../bin/entrada.txt", "r");
    if(!inputFile) 
    {
        printf("Error al intentar abrir el archivo %s.\n", argv[1]);
        return EXIT_FAILURE;
    }
    
    FILE* outputFile = fopen("../bin/output.txt", "w");
    if(!outputFile)
    {
        printf("¡Error al intentar cargar el archivo!");
        return EXIT_FAILURE;
    }
    lexer(inputFile, outputFile);

    fclose(inputFile);
    fclose(outputFile);

    return EXIT_SUCCESS;
}