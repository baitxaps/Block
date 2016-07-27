//
//  binaryTree.h
//  Block
//
//  Created by hairong chen on 16/2/11.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#ifndef binaryTree_h
#define binaryTree_h

#include <stdio.h>
#include "link.h"

//////////////////////////////////////////////////
//Binary Tree
//////////////////////////////////////////////////
/*
 指针提供一种维护三个节点之间的关系的直观、动态的方式。可以动态分配节点，将其按需插入树中。
 这里使用下面的结构体作为节点，借助void指针可以处理需要的任意类型的数据
 */
typedef struct _tree{
    void *data;
    struct _tree *left;
    struct _tree *right;
}TreeNode;


void insertNode(TreeNode **root,COMPARE compare,void *data);
void preOrder(TreeNode *root,DISPLAY display);
void inOrder(TreeNode *root,DISPLAY display);
void postOrder(TreeNode *root,DISPLAY display);

#endif /* binaryTree_h */
