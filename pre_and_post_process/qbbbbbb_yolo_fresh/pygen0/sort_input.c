#include <stdio.h>
#include <math.h>
#include "./input_image_short.h"
//sortinput:
void main() {
    FILE* fp2 = fopen("./input_img_sort.h", "w");

    fprintf(fp2, "short SizedData_tranfp[]={");


    int i,j;
    for (i = 0; i < 416 * 416; i++) {
        for (j = 0; j < 3; j++) {
            fprintf(fp2, "%hd,\n", SizedData_fp[i + 416 * 416 * j]);
        }
    }

    fseek(fp2, -2, SEEK_CUR);
    fprintf(fp2, "};");
    fclose(fp2);
}