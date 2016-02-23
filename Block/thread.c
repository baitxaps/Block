//
//  thread.c
//  Block
//
//  Created by hairong chen on 16/2/11.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#include "thread.h"
#import <pthread/pthread.h>
#include <unistd.h>
#include <stdlib.h>
//pointer alias
/*
 指针的别名，如果两个指针引用同一内存地址，我们称一个指针是另一个指针的别名。别名并不罕见，不过可能会引发一些问题
 强别名：它不允许一种类型的指针成为另一种类型的指针的别名
 
 Ｃ是类型语言，在声明变量时就得为其指定类型，可以存在不同类型的多个变量
 有时可能需要把一种类型转换成另一种类型，这一般是通过类型转换实现的，不过也可能使用联合体，类型双关就是指这种绕开
 类型系统的技术
 
 如果转换涉及指针，可能会产生严重的问题。为了说明这种技术，函数会判断一个浮点数是否为正，
 这个可以正确工作，也不会涉及别名，因为没有用到指针
 
 */
typedef union _conversion{
    float fNum;
    unsigned int uiNum;
}Conversion;

int isPositivel(float number){
    Conversion conversion ={.fNum = number};
    return (conversion.uiNum & 0x80000000)==0;
}
/*restric关键字可以在声明指针时告诉编译器这个指针没有别名，这样就允许编译器产生更高效的代码。
 //很多情况下这是通过缓存指针实现的，不这，编译器也可以选择不优化代码，如果用了别名，那么执代码会导致
 //未定义行为，编译器不会因为破坏强别名假设而提供任何警告信息
 
 volatile关键字可以阻止运行时系统使用寄存器暂存端口值，每次访问端口都需要系统读写端口，而不是从寄存器中读
 取一个可能已经过期的值。
 如把所有变量声明为volatile,会阻碍编译器进行所有类型的优化
 */
void add(int size,double *restrict arr1,const double *restrict arr2){
    for (int i =0; i<size ; i++) {
        arr1[i] += arr2[i];
    }
}

//thread
#pragma mark - 线程间共享指针
pthread_mutex_t mutexSum;//全局区域声明它以充许多个线程访问
/*
 所有线程会在同一时间对两个向量进行计算，但是它们访问的是向量的不同部分，所以不会有冲突。
 每个线程会计算自己负责的那些向量的各，不过，这个各需要累加到VectorInfo结构体的sum字段上。
 多个线程可能会同时访问sum字段，所以需要用互斥锁保护数据，下面会声明互斥锁。同一时间互斥锁只允许
 一个线程访问受保护的变量，声明互斥锁保护sum变量，在全局区域声明它以充许多个线程访问
 */
void dotProduct(void *prod){
    Product *product = (Product *)prod;
    VectorInfo *vectorInfo = product->info;
    int beginningIndex = product->beginningIndex;
    int endingIndex = beginningIndex +vectorInfo->length;
    
    double total = 0;
    for (int i = beginningIndex; i<endingIndex;i++) {
        total +=(vectorInfo->vectorA[i] *vectorInfo->vectorB[i]);
    }
    
    pthread_mutex_lock(&mutexSum);
    vectorInfo->sum += total;
    pthread_mutex_unlock(&mutexSum);
    
    pthread_exit((void *)0);
}

#define NUM_THREADS 4
void threadExample(){
    VectorInfo vectorInfo;
    double vectorA[]={1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0,16.0
    };
    double vectorB[]={1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0,16.0
    };
    
    vectorInfo.vectorA = vectorA;
    vectorInfo.vectorB = vectorB;
    vectorInfo.length = 4;
    
    //创建4个元素的线程数组，初始化互斥锁和线程的属性字段
    pthread_t threads[NUM_THREADS];
    
    void *status;
    pthread_attr_t attr;
    
    pthread_mutex_init(&mutexSum, NULL);
    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);
    
    int returnValue;
    int threadNumber;
    
    //每次迭代都会创创建一个新的Product实例，会把vectorInfo的地址和一个基于threadNumber得到的唯一索引赋给它。
    //然后创建线程
    for (threadNumber = 0; threadNumber <NUM_THREADS; threadNumber ++) {
        Product *product = (Product *)malloc(sizeof(Product));
        product->beginningIndex = threadNumber *4;
        product->info = &vectorInfo;
        returnValue = pthread_create(&threads[threadNumber], &attr, (void *)dotProduct,(void *)product);
        
        if (returnValue) {
            printf("ERROR,Unable to create thread:%d\n",returnValue);
            exit(-1);
        }
    }
    
    //loop结束，销毁线程属性和互斥锁，for循环确保程序等到4个线程都完成后打印点积
    pthread_attr_destroy(&attr);
    for (int i =0; i<NUM_THREADS; i++) {
        pthread_join(threads[i], &status);
    }
    pthread_mutex_destroy(&mutexSum);
    printf("Dot Product sum:%lf\n",vectorInfo.sum);
    pthread_exit(NULL);
}

//factorial
#pragma mark - 用函数指针支持回调
/*
 1.回调定义：如果一个线程的事件导致另一个线程的函数调用。 将回调函数的指针传递给线程，
 而函数的某个事件会引发对回调函数的调用，这种方法在GUI应用程序中处理用户线程事件很有用。
 2.factorial:阶乘，结果和回调函数指针。用这些数据计算阶乘，把结果保存到result字段，
 调用回调函数，然后结束线程
 */


void factorial(void *agrs){
    FactorialData *factorialData = (FactorialData*)agrs;
    void(*callBack)(FactorialData*);
    
    int number = factorialData->number;
    callBack = factorialData->callBack;
    
    int num = 1;
    for (int i =1; i<=number; i++) {
        num *= i;
    }
    
    factorialData->result = num;
    callBack(factorialData);
    pthread_exit(NULL);
    
}

void startThread(FactorialData *data){
    pthread_t thread_id;
    int thread = pthread_create(&thread_id, NULL,(void *(*)(void *))factorial, (void *)data);
    if (thread) {
        printf("ERROR,Unable to create thread:%d\n",thread);
        exit(-1);
    }
}

void callBackFunction(FactorialData *factorialData){
    printf("Factorial is %d \n",factorialData->result);
}

void initThread(){
    FactorialData *datas = (FactorialData *)malloc(sizeof(FactorialData));
    
    if (!datas) {
        printf("Faild to allocate memory\n");
        return  ;
    }
    datas->number = 6;
    datas->callBack = callBackFunction;
    
    startThread(datas);
    
    sleep(2);//为所有线程正常结束提供足够的时间
}