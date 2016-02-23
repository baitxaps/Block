//
//  character.c
//  Block
//
//  Created by hairong chen on 16/2/11.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#include "character.h"
#include <stdlib.h>
#include <strings.h>

char *GetMemery(char *p,int num)
{
    p = (char*)malloc(sizeof(char)* num);
    return p;
}

typedef long long llong;
int hash[10];//标记是否使用过...
void dfs(int dep,long val)
{
    int i;
    llong tmp;
    if(dep==9)//9位了
    {
        printf("val = %ld \n",val);
        return;
    }
    for(i=1;i<=9;++i)
    {
        if(!hash[i])
        {
            hash[i] = 1;
            tmp     = val*10+i;
            
            if(tmp%(dep+1)==0)
                dfs(dep+1,tmp);
            
            hash[i] = 0;
        }
    }
}


//realloc调整数组长度（增加）
char *getLine(void)
{
    const size_t sizeIncrement = 10;
    char *buffer = malloc(sizeIncrement);
    char *currentPosition = buffer;
    size_t maximumLength = sizeIncrement;
    size_t lenght = 0;
    int character;
    
    if (currentPosition == NULL) {return NULL;}
    
    while (1) {
        character = fgetc(stdin);
        if (character == '\n') {
            break;
        }
        if (++lenght >= maximumLength) {
            char *newBuffer = realloc(buffer, maximumLength +=sizeIncrement);
            
            if (newBuffer == NULL) {
                free(buffer);
                return NULL;
            }
            currentPosition = newBuffer +(currentPosition -buffer);
            buffer = newBuffer;
        }
        *currentPosition ++ = character;
    }
    *currentPosition = '\0';
    return buffer;
}

//realloc调整数组长度（减少）
char *trim(char *phrase)
{
    char *old = phrase;
    char *new = phrase;
    
    while (*old == ' ') {//跳过开头空白符:”   helloworld"
        old ++;
    }
    
    while (*old) {
        *(new++) = *(old++);
    }
    *new = '\0';
    return (char *)realloc(phrase, strlen(new)+1);
}

//display2DArray(matrix,2);
void display2DArray(int arr[][5],int rows)
{
    for (int i = 0; i <rows; i ++) {
        for (int j = 0; j<5; j++) {
            printf("%d",arr[i][j]);
        }
        printf("\n");
    }
}


//display2DArrayUnknownSize(&matrix[0][0],2,5);
void display2DArrayUnknowSize(int *arr,int rows,int cols)
{
    for (int i = 0; i <rows; i ++) {
        for (int j = 0; j<cols; j++) {
            printf("%d",*(arr+ (i*cols)+j));
            //printf("%d",(arr+i)[j]);
        }
        printf("\n");
    }
}


//分配连续内存

void mallocContinuity(){
    int rows =2;
    int columns = 5;
    int **matrix = (int **)malloc(rows *sizeof(int*));
    matrix[0] = (int *)malloc(rows *columns *sizeof(int));
    
    for (int i =1; i <rows; i ++) {
        matrix[i] = matrix[0] +i *columns ;
    }
    //  *(matrix +(i * columns)+j)= i*j;
}

//分配不连续内存
void mallocDiscontinuity(){
    int rows =2;
    int columns = 5;
    int **matrix = (int **)malloc(rows *sizeof(int*));
    
    for (int i =1; i <rows; i ++) {
        matrix[0] = (int *)malloc(columns *sizeof(int));
    }
}

//不规则数组
int (*(arr1[]))= {
    (int[]){0,1,2},
    (int[]){3,5,6},
    (int[]){4,8,9},
    //   printf("%d",arr1[i][j]);
};

int (*(arr2[]))= {
    (int[]){0,1,2,6},
    (int[]){3,5},
    (int[]){4,8,9}
};

//int rows = 0;
//for(int i =0,i<4;i++){printf(arr2[row][i]);}

//int rows = 1;
//for(int i =0,i<2;i++){printf(arr2[row][i]);}

//int rows = 2;
//for(int i =0,i<3;i++){printf(arr2[row][i]);}



int count =0;
int foo(int i){
    count ++;
    if(i==0)
    {
        return 0;
    }
    if(i ==1)
    {
        return 1;
    }
    
    return  foo(i-1)+foo(i-2);
}



int compare(const char *s1, const char *s2){
    return strcmp(s1,s2);
}

void displayNames(char *names[],int size){
    for (int i= 0; i<size; i ++) {
        printf("%s ",names[i]);
    }
    printf("\n");
}

void sort(char *array[],int size, fptrOperation operation)
{
    int swap = 1;
    while (swap) {
        swap = 0;
        for (int i = 0; i<size -1; i ++) {
            if(operation(array[i],array[i+1])>0){
                swap  = 1;
                char *tmp = array[i];
                array[i] = array[i+1];
                array[i +1] = tmp;
            }
        }
    }
}