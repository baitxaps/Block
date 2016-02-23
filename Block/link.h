//
//  link.h
//  Block
//
//  Created by hairong chen on 16/2/11.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#ifndef link_h
#define link_h

#include <stdio.h>
#include <stdlib.h>


/*
 Node结构体定义一个节点，有两个指针，第一个是void指针，持有任意类型的数据，
 第二个是指向下一个结点指针
 */
typedef struct _node{
    void *data;
    struct _node *next;
}Node ;

/*
 LinkedList结构体表示链表, 持有指向头节点和尾节点的指针，当前指针用来辅助遍历链表
 */
typedef struct _linkedList{
    Node *head;
    Node *tail;
    Node *current;
}LinkedList;


typedef void *Data;
typedef void (*DISPLAY)(void*);
typedef int (*COMPARE)(void*,void*);

typedef struct _employee{
    char name[32];
    unsigned char age;
}Employee;

void initializeLinkList(LinkedList *);//初始化
void addHead(LinkedList*,void *);   //增加头节点数据
void addTail(LinkedList *,void *);  //增加尾节点数据
void delete(LinkedList *,Node*);    //删除结点
Node *getNode(LinkedList *,COMPARE,void*);//返回指定节点的指针
void displayLinkedList(LinkedList *,DISPLAY);//打印链表

LinkedList *getLinkedListInstance();
void removeLinkedListIntance(LinkedList *list);
void addNode(LinkedList *,Data);
Data removeNode(LinkedList *);
void displayPerson(LinkedList *list);

int compareEmployee(Employee *e1,Employee *e2);
void displayEmployee(Employee *employee);
#endif /* link_h */
