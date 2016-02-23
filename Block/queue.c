//
//  queue.c
//  Block
//
//  Created by hairong chen on 16/2/11.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#include "queue.h"


void initializeQueue(Queue *queue){
    initializeLinkList(queue);
}

void enqueue(Queue *queue,void *data){
    addHead(queue, data);
}

/*
 之前的链表没有删除尾节点的函数，deueue函数删除最后一个节点
 需要处理以下三种情况：
 1.空队列:返回空
 2.单节点队列:由else if语句处理
 3.多节点队列:由else if分支外理
 最后一种情况，用tmp指针来一个节点一个节点前进，直到到指向尾节点的前一个节点，
 然后按顺序执行下面三种操作：
 1>将尾节点赋值为tmp
 2>将tmp指针前进一个节点
 3>将尾节点的next字段置为NULL,表示后面没有节点了
 */

void *dequeue(Queue *queue){
    Node *tmp = queue->head;
    void *data;
    if (queue->head == NULL) {
        data = NULL;
    }else if(queue->head == queue->tail){
        queue->head = queue->tail = NULL;
        data = tmp->data;
        free(tmp);
    }else{
        while (tmp->next != queue->tail) {
            tmp =tmp->next;
        }
        queue->tail = tmp;
        tmp = tmp->next;
        queue->tail->next = NULL;
        data=tmp->data;
        free(tmp);
    }
    return data;
}
