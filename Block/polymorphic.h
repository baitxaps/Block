//
//  polymorphic.h
//  Block
//
//  Created by hairong chen on 16/2/11.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#ifndef polymorphic_h
#define polymorphic_h

#include <stdio.h>

typedef void (*fptrSet)(void *,int);
typedef int (*fptrGet)(void *);
typedef void(*fptrDisPlay) ();

/*
 1.C++多态是建立在基类及派生类之间继承关系的基础上的，Ｃ不支持继承，所以得模拟结构体之间的继承
 定议和使用两个结构体来说明多态行为：Shape结构体表示基“类”，而Rectangle结构表示从基类Shape派生的类
 结构体的变量分配顺序对这个技术的工作原理影响很大，当创建一个派生类/结构体的实例时，会先分配基类/结构体的
 变量，也需要考虑打算覆盖的函数
 2.Shape结构体持有函数指针，接着是x和y的坐标整数
 3.vFunctions结构体：由一系列函数指针组成.fptrSet和fptrGet函数指针为整数类型数据定义了典型的getter和setter
 函数，用来获取和设置Shape和Rectangle的x和y值，fptrDisplay函数指针定义了一个参数为空，返回值为空的函数
 会用这个打印函数解释多态行为
 4.当一个类/结构体执行函数时，其行为取决它作用的对象是什么，如对Shpae调用打印函数
 就会显示一个Shape，对Rectangle调用打印函数就会显示Rectangle.在面向对象编程中这通常通过虚表(VTable)
 实现，vFunctions结构就是用来实现这种功能
 */
typedef struct _functions{
    fptrSet setX;
    fptrGet getX;
    fptrSet setY;
    fptrGet getY;
    fptrDisPlay display;
    
}vFunctions;


typedef struct _shape{
    vFunctions functions;
    int x;
    int y;
}Shape;

/*
 看起来实现Shape结构体这么做有点大费周章，但是从Shape派生出一个Rectangle结构体，就会看到这么做
 强大的能力
 */
typedef struct _rectangle{
    Shape base;
    int width;
    int height;
}Rectangle;

void shapeDisplay(Shape *shape);
void shapeSetX(Shape *shape,int x);
void shapeSetY(Shape *shape,int y);
int shapeGetY(Shape *shape);
int  shapeGetX(Shape *shape);

void rectangleDisplay();
void rectangleSetX(Rectangle *rectangle,int x);
void rectangleSetY(Rectangle *rectangle,int y);
int rectangleGetX(Rectangle *rectangle);
int rectangleGetY(Rectangle *rectangle);

/*
 为对象分配内存，然后为其设置函数
 */
Shape *getShapeInstance();
Rectangle *getRectangleInstance();

void initPolymorephic();
#endif /* polymorphic_h */
