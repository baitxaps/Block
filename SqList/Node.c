//
//  Node.c
//  Block
//
//  Created by hairong chen on 16/7/27.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#include "Node.h"
#include<stdlib.h>
#include<time.h>
#include "RHCMacros.h"

/**
 *  随机产生n个元素的值，建立带表头结点的单链线性表L(头插法)
 *
 */
void CreateListHead(LinkList *L,int n ) {
    LinkList p;
    int i;
    srand((unsigned int)time(NULL));
    
    *L = (LinkList)malloc(sizeof(Node));
    (*L)->next = NULL;
    
    for (i = 0; i < n; i ++) {
        p = (LinkList)malloc(sizeof(Node));
        
        p->data = rand() *100 +1;
        p->next = (*L)->next;
        (*L)->next = p;
    }
}

/**
 *  随机产生n个元素的值，建立带表头结点的单链线性表L(尾插法)
 */
void CreateListTail(LinkList *L,int n) {
    LinkList p,r;
    int i ;
    
    srand((unsigned int)time(NULL));
    *L = (LinkList)malloc(sizeof(Node));
    r = *L;
    
    for (i = 0; i < n; i ++) {
        p = (Node *)malloc(sizeof(Node));
        p->data = rand()%100 +1;
        r ->next = p;
        r = p;
    }
    r->next = NULL;
}

/** 获得链表第i个数据
 *  初始化条件:顺序线性表Ｌ已经存在，1<= i <= ListLength(L)
 *  操作结果:用e 返回Ｌ中第i个数据元素的值
 */
Status GetElem(LinkList L,int i,ELemType *e) {
    int j;
    LinkList p;
    
    p = L->next;
    j = 1;
    
    while (p && j <i) {
        p = p ->next;
        ++j;
    }
    
    if (!p || j>i) {
        return ERROR;
    }
    *e = p->data;
    
    return OK;
}

/** 单链表第i个数据插入结点的算法思路
 *  初始条件:顺序线性表L已经存在，1 <=i <= ListLength(L)
 *  操作结果:在L中第i个位置之前插入新的数据元素e,L的长度加1
 */
Status ListInsert (LinkList *L,int i,ELemType e) {
    int j;
    LinkList p,s;
    
    p= *L;
    j = 1;
    
    while (p && j <i) {
        p = p ->next;
        ++j;
    }
    
    if (!p || j>i) {
        return ERROR;
    }
 
    s = (LinkList)malloc(sizeof(Node)) ;

    s->data = e;
    s->next = p->next;
    p->next = s;
    
    return OK;
}


/**  单链表第i个数据删除结点的算法
 *   初始条件:顺序线性表L已经存在，1 <=i <= ListLength(L)
 *   操作结果::删除L中第i个元素，并用数据元素e返回其值,L的长度-1
 */
Status ListDelete(LinkList *L,int i, ELemType *e) {
    int j ;
    LinkList p,q;
    
    p = *L;
    j = 1;
    
    while (p->next && j < i) {
        p = p->next;
        ++j;
    }
    
    if (!(p->next) || j > i) {
        return ERROR;
    }
    
    q = p->next;
    p->next = q->next;
    *e = q->data;
    
    free(q);
    
    return OK;
}

/**
 *  单链表的整表删除
 */
Status Clear(LinkList *L) {
    
    LinkList p,q;
    
    p= (*L)->next;
    
    while (p) {
        q = p->next;
        free(p);
        p =q;
    }
    
    (*L)->next = NULL;
    
    return OK;
}
