#!/bin/bash

# Constantes para facilitar a utilização das cores.
GREEN='\033[32;1m'
BLUE='\033[34;1m'
RED='\033[31;1m'
RED_BLINK='\033[31;5;1m'
END='\033[m'

# Função chamada quando cancelar o programa com [Ctrl]+[c]
trap __Ctrl_c__ INT

__Ctrl_c__() {
   # __Clear__
    rm temp_file*
    printf "\n${RED_BLINK} [!] Ação abortada!${END}\n\n"
    exit 1
}

# LIMPA OS ARQUIVOS TEMPORARIOS
rm temp_file* 2>/dev/null

if [ "$1" == "" ]
then
    echo " "
    toilet -f future " GITHUB FOLLOWER ASSISTANT"
    echo " "
    echo -e "${BLUE}     Este utilitario lista os usuarios que${END}${RED} estao sendo seguidos${END}"
    echo -e "${BLUE}     e que${END}${RED} nao seguem de volta${END}${BLUE}.${END}"
    echo " "
    echo -e "${BLUE}     [*] Informe o seu username do GitHub como argumento${END}"
    echo -e "${BLUE}         Exemplo:${END}${GREEN} $0 UserN4me${END}"
    echo " "
else
        echo " "
        toilet -f future " GITHUB FOLLOWER ASSISTANT"
        echo " "
        echo -e "${BLUE}     Este utilitario lista os usuarios que${END}${RED} estao sendo seguidos${END}"
        echo -e "${BLUE}     e que${END}${RED} nao seguem de volta${END}${BLUE}.${END}"
        echo " "
    echo -e "${BLUE}     [*] Analisando perfil:${END}${GREEN} https://github.com/$1 ${END}"
    echo " "

    # WGET NO PERFIL PARA CONTAR QUANTAS PÁGINAS DE FOLLOWERS/FOLLOWING EXISTEM:
    wget "https://github.com/$1" -O temp_file0 2>temp_file

    # VERIFICA SE A PAGINA EXISTE
    EXISTE=$(head -n4 temp_file | grep "404" | cut -d "." -f4 | sed 's/ Not Found//' | sed 's/ //')
    rm temp_file
    if [ "$EXISTE" == "404" ]
    then
        echo -e "${RED}     [!] ESTE PERFIL NAO EXISTE${END}"
        echo " "
        exit
    fi

    # OBTER VALORES DE FOLLOWERS/FOLLOWING:
    cat temp_file0 | grep "text-bold color-fg-default" | cut -d ">" -f2 | cut -d "<" -f1 > temp_file1
    rm temp_file0

    # SALVAR VALORES EM VARIAVEIS
    SEGUIDORES=$(head -n1 temp_file1)
    SEGUINDO=$(tail -n1 temp_file1)
    rm temp_file1

    # VERIFICA SE OS VALORES SAO ZEROS
    if [ "$SEGUIDORES" == "0" ]
    then
        echo -e "${RED}     [!] ESTE PERFIL NAO TEM SEGUIDORES${END}"
        echo " "
        exit
    fi
    if [ "$SEGUINDO" == "0" ]
    then
        echo -e "${RED}     [!] ESTE PERFIL NAO SEGUE NINGUEM${END}"
        echo " "
        exit
    fi

    # CALCULAR NUMERO DE PAGINAS DE SEGUIDORES
    if [ "$SEGUIDORES" -gt "50" ]
    then
        QTD_P_SEGUIDORES=$(($SEGUIDORES/50))
        QTD_P_SEGUIDORES=$(($QTD_P_SEGUIDORES+1))
    else
        QTD_P_SEGUIDORES=1
    fi

    # CALCULAR NUMERO DE PAGINAS DE SEGUINDO
    if [ "$SEGUINDO" -gt "50" ]
    then
        QTD_P_SEGUINDO=$(($SEGUINDO/50))
        QTD_P_SEGUINDO=$(($QTD_P_SEGUINDO+1))
    else
        QTD_P_SEGUINDO=1
    fi

    # WGET EM FOLLOWERS
    for i in $(seq $QTD_P_SEGUIDORES);
    do
        wget -q "https://github.com/$1?page=$i&tab=followers";
    done

    # WGET EM FOLLOWING
    for i in $(seq $QTD_P_SEGUINDO);
    do
        wget -q "https://github.com/$1?page=$i&tab=following";
    done

    # UNIFICAR TODOS OS WGETS
    cat $1\?page\=*\&tab\=followers > temp_file1
    cat $1\?page\=*\&tab\=following > temp_file2

    # REMOVER TODOS OS WGETS
    rm $1\?page\=*\&tab\=*

    # GREP PARA OBTER LISTA DE FOLLOWERS
    cat temp_file1 | grep "Link\-\-secondary" | sed 's/pl\-1//' | sed 's/Link\-\-secondary //' | sed 's/Link\-\-secondary//' | grep "span class" | sed 's\<span class="">\\' | sed 's/<\/span>//' > temp_file3
    rm temp_file1 2>/dev/null
    # GREP PARA OBTER LISTA DE FOLLOWING
    cat temp_file2 | grep "Link\-\-secondary" | sed 's/pl\-1//' | sed 's/Link\-\-secondary //' | sed 's/Link\-\-secondary//' | grep "span class" | sed 's\<span class="">\\' | sed 's/<\/span>//' > temp_file4
    rm temp_file2 2>/dev/null

    # SALVAR EM ORDEM ALFABETICA
    cat temp_file3 | sed 's/       //' | sort -u > temp_file5
    rm temp_file3 2>/dev/null
    cat temp_file4 | sed 's/       //' | sort -u > temp_file6
    rm temp_file4 2>/dev/null

    # SALVA LISTA DOS QUE NAO SEGUEM DE VOLTA
    for naoseguem in $(cat temp_file5);
    do
    cat temp_file6 | grep -v $naoseguem >> temp_file8;
    done

    # EXIBE LISTA DOS QUE NAO SEGUEM DE VOLTA
    echo -e "${BLUE}     [*] USUARIOS QUE${END}${RED} NAO SEGUEM DE VOLTA${END}${BLUE} O USER $1:${END}"
    echo " "
    cat temp_file8 | sort | uniq -c | sort -ur > temp_file9
    FILTRO=$(head -n1 temp_file9 | rev | cut -d " " -f3 | rev)
    cat temp_file9 | grep $FILTRO | sed 's/........./     \[\+\] /' #| cut -d " " -f8
    echo " "

    # LIMPA ARQUIVOS TEMPORARIOS
    rm temp_file* 2>/dev/null
fi
