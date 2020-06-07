# miniscript-compiler
This is a lexical and syntactictical analysis of the imaginary language miniscript, using flex and bison. To be more specific, I am creating a transpiler, meaning I take .ms files, search for Lexical and syntactical mistakes, and then translate the .ms file in to .c file and compile it and execute it.

There are 5 shift/reduce conflicts that I could not fix, before the final commit of the project.
