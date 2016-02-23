//
//  character.h
//  Block
//
//  Created by hairong chen on 16/2/11.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#ifndef character_h
#define character_h

#include <stdio.h>

#define ACCESS_BEFORE(element,offset,value) *SUB(&element,offset) = value
#define RE(b) (!(b))
#define SUM(a,b) ((a)+(b))
#define SUB(x,y) ((x)-(y))

typedef int (fptrOperation)(const char *,const char *);

char *GetMemery(char *p,int num);
void dfs(int dep,long val);

//realloc调整数组长度（增加）
char *getLine(void);

//realloc调整数组长度（减少）
char *trim(char *phrase);

//display2DArray(matrix,2);
void display2DArray(int arr[][5],int rows);


//display2DArrayUnknownSize(&matrix[0][0],2,5);
void display2DArrayUnknowSize(int *arr,int rows,int cols);


//分配连续内存
void mallocContinuity();

//分配不连续内存
void mallocDiscontinuity();


int compare(const char *s1, const char *s2);
void displayNames(char *names[],int size);
void sort(char *array[],int size, fptrOperation operation);
#endif /* character_h */
