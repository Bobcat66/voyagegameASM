#include <stdlib.h>
#include <stdio.h>

int randint(int max) {
    return (int)(rand() * (max/((double)RAND_MAX)));
}

double randfp() {
    return (double)(rand()/RAND_MAX);
}

char *fgets_stdin(char *buf, int size) {
    return fgets(buf,size,stdin);
}