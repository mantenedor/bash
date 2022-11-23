#/bin/bash

#
# Script de benchmark
# Autor: Wagton Azevedo
# Criado: 11/2022
#

#df -h | grep sd | cut -d' ' -f1 | xargs hdparm -t


function NETWORK {
        echo 'Testando rede...' 
        for i in `cat $LISTA`; do
                echo $i
                ping -c $COUNT  $i -s $SIZE -qN name
        done
}

function HD {
        echo 'Testando discos locais...' 
        LOCAL=`df -h | grep sd | cut -d' ' -f1`

        for i in `echo $LOCAL`; do
                echo "":
                echo "Testando $i..."
                hdparm -t  $i  
                ##fio --filename=$i --readonly --rw=read --name=TEST --runtime=3 | grep READ
                sleep 1
        done
}

function FS {
        echo 'Testando sistemas de arquivos externos...'
        LOCAL=`df -T | grep -e cifs -e nfs | rev | cut -d' ' -f1| rev`

        for i in `echo $LOCAL`; do
                echo "":
                echo "Testando $i..."
                dd if=/dev/zero of=$i/test1.img bs=1G count=1 oflag=dsync
                #hdparm -t  $i
                ##fio --filename=$i --readonly --rw=read --name=TEST --runtime=3 | grep READ
                sleep 1
        done
        #df -T | grep -e cifs -e nfs
}


function RAM {
        echo 'Testando memória RAM...' 
        sysbench memory --memory-access-mode=rnd run
}

function CPU {
        echo 'Testando memória RAM...' 
        sysbench cpu --threads=1 run
}




function HELP {
        clear
        echo "Instale o sysbench."
        echo ""
        echo "Utilize: ./bmk.sh [OPTIONS]."
        echo ""
        echo "--hd) Testa disco rígido"
        echo "--fs) Testa sistema de arquivos externos"
        echo "--ram) Testa memória randômica"
        echo "--cpu) Testa processador"
        echo ""
        echo "--network)        Testa latência de rede. Você deve infomrar uma arquivo com uma lsita de ips,"
        echo "          ordenados verticalmente, o número de pings e o tamanho do pacote."
        echo "          Exeemplo ./bmk.sh --network lista.txt 10 1024"
        echo ""
        echo "--all) Executa todos os testes anteriores"
        echo "--help) Exibe esta ajuda."
        echo ""
        exit
}

function ALL {
        if [ -z $LISTA ];then
                HELP
        fi
        HD
        FS
        RAM
        CPU
        NETWORK
}

LISTA=$2
COUNT=$3
SIZE=$4

case $1 in
        --hd) HD;;
        --fs) FS;;
        --ram) RAM;;
        --cpu) CPU;;
        --network) NETWORK;;
        --all) ALL;;
        --help) HELP;;
        *) HELP;;
esac
