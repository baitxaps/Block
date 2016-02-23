//
//  PStruct.c
//  Block
//
//  Created by hairong chen on 16/2/11.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#include "struct.h"
#include <strings.h>
#include <stdlib.h>

#pragma mark - struct
//////////////////////////////////////////////////
//struct
//////////////////////////////////////////////////

void initializePerson(Person *person,const char *fn,
                      const char *ln,const char *title,
                      uint age )  {
    person ->firstName = (char *)malloc(strlen(fn)+1);
    strcpy(person->firstName, fn);
    
    person ->lastName = (char *)malloc(strlen(ln)+1);
    strcpy(person->lastName, ln);
    
    person ->title = (char *)malloc(strlen(title)+1);
    strcpy(person->title, title);
    
    person->age = age;
}

void deallocatePerson(Person *person){
    free(person->firstName);
    free(person->lastName);
    free(person->title);
}

void processPerson(){
    //    Person person;
    //    initializePerson(&person, "person", "Underwood", "Manage", 26);
    //
    //    deallocatePerson(&person);
    
    Person *ptrPerson;
    ptrPerson = (Person*)malloc(sizeof(Person));
    initializePerson(ptrPerson, "person", "Underwood", "Manage", 26);
    //...
    deallocatePerson(ptrPerson);
    free(ptrPerson);
}
#define LIST_SIZE 5
Person *list[LIST_SIZE];
void initializeList(){
    for (int i =0; i<LIST_SIZE;i++ ) {
        list[i]= NULL;
    }
}

/*
 list[i]   ptr
 |
 ↓
 Person
 
 
 list[i]   ptr
 |       |
 ↓       ↓
 NULL   Person
 */

Person *getPerson(){
    for (int i =0; i<LIST_SIZE; i++) {
        if (list[i]!=NULL) {
            Person *ptr = list[i];//ptr,与list是两个不同的指针，都指向Person
            list[i]= NULL;
            return ptr;
            
        }
    }
    Person *person = (Person *)malloc(sizeof(Person));
    return person;
}

Person *returnPerson(Person *person){
    for (int i = 0; i< LIST_SIZE; i++) {
        if (list[i]==NULL) {
            list[i]= person;
            return person;
        }
    }
    deallocatePerson(person);
    free(person);
    return NULL;
}
