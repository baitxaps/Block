//
//  ObjcTest.c
//  RunTime
//
//  Created by William on 2016/5/15.
//  Copyright © 2016 技术研发-IOS. All rights reserved.
//

#include "ObjcTest.h"

#pragma mark-  Objective-C的本质
struct Student_IMPLs {
    Class isa;
    int _no;
    int _age;
};

void ObjClass() {
    NSObject *obj = [[NSObject alloc]init];
    //成员变量占用的内存大小
    NSLog(@"%zd",class_getInstanceSize([NSObject class]));
    
    //一个NSObject对象, 到底占用多少的内存空间
    NSLog(@"%zd",malloc_size((__bridge const void *)(obj)));
    
    Student *stu = [[Student alloc] init];
    stu->_no = 4;
    stu->_age = 5;
    
    struct Student_IMPLs *stuImpl = (__bridge struct Student_IMPLs*)stu;
    NSLog(@"no - %d, age - %d", stuImpl->_no, stuImpl->_age);
}

#pragma mark - OC对象的分类
void ObjCatagory() {
    NSObject *obj1 = [[NSObject alloc] init];
    NSObject *obj2 = [[NSObject alloc] init];
    // - (Class)class
    Class objectClass1 = [obj1 class];
    Class objectClass2 = [obj2 class];
    // + (Class)class
    Class objectClass3 = [NSObject class];
    // object_getClass(实例对象)
    Class objectClass4 = object_getClass(obj1);
    Class objectClass5 = object_getClass(obj2);
    
    NSLog(@"%p %p %p %p %p", objectClass1, objectClass2,
          objectClass3, objectClass4,objectClass5);
    
    Class objectClass = [NSObject class];
    NSLog(@"%d", class_isMetaClass(objectClass));           // 打印: 0
    
    Class objectMetaClass = object_getClass([NSString class]);
    NSLog(@"%d", class_isMetaClass(objectMetaClass));       // 打印: 1
    NSLog(@"%@",object_getClass(objectMetaClass));
/*
     class类对象, 可以通过alloc创建出instance对象
     有三种方式, 可以获取一个类对象
     - (Class)class
     + (Class)class
     object_getClass(实例对象)
 
     NSObject *obj1 = [[NSObject alloc] init];
     NSObject *obj2 = [[NSObject alloc] init];
     // - (Class)class
     Class objectClass1 = [obj1 class];
     Class objectClass2 = [obj2 class];
     // + (Class)class
     Class objectClass3 = [NSObject class];
     // object_getClass(实例对象)
     Class objectClass4 = object_getClass(obj1);
     Class objectClass5 = object_getClass(obj2);

    注意:
    0. -(Class)class和+(Class)class方法只能获取class对象, 不能获取meta-class对象
       meta-class对象只能通过Runtime的object_getClass(类对象)获取
 
    1.Class objc_getClass(const char *aClassName)
    1> 传入字符串类名
    2> 返回对应的类对象

    2.Class object_getClass(id obj)
    1> 传入的obj可能是instance对象、class对象、meta-class对象
    2> 返回值
    a) 如果是instance对象，返回class对象
    b) 如果是class对象，返回meta-class对象
    c) 如果是meta-class对象，返回NSObject（基类）的meta-class对象

    3.- (Class)class、+ (Class)class
    1> 返回的就是类对象

    - (Class) {
        return self->isa;
    }

    + (Class) {
        return self;
    }
*/
}

#pragma mark -  isa和superclass
void ISASuperClass() {
    Person *person = [[Person alloc] init];
    [person personInstanceMethod];
    [Person test];
    
    NSLog(@"[Person class] - %p", [Person class]);
}

#pragma mark -  KVO的本质
void NatureKVO() {
    kvoObj *obj = [[kvoObj alloc]init];
    [obj manualCallKVO];
}


#pragma mark - KVC的本质
void NatureKVC() {
//    Persons *p = [Persons new];
//    [p setValue:@10 forKey:@"age"];
//    NSLog(@"%@", [p valueForKey:@"age"]);
//
//    Cat *cat = [Cat new];
//    p.cat = cat;
//    [p setValue:@20 forKeyPath:@"cat.weight"];
//    NSLog(@"%@", [p valueForKeyPath:@"cat.weight"]);
    
    kvcObj *obj = [kvcObj new];
    [obj setValue:@10 forKey:@"age"];
    
    obj->_age = 10;
    obj->isAge = 13;
    obj->_isAge = 40;
    obj->age = 30;
    
    NSLog(@"%@",[obj valueForKey:@"age"]);
}

#pragma mark - catagory
void CatagoryTest() {
    Person *p = [Person new];
    [p personTest];
    [Person personTests];
    /*
    Category原理:
    Category编译之后的底层结构是struct category_t, 里面存储着分类的对象方法、类方法、属性、协议信息
    在程序运行的时候, runtime会将Category的数据, 合并到类信息中(类对象、元类对象中)
     
    Class Extension在编译的时候, 他的数据就已经包含在类信息中
    Category是在运行时, 才会将数据合并到类信息中
    */
}

#pragma mark -  load方法
void printMethodNamesOfClass(Class cls) {
    unsigned int count;
    Method *methodList = class_copyMethodList(cls, &count);
    NSMutableString *methodNames = [NSMutableString string];
    for (int i = 0; i < count; i++) {
        Method method = methodList[i];
        NSString *methodName = NSStringFromSelector(method_getName(method));
        [methodNames appendString:methodName];
        [methodNames appendString:@", "];
    }
    free(methodList);
    NSLog(@"%@ %@", cls, methodNames);
}

void LoadMathod() {
   // [Person load];
    printMethodNamesOfClass([Person class]);
    NSLog(@"---------");
    [Student load];
  /*
    0.由源码可知: 在程序启动的时候, runtime会主动调用一次所有类和分类的+(void)load方法, 会先调用所有类的+(void)load方法, 再调用Category的+(void)load方法
    所以, 不论加载顺序, 类中的+(void)load方法都会优先于Category调用, 而Category中的+(void)load的方法会根据Category的加载顺序调用.(从前往后)
    而当我们使用代码调用+(void)load和+(void)test方法时, 使用的是消息机制, 代码等同于下面
    objc_msgSend([Person class], @selector(load));
    objc_msgSend([Person class], @selector(test));
    此时会通过Person类对象的isa指针找到元类对象, 接着查找方法列表, 最后调用
    因为Person+Test1是最后编译的, 所以会调用里面的+(void)load和+(void)test两个方法
   
    1.Category中有load方法, load方法会在runtime加载类的时候调用
    类的load方法调用早于Category中的load方法, 调用子类的load方法之前, 会先调用父类的load方法
    没有关系的类会根据编译顺序调用load方法, Category会根据编译顺序调用load方法
    所有的类和分类, load方法只会调用一次.
    2.load方法可以继承, 但是一般情况下不会主动调用load方法, 都是让系统自动调用
   */
}

#pragma mark -  Initialize方法
void Initialize() {
    NSLog(@"---------");
   // [Person alloc];
    [Student alloc];
    /*
    1.当一个类在第一次接受消息时, 会调用他自己的+(void)initialize方法,
     如果他有父类, 那么就会优先调用父类的+(void)initialize方法
    2. 通过源码可以看到, 当一个类在查找方法的时候, 会先判断当前类是否初始化, 如果没有初始化就会去掉用initialize方法
     如果这个类的父类没有初始化, 就会先调用父类的initialize方法, 再调用自己的initialize方法
     类在调用initialize时, 使用的是objc_msgSend消息机制调用
    3.调用方式 load是根据函数地址直接调用,initialize是通过objc_msgSend调用
      调用时刻
        load是runtime加载类、分类的时候调用(只会调用一次)
        initialize是类第一次接收到消息的时候调用, 每一个类只会initialize一次(如果子类没有实现initialize方法,
        会调用父类的initialize方法, 所以父类的initialize方法可能会调用多次)
     4.load和initializee的调用顺序
     load:先调用类的load, 在调用分类的load, 先编译的类, 优先调用load, 调用子类的load之前, 会先调用父类的load
     先编译的分类, 优先调用load
     initialize: 先初始化分类, 后初始化子类
     通过消息机制调用, 当子类没有initialize方法时, 会调用父类的initialize方法, 所以父类的initialize方法会调用多次
     */
}

#pragma mark -  关联对象相关方法
void AssociatedObject() {
    Person *p = [Person new];
    p.name = @"wrc";
    p.weight = 138;
    NSLog(@"name=%@,weight=%d",p.name,p.weight);
   //通过对象关联的成员变量, 在底层是被统一管理的, 并不是合并到了类对象的成员列表中
}

#pragma mark -  block的底层结构
struct __Block_byref_age_0_ {
    void *__isa;
    __Block_byref_age_0_ *__forwarding;
    int __flags;
    int __size;
    int age;
};

struct __main_block_impl_0_ {
    __Block_byref_age_0_ *age;
    __main_block_impl_0_(__Block_byref_age_0_ *_age):age(_age->__forwarding) {
        
    }
};


int num = 0;
typedef void (^WRBLock)(void);
WRBLock block8() {
    int tmp = 10;
    return ^{
        NSLog(@"block8 -%d",tmp);
    };
}


void StructOfBlock() {
    __Block_byref_age_0_ age = {
        (void*)0,
        (__Block_byref_age_0_ *)&age,
        0,
        sizeof(__Block_byref_age_0_),
        20
    };
    
    //__block会修改block内部auto变量的值
    (age.__forwarding->age) = 25;
   // (age.age) = 25;
    
    ^{
        NSLog(@"this is a block");
        NSLog(@"this is a block");
        NSLog(@"this is a block");
    }();
    
    /*
    总结: block的本质就是封装了函数调用以及函数调用环境的OC对象
    1.创建__main_block_impl_0时, 传入两个参数,第一个就是封装了block代码块的__main_block_func_0函数的地址, 第二个是block的描述结构体__main_block_desc_0(0,__main_block_impl_0占用内存大小)
     2.在OC中变量的类型主要使用三种, 分别是auto、static、全局变量, 其中auto和static修饰的是局部变量
     在block中, 如果使用局部变量, 那么就会捕获该变量
     在block中, 如果使用全局变量, 那么就不会捕获该变量, 而是直接使用
     */
    
    void (^block1)(void)= ^{
        NSLog(@"block1");
    };
    NSLog(@"block1=%@",[block1 class]);//block1=__NSGlobalBlock__
    
    void (^block2)(int ,int )= ^(int a ,int b){
        NSLog(@"block2-%d -%d",a,b);
    };
    NSLog(@"block2=%@",[block2 class]);//block2=__NSGlobalBlock__
    
    void (^block3)(void)= ^{
        NSLog(@"block3 -%d",num);
    };
    NSLog(@"block3=%@",[block3 class]);//block3=__NSGlobalBlock__
    
    static int ages = 3;
    void (^block4)(void)= ^{
        NSLog(@"block4- %d",ages =34);
    };
    block4();
    NSLog(@"block4=%@",[block4 class]);//block4=__NSGlobalBlock__
    
    int height = 170;
    void (^block5)(void)= ^{
        NSLog(@"block5 -%d",height);
    };
    NSLog(@"block5=%@",[block5 class]);//block4=__NSMallocBlock__
    
    void (^block6)(void)= [^{
        NSLog(@"block6 -%d",height);
    }copy];
    NSLog(@"block6=%@",[block6 class]);//block4=__NSMallocBlock__
    
    NSLog(@"%@",[^{
        NSLog(@"block7 -%d",height);
    }class]);//__NSStackBlock__
    
    NSArray *array;
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
    }];
    
    NSLog(@"block8=%@",[block8() class]) ;//block8=__NSMallocBlock__
    
    WRBLock blockP;
    {
        Person *p = [[Person alloc]init];
        p.height = 20;
        __block __weak Person *weakPersons = p;
        blockP = ^{
            __strong Person *strongPersions = weakPersons;
            NSLog(@"height is %d",strongPersions.height);
        };
        blockP();
    }
    // blockP();

    /* 1.内部没有使用auto类型变量的block, 就是__NSGlobalBlock__类型
       2.__NSStackBlock__类型的block做为函数返回值时, 会将返回的block复制到堆区
       3.如果没有__strong指针引用__NSStackBlock__类型的block, 那么block的类型是__NSStackBlock__
       4.block作为Cocoa API中方法名含有usingBlock的方法参数时, block在堆区
       5.block作为GCD API的方法参数时, block在堆区
       6.__NSGlobalBlock__类型的block, 不管怎样类型都不会改变, 依然在数据区
       7.栈中的block不会将对象类型的auto变量进行retain处理, 只有在将block复制到堆上时, 才会将对象类型的auto变量进行retain处理(引用计数+1)
         当堆中的block释放时, 会对其中的对象类型的auto变量进行release处理(引用计数-1), 如果此时对象类型的auto变量的引用计数为零, 就会被释放
       8.不论在ARC还是MRC下,栈中的block不会对捕获到的对象类型auto变量进行强引用(引用计数+1), 只会在copy到堆中时, 会对对象类型auto变量进行强引用
         ARC下, 被__weak修饰的对象类型auto变量, 在block复制到堆中时不会进行强引用
       9.block在栈上时, 并不会对__block变量产生强引用.当block被copy到堆时 a.会调用block内部的copy函数 b.copy函数内部会调用_Block_object_assign函数 c._Block_object_assign函数会对__block变量形成强引用

     */
}

#pragma mark - isa详解
void ISA() {
    /*
    1.OC中, 每一个对象都有一个isa指针
    实例对象的isa指向类对象, 类对象的isa指向元类对象, 元类对象的isa指向基类的元类对象, 基类元类对象的isa指向基类元类对象本身
    2. 在arm64架构之前，isa就是一个普通的指针，存储着Class、Meta-Class对象的内存地址
     从arm64架构开始，对isa进行了优化，变成了一个共用体（union）结构，还使用位域来存储更多的信息.想要通过isa获取类对象和元类对象的地址, 就需要使用isa & ISA_MASK
     */
    ISAOBJ *isaO = [[ISAOBJ alloc]init];
    isaO.tall = NO;
    isaO.rich = YES;
    isaO.handsome = NO;
    NSLog(@"tall= %d,rich= %d,handsome= %d",isaO.isTall,isaO.isRich,isaO.isHandsome);
}

#pragma mark - Class结构
void StructClass() {
//    Person *pn = [[Person alloc]init];
//    wr_objc_class *pnClass = (__bridge wr_objc_class*)[Person class];
//    [pn personTest];
    
    GoodStudent *person = [[GoodStudent alloc]init];
    wr_objc_class *personClass = (__bridge wr_objc_class *)[GoodStudent class];
    [person goodStudentTest];
    [person  studentTest];
    [person  personTest];
    [person goodStudentTest];
    [person  studentTest];
    
    NSLog(@"-----------");
    cache_t cache = personClass->cache;
    mask_t mask = cache._mask;
    bucket_t *buckets = cache._buckets;
    for (int i = 0; i < cache._mask+1; i++) {
        NSLog(@"%s %p",buckets[i]._key,buckets[i]._imp);
    }
    NSLog(@"-----------");
    
    // p (IMP)0x100003280
    // (IMP) $0 = 0x0000000100003280 (RunTime`-[Person(Date) personTest] at WRClass.m:102)
    NSLog(@"print index start-----------");
    int index = (long long)@selector(personTest) & mask;
    IMP imp = cache._buckets[index]._imp;
    NSLog(@"%s %p",@selector(personTest),imp);
    
    NSLog(@"print index end-----------");
    
    
    NSLog(@"%s %p",@selector(personTest),cache.imp(@selector(personTest)));
    NSLog(@"%s %p",@selector(goodStudentTest),cache.imp(@selector(goodStudentTest)));
    NSLog(@"%s %p",@selector(studentTest),cache.imp(@selector(studentTest)));
}

#pragma mark - 动态方法解析 DynamicmethodResolution
void DynamicResolution() {
    Person *p = [Person new];
//    [p dynamic];
//    [Person Cdynamic];
    
    [p test:10 height:30];
}

#pragma mark - super
void SuperClass() {
    NSLog(@"-----------");
    Student *sd = [[Student alloc]init];
    [sd run];
/*
 struct objc_super {
    __unsafe_unretained _Nonnull id receiver;       //消息接收者
    __unsafe_unretained _Nonnull Class super_class; //开始查找调用的方法
 };
 
 objc_msgSendSuper(
    (__rw_objc_super){
        (id)self,(id)class_getSuperclass(objc_getClass("Student"))
    },
    sel_registerName("run")
 );
 
 __rw_objc_super arg = {self,class_getSuperclass(objc_getClass("Student"))};
 objc_msgSendSuper(arg, sel_registerName("run"));
 
 总结: 1.super的含义是, 查询方法的起点是父类, 不是本身的类对象
      2.消息接收者是self, 不是父类对象
      3.发送的消息是调用的方法
*/
}
#pragma mark - MemberKindOfClass
void MemberKindOfClass() {
     NSLog(@"-----------");
    // 元类对象最后会通过`superclass`找到[NSObject class], 所以结果相等, 结果是1
    NSLog(@"%d", [NSObject isKindOfClass:[NSObject class]]);
    
    // objc_getClass([NSObject class]) != [NSObject class] 结果是0
    NSLog(@"%d", [NSObject isMemberOfClass:[NSObject class]]);

    // objc_getClass([Person class]) != [Person class] 结果是0
    NSLog(@"%d", [Person isKindOfClass:[Person class]]);
    
    // objc_getClass([Person class]) != [Person class] 结果是0
    NSLog(@"%d", [Person isMemberOfClass:[Person class]]);

    Class currentClass = [NSObject class];
    const char *a = object_getClassName(currentClass);
    NSLog(@"%@",objc_getClass(a));
    currentClass = object_getClass(currentClass);// 获得的是isa的指向
    NSLog(@"%@",currentClass);
    
    /*
     是将self的类方法, 与传入的Class进行对比
    - (BOOL)isMemberOfClass:(Class)cls {
        return [self class] == cls;
    }
     
    - (BOOL)isKindOfClass:(Class)cls {
        for (Class tcls = [self class]; tcls; tcls = tcls->superclass) {
            if (tcls == cls) return YES;
        }
        return NO;
        }
     
     获取了self的元类对象与传入的cls进行对比
     + (BOOL)isMemberOfClass:(Class)cls {
        return object_getClass((id)self) == cls;
     }
     
     + (BOOL)isKindOfClass:(Class)cls {
         for (Class tcls = object_getClass((id)self); tcls; tcls = tcls->superclass) {
            if (tcls == cls) return YES;
         }
         return NO;
      }
     */
   
    NSLog(@"-----------");
    Person *p = [Person new];
    p.height = 40;
    [p run];
    
    id cls = [Person class];
    void *obj = &cls;
    [(__bridge id)obj run];
    
    /*
        p调用方法的流程是: p->isa->[Person class]
        obj调用的流程与person类似. obj->cls->[Person class]
     */
}

#pragma mark - llvm中间代码
void LLVMIntermediateCode() {
    LLVMClass *vm = [[LLVMClass alloc]init];
    [vm test];
    
    /*
     我们编写OC代码, 在底层实际上转化成了llvm汇编代码, 然后在转成汇编和机器语言
     我们可以使用终端命令获取llvm中间代码
     clang -emit-llvm -S LLVMClass.m
     
     语法简介: 具体可以参考官方文档：https://llvm.org/docs/LangRef.html
     @ - 全局变量
     % - 局部变量
     alloca - 在当前执行的函数的堆栈帧中分配内存，当该函数返回到其调用者时，将自动释放内存
     i32 - 32位4字节的整数
     align - 对齐
     load - 读出，store 写入
     icmp - 两个整数值比较，返回布尔值
     br - 选择分支，根据条件来转向label，不根据条件跳转的话类似 goto
     label - 代码标签
     call - 调用函数
     */
}

#pragma mark - Runtime API
void roar(id self,SEL _cmd) {
    NSLog(@"%@ ---%@",self,NSStringFromSelector(_cmd));
}

void RunTimeAPI() {
    Person *p = [[Person alloc]init];
    [p run];
    
    object_setClass(p, [Dog class]);
    [p run];
    
    // create Tigger
    Class Tiger = objc_allocateClassPair([NSObject class], "Tiger", 0);
    class_addMethod(Tiger, @selector(roar), (IMP)roar, "v@:");
    // regisger Class
    objc_registerClassPair(Tiger);
    
    id tiger = [[Tiger alloc]init];
   // [tiger roar];
     objc_msgSend(tiger, @selector(roar));
    
   /*
    1.类
    动态创建一个类（参数：父类，类名，额外的内存空间）
    Class objc_allocateClassPair(Class superclass, const char *name, size_t extraBytes)
    
    注册一个类（要在类注册之前添加成员变量）
    void objc_registerClassPair(Class cls)
    
    销毁一个类
    void objc_disposeClassPair(Class cls)
    
    获取isa指向的Class
    Class object_getClass(id obj)
    
    设置isa指向的Class
    Class object_setClass(id obj, Class cls)
    
    判断一个OC对象是否为Class
    BOOL object_isClass(id obj)
    
    判断一个Class是否为元类
    BOOL class_isMetaClass(Class cls)
    
    获取父类
    Class class_getSuperclass(Class cls)
    
    
    2.成员变量
    获取一个实例变量信息
    Ivar class_getInstanceVariable(Class cls, const char *name)
    
    拷贝实例变量列表（最后需要调用free释放）
    Ivar *class_copyIvarList(Class cls, unsigned int *outCount)
    
    设置和获取成员变量的值
    void object_setIvar(id obj, Ivar ivar, id value)
    id object_getIvar(id obj, Ivar ivar)
    
    动态添加成员变量（已经注册的类是不能动态添加成员变量的）
    BOOL class_addIvar(Class cls, const char * name, size_t size, uint8_t alignment, const char * types)
    
    获取成员变量的相关信息
    const char *ivar_getName(Ivar v)
    const char *ivar_getTypeEncoding(Ivar v)
    
   3.属性
    获取一个属性
    objc_property_t class_getProperty(Class cls, const char *name)
    
    拷贝属性列表（最后需要调用free释放）
    objc_property_t *class_copyPropertyList(Class cls, unsigned int *outCount)
    
    动态添加属性
    BOOL class_addProperty(Class cls, const char *name, const objc_property_attribute_t *attributes,
    unsigned int attributeCount)
    
    动态替换属性
    void class_replaceProperty(Class cls, const char *name, const objc_property_attribute_t *attributes,
    unsigned int attributeCount)
    
    获取属性的一些信息
    const char *property_getName(objc_property_t property)
    const char *property_getAttributes(objc_property_t property)
    
    4.方法
    获得一个实例方法、类方法
    Method class_getInstanceMethod(Class cls, SEL name)
    Method class_getClassMethod(Class cls, SEL name)
    
    方法实现相关操作
    IMP class_getMethodImplementation(Class cls, SEL name)
    IMP method_setImplementation(Method m, IMP imp)
    void method_exchangeImplementations(Method m1, Method m2)
    
    拷贝方法列表（最后需要调用free释放）
    Method *class_copyMethodList(Class cls, unsigned int *outCount)
    
    动态添加方法
    BOOL class_addMethod(Class cls, SEL name, IMP imp, const char *types)
    
    动态替换方法
    IMP class_replaceMethod(Class cls, SEL name, IMP imp, const char *types)
    
    获取方法的相关信息（带有copy的需要调用free去释放）
    SEL method_getName(Method m)
    IMP method_getImplementation(Method m)
    const char *method_getTypeEncoding(Method m)
    unsigned int method_getNumberOfArguments(Method m)
    char *method_copyReturnType(Method m)
    char *method_copyArgumentType(Method m, unsigned int index)
    
    选择器相关
    const char *sel_getName(SEL sel)
    SEL sel_registerName(const char *str)
    
    用block作为方法实现
    IMP imp_implementationWithBlock(id block)
    id imp_getBlock(IMP anImp)
    BOOL imp_removeBlock(IMP anImp)

    */
}
