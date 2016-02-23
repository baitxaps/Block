//
//  link.c
//  Block
//
//  Created by hairong chen on 16/2/11.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#include "link.h"
#include <string.h>
#include "struct.h"

//typedef struct _node{
//    Data *data;
//    struct _node *next;
//}Node;
//
//typedef struct _linkedList{
//    Node *head;
//}LinkedList;

#pragma mark - LinkList
LinkedList *getLinkedListInstance(){
    LinkedList *list = (LinkedList*)malloc(sizeof(LinkedList));
    list->head = NULL;
    return list;
}
void removeLinkedListIntance(LinkedList *list){
    Node *tmp = list->head;
    while (tmp!=NULL) {
        free(tmp->data);
        Node *current = tmp;
        tmp = tmp ->next;
        free(current);
    }
    free(list);
}


void addNode(LinkedList *list,Data data){
    Node *node = (Node *)malloc(sizeof(Node));
    node->data = data;
    if (list->head == NULL) {
        list->head = node;
        node->next = NULL;
    }else{
        node->next = list ->head;
        list->head = node;
    }
}

Data removeNode(LinkedList *list){
    if (list->head==NULL) {
        return NULL;
    }else{
        Node *tmp = list->head;
        Data *data;
        list->head = list->head->next;
        data =tmp->data;
        free(tmp);
        return data;
    }
}


void displayPerson(LinkedList *list){
    Node *node = list->head;
    while (node!=NULL) {
        Person *person = (Person *)(node->data);
        printf("%s\n",person->firstName);
        node = node->next;
    }
    
}


void initializeLinkList(LinkedList *list){
    list->head = NULL;
    list->tail = NULL;
    list->current = NULL;
    
}
/*
 1.查链表是否为空，如果空，把尾指针指向节点，然后把节点next字段赋值为NULL
 2.如果不空，将节点的next指向链表头
 3.无论哪种情况，链表头都指向节点
 */
void addHead(LinkedList *list,void *data){
    Node *node = (Node *)malloc(sizeof(Node));
    node->data = data;
    if (list->head == NULL) {
        list->tail = node;
        node->next = NULL;
    }else{
        node->next = list->head;
    }
    list->head = node;
}

/*
 1.因总是将节点添加到末尾，即该节点的next字段被赋值NULL
 2.如果链表空，head指针就是NULL,把新节点赋给head
 2.如果不空，尾节点的next指针赋为新节点
 3.无论哪种情况，链表tail指针都赋为该节点
 */
void addTail(LinkedList *list,void *data){
    Node *node = (Node *)malloc(sizeof(Node));
    node->data = data;
    node->next = NULL;
    if (list->head == NULL) {
        list->head = node;
    }else{
        list->tail->next = node;
    }
    list->tail = node;
}

/*
 为了保持函数简单，不检查链表内的空值和传入的节点
 1.第一个if处理删除头节点，如果头节点是唯一节点，那么将头节点和尾节点置为NULL,否则，
 头节点赋为原头节点的下一节点
 2.tmp指针从头到尾遍历链表，不论是将tmp赋值为NULL，还是tmp的下一节点就是要找的节点。
 3.tmp为空，表示要找的节点不在链表中
 4.函数末尾，将节点释放
 */
void delete(LinkedList *list,Node*node){
    if (node==list->head) {
        if (list->head->next == NULL) {
            list->head=list->tail=NULL;
        }else{
            list->head=list->head->next;
        }
    }else{
        Node *tmp = list->head;
        while (tmp!=NULL && tmp->next !=node) {
            tmp = tmp->next;
        }
        if (tmp!=NULL) {
            tmp->next = node->next;
        }
    }
    free(node);
}

int compareEmployee(Employee *e1,Employee *e2){
    return strcmp(e1->name, e2->name);
}

void displayEmployee(Employee *employee){
    printf("%s\t %d\n",employee->name,employee->age);
}



Node *getNode(LinkedList *list,COMPARE compare,void *data){
    Node *node = list->head;
    while (node!=NULL) {
        if (compare(node->data,data)==0) {
            return node;
        }
        node=node->next;
    }
    return NULL;
}

void displayLinkedList(LinkedList *list,DISPLAY display){
    printf("\nLinked List\n");
    Node *current = list->head;
    while (current!=NULL) {
        display(current->data);
        current=current->next;
    }
}


