//
//  main.m
//  Block
//
//  Created by hairong chen on 16/2/23.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#import "RHCHeaders.h"

int main(int argc, const char * argv[]) {
    // SqList
#if Swith
    SqList *sqlist = (SqList *)malloc(sizeof(SqList));
    for (int i = 0; i <3; i ++) {
//        (*sqlist).data[i] = i;
//        (*sqlist).length = i+1;
        sqlist->data[i] = i;
        sqlist->length = i+1;
        
        NSLog(@"%d",sqlist->data[i]);
    }

    ListInsert(sqlist, 2, 3);
    ListDelete(sqlist, 1, 0);
    
    for (int i = 0; i <sqlist->length; i ++) {
        NSLog(@"%d",sqlist->data[i]);
    }
#endif
    // Algorithm
    execCmd();

    // GCD
    GCD *gcd = [GCD new];
    [gcd GCDTest];
    
    // block
    block *b = [block new];
    [b BlockTest1];
    [b BlockTest2];
    
    // polymorephic
    initPolymorephic();
    
    Employee *samuel = (Employee *)malloc(sizeof(Employee));
    strcpy(samuel->name, "samuel");
    samuel->age = 32;
    
    Employee *sally = (Employee *)malloc(sizeof(Employee));
    strcpy(sally->name, "sally");
    sally->age = 28;
    
    Employee *susan = (Employee *)malloc(sizeof(Employee));
    strcpy(susan->name, "susan");
    susan->age = 56;
    
    // Binary tree
    TreeNode *tree = NULL;
    insertNode(&tree, (COMPARE )compareEmployee, samuel);
    insertNode(&tree, (COMPARE )compareEmployee, sally);
    insertNode(&tree, (COMPARE )compareEmployee, susan);
    
    preOrder(tree,(DISPLAY)displayEmployee);
    inOrder(tree,(DISPLAY)displayEmployee);
    postOrder(tree,(DISPLAY)displayEmployee);
    
    // Stack
    Stack stack;
    initializeLinkList(&stack);
    push(&stack, samuel);
    push(&stack, sally);
    push(&stack, susan);
    
    Employee *employee;
    for (int i =0; i<4; i++) {
        employee = (Employee *)pop(&stack);
        printf("popped %s\n",employee->name);
    }
    
    // Queue
    Queue queue;
    initializeLinkList(&queue);
    enqueue(&queue, samuel);
    enqueue(&queue, sally);
    enqueue(&queue, susan);
    
    void *data = dequeue(&queue);
    printf("Dequeued %s\n",((Employee *)data)->name);
    
    data = dequeue(&queue);
    printf("Dequeued %s\n",((Employee *)data)->name);
    
    data = dequeue(&queue);
    printf("Dequeued %s\n",((Employee *)data)->name);
    
    // LinkList
    LinkedList *list = getLinkedListInstance();
    Person *person = (Person *)malloc(sizeof(Person));
    initializePerson(person, "Peter", "Underwood", "Manager", 36);
    addNode(list, person);
    
    person = (Person *)malloc(sizeof(Person));
    initializePerson(person, "Sue", "Stevenson", "Developer", 28);
    addNode(list, person);
    displayPerson(list);
    
    person = removeNode(list);
    displayPerson(list);
    removeNode(list);
    
    LinkedList linkedList;
    initializeLinkList(&linkedList);
    addHead(&linkedList, samuel);
    addHead(&linkedList, sally);
    addHead(&linkedList, susan);
    displayLinkedList(&linkedList, (DISPLAY)displayEmployee);
    
    Node *node = getNode(&linkedList, (int(*)(void*,void*))compareEmployee, susan);
    delete(&linkedList, node);
    displayLinkedList(&linkedList, (DISPLAY)displayEmployee);
    
    
    // struct
    initializeList();
    Person *ptrPerson;
    ptrPerson = getPerson();
    initializePerson(ptrPerson, "Ralph", "Fitsgerald",  "Mr", 35);
    returnPerson(ptrPerson);
    
    ptrPerson = getPerson();
    initializePerson(ptrPerson, "Salph", "gitsgerald",  "Mr", 45);
    returnPerson(ptrPerson);
    
    ptrPerson = getPerson();
    initializePerson(ptrPerson, "Talph", "hitsgerald",  "Mr", 55);
    returnPerson(ptrPerson);
    
    // thread
    initThread();
    threadExample();
    
    // character
    char *names[] = {"Bob","Ted","Carol","Alice"};
    sort(names, 4, compare);
    displayNames(names, 4);
    
    char *buffer = (char *)malloc(strlen("  cat")+1);
    strcpy(buffer, " cat");
    printf("%s\n",trim(buffer));
    
    return 0;
}