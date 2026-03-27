#include <stdlib.h>
#include <stdio.h>
#include <time.h>

int randint(int max) {
    return (int)(rand() * (max/((double)RAND_MAX)));
}

double randfp() {
    return (double)(rand()/((double)RAND_MAX));
}

void srand_vg() {
    srand((unsigned int)time(NULL));
}

char *fgets_stdin(char *buf, int size) {
    return fgets(buf,size,stdin);
}