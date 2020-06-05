#!/bin/bash

bison -d -v -r all myanalyzer.y
flex mylexer.l #give name of .l file
gcc -o mycompiler myanalyzer.tab.c lex.yy.c cgen.c -lfl

./mycompiler < myprog.ms
gcc -o myprog myprog.c 
./myprog

rm lex.yy.c myanalyzer.tab.c  myanalyzer.tab.h 
rm mycompiler myanalyzer.output myprog