//
//  DulNode.h
//  Block
//
//  Created by hairong chen on 16/8/1.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#include "RHCMacros.h"

#ifndef DulNode_h
#define DulNode_h

typedef struct DulNode {
    ELemType data;
    struct DulNode *prior;
    struct DulNode *next;
    
} DulNode,*DulLinkList;

#include <stdio.h>

#endif /* DulNode_h */
