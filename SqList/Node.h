//
//  Node.h
//  Block
//
//  Created by hairong chen on 16/7/27.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#ifndef Node_h
#define Node_h

#include "RHCMacros.h"

typedef struct Node {
    ELemType data;
    struct Node *next;
}Node, *LinkList;

//typedef struct Node *LinkList;

#include <stdio.h>
void CreateListHead (LinkList *L,int n );
void CreateListTail(LinkList *L,int n);

Status GetElem(LinkList L,int i,ELemType *e);
Status ListInsert (LinkList *L,int i,ELemType e);
Status ListDelete(LinkList *L,int i, ELemType *e);

Status Clear(LinkList *L);
#endif /* Node_h */
