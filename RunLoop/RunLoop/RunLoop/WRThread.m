//
//  WRThread.m
//  RunLoop
//
//  Created by William on 2016/5/22.
//  Copyright © 2016 技术研发-IOS. All rights reserved.
//

#import "WRThread.h"
#import <pthread.h>

#define kPthreadConfig 0

@implementation WRThread

- (void)dealloc {
    NSLog(@"%s",__func__);
}

@end


@interface PthreadTest ()

@property (nonatomic ,assign) pthread_mutex_t mutexLock;
@property (nonatomic ,strong) NSMutableArray *array;
@property (nonatomic ,assign) pthread_cond_t cond;

//NSLock、NSRecursiveLock、NSCondition和NSConditionLock是基于pthread封装的OC对象
//@property (nonatomic ,strong) NSRecursiveLock *lock;
@property (nonatomic ,strong) NSConditionLock *lock;
@property (nonatomic ,strong) NSCondition *condition;

@end

@implementation PthreadTest

- (instancetype)init {
    if (self = [super init]) {
#if kPthreadConfig
        [self __addPthread:&_mutexLock];
        _array = [NSMutableArray array];
#else
        self.condition = [[NSCondition alloc]init];
        _array = [NSMutableArray array];
#endif
        
//      self.lock = [[NSRecursiveLock alloc]init];
        self.lock = [[NSConditionLock alloc]initWithCondition:1];
    }
    return self;
}

- (void)__addPthread:(pthread_mutex_t *)pthread {
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    //递归锁允许同一线程内, 对同一把锁进行重复加锁
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);// PTHREAD_MUTEX_DEFAULT
    
    pthread_mutex_init(pthread, &attr);
    pthread_mutexattr_destroy(&attr);
    
    pthread_cond_init(&_cond, NULL);//使用条件对两个方法__remove,__add进行优化
}

/*
 当array.count == 0时, 是程序进入休眠, 只有当array中添加了新数据后在发起信号, 将休眠的线程唤醒
  运行程序, 点击屏幕, 可以看到程序先进入__remove方法, 但是却在__add中添加新元素之后再移除元素
 */
- (void)__remove {
#if kPthreadConfig
    pthread_mutex_lock(&_mutexLock);
    NSLog(@"%s",__func__);
    if (_array.count == 0) {
        pthread_cond_wait(&_cond, &_mutexLock);
    }
    NSLog(@"删除一个元素 count=%ld",_array.count);
    [_array removeLastObject];
    pthread_mutex_unlock(&_mutexLock);
#else
    [self.condition lock];
    NSLog(@"%s",__func__);
    if (_array.count == 0) {
        [self.condition wait];
    }
    NSLog(@"删除一个元素 count=%ld",_array.count);
    [_array removeLastObject];
    [self.condition unlock];
#endif
}

- (void)__add {
#if kPthreadConfig
    pthread_mutex_lock(&_mutexLock);
    NSLog(@"%s",__func__);
    [_array addObject:@"self"];
    NSLog(@"增加一个元素 count=%ld",_array.count);
    pthread_cond_signal(&_cond);//当array中添加了新数据后在发起信号, 将休眠的线程唤醒
    pthread_mutex_unlock(&_mutexLock);
#else
    [self.condition lock];
    NSLog(@"%s",__func__);
    [_array addObject:@"self"];
    NSLog(@"增加一个元素 count=%ld",_array.count);
    [self.condition signal];//当array中添加了新数据后在发起信号, 将休眠的线程唤醒
    [self.condition unlock];
#endif
}

- (void)__one {
    [self.lock lockWhenCondition:1];//只有NSConditionLock实例中的condition值与传入的condition值相等时, 才能加锁
    NSLog(@"------one-------");
    [self.lock unlockWithCondition:2];//解锁, 同时设置NSConditionLock实例中的condition值
}

- (void)__two {
    [self.lock lockWhenCondition:2];
    NSLog(@"------two-------");
    [self.lock unlockWithCondition:3];
}

- (void)__three {
    [self.lock lockWhenCondition:3];
    NSLog(@"------three-------");
    [self.lock unlock];
}

- (void)pthreadTest {
//    [[[NSThread alloc]initWithTarget:self selector:@selector(__remove) object:nil]start];
//    [[[NSThread alloc]initWithTarget:self selector:@selector(__add) object:nil]start];
  
 //   可以使用NSConditionLock设置线程的执行顺序
    [[[NSThread alloc]initWithTarget:self selector:@selector(__three) object:nil]start];
    [[[NSThread alloc]initWithTarget:self selector:@selector(__two) object:nil]start];
    [[[NSThread alloc]initWithTarget:self selector:@selector(__one) object:nil]start];
}

- (void)recursive {
//    pthread_mutex_lock(&_mutexLock);
//    static int count = 0;
//    NSLog(@"%d---%@",count,[NSThread currentThread]);
//    if (count < 10) {
//        count ++;
//        [self recursive];
//    }
//    pthread_mutex_unlock(&_mutexLock);
    
    [self.lock lock];
    static int count = 0;
    NSLog(@"%d---%@",count,[NSThread currentThread]);
    if (count < 10) {
        count ++;
        [self recursive];
    }
    [self.lock unlock];
}

- (void)atomicInfo {
    self.array = [NSMutableArray array];
    //等价于[self setArray:[NSMutableArray array]];只有setter方法内部才是安全的
    
    //等价于[self array]只有getter方法才是安全的, 使用datas 的时候，并不能保证安全性
    NSMutableArray *array = self.array;
    
    [array addObject:@1];
}

@end
