//
//  binaryTree.c
//  Block
//
//  Created by hairong chen on 16/2/11.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#include "binaryTree.h"
#include "thread.h"
/*
 二叉查找树(插入新节点后，这个节点的所有左子节点的值都比父节点小，所有右子节点的值都比父节点的值大)
 0.insertNode函数会把一个节点插入二叉查找树，函数第一部分为新节点分配内存并把数据赋给节点，
 新节点插入树后总是叶子节点，所以将左子节点和右子节点置为NULL。
 1.根节点是以TreeNode指针的指针和形式传递的，因为需要修改传入的函数的指针，而不是指针指向的对象。
 如果树非空，进入一个无限循环，直到将新节点插入树中结束
 2.每次循环迭代都会比较新节点和当前节点，根据比较结果，将局部root指针置为左子节点或右子节点，这个
 root指针总是指向当前节点
 3.如果左子节点或右子节点为空，那么就将新节点添加为当前节点的子节点，循环结束
 
 */
void insertNode(TreeNode **root,COMPARE compare,void *data){
    TreeNode *node = (TreeNode *)malloc(sizeof(TreeNode));
    node->data = data;
    node->left = NULL;
    node->right= NULL;
    
    if (*root==NULL) {
        *root = node ;
        return;
    }
    
    while (1) {
        if (compare((*root)->data,data)>0) {
            if ((*root)->left !=NULL) {
                *root = (*root)->left;
            }else{
                (*root)->left = node;
                break;
            }
        }else{
            if ((*root)->right !=NULL) {
                *root = (*root)->right;
            }else{
                (*root)->right = node;
                break;
            }
        }
    }
}
/*
 前序：节点，往左，再往右
 中序：往左，节点，再往右
 后序：往左，往右，再节点
 所有函数的参数都是树根和作为打印函数的一个函数指针，它们都是递归的，只要传入的根节点非空就会调用自身
 不同点只在于执行三步操作的顺序
 */
void preOrder(TreeNode *root,DISPLAY display){
    if (root !=NULL) {
        display(root->data);
        preOrder(root->left,display);
        preOrder(root->right, display);
    }
}

void inOrder(TreeNode *root,DISPLAY display){
    if (root !=NULL) {
        inOrder(root->left,display);
        display(root->data);
        inOrder(root->right, display);
    }
}

void postOrder(TreeNode *root,DISPLAY display){
    if (root !=NULL) {
        postOrder(root->left,display);
        postOrder(root->right, display);
        display(root->data);
    }
}

//判断机器字节序
void machineByteOrder(){
    
    //判断机器的字节序,如在Intel PC上输出，这是小字节序架构，内存中分配：
    //100:78
    //101:56
    //102:34
    //103:12
    int num = 0x12345678;
    char *pc = (char *)&num;
    for (int i =0; i<4; i++) {
        printf("%p:%02x",pc,(unsigned char)*pc++);
    }
    
    char firstName[8] ="1234567";
    char middleName[8]="1234567";
    char lastName[8]  ="1234567";
    middleName[-2]='X';
    middleName[0]= 'X';
    middleName[10]='X';
    
    printf("firstName =%s middleName = %s,lastName= %s",firstName,middleName,lastName);

    //restric key
    double vector1[] = {1.1,2.2,3.3,4.4};
    double vector2[] = {1.1,2.2,3.3,4.4};
    //double *vector3 = vector2;
    add(4,vector1,vector2);
    printf("%d", isPositivel(-3.2));
    
    float number = 3.25f;
    unsigned int *ptrValue = (unsigned int *)&number;
    unsigned int result = (*ptrValue & 0x80000000) == 0;
    printf("result = %d",result);
    
}