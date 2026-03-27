#include <stdlib.h>

int randint(int max) {
    return (int)(rand() * (max/((double)RAND_MAX)));
}

double randfp() {
    return (double)(rand()/RAND_MAX);
}