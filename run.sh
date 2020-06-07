#!/bin/bash

echo -n "Give the name of the example(e.g. example_1) : "
read example
echo -n ""

bison -d -v -r all myanalyzer.y
flex mylexer.l 
gcc -o mycompiler lex.yy.c myanalyzer.tab.c cgen.c -lfl
echo -n "========== Compiler Ready =========="
echo ""
./mycompiler < $example.ms 
./mycompiler < $example.ms > sample.c
echo -n "=========== Executing ============"
echo -n ""
gcc -o sample sample.c 
echo ""
./sample

rm lex.yy.c myanalyzer.tab.c  myanalyzer.tab.h 
rm mycompiler myanalyzer.output sample sample.c