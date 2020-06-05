#include <stdio.h> 

/* MiniScrip Library */
void writeString(const char* s) {printf("%s", s);}

const char* message = "Hello world!\n";

void main() {
  writeString(message);	
}