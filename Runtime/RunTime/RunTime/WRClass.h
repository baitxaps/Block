//
//  WRClass.h
//  objc
//
//  Created by William on 2016/5/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Test)
+ (void)test;
@end
@implementation NSObject (Test)
+ (void)test {
    NSLog(@"+ [NSObject test] - %p", self);
}
@end


@interface Person : NSObject
{
@public
    int _no;
    int _age;
}

@property (nonatomic, assign) int height;
+ (void)test;
- (void)personTest;
+ (void)personTests;
- (void)personInstanceMethod;
+ (void)personClassMethod;
- (void)dynamic;
+ (void)Cdynamic;
- (int)test:(int)age height:(float)height;
- (int)age:(int)age height:(float)height ;
- (void)run;
@end

@interface Person(Test)
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int weight;

- (void)personTest;
+ (void)personTests;
@end

@interface Person(Date)
- (void)personTest;
+ (void)personTests;
@end

@interface Student:Person
- (void)studentTest;
- (void)studentInstanceMethod;
+ (void)studentClassMethod;
- (void)run;
@end

@interface Student(Test)
@end

@interface Student(Date)
@end

@interface GoodStudent:Student
- (void)goodStudentTest;
@end

@interface Cat:NSObject
@property (nonatomic, assign) int weight;
@end

@interface Dog:NSObject
- (void)run;
@property (nonatomic, assign) int age;
@property (nonatomic, strong) Cat *cat;
@end

@interface kvoObj:NSObject
@property(nonatomic,strong)Person *person1;
@property(nonatomic,strong)Person *person2;

- (void)manualCallKVO ;

@end

@interface kvcObj:NSObject
{
    @public
    int _age;
    int _isAge;
    int age;
    int isAge;
}
@end

#pragma mark - ISA Class
@interface ISAOBJ:NSObject

-(void)setTall:(BOOL)tall;
-(void)setRich:(BOOL)rich;
-(void)setHandsome:(BOOL)handsome;

- (BOOL)isTall;
- (BOOL)isRich;
- (BOOL)isHandsome;

//@property (nonatomic ,assign,getter=isTall) BOOL tall;
//@property (nonatomic ,assign,getter=isRich) BOOL rich;
//@property (nonatomic ,assign,getter=isHandsome) BOOL handsome;

@end

#pragma mark - LLVM 中间代码 Test class
@interface LLVMClass:NSObject
- (void)test;
@end

NS_ASSUME_NONNULL_END
