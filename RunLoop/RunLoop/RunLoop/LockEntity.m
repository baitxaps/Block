//
//  LockEntity.m
//  RunLoop
//
//  Created by William on 2016/5/23.
//  Copyright © 2016 技术研发-IOS. All rights reserved.
//

#import "LockEntity.h"
#import <libkern/OSAtomic.h>

#import <os/lock.h>
#import <pthread.h>

@interface LockEntity ()
//@property (nonatomic ,assign) OSSpinLock moneyLock;
//@property (nonatomic ,assign) OSSpinLock ticketLock;

//@property (nonatomic ,assign) os_unfair_lock moneyLock;
//@property (nonatomic ,assign) os_unfair_lock ticketLock;

//@property (nonatomic ,assign) pthread_mutex_t moneyLock;
//@property (nonatomic ,assign) pthread_mutex_t ticketLock;

//@property (nonatomic ,strong) NSLock *moneyLock;
//@property (nonatomic ,strong) NSLock *ticketLock;

//@property (nonatomic ,strong) dispatch_queue_t moneyQueue;
//@property (nonatomic ,strong) dispatch_queue_t ticketQueue;

@property (nonatomic ,strong) dispatch_semaphore_t moneySemaphore;
@property (nonatomic ,strong) dispatch_semaphore_t ticketSemaphore;

@property (nonatomic ,assign) pthread_rwlock_t rwlock;

@property (nonatomic ,strong) dispatch_queue_t  queue;

@end

@implementation LockEntity

- (void)dealloc {
//    pthread_mutex_destroy(&_moneyLock);
//    pthread_mutex_destroy(&_ticketLock);
}

- (instancetype)init {
    if (self = [super init]) {
//        _moneyLock = OS_SPINLOCK_INIT;
//        _ticketLock = OS_SPINLOCK_INIT;
        
//        _moneyLock = OS_UNFAIR_LOCK_INIT;
//        _ticketLock = OS_UNFAIR_LOCK_INIT;
    
//        [self __addPthread:&_moneyLock];
//        [self __addPthread:&_ticketLock];
        
//        self.moneyLock = [[NSLock alloc]init];
//        self.ticketLock = [[NSLock alloc]init];
        
//        self.moneyQueue = dispatch_queue_create("moneyQueue", DISPATCH_QUEUE_SERIAL);
//        self.ticketQueue = dispatch_queue_create("moneyQueue", DISPATCH_QUEUE_SERIAL);
        
        self.moneySemaphore = dispatch_semaphore_create(1);
        self.ticketSemaphore = dispatch_semaphore_create(1);
        
        pthread_rwlock_init(&_rwlock, NULL);
        
        self.queue  = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)__addPthread:(pthread_mutex_t *)pthread {
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_DEFAULT);
    
    pthread_mutex_init(pthread, &attr);
    pthread_mutexattr_destroy(&attr);
}

- (void)__saveMoney {
//    OSSpinLockLock(&_moneyLock);
//    [super __saveMoney];
//    OSSpinLockUnlock(&_moneyLock);
    
//    os_unfair_lock_lock(&_moneyLock);
//    [super __saveMoney];
//    os_unfair_lock_unlock(&_moneyLock);
    
//    pthread_mutex_lock(&_moneyLock);
//    [super __saveMoney];
//    pthread_mutex_unlock(&_moneyLock);
    
//    [self.moneyLock lock];
//    [super __saveMoney];
//    [self.moneyLock unlock];
    
//    dispatch_sync(self.moneyQueue, ^{
//        [super __saveMoney];
//    });
    
//    dispatch_semaphore_wait(self.moneySemaphore, DISPATCH_TIME_FOREVER);
//    [super __saveMoney];
//    dispatch_semaphore_signal(self.moneySemaphore);
    
    @synchronized (self) {
        [super __saveMoney];
    }

}

- (void)__drayMoney {
//    OSSpinLockLock(&_moneyLock);
//    [super __drayMoney];
//    OSSpinLockUnlock(&_moneyLock);
    
//    os_unfair_lock_lock(&_moneyLock);
//    [super __drayMoney];
//    os_unfair_lock_unlock(&_moneyLock);
    
//    pthread_mutex_lock(&_moneyLock);
//    [super __drayMoney];
//    pthread_mutex_unlock(&_moneyLock);
    
//    [self.moneyLock lock];
//    [super __drayMoney];
//    [self.moneyLock unlock];
    
//    dispatch_sync(self.moneyQueue, ^{
//        [super __drayMoney];
//    });
    
//    dispatch_semaphore_wait(self.moneySemaphore, DISPATCH_TIME_FOREVER);
//    [super __drayMoney];
//    dispatch_semaphore_signal(self.moneySemaphore);
    
    @synchronized (self) {
        [super __drayMoney];
    }
}


- (void)__sellingTickets {
//    OSSpinLockLock(&_moneyLock);
//    [super __sellingTickets];
//    OSSpinLockUnlock(&_moneyLock);
    
//    os_unfair_lock_lock(&_moneyLock);
//    [super __sellingTickets];
//    os_unfair_lock_unlock(&_moneyLock);
    
//    pthread_mutex_lock(&_ticketLock);
//    [super __sellingTickets];
//    pthread_mutex_unlock(&_ticketLock);
    
//    [self.ticketLock lock];
//    [super __sellingTickets];
//    [self.ticketLock unlock];
    
//    dispatch_sync(self.ticketQueue, ^{
//        [super __sellingTickets];
//    });
    
//    dispatch_semaphore_wait(self.ticketSemaphore, DISPATCH_TIME_FOREVER);
//    [super __sellingTickets];
//    dispatch_semaphore_signal(self.ticketSemaphore);
    
    static NSObject *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        obj = [[NSObject alloc]init];
    });
    @synchronized (obj) {
        [super __sellingTickets];
    }
}

#pragma pthread_rwlock 读写锁
- (void)pthrea_rwlock_test {
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i< 10; i ++) {
        dispatch_async(queue, ^{
            [self __read];
        });
        
        dispatch_async(queue, ^{
            [self __write];
        });
    }
}

- (void)__read {
    pthread_rwlock_rdlock(&_rwlock);
    sleep(0.2);
    NSLog(@"读取文件 - %@",[NSThread currentThread]);
    pthread_rwlock_unlock(&_rwlock);
}

- (void)__write {
    pthread_rwlock_wrlock(&_rwlock);
    sleep(0.2);
    NSLog(@"写文件 - %@",[NSThread currentThread]);
    pthread_rwlock_unlock(&_rwlock);
}

#pragma dispatch_barrier_async
- (void)dispatch_barrier_async_test {
    for (int i = 0; i <10; i++) {
        [self barr_read];
        [self barr_read];
        [self barr_read];
        [self barr_write];
    }
}

- (void)barr_read {
    dispatch_async(self.queue, ^{
        sleep(0.1);
        NSLog(@"读取文件 - %@",[NSThread currentThread]);
    });
}

- (void)barr_write {
    dispatch_async(self.queue, ^{
        sleep(0.1);
        NSLog(@"写文件 - %@",[NSThread currentThread]);
    });
}

@end

/*
 OS中的线程同步方案
 OSSpinLock:自旋锁，等待锁的线程会处于忙等（busy-wait）状态，一直占用着CPU资源
 os_unfair_lock
 pthread_mutex
 dispatch_semaphore
 dispatch_queue(DISPATCH_QUEUE_SERIAL)
 NSLock
 NSRecursiveLock
 NSCondition:封装了cond和mutex
 NSConditionLock:对NSCondition的进一步封装
 @synchronized:对mutex递归锁的封装
 (NSLock、NSRecursiveLock、NSCondition和NSConditionLock是基于pthread封装的OC对象)
 */

/*
 1.
 OSSpinLock(自旋锁)：
 假设通过OSSpinLock给两个线程`thread1`和`thread2`加锁
 thread优先级高, thread2优先级低
 如果thread2先加锁, 但是还没有解锁, 此时CPU切换到`thread1`
 因为`thread1`的优先级高, 所以CPU会更多的给`thread1`分配资源, 这样每次`thread1`中遇到`OSSpinLock`都处于使用状态
 此时`thread1`就会不停的检测`OSSpinLock`是否解锁, 就会长时间的占用CPU
 这样就会出现类似于死锁的问题
 
 2.
 os_unfair_lock(互斥锁):
 os_unfair_lock lock = OS_UNFAIR_LOCK_INIT; 初始化
 os_unfair_lock_trylock(&lock);尝试加锁, 如果lcok已经被使用, 加锁失败返回false, 如果加锁成功, 返回true
 os_unfair_lock_lock(&lock);加锁
 os_unfair_lock_unlock(&lock); 解锁
 
 3.
 pthread_mutex(做互斥锁):等待锁的线程会处于休眠状态
 初始化属性
 pthread_mutexattr_t attr;
 pthread_mutexattr_init(&attr);
 pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_DEFAULT);
 初始化锁
 pthread_mutex_t pthread;
 pthread_mutex_init(&pthread, &attr);
 pthread_mutexattr_destroy(&attr);销毁属性
 pthread_mutex_destroy(&pthread);销毁锁
 属性类型的取值
 #define PTHREAD_MUTEX_NORMAL        0
 #define PTHREAD_MUTEX_ERRORCHECK    1
 #define PTHREAD_MUTEX_RECURSIVE     2
 #define PTHREAD_MUTEX_DEFAULT       PTHREAD_MUTEX_NORMAL

 4.
 NSCondition:查看GNUStep中关于NSCondition的底层代码

 5.
 NSConditionLock:NSConditionLock是对NSCondition的进一步封装,可以使用NSConditionLock设置线程的执行顺序.查看GNUStep中关于NSRecursiveLock的底层代码
 - (instancetype)initWithCondition:(NSInteger)condition; // 初始化, 同时设置 condition
 @property (readonly) NSInteger condition;//condition值
 // 只有NSConditionLock实例中的condition值与传入的condition值相等时, 才能加锁
 - (void)lockWhenCondition:(NSInteger)condition;
 - (BOOL)tryLock; // 尝试加锁
 // 尝试加锁, 只有NSConditionLock实例中的condition值与传入的condition值相等时, 才能加锁
 - (BOOL)tryLockWhenCondition:(NSInteger)condition;
 // 解锁, 同时设置NSConditionLock实例中的condition值
 - (void)unlockWithCondition:(NSInteger)condition;
 // 加锁, 如果锁已经使用, 那么一直等到limit为止, 如果过时, 不会加锁
 - (BOOL)lockBeforeDate:(NSDate *)limit;
 // 加锁, 只有NSConditionLock实例中的condition值与传入的condition值相等时, 才能加锁, 时间限制到limit, 超时加锁失败
 - (BOOL)lockWhenCondition:(NSInteger)condition beforeDate:(NSDate *)limit;
 @property (nullable, copy) NSString *name;// 锁的name

 6.
 dispatch_semaphore_t:
 可以使用dispatch_semaphore_t设置信号量为1, 来控制同意之间只有一条线程能执行
 
 7.
 @synchronized底层原理:
 找到objc_sync_enter和objc_sync_exit两个函数, 分别用于加锁和解锁
 
 8.
 atomic:原子锁只能保证setter和getter内部的区域是安全的, 但是外部使用的时候就没办法保证,底层用的是os_unfair_lock锁
 atomic用于保证属性setter、getter的原子性操作，相当于在getter和setter内部加了线程同步的锁
 可以参考源码objc4的objc-accessors.mm,它并不能保证使用属性的过程是线程安全的
 
 8.1
 文件的读写安全:
 同一时间，只能有1个线程进行写的操作
 同一时间，允许有多个线程进行读的操作
 同一时间，不允许既有写的操作，又有读的操作
 上面的场景就是典型的多读单写，经常用于文件等数据的读写操作，iOS中的实现方案有
 pthread_rwlock：读写锁
 dispatch_barrier_async：异步栅栏调用
 
 pthread_rwlock API:
 pthread_rwlock_t rwlock;//定义读写锁
 pthread_rwlock_init(&rwlock, NULL);// 初始化读写锁
 pthread_rwlock_rdlock(&rwlock); // 读取加锁
 pthread_rwlock_tryrdlock(&rwlock); // 尝试读取加锁
 pthread_rwlock_wrlock(&rwlock); // 写入加锁
 pthread_rwlock_trywrlock(&rwlock); // 尝试写入加锁
 pthread_rwlock_unlock(&rwlock); // 解锁
 pthread_rwlock_destroy(&rwlock);// 销毁读写锁

 这个函数传入的并发队列必须是自己通过dispatch_queue_cretate创建的
 如果传入的是一个串行或是一个全局的并发队列，那这个函数便等同于dispatch_async函数的效果
 
 9.
 性能从高到低排序
 os_unfair_lock
 OSSpinLock
 dispatch_semaphore
 pthread_mutex
 dispatch_queue(DISPATCH_QUEUE_SERIAL)
 NSLock
 NSCondition
 pthread_mutex(recursive)
 NSRecursiveLock
 NSConditionLock
 @synchronized
 
 10.
 自旋锁、互斥锁比较:
 什么情况使用自旋锁比较划算？
 预计线程等待锁的时间很短
 加锁的代码（临界区）经常被调用，但竞争情况很少发生
 CPU资源不紧张
 多核处理器
 
 什么情况使用互斥锁比较划算？
 预计线程等待锁的时间较长
 单核处理器
 临界区有IO操作
 临界区代码复杂或者循环量大
 临界区竞争非常激烈
 
 */
