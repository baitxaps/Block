//
//  PStruct.h
//  Block
//
//  Created by hairong chen on 16/2/11.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#ifndef PStruct_h
#define PStruct_h

#include <stdio.h>
typedef struct _person{
    char *firstName;
    char *lastName;
    char *title;
    uint age;
}Person;

void initializePerson(Person *person,const char *fn,
                      const char *ln,const char *title,
                      uint age );
void deallocatePerson(Person *person);
void initializeList();
Person *getPerson();
Person *returnPerson(Person *person);
#endif /* PStruct_h */
