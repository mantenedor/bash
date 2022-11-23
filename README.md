# bmk

Benchmark simples para linux.

É preciso ter os pacotes "fio" e "sysbench" instalados.

Execute:
```
./bmk.sh --help
```
Exemplo de um teste completo com saída para arquivo:
```
./bmk.sh --all lista.txt 1000 10240 | tee -a out
```
