//
//  runloop.m
//  Block
//
//  Created by hairong chen on 16/2/25.
//  Copyright © 2016年 hairong chen. All rights reserved.
//
#import "runloop.h"
#import <pthread/pthread.h>

@interface runloop ()
@property (nonatomic,strong)NSThread *thread;
@end

@implementation runloop
//AFNetworking 中RunLoop的创建
- (void)netWorkRequestThreadEntryPoint:(id)__unused  object{
    @autoreleasepool {
        [[NSThread currentThread]setName:@"AFNetworking"];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        
        [runLoop run];
    }
}


- (NSThread *)networkRequestThread{
    static NSThread *_networkRequestThread = nil;
    static dispatch_once_t oncePreadicate;
    dispatch_once(&oncePreadicate, ^{
        _networkRequestThread = [[NSThread alloc]initWithTarget:self selector:@selector(netWorkRequestThreadEntryPoint:) object:nil];
        [_networkRequestThread start];
    });
    return _networkRequestThread;
}



//接到crash的singal 后后动重启RunLoop
- (void)restartRuningRunLoop{
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    NSArray *allModes = CFBridgingRelease(CFRunLoopCopyAllModes(runloop));
    while(1){
        for(NSString *mode in allModes){
            CFRunLoopRunInMode((CFStringRef)mode,0.001,false);
        }
    }
}


//TableView 延迟加载图片新思路
#if TARGET_OS_IPHONE
UIImageView *imageView;
- (void)delayLoadingImage{
    
    UIImage *downLoadImage = nil;
    [imageView performSelector:@selector(setImage:)
                    withObject:downLoadImage
                    afterDelay:0
                       inModes:@[NSDefaultRunLoopMode]]
}
#elif TARGET_OS_MAC
//...
#endif

- (void)content:(NSString *(^)(NSString * content))block{
    
}

//异步测试
- (void)runUnitlBlock:(BOOL(^)())block timeout:(NSTimeInterval)timeout{
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
    do{
        CFTimeInterval quantum = 0.0001;
        CFRunLoopRunInMode(kCFRunLoopDefaultMode,quantum,false);
    }while ([timeoutDate timeIntervalSinceNow]>0 &&!block()) ;
}

//异步测试升级
- (BOOL)upgradeRunUnitlBlock:(BOOL(^)())block timeout:(NSTimeInterval)timeout{
    __block Boolean fulfilled = NO;
    void(^beforeWaiting)(CFRunLoopObserverRef observer,CFRunLoopActivity activity)=
    ^(CFRunLoopObserverRef observer,CFRunLoopActivity activity){
        fulfilled = block();
        if (fulfilled) {
            CFRunLoopStop(CFRunLoopGetCurrent());
        }
    };
    
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(NULL,\
                                                                       kCFRunLoopBeforeWaiting, true, 0, beforeWaiting);
    
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    
    //run
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, timeout, false);
    CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    CFRelease(observer);
    
    return fulfilled;
}


// 创建一个观察者监听所有的事件
- (void)createObserver {
    
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(),\
                               kCFRunLoopBeforeWaiting, true, 0, ^(CFRunLoopObserverRef observeref,CFRunLoopActivity activity){
                                   NSLog(@"%ld",activity); // activity 状态
                                }
                            );
    
     CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
     CFRelease(observer);
}

 /**
   *  RunLoop 应用:
  NSTimer
  ImageView 显示
  performSelector
  常驻线程
  自动释放池
   */

- (void)createThread {
    _thread = [[NSThread alloc]initWithTarget:self selector:@selector(threadExec:) object:self];
    [_thread start];
}


- (void)threadExec:(id)obj {
    NSLog(@"======%@=====",[NSThread currentThread]);
    [[NSRunLoop currentRunLoop]addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop]run];
}


- (void)threadAgain {
    [self performSelector:@selector(threadDoOtherthing:) onThread:_thread withObject:self waitUntilDone:NO];
}


- (void)threadDoOtherthing:(id)obj {
     NSLog(@"@%s======%@===== obj = %@",__func__,[NSThread currentThread],obj);
}


// 定时器
- (void)createTimer {
    // 加个池子，当runloop在休眠之前会释放自动释放池.当runloop再启动时就会再创建池子
    // __weak typeof(self)weakSelf = self;
    @autoreleasepool {
       // 定时器生效的方式，一定要保证runloop开启且mode不为空
        NSTimer *timer = [NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(timerExec:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:timer forMode: NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop]run];
    }
}

- (void)timerExec:(id)obj {
    NSLog(@"%s",__func__);
}



//  加锁 @synchronized、NSLock、dispatch_semaphore、NSCondition、pthread_mutex、OSSpinLock

/**
 * http://blog.csdn.net/qq342261733/article/details/51896745
 synchronized
 @synchronized(obj)指令使用的obj为该锁的唯一标识，只有当标识相同时，才为满足互斥，
 如果线程2中的@synchronized(obj)改为@synchronized(self),刚线程2就不会被阻塞，
 @synchronized指令实现锁的优点就是我们不需要在代码中显式的创建锁对象，便可以实现锁的机制，
 但作为一种预防措施，@synchronized块会隐式的添加一个异常处理例程来保护代码，
 该处理例程会在异常抛出的时候自动的释放互斥锁。所以如果不想让隐式的异常处理例程带来额外的开销，你可以考虑使用锁对象
 */
- (void)chonized {
    NSObject *obj = [[NSObject alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized(obj) {
            NSLog(@"需要线程同步的操作1 开始");
            sleep(3);
            NSLog(@"需要线程同步的操作1 结束");
        }
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        @synchronized(obj) {
            NSLog(@"需要线程同步的操作2");
        }
    });
}
/**
 *  dispatch_semaphore是GCD用来同步的一种方式，与他相关的共有三个函数，分别是dispatch_semaphore_create，dispatch_semaphore_signal，dispatch_semaphore_wait。
 
 （1）dispatch_semaphore_create的声明为：
 
 　　dispatch_semaphore_t dispatch_semaphore_create(long value);
 
 　　传入的参数为long，输出一个dispatch_semaphore_t类型且值为value的信号量。
 
 　　值得注意的是，这里的传入的参数value必须大于或等于0，否则dispatch_semaphore_create会返回NULL。
 
 （2）dispatch_semaphore_signal的声明为：
 
 　　long dispatch_semaphore_signal(dispatch_semaphore_t dsema)
 
 　　这个函数会使传入的信号量dsema的值加1；
 
 (3) dispatch_semaphore_wait的声明为：
 
 　　long dispatch_semaphore_wait(dispatch_semaphore_t dsema, dispatch_time_t timeout)；
 
 　　这个函数会使传入的信号量dsema的值减1；这个函数的作用是这样的，如果dsema信号量的值大于0，该函数所处线程就继续执行下面的语句，并且将信号量的值减1；如果desema的值为0，那么这个函数就阻塞当前线程等待timeout（注意timeout的类型为dispatch_time_t，不能直接传入整形或float型数），如果等待的期间desema的值被dispatch_semaphore_signal函数加1了，且该函数（即dispatch_semaphore_wait）所处线程获得了信号量，那么就继续向下执行并将信号量减1。如果等待期间没有获取到信号量或者信号量的值一直为0，那么等到timeout时，其所处线程自动执行其后语句。
 
 dispatch_semaphore 是信号量，但当信号总量设为 1 时也可以当作锁来。在没有等待情况出现时，它的性能比 pthread_mutex 还要高，但一旦有等待情况出现时，性能就会下降许多。相对于 OSSpinLock 来说，它的优势在于等待时不会消耗 CPU 资源。
 
 如上的代码，如果超时时间overTime设置成>2，可完成同步操作。如果overTime<2的话，在线程1还没有执行完成的情况下，此时超时了，将自动执行下面的代码。
 */
- (void)semaphore {
    dispatch_semaphore_t signal = dispatch_semaphore_create(1);
    dispatch_time_t overTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(signal, overTime);
        NSLog(@"需要线程同步的操作1 开始");
        sleep(2);
        NSLog(@"需要线程同步的操作1 结束");
        dispatch_semaphore_signal(signal);
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        dispatch_semaphore_wait(signal, overTime);
        NSLog(@"需要线程同步的操作2");
        dispatch_semaphore_signal(signal);
    });
}

/**
 *  NSLock是Cocoa提供给我们最基本的锁对象，这也是我们经常所使用的，除lock和unlock方法外，NSLock还提供了tryLock和lockBeforeDate:两个方法，前一个方法会尝试加锁，如果锁不可用(已经被锁住)，刚并不会阻塞线程，并返回NO。lockBeforeDate:方法会在所指定Date之前尝试加锁，如果在指定时间之前都不能加锁，则返回NO。
 */
- (void)nslock {
    NSLock *lock = [[NSLock alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //[lock lock];
        [lock lockBeforeDate:[NSDate date]];
        NSLog(@"需要线程同步的操作1 开始");
        sleep(2);
        NSLog(@"需要线程同步的操作1 结束");
        [lock unlock];
        
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        if ([lock tryLock]) {//尝试获取锁，如果获取不到返回NO，不会阻塞该线程
            NSLog(@"锁可用的操作");
            [lock unlock];
        }else{
            NSLog(@"锁不可用的操作");
        }
        
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:3];
        if ([lock lockBeforeDate:date]) {//尝试在未来的3s内获取锁，并阻塞该线程，如果3s内获取不到恢复线程, 返回NO,不会阻塞该线程
            NSLog(@"没有超时，获得锁");
            [lock unlock];
        }else{
            NSLog(@"超时，没有获得锁");
        }
        
    });
}


/**
 *  NSRecursiveLock实际上定义的是一个递归锁，这个锁可以被同一线程多次请求，而不会引起死锁。
 这主要是用在循环或递归操作中。
 
 这段代码是一个典型的死锁情况。在我们的线程中，RecursiveMethod是递归调用的。所以每次进入这个block时，都会去加一次锁，而从第二次开始，由于锁已经被使用了且没有解锁，所以它需要等待锁被解除，这样就导致了死锁，线程被阻塞住了。调试器中会输出如下信息：
 
value = 5
[NSLock lock]: deadlock (<NSLock: 0x7fd811d28810> '(null)')
 Break on _NSLockError() to debug.
 
 在这种情况下，我们就可以使用NSRecursiveLock。它可以允许同一线程多次加锁，而不会造成死锁。递归锁会跟踪它被lock的次数。每次成功的lock都必须平衡调用unlock操作。只有所有达到这种平衡，锁最后才能被释放，以供其它线程使用。
 
 如果我们将NSLock代替为NSRecursiveLock，上面代码则会正确执行
 */
- (void)recursiveLock {
    NSRecursiveLock *lock = [[NSRecursiveLock alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static void (^RecursiveMethod)(int);
        RecursiveMethod = ^(int value) {
            [lock lock];
            if (value > 0) {
                
                NSLog(@"value = %d", value);
                sleep(1);
                RecursiveMethod(value - 1);
            }
            [lock unlock];
        };
        
        RecursiveMethod(5);
    });
}

/**
 *  当我们在使用多线程的时候，有时一把只会lock和unlock的锁未必就能完全满足我们的使用。因为普通的锁只能关心锁与不锁，而不在乎用什么钥匙才能开锁，而我们在处理资源共享的时候，多数情况是只有满足一定条件的情况下才能打开这把锁：
 
 在线程1中的加锁使用了lock，所以是不需要条件的，所以顺利的就锁住了，但在unlock的使用了一个整型的条件，它可以开启其它线程中正在等待这把钥匙的临界地，而线程2则需要一把被标识为2的钥匙，所以当线程1循环到最后一次的时候，才最终打开了线程2中的阻塞。但即便如此，NSConditionLock也跟其它的锁一样，是需要lock与unlock对应的，只是lock,lockWhenCondition:与unlock，unlockWithCondition:是可以随意组合的，当然这是与你的需求相关的。
 */
- (void)condtionLock {
    NSMutableArray *products = [NSMutableArray array];
    
    NSInteger HAS_DATA = 1;
    NSInteger NO_DATA = 0;
    NSConditionLock *lock = [[NSConditionLock alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (1) {
            [lock lockWhenCondition:NO_DATA];
            [products addObject:[[NSObject alloc] init]];
            NSLog(@"produce a product,总量:%zi",products.count);
            [lock unlockWithCondition:HAS_DATA];
            sleep(1);
        }
        
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (1) {
            NSLog(@"wait for product");
            [lock lockWhenCondition:HAS_DATA];
            [products removeObjectAtIndex:0];
            NSLog(@"custome a product");
            [lock unlockWithCondition:NO_DATA];
        }
        
    });
}


/**
 *  一种最基本的条件锁。手动控制线程wait和signal。
 
 [condition lock];一般用于多线程同时访问、修改同一个数据源，保证在同一时间内数据源只被访问、修改一次，
 其他线程的命令需要在lock 外等待，只到unlock ，才可访问
 [condition unlock];与lock 同时使用
 [condition wait];让当前线程处于等待状态
 [condition signal];CPU发信号告诉线程不用在等待，可以继续执行
 */
- (void)nsconditon {
    NSCondition *condition = [[NSCondition alloc] init];
    
    NSMutableArray *products = [NSMutableArray array];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (1) {
            [condition lock];
            if ([products count] == 0) {
                NSLog(@"wait for product");
                [condition wait];
            }
            [products removeObjectAtIndex:0];
            NSLog(@"custome a product");
            [condition unlock];
        }
        
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (1) {
            [condition lock];
            [products addObject:[[NSObject alloc] init]];
            NSLog(@"produce a product,总量:%zi",products.count);
            [condition signal];
            [condition unlock];
            sleep(1);
        }
        
    });
}


/**
 *  c语言定义下多线程加锁方式。
 1：pthread_mutex_init(pthread_mutex_t mutex,const pthread_mutexattr_t attr);
 初始化锁变量mutex。attr为锁属性，NULL值为默认属性。
 2：pthread_mutex_lock(pthread_mutex_t mutex);加锁
 3：pthread_mutex_tylock(*pthread_mutex_t *mutex);加锁，但是与2不一样的是当锁已经在使用的时候，返回为EBUSY，而不是挂起等待。
 4：pthread_mutex_unlock(pthread_mutex_t *mutex);释放锁
 5：pthread_mutex_destroy(pthread_mutex_t* mutex);使用完后释放
 */
- (void)pthreadMutex {
    __block pthread_mutex_t theLock;
    pthread_mutex_init(&theLock, NULL);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        pthread_mutex_lock(&theLock);
        NSLog(@"需要线程同步的操作1 开始");
        sleep(3);
        NSLog(@"需要线程同步的操作1 结束");
        pthread_mutex_unlock(&theLock);
        
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        pthread_mutex_lock(&theLock);
        NSLog(@"需要线程同步的操作2");
        pthread_mutex_unlock(&theLock);
        
    });
}

/**
 *  这是pthread_mutex为了防止在递归的情况下出现死锁而出现的递归锁。作用和NSRecursiveLock递归锁类似。
 如果使用pthread_mutex_init(&theLock, NULL);初始化锁的话，上面的代码会出现死锁现象。如果使用递归锁的形式，则没有问题。
 */
- (void)pthreadMutexrecusive {
    __block pthread_mutex_t theLock;
    //pthread_mutex_init(&theLock, NULL);
    
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
   // pthread_mutex_init(&lock, &attr);
    pthread_mutexattr_destroy(&attr);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        static void (^RecursiveMethod)(int);
        
        RecursiveMethod = ^(int value) {
            
            pthread_mutex_lock(&theLock);
            if (value > 0) {
                
                NSLog(@"value = %d", value);
                sleep(1);
                RecursiveMethod(value - 1);
            }
            pthread_mutex_unlock(&theLock);
        };
        
        RecursiveMethod(5);
    });
}


/**
 *  OSSpinLock 自旋锁，性能最高的锁。原理很简单，就是一直 do while 忙等。
 它的缺点是当等待时会消耗大量 CPU 资源，所以它不适用于较长时间的任务。 
 不过最近YY大神在自己的博客不再安全的 OSSpinLock中说明了OSSpinLock已经不再安全，请大家谨慎使用。
 */
- (void)oSSpinLock {
    __block OSSpinLock theLock = OS_SPINLOCK_INIT;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OSSpinLockLock(&theLock);
        NSLog(@"需要线程同步的操作1 开始");
        sleep(3);
        NSLog(@"需要线程同步的操作1 结束");
        OSSpinLockUnlock(&theLock);
        
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OSSpinLockLock(&theLock);
        sleep(1);
        NSLog(@"需要线程同步的操作2");
        OSSpinLockUnlock(&theLock);
        
    });
}


/**
 *  三、性能对比
 对以上各个锁进行1000000此的加锁解锁的空操作时间如下：
 OSSpinLock: 46.15 ms
 dispatch_semaphore: 56.50 ms
 pthread_mutex: 178.28 ms
 NSCondition: 193.38 ms
 NSLock: 175.02 ms
 pthread_mutex(recursive): 172.56 ms
 NSRecursiveLock: 157.44 ms
 NSConditionLock: 490.04 ms
 @synchronized: 371.17 ms
 
 总的来说：
 
 OSSpinLock和dispatch_semaphore的效率远远高于其他。
 
 @synchronized和NSConditionLock效率较差。
 
 鉴于OSSpinLock的不安全，所以我们在开发中如果考虑性能的话，建议使用dispatch_semaphore。
 
 如果不考虑性能，只是图个方便的话，那就使用@synchronized。
 */

@end
