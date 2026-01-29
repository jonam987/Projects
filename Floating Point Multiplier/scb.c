#include <stdio.h>

int floatOperations(int op1, int op2) {
    float floatOp1 = *(float*)&op1;
    float floatOp2 = *(float*)&op2;
    float floatResult;

   
    floatResult = floatOp1 * floatOp2;

    return *(int*)&floatResult;
}