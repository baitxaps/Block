//
//  queue.h
//  Block
//
//  Created by hairong chen on 16/2/11.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#ifndef queue_h
#define queue_h
#include <stdio.h>
#include "link.h"

typedef LinkedList Queue;

void initializeQueue(Queue *queue);
void enqueue(Queue *queue,void *data);
void *dequeue(Queue *queue);

#endif /* queue_h */
