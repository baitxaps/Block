//
//  thread.h
//  Block
//
//  Created by hairong chen on 16/2/11.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#ifndef thread_h
#define thread_h

#include <stdio.h>


//thread
#pragma mark - 线程间共享指针
/*
 两个向量指针，sum字段（持有点积），length字段（定点积函数要用的向量的长度）
 length字段表示线程处理的向量的部分，不是整个向量的长度
 */

typedef struct {
    double *vectorA;
    double *vectorB;
    double sum;
    int length;
}VectorInfo;

/*
 VectorInfo指针和计算点积向量的起始索引
 */
typedef struct {
    VectorInfo *info;
    int beginningIndex;
}Product;

/*
 所有线程会在同一时间对两个向量进行计算，但是它们访问的是向量的不同部分，所以不会有冲突。
 每个线程会计算自己负责的那些向量的各，不过，这个各需要累加到VectorInfo结构体的sum字段上。
 多个线程可能会同时访问sum字段，所以需要用互斥锁保护数据，下面会声明互斥锁。同一时间互斥锁只允许
 一个线程访问受保护的变量，声明互斥锁保护sum变量，在全局区域声明它以充许多个线程访问
 */
void dotProduct(void *prod);
#define NUM_THREADS 4
void threadExample();
//factorial
#pragma mark - 用函数指针支持回调
/*
 1.回调定义：如果一个线程的事件导致另一个线程的函数调用。 将回调函数的指针传递给线程，
 而函数的某个事件会引发对回调函数的调用，这种方法在GUI应用程序中处理用户线程事件很有用。
 2.factorial:阶乘，结果和回调函数指针。用这些数据计算阶乘，把结果保存到result字段，
 调用回调函数，然后结束线程
 */
typedef struct _factorialData{
    int number;
    int result;
    void (*callBack)(struct _factorialData *);
}FactorialData;

void factorial(void *agrs);
void startThread(FactorialData *data);
void callBackFunction(FactorialData *factorialData);
void initThread();

void add(int size,double *restrict arr1,const double *restrict arr2);
int isPositivel(float number);
#endif /* thread_h */
