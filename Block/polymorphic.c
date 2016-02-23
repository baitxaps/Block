//
//  polymorphic.c
//  Block
//
//  Created by hairong chen on 16/2/11.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#include "polymorphic.h"
#include <stdlib.h>

void shapeDisplay(Shape *shape){
    printf("Shape\n");
}

void shapeSetX(Shape *shape,int x){
    shape->x = x;
}
int  shapeGetX(Shape *shape){
    return  shape->x;
}
void shapeSetY(Shape *shape,int y){
    shape->y= y;
}
int shapeGetY(Shape *shape){
    return shape->y;
}

void rectangleSetX(Rectangle *rectangle,int x){
    rectangle->base.x= x;
}

void rectangleSetY(Rectangle *rectangle,int y){
    rectangle->base.y= y;
}
int rectangleGetX(Rectangle *rectangle){
    return rectangle->base.x;
}

int rectangleGetY(Rectangle *rectangle){
    return  rectangle->base.y;
}

void rectangleDisplay(){
    printf("Rectangle\n");
}
/*
 为对象分配内存，然后为其设置函数
 */

Shape *getShapeInstance(){
    Shape *shape = (Shape *)malloc(sizeof(Shape));
    shape->functions.display = shapeDisplay;
    shape->functions.setX  = (void *)shapeSetX;
    shape->functions.getX  = (void *)shapeGetX;
    shape->functions.setY  = (void *)shapeSetY;
    shape->functions.getY  = (void *)shapeGetY;
    
    shape->x = 100;
    shape->y = 100;
    return shape;
}

Rectangle *getRectangleInstance(){
    Rectangle *rectangle = (Rectangle *)malloc(sizeof(Rectangle));
    rectangle->base.functions.display = rectangleDisplay;
    rectangle->base.functions.setX  = (void *)rectangleSetX;
    rectangle->base.functions.getX  = (void *)rectangleGetX;
    rectangle->base.functions.setY  = (void *)rectangleSetY;
    rectangle->base.functions.getY  = (void *)rectangleGetY;
    
    rectangle->base.x = 200;
    rectangle->base.y = 200;
    rectangle->width  = 300;
    rectangle->height = 500;
    return rectangle;
}

void initPolymorephic(){
//    Shape *sptr = getShapeInstance();
//    sptr->functions.setX(sptr,35);
//    sptr->functions.display();
//    printf("%d\n",sptr->functions.getX(sptr));
//    
//    
//    Rectangle *rptr = getRectangleInstance();
//    rptr->base.functions.setX(rptr,65);
//    rptr->base.functions.display();
//    printf("%d\n",rptr->base.functions.getX(rptr));

    
    /*
     1.创建一个Shape指针的数组，然后初始化。当把Rectangle赋给shapes[1]时，没有必要非得把它转成(Shape*),
     但是不强转会产生警告
     2.创建Shape指针的数组过程中，创建一个Rectangle实例并将其赋给数组的第二个元素，当for循环中打印元素时，
     它倒用Rectangle的函数行为而不是Shape的，这就是一种多态行为。display函数的行为取决于它所执行的对象
     3.我们把它当成Shape来访问，因此不应该试图用shape[i]来访问其宽度和高度，原因是这个元素可能引用一个Rectangle，
     也可能不是。如果不这么做，就可能访问shapes的其他内存，那些内存并不代表宽度和高度信息，会导致不可预期的结果
     4.也可以再从Shape中派生一个结构，如Circle，把它加入数组，而不需要大量修改代码。我们也需要为这个结构体创建函数
     5.如给基结构Shape增加一个函数，如getArea,就可以为每一个类实现一个唯一的getArea函数，在循环中，可以轻易地把所有Shape和Shape 派生的结构体的面积累加，而不需要先判断处理的是什么类型的Shape.
     6.如果Shape的getArea实现足够了，那么就不需要为其他结构增加函数了。这样很容易维护和扩展一个应用程序
     */
    
    Shape *shape[3];
    shape[0] = getShapeInstance();
    shape[0]->functions.setX(shape[0],5);
    
    shape[1] = getRectangleInstance();
    shape[1]->functions.setX(shape[1],15);
    
    shape[2] = getShapeInstance();
    shape[2]->functions.setX(shape[2],25);
    
    
    for (int i = 0; i<3; i++) {
        shape[i]->functions.display();
        printf("%d\n",shape[i]->functions.getX(shape[i]));
    }
}