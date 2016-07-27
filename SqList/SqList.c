//
//  SqList.c
//  Block
//
//  Created by hairong chen on 16/7/27.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#include "SqList.h"

#if Swith
 
// 顺序线性表Ｌ已经存在，1<= i <= ListLength(L)
// 用e 返回Ｌ中第i个数据元素的值

Status GetElem(SqList L,int i,ELemType *e) {
    if (L.length == 0 || i<1 ||i>L.length) {
        return ERROR;
    }
    
     *e = L.data[i-1];
    return OK;
}

// condition:顺序线性表L已经存在，1 <=i <= ListLength(L)
// result:在L中第i个位置之前插入新的数据元素e,L的长度加1
Status ListInsert (SqList *L,int i, ELemType e) {
    int k ;
    if (L->length == MAXSIZE) {
        return ERROR;
    }
    if (i < 1 || i > L->length +1) {
        return ERROR;
    }
    
    if (i <= L->length) {
        for (k = L->length -1; k >=i-1; k --) {
            L->data[k+1] = L->data[k];
        }
    }
    L->data[i-1] = e;
    L->length ++;
    
    return OK;
}

// condition:顺序线性表L已经存在，1 <=i <= ListLength(L)
// result:删除L中第i个元素，并用数据元素e返回其值,L的长度-1
Status ListDelete (SqList *L,int i ,ELemType *e ) {
    int k ;
    if (L->length == 0) {
        return ERROR;
    }
    if (i <1 || i>L->length) {
        return ERROR;
    }
    
    if (i < L->length) {
        for (k = i; k < L->length; k ++) {
            L->data[k-1] = L->data[k];
        }
        
    }
    L->length --;
    return OK;
}
#endif
