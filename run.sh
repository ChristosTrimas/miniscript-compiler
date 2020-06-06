#!/bin/bash

bison -d -v -r all myanalyzer.y
flex mylexer.l 
gcc -o mycompiler lex.yy.c myanalyzer.tab.c cgen.c -lfl

./mycompiler < myprog.ms > sample.c
gcc -o sample sample.c 
./sample

rm lex.yy.c myanalyzer.tab.c  myanalyzer.tab.h 
rm mycompiler myanalyzer.output sample sample.c