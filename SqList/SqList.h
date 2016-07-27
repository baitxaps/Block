//
//  SqList.h
//  Block
//
//  Created by hairong chen on 16/7/27.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#ifndef SqList_h
#define SqList_h

#define MAXSIZE 20

typedef int ELemType;
typedef int  Status;

typedef struct {
    ELemType data[MAXSIZE];
    int length;
} SqList;

#include <stdio.h>

Status GetElem(SqList L,int i,ELemType *e) ;
Status ListInsert (SqList *L,int i, ELemType e);
Status ListDelete (SqList *L,int i ,ELemType *e );

#endif /* SqList_h */
