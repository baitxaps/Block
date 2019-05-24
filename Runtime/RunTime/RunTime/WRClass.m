//
//  WRClass.m
//  objc
//
//  Created by William on 2016/5/14.
//

#import "WRClass.h"
#import <objc/runtime.h>

@implementation Person
- (void)dealloc  {
    NSLog(@"%s",__func__);
}

+ (void)load {
    NSLog(@"person -load");
}

+(void)initialize {
    NSLog(@"person -initialize");
}

- (void)personTest {
    NSLog(@"-personTest");
}

+ (void)personTests {
   NSLog(@"+personTestss");
}

- (void)personInstanceMethod{}
+ (void)personClassMethod{}

- (int)age:(int)age height:(float)height {
    NSLog(@"age = %d height= %g",age,height);
    return age+height;
}

- (void)willChangeValueForKey:(NSString *)key {
    NSLog(@"willChangeValueForKey - begin");
    [super willChangeValueForKey:key];
    NSLog(@"willChangeValueForKey - end");
}

- (void)didChangeValueForKey:(NSString *)key {
    NSLog(@"didChangeValueForKey - begin");
    [super didChangeValueForKey:key];
    NSLog(@"didChangeValueForKey - end");
}

- (void)run {
   NSLog(@" Person run %d",self.height);
}

#pragma mark - 动态方法解析
void c_func(id self,SEL _cmd) {
    NSLog(@"c_func - %@ - %@",self,NSStringFromSelector(_cmd));
}

//+ (BOOL)resolveInstanceMethod:(SEL)sel {
//    NSLog(@"%s",__FUNCTION__);
//    if (sel == @selector(dynamic)) {
//        class_addMethod(self, sel,(IMP)c_func,"v16@0:8");
// //        Method method = class_getClassMethod(self, @selector(test));// Method method = class_getInstanceMethod(self, @selector(test));
// //        class_addMethod(self, sel, method_getImplementation(method), method_getTypeEncoding(method));
//
//        return YES;
//    }
//
//    return [super resolveInstanceMethod:sel];
//}

+(BOOL)resolveClassMethod:(SEL)sel {
    if (sel == @selector(Cdynamic)) {
        class_addMethod(object_getClass(self) , sel,(IMP)c_func,"v16@0:8");
        return YES;
    }
    return [super resolveClassMethod:sel];
}

#pragma mark - 消息转发
//- (id)forwardingTargetForSelector:(SEL)aSelector {
//    if (aSelector == @selector(dynamic)) {
//        return [[Person alloc]init];// or class obj: return [Person class];
//    }
//    return [super forwardingTargetForSelector:aSelector];
//}

//-(NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
//    if (aSelector == @selector(dynamic)) {
//        return  [NSMethodSignature signatureWithObjCTypes:"v16@0:8"];
//    }
//    return [super methodSignatureForSelector:aSelector];
//}

-(NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if (aSelector == @selector(test:height:)) {
        return  [NSMethodSignature signatureWithObjCTypes:"i24@0:8i16f20"];
    }
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation*)anInvocation {
//    int age;
//    [anInvocation getArgument:&age atIndex:2];
//    float height;
//    [anInvocation getArgument:&height atIndex:3];
    
    
    int age;
    [anInvocation getArgument:&age atIndex:2];
    float height;
    [anInvocation getArgument:&height atIndex:3];
    anInvocation.selector = @selector(age:height:);// 修改发送的消息
    [anInvocation invoke];
    int result;
    [anInvocation getReturnValue:&result];
    
    NSLog(@"age = %d height= %g,result = %d",age,height,result);

}


//- (void)forwardInvocation:(NSInvocation*)anInvocation {
////    anInvocation.target = [[Person alloc]init];// 修改接收者
////    anInvocation.selector = @selector(personTest);// 修改发送的消息
////    [anInvocation invoke];// 发送消息
//
//    anInvocation.target = [Person class];// 修改接收者
//    anInvocation.selector = @selector(test);// 修改发送的消息
//    [anInvocation invoke];// 发送消息
//}

@end

@implementation Person(Test)
static const char NameKey;
static const char WeightKey;

//static const void *NameKey = &NameKey;
//static const void *WeightKey = &WeightKey;
//#define keyName @"keyName"

+ (void)load {
    NSLog(@"Person(Test) -load");
}

+(void)initialize {
    NSLog(@"Person(Test) -initialize");
}

- (void)personTest {
    NSLog(@"-Person(Test) personTest");
}

+ (void)personTests {
    NSLog(@"+Person(Test) personTests");
}

- (void)setName:(NSString *)name {
    objc_setAssociatedObject(self, &NameKey, name, OBJC_ASSOCIATION_COPY_NONATOMIC);
  //  objc_setAssociatedObject(self, NameKey, name, OBJC_ASSOCIATION_COPY_NONATOMIC);
  //  objc_setAssociatedObject(self, @selector(name), name, OBJC_ASSOCIATION_COPY_NONATOMIC);
  //  objc_setAssociatedObject(self, keyName, name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)name {
    return objc_getAssociatedObject(self, &NameKey);
}

- (void)setWeight:(int)weight {
   objc_setAssociatedObject(self, &WeightKey, @(weight), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (int)weight {
    return [objc_getAssociatedObject(self, &WeightKey) intValue];
}

@end

@implementation Person(Date)
+ (void)load {
    NSLog(@"Person(Date) -load");
}

+(void)initialize {
    NSLog(@"Person(Date) -initialize");
}

- (void)personTest {
    NSLog(@"-Person(Date) personTest");
}

+ (void)personTests {
    NSLog(@"+Person(Date) personTests");
}

@end

@implementation Student
//+ (void)load {
//    NSLog(@"Student -load");
//}
- (instancetype)init {
    self = [super init];
    if (self) {
        NSLog(@"%@",[self class]);      //Student
        NSLog(@"%@",[self superclass]); //Person
        NSLog(@"%@",[super class]);     //Student
        NSLog(@"%@",[super superclass]);//Person
    }
    return self;
/*
    objc_msgSend(self, sel_registerName("class")
    objc_msgSend(self, sel_registerName("superclass"))
    objc_msgSendSuper((__rw_objc_super){self, class_getSuperclass(objc_getClass("Student"))}, sel_registerName("class"))
    objc_msgSendSuper((__rw_objc_super){self, class_getSuperclass(objc_getClass("Student"))}, sel_registerName("superclass"))
 */
}

+(void)initialize {
    NSLog(@"Student -initialize");
}

+ (void)personTests {
    NSLog(@"+Person(Test) personTests");
}

- (void)studentTest {
     NSLog(@"%s",__func__);
}

- (void)studentInstanceMethod{}
+ (void)studentClassMethod{}

- (void)run {
    [super run];
    NSLog(@" Student run ");
}

@end

@implementation GoodStudent
- (void)goodStudentTest {
     NSLog(@"%s",__func__);
}
@end

@implementation Student(Test)
//+ (void)load {
//    NSLog(@"Student(Test) -load");
//}
+(void)initialize {
    NSLog(@"Student(Test) -initialize");
}
@end

@implementation Student(Date)
//+ (void)load {
//    NSLog(@"Student(Date) -load");
//}
+(void)initialize {
    NSLog(@"Student(Date) -initialize");
}
@end

@implementation Cat
+ (void)load {
    NSLog(@"Cat -load");
}
@end

@implementation Dog
+ (void)load {
    NSLog(@"Dog -load");
}

- (void)run {
    NSLog(@"Dog -run");
}

@end

@implementation kvoObj
void PrintMethodNamesOfClass(id obj) {
    Class cls = object_getClass(obj);
    unsigned int count;
    Method *methodList = class_copyMethodList(cls, &count);
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        Method method = methodList[i];
        NSString *methodName = NSStringFromSelector(method_getName(method));
        [array addObject:methodName];
    }
    NSLog(@"%@ - %@", cls, array);
}

- (instancetype)init {
    if (self = [super init]) {
        self.person1 = [[Person alloc]init];
        self.person2 = [[Person alloc]init];
        self.person1.height = 1;
        self.person2.height = 2;
        
        NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
        [self.person1 addObserver:self forKeyPath:@"height" options:options context:@"身高"];
        
        PrintMethodNamesOfClass(self.person1);
        PrintMethodNamesOfClass(self.person2);
    }
    return  self;
}

- (void)manualCallKVO {
    [self.person1 willChangeValueForKey:@"height"];
  //self.person1->_age = 21;
    self.person1.height = 21;
    [self.person1 didChangeValueForKey:@"height"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
}

-(void)dealloc {
    [self.person1 removeObserver:self forKeyPath:@"height"];
}
@end

@implementation kvcObj
#pragma mark - Set
- (void)setAge:(int)age {
    NSLog(@"setAge: - %d",age);
}

- (void)_setAge:(int)age {
    NSLog(@"_setAge: - %d",age);
}

#pragma mark - Get
- (int)getAge {
   NSLog(@"getAge");
    return 0;
}

- (int)age {
    NSLog(@"age");
    return 1;
}

- (int)isAge {
    NSLog(@"isAge");
    return 2;
}

- (int)_age {
    NSLog(@"_age");
    return 3;
}

+ (BOOL)accessInstanceVariablesDirectly {
    NSLog(@"accessInstanceVariablesDirectly");
    return  YES;//NO
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"setValue:-%@ forUndefinedKey:-%@",value,key);
}

- (id)valueForUndefinedKey:(NSString *)key {
    NSLog(@"valueForUndefinedKey:-%@",key);
    return @0;
}
@end

#pragma mark - ISA class implementation

#define kTallMask       (1<<0)
#define kRichMask       (1<<1)
#define kHandsomeMask   (1<<2)
@interface ISAOBJ()
{
    char _tallRichHandsome;
    
    struct {
        char tall:2;
        char rich:2;
        char handsome :2;
    }_tallRichHandsome_;//因为使用了位域,所以tall只占用第一位, rich只占用第二位, handsome只占用第三位
    
    
    union {
        char bits;
        struct {
            char tall:1;
            char rich:1;
            char handsome:1;
        };
    }_untallRichHandsome;
}
@end

@implementation ISAOBJ
//char类型在内存中只占用一个字节0b0000 0000, 可以使用最后面的三个bite位来存储tall、rich和handsome的值
- (instancetype)init {
    if (self = [super init]) {
        _tallRichHandsome = 0b00000000;
    }
    return self;
}

/*
  1.
    当tall的值是YES时, 我们将_tallRichHandsome的最低位设置为1
    当tall的值为0时, 我们需要将_tallRichHandsome的最低位设置为0, 其他位不变
    同理, rich和handsome存在第二位和第三位
  2.
    1向左位移可以获取如下的值
    1<<0 = 0b00000001
    1<<1 = 0b00000010
    1<<2 = 0b00000100
    通过取反又能获取下面的值
    ~0b00000001 = 0b111111110
    ~0b00000010 = 0b111111101
    ~0b00000100 = 0b111111011
 */
-(void)setTall:(BOOL)tall {
    if (tall) {
        //_tallRichHandsome |= (0b00000001);// 逻辑或, 只要不为1, 结果就是1
       // _tallRichHandsome |= (1<<0);
        _untallRichHandsome.bits |= kTallMask;
    }else {
       // _tallRichHandsome &= (0b11111110); // 逻辑与, 只要全是1, 结果才是1
       // _tallRichHandsome &= ~(1<<0);
        _untallRichHandsome.bits &= ~kTallMask;
    }
    
//    _tallRichHandsome_.tall = tall;
}

-(void)setRich:(BOOL)rich{
    if (rich) {
        //_tallRichHandsome |= (0b00000010);
        // _tallRichHandsome |= (1<<1);
        _untallRichHandsome.bits |= (1<<1);
    }else {
        //_tallRichHandsome &= (0b11111101);
        // _tallRichHandsome &= ~(1<<1);
        _untallRichHandsome.bits &= (1<<1);
    }
    
 //   _tallRichHandsome_.rich = rich;
}

-(void)setHandsome:(BOOL)handsome{
    if (handsome) {
       // _tallRichHandsome |= (0b00000100);
       // _tallRichHandsome |= (1<<2);
        _untallRichHandsome.bits |= (1<<2);
    }else {
       // _tallRichHandsome &= (0b11111011);
       // _tallRichHandsome &= ~(1<<2);
        _untallRichHandsome.bits &= (1<<2);
    }
    
 //   _tallRichHandsome_.handsome = handsome;
}

/*00000100
 - (BOOL)isTall方法中,将_tallRichHandsome最低位取出来,而取值,只需要将二进制数据 & 0b00000001即可.
 同理, isRich和isHandsome方法也是一样
 通过逻辑与取出的值, 每一位上如果是1, 那么结果肯定大于0, 例如0b00000001、0b00000010和0b00000100
 此时说明存的值是YES, 否则就是NO
 */
- (BOOL)isTall{
  //  return !!(_tallRichHandsome & (1<<0));// 逻辑与, 只有全是1, 结果才是1
  //  return _tallRichHandsome_.tall;
    return  !!(_untallRichHandsome.bits & (1<<0));
}

- (BOOL)isRich{
  //  return !!(_tallRichHandsome & (1<<1));
  //  return _tallRichHandsome_.rich;
    return  !!(_untallRichHandsome.bits & (1<<1));
}

- (BOOL)isHandsome{
   // return !!(_tallRichHandsome & (1<<2));//00000100 ->0->1
   // return _tallRichHandsome_.handsome;
    return  !!(_untallRichHandsome.bits & (1<<2));
}
@end


#pragma mark - LLVM 中间代码 Test class
@implementation LLVMClass
void test(int c) {
    NSLog(@"c is %d",c);
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
//    [super forwardInvocation:anInvocation];
    int a = 10;
    int b = 20;
    int c = a +b;
    test(c);
}

@end
