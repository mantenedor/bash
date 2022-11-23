#!/bin/bash

#
# Script de benchmark
# Autor: Wagton Azevedo
# Criado: 11/2022
#

function NETWORK {
        echo 'Testando rede...' | tee -a out.txt
        for i in `cat $LISTA`; do
                echo $i
                ping -c $COUNT  $i -s $SIZE -qN name >> out.txt
        done
}

function HD {
        echo 'Testando discos locais...' | tee -a out.txt
        LOCAL=`df -h | grep sd | cut -d' ' -f1`
        #df -h | grep sd | cut -d' ' -f1 | xargs hdparm -t

        for i in `echo $LOCAL`; do
                echo "":
                echo "Testando $i..."
                hdparm -t  $i  >> out.txt
                ##fio --filename=$i --readonly --rw=read --name=TEST --runtime=3 | grep READ >> out.txt
                sleep 1
        done
}

function FS {
        echo 'Testando sistemas de arquivos externos...' | tee -a out.txt
        LOCAL=`df -T | grep -e cifs -e nfs | rev | cut -d' ' -f1| rev`

        for i in `echo $LOCAL`; do
                echo "":
                echo "Testando $i..." | tee -a out.txt
                dd if=/dev/zero of=$i/test1.img bs=1G count=1 oflag=dsync &>> out.txt
                #hdparm -t  $i
                ##fio --filename=$i --readonly --rw=read --name=TEST --runtime=3 | grep READ
                sleep 1
        done
        #df -T | grep -e cifs -e nfs
}


function RAM {
        echo 'Testando memória RAM...' | tee -a out.txt
        sysbench memory --memory-access-mode=rnd run >> out.txt
}

function CPU {
        echo 'Testando CPU...' | tee -a out.txt
        sysbench cpu --threads=1 run >> out.txt
}

function HELP {
        clear
        echo "Instale o sysbench."
        echo ""
        echo "Utilize: ./bmk.sh [OPTIONS]."
        echo ""
        echo "--hd) Testa disco rígido."
        echo "--fs) Testa sistema de arquivos externos."
        echo "--ram) Testa memória randômica."
        echo "--cpu) Testa processador."
        echo ""
        echo "--network)        Testa latência de rede. Você deve infomrar uma arquivo com uma lsita de ips,"
        echo "          ordenados verticalmente, o número de pings e o tamanho do pacote."
        echo "          Exeemplo ./bmk.sh --network lista.txt 10 1024"
        echo ""
        echo "--all) Executa todos os testes anteriores."
        echo "--sumary)Resume o resultado da última execução."
        echo "--help) Exibe esta ajuda."
        echo ""
        exit
}

function SUMARY {
        cat out.txt > last.out
        echo ""
        echo "||||||||||||||||||||||||||||||||"
        echo "||||| Resumo das operações |||||"
        echo "||||||||||||||||||||||||||||||||"
        echo ""
        echo "Teste de memória randômica:"
        cat last.out | grep "Testando memória RAM" -A36 | grep "Total operations"
        echo ""
        echo "Teste de processamento:"
        cat last.out | grep "Testando CPU" -A30 | grep -e "Number of threads" -e "events per second" -e "total time" -e events -e "execution time"
        echo ""
        echo "Teste de armazenamento:"
        cat last.out | grep "Timing buffered disk reads" -B1
        echo ""
        cat last.out | grep "bytes (" -B1
        echo ""
        echo "Teste de rede:"
        cat last.out | grep "ping statistics" -A2
        echo ""
        echo 'Veja o relatóio completo em "out.txt".'
        exit
}

function ALL {
        if [ -z $LISTA ];then
                HELP
        fi
        date > out.txt
        HD
        FS
        RAM
        CPU
        NETWORK
}

function PKG {

        HDPAR=`whereis hdparm | cut -d: -f2`
        #FIOO=`whereis fio | cut -d: -f2`
        SYSBEN=`whereis sysbench |cut -d: -f2`

        #if [ -z "$FIOO" ];then
        #       echo 'Pacote "fio" ausente.'
        #       exit
        #fi
        if [ -z "$HDPAR" ];then
                echo 'Pacote "hdparm" ausente.'
                exit
        fi
        if [ -z "$SYSBEN" ];then
                echo 'Pacote "sysbench" ausente.'
                exit
        fi
}


LISTA=$2
COUNT=$3
SIZE=$4

PKG

case $1 in
        --hd) HD;;
        --fs) FS;;
        --ram) RAM;;
        --cpu) CPU;;
        --network) NETWORK;;
        --sumary) SUMARY;;
        --all) ALL;;
        --help) HELP;;
        *) HELP;;
esac

SUMARY
