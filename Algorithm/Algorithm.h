//
//  Algorithm.h
//  Block
//
//  Created by hairong chen on 16/2/23.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Algorithm : NSObject

+ (instancetype)shareInstance;

int  maxUnique(char str[]);
char *getRandomString(int len);
char *maxUniqueString(char * str);

int getMax1(int arr[]);
int getMax2(int arr[]);
int *getRandomArray(int len);


long gapNumber(char str1[],char str2[]);
long pos(char s[],long len);
int minPath(int (*t)[4],int len);
int  maxLength(int arr1[],int len1,int arr2[],int len2);

void execCmd();


struct Item {
    int iValue;
    struct Item *pNext;
};
typedef struct Item _Node;

unsigned char symmetry(long n);
_Node* setItem( _Node *pHead,int m) ;
int search(int a[],int x,int low,int high);
@end
