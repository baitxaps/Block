//
//  Algorithm.m
//  Block
//
//  Created by hairong chen on 16/2/23.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#import "Algorithm.h"

@implementation Algorithm

char *getRandomString(int len)
{
    char *str = (char *)malloc(sizeof(char)*len);
    int base  = 'a';
    int range = 'z'-'a' +1;
    for (int i = 0; i!= len; i ++) {
        str[i]= rand()%range + base;
    }
    
    return str;
}

char *maxUniqueString(char * str)
{
    if (str == NULL || strlen(str) ==0 ) {
        return str;
    }
    int map[256];
    for (int i =0; i <256; i ++) {
        map[i]=-1;
    }
    int len = -1;
    int pre = -1;
    int cur = 0;
    int end = -1;
    
    for (int i =0 ; i !=strlen(str); i ++) {
        // printf("map[str[%d]]=%c\n",i,map[str[i]]);
        pre = MAX(pre, map[str[i]]);
        cur = i -pre;
        if (cur >len) {
            len = cur;
            end = i;
        }
        map[str[i]] = i;
        //printf("pre = %d,cur = %d,len = %d,end = %d,map[str[%d]]=%d\n",pre,cur,len,end,i,map[str[i]]);
    }
    char *desc = (char*)malloc(sizeof(char)*len);
    strncpy(desc, str+(end - len + 1), len);
    return desc;//返回后free(desc)
}

int maxUnique(char str[])
{
    if (!str  || strlen(str)<2) {
        return 0;
    }
    int map[256];
    for (int i = 0; i <256; i ++) {
        map[i]= -1;
    }
    
    int len = 0;
    int pre = -1;
    
    for (int i = 0; i!= strlen(str); i++) {
        // printf("start --->pre= %d,i=%d,i-pre=%d,len =%d,map[str[%d]]= %d\n",pre,i,i-pre,len,i,map[str[i]]);
        pre = MAX(pre, map[str[i]]);
        len = MAX(len, i - pre);
        map[str[i]]= i;
        
        printf("end --->pre= %d,i=%d,i-pre=%d,len =%d,map[str[%d]]= %d\n\n",pre,i,i-pre,len,i,map[str[i]]);
    }
    
    return len;
}


int getMax1(int arr[])
{
    int count = 0;
    for (int i = 0; arr[i] >0; i++)count ++;
    if (arr== NULL || count<2) {
        return 0;
    }
    
    int res = 0;
    for (int i =0; i < count -1; i ++) {
        for (int j = i + 1; j <count; j ++) {
            res = MAX(res, arr[j]- arr[i]);
        }
    }
    return res;
}


int getMax2(int arr[])
{
    int count = 0;
    for (int i = 0; arr[i] >0; i++)count ++;
    if (arr == NULL ||count <2 ) {
        return 0;
    }
    int min = INT32_MAX;
    int res = 0;
    for (int i =0; i< count; i++) {
        min = MIN(min, arr[i]);
        res = MAX(res, arr[i]-min);
    }
    return res  ;
}

int *getRandomArray(int len)
{
    int *arr = (int *)malloc(sizeof(int)*len);
    for (int i = 0; i < len; i ++) {
        arr[i]= rand()%100+1;
    }
    return arr;
}



long gapNumber(char *str1,char *str2)
{
    long str1_len = strlen(str1);
    long str2_len = strlen(str2);
    if (str1_len ==0 || str2_len ==0||(strcmp(str1,str2)==0)) {
        return 0;
    }
    
    long len = MAX(str1_len, str2_len);
    
    return (pos(str2, len) - pos(str1, len))-1;
}

long  pos(char *s,long len)
{
    long res = 0;
    long pre = 0;
    for (long i = 0; i <strlen(s); i ++) {
        pre = pre * 26 +s[i] -'a';
        pre += pre + 1;
    }
    for (long i = strlen(s); i <len; i ++) {
        pre *= 26;
        res +=pre;
    }
    return res;
}

int minPath(int (*t)[4],int len)
{
    for (int i =len -2 ; i>=0; i--) {
        for (int j = 0; j<=i; j++) {
            printf("%d,%d\n",t[i+1][j], t[i+1][j+1]);
            t[i][j] += MIN(t[i+1][j], t[i+1][j+1]);
        }
    }
    return t[0][0];
}

int  maxLength(int arr1[],int len1,int arr2[],int len2)
{
    if (len1 ==0 ||len2==0 || len1 != len2) {
        return 0;
    }
    
    for (int i = 0; i< len1; i ++) {
        arr1[i]+= (arr2[i] == 1?-1:0);
        printf("arr1[%d]=%d\n",i,arr1[i]);
    }
    
    char *map = (char*)malloc(sizeof(char)*len1);
    
    map[0]  = -1;
    int len = 0;
    int sum = 0;
    for (int i = 0; i <len1; i ++) {
        sum += arr1[i];
        printf("map[%d]=%d\n",i,map[i]);
        if (map[sum]) {
            len = MAX(i - map[sum], len);
        }
        if (!map[sum]) {
            map[sum]= i;
        }
    }
    free(map);
    return len;
}


char *repaceSpace(char str[],int length)
{
    int count=0,newLength=0;
    
    for (int i =0; str[i]; i++) {
        if (str[i] == ' ') {
            count ++;
        }
    }
    newLength = count * 2 +length;
    
    for (int i = length -1; i >=0;i--) {
        if (str[i]== ' ') {
            str[newLength -1]='0';
            str[newLength -2]='2';
            str[newLength -3]='%';
            newLength -=3;
            
        }else{
            str[newLength -1] =str[i];
            newLength --;
            printf("%c\n",str[newLength -1]);
        }
    }
    return str;
}

char *zipString(char str[])
{
    //char zip[255];
    char *zip = (char*)malloc(sizeof(char)*255);
    int k =0,count,j;
    
    for (int i =0; str[i]; i++) {
        count =1;
        i     =j;
        while (str[i]== str[++j]) {
            count ++;
        }
        zip[k++]  =str[i];
        zip[k++]  =count +'0';
        
    }
    zip[k]='\0';
    return zip;
}


//List
typedef struct Node {
    char data;
    struct Node *next;
}ListNode;

ListNode *create(void)
{
    ListNode *head,*p = NULL,*q = NULL;
    head = NULL;
    
    int i =0;
    
    while (i <6) {
        p = (ListNode *)malloc(sizeof(ListNode));
        if (head ==NULL) {
            head =q =p;
        }else{
            q->next = p;
            q->data = 'c'+i;
            q=p;
        }
        i++;
    }
    p->next = NULL;
    return head;
}

void showList(ListNode * head)
{
    ListNode *p = head;
    while (p) {
        printf("%c\n",p->data);
        p = p->next;
    }
}

ListNode * reverseList( ListNode *node)
{
    ListNode *p,*q =NULL,*r =NULL;
    p =node;
    while (p) {
        q = p->next;
        p->next = r;
        r= p;
        p =q;
    }
    
    return r;
}

char *InneerInfo()
{
    char *info = (char *)malloc(sizeof(10));
    
    return info;
}

void execCmd(){
    
    long num = 3;
    char s = 'a';
    intptr_t *pi = &num;
    uintptr_t *upi = (uintptr_t *)&num;
    uintptr_t *spi = (uintptr_t *)&s;
    printf("%ld,%lu,%p",*pi,*upi,spi);
    
    srand((unsigned)time( NULL ) );
    char *str = getRandomString(10);
    printf("str = %s\n",str);
    printf("len = %d\n",maxUnique(str));
    str = maxUniqueString(str);
    printf("str = %s\n",str);
    
    int *arr = getRandomArray(100);
    int times = 1000;
    for (int i = 0 ;i<times;i ++) {
        if (getMax1(arr)!=getMax2(arr)) {
            printf("what a fucking day");
        }
    }
    free(str);//
    free(arr);//
    
    printf("%ld",sizeof(InneerInfo()))   ;
    
//    char *app = zipString("aaaaaa1eee0");
//    printf("%s\n",app);
//    free(app);
    
    ListNode *listNode = create()   ;
    
    showList(listNode);
    
    ListNode *reverse =  reverseList(listNode);
    
    showList(reverse);
    
    /*
     1.给定两个字符串A和B，其中只有小写字符，已知A的字典序小于B，
     求在A和B的字典序之间，有多少个字符串。以长度较长的一方为准。
     例如：A=“ab”，B=“ac”。他们的字典序挨着，所以返回0。
     
     例如：A=“a”，B=“cc”。B的长度较长为2，所以A和B之间的字符串包括：
     ”aa”..”az”,”b”,”ba”..”bz”,”c”,”ca”,”cb”。一共56个
     
     例如：A=“aa”,B=“c”。A的长度较长为2，所以所以A和B之间的字符串包括：
     “ab”..”az”，“b”，“ba”..”bz”。一共52个。
     */
    
    // printf("count =%ld\n",gapNumber("aa", "c"));
    
    /*
     2.给定一个二维数组代表一个三角形，比如：
     
     int[][] t = { { 2 }, { 3, 4 }, { 6, 5, 7 }, { 4, 1, 8, 3 }, };
     
     t代表如下三角形：
     
     2
     3 4
     6 5 7
     4 1 8 3
     
     找出从其顶部到底部的所有路径中，路径上的整数构成的最小和。
     从顶部向底部移动时，每次可以移动到下一行中左边或右边的相邻整数，比如如上的例子，
     最小整数和为11，即2+3+5+1=11。
     */
    
    int t[][4] = {
        { 2 },
        { 3, 4 },
        { 6, 5, 7 },
        { 4, 1, 8, 3 }
    };
    
    printf("count =%d\n",minPath(t,4));
    
    /*
     3.给定两个数组A和B，A和B长度相等，并且已知其中所有只包含0和1。
     求最长的包含相同数目的1的子数组长度，要求索引位置一样，
     即A[i]到A[j]包含的1的个数和B[i]到B[j]包含的1的个数一样。
     */
    
    int arr1[5] = {1,1,0,1,0};
    int arr2[5] = {1,1,0,1,1};
    
    printf("len = %d \n",maxLength(arr1, 5, arr2, 5));
    
    /*
     4.把字符串中的空格替换为"%20",这个需要注意的是字符串的结尾最后一个字符为'\0'，
     并不是空字符，复制时要一块复制，算法思想就是先计算出字符串中总的空格数，然后
     重新计算字符串的长度，由于"%20"为3个字符，比原来多2个，所以，字符串长度是原来字符串长度
     加上空格字符总数×2,就是新的字符串的长度
     */
    char *str_ = "hello world!";
    
    printf("%s\n",repaceSpace(str_,(int)strlen(str_)));
    
}

@end
