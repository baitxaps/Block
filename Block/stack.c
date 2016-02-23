//
//  stack.c
//  Block
//
//  Created by hairong chen on 16/2/11.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#include "stack.h"
#pragma mark - Stack

void initializeStack(Stack *stack){
    initializeLinkList(stack);
}

void push(Stack *stack,void*data){
    addHead(stack, data);
}
/*
 出栈操作：先把栈的头节点赋给一个节点指针，涉及三种情况
 1.栈为空:函数返回NULL
 2.栈中有一个元素:如果节点指向尾节点，那么头节点和尾节点是同一个元素。将头节点和尾节点置为NULL,然后返回数据
 3.栈中有多个元素:将头节点赋值为链表中的下一个元素，然后返回数据
 4.在后两种情况下，节点会被释放
 */
void *pop(Stack *stack){
    Node *node = stack ->head;
    if (node == NULL) {
        return NULL;
    }else if (node == stack->tail){
        stack ->head = stack ->tail = NULL;
        void *data = node ->data;
        free(node);
        return data;
    }else{
        stack->head = stack->head->next;
        void *data = node->data;
        free(node);
        return data;
    }
}
