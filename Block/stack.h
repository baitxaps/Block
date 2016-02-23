//
//  stack.h
//  Block
//
//  Created by hairong chen on 16/2/11.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#ifndef stack_h
#define stack_h

#include <stdio.h>
#include "link.h"

typedef LinkedList Stack;

void initializeStack(Stack *stack);
void push(Stack *stack,void*data);
void *pop(Stack *stack);

#endif /* stack_h */
