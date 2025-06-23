
#include "scheduler/hooks/hook.h"
int value;
int value2 = 32;

void hook(void){
    value = 2;
    value2 = 2;
}