//
//  ViewController.m
//  RunLoop
//
//  Created by William on 2016/5/22.
//  Copyright © 2016 技术研发-IOS. All rights reserved.
//

#import "ViewController.h"
#import "WRThread.h"
#import "LockEntity.h"

@interface ViewController ()
@property (nonatomic ,strong) WRThread *thread;
@property (nonatomic ,assign) BOOL bStop;

@property (nonatomic ,strong) LockEntity *lockentity;
@property (nonatomic ,strong) PthreadTest *threadTest;

//内存管理-定时器
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) dispatch_source_t source_t;

// Tagged Pointer
@property (nonatomic, copy) NSString *name;
//@property (atomic, copy) NSString *name;

@end

@implementation ViewController

- (void)dealloc {
    NSLog(@"%s",__func__);
    [self thReadFreeEvent:nil];
    
    [self.displayLink invalidate];
    [self.timer invalidate];
}


- (void)viewDidLoad {
    [super viewDidLoad];
//   [self observerTest];
//   [self watchObserver];
//   [self theadStart];
    
    [self taggedPointerTest];
}

#pragma mark -Tagged Pointer
- (void)taggedPointerTest {
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    for (int i = 0; i < 1000; i++) {
        dispatch_async(queue, ^{
         //   self.name = [NSString stringWithFormat:@"abcdefghijklmn"];//崩溃
           self.name = [NSString stringWithFormat:@"abc"];//不会崩溃
        });
    }
    
    /*
     从64bit开始，iOS引入了Tagged Pointer技术，用于优化NSNumber、NSDate、NSString等小对象的存储
     在没有使用Tagged Pointer之前， NSNumber等对象需要动态分配内存、维护引用计数等，NSNumber指针存储的是堆中NSNumber对象的地址值
     使用Tagged Pointer之后，NSNumber指针里面存储的数据变成了: Tag + Data，也就是将数据直接存储在了指针中
     当指针不够存储数据时，才会使用动态分配内存的方式来存储数据
     
     如何判断一个指针是否为Tagged Pointer？
     iOS平台，最高有效位是1（第64bit）
     Mac平台，最低有效位是1
     
     判断一个指针是否是Tagged Pointer的源码使用的是_objc_isTaggedPointer函数
     static inline bool _objc_isTaggedPointer(const void * _Nullable ptr) {
       return ((uintptr_t)ptr & _OBJC_TAG_MASK) == _OBJC_TAG_MASK;
     }


     运行程序, 可以看到崩溃在了objc_release中
     这主要是因为在-setName:方法中, 实际的实现如下
     - (void)setName:(NSString *)name {
         if (_name != name) {
             [_name release];
             _name = [name copy];
         }
     }
    因为使用多线程赋值, 所以会有多个线程同时调用[_name release], 所以才发触发上面的崩溃
    解决的方式就是加锁, 可以使用atomic, 或者其他的锁
     
    self.name = [NSString stringWithFormat:@"abc"];
    运行程序, 上面的代码确实不会发生崩溃
    这是因为[NSString stringWithFormat:@"abc"]是一个Tagged Pointer, 在调用-setName:方法时, 底层使用的是objc_msgSend(self, @selector(setName:)
    此时就会在底层调用_objc_isTaggedPointer函数判断是否是Tagged Pointer, 如果是, 就会直接将地址赋值给_name, 没有release和copy的操作
*/
}

#pragma mark -内存管理-定时器
- (void)memoryDisplayLink {
    if (!_displayLink) {
        // _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTest)];
        //解决循环引用
        _displayLink = [CADisplayLink displayLinkWithTarget:[Proxy proxyWithTarget:self] selector:@selector(displayLinkTest)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    
    if (!_timer) {
//        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:[Proxy proxyWithTarget:self] selector:@selector(displayLinkTest) userInfo:nil repeats:YES];
        
         _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:[BWProxy proxyWithTarget:self] selector:@selector(displayLinkTest) userInfo:nil repeats:YES];
    }
   
    /*
    Proxy *proxy1 = [Proxy proxyWithTarget:self];
    BWProxy *proxy2 = [BWProxy proxyWithTarget:self];
    //proxy1的基类是NSObject, 所以打印为0
    NSLog(@"%d", [proxy1 isKindOfClass:[ViewController class]]);
    
    //proxy2实际上是进行了消息转发, 将isKindOfClass:转发给了target, 也就是ViewController, 所以打印是1
    NSLog(@"%d", [proxy2 isKindOfClass:[ViewController class]]);
    */
    
    //GCD:
    // NSTimer依赖于RunLoop，如果RunLoop的任务过于繁重，可能会导致NSTimer不准时.GCD定时器不依赖于RunLoop, 会更加的准时
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_source_t source_t = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    NSTimeInterval start = 2.0; // 2秒后执行
    NSTimeInterval interval = 1.0; // 执行间隔1秒
    // 设置定时器
    dispatch_source_set_timer(source_t,
                              dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_SEC),
                              interval * NSEC_PER_SEC,
                              0);
    // 设置回调
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(source_t, ^{
        [weakSelf displayLinkTest];
    });
    // 启动定时器
    dispatch_resume(source_t);
    self.source_t = source_t;
}

- (void)displayLinkTest {
    NSLog(@"%s", __func__);
}


#pragma mark -sThread recursive

#if 0
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_threadTest) {
        _threadTest = [[PthreadTest alloc]init];
    }
    
  //  [_threadTest recursive];
    [_threadTest pthreadTest];
}
#endif

#pragma Thread safe

#if 0
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_lockentity) {
        _lockentity = [[LockEntity alloc]init];
    }
    
//    [_lockentity moneyTest];
//    [_lockentity ticketsTest];

//    [_lockentity  pthrea_rwlock_test];
    
    [_lockentity  dispatch_barrier_async_test];
}
#endif

#pragma mark - RunLoop 线程存活
- (void)theadStart {
    __weak typeof(self)weakSelf = self;
    self.thread= [[WRThread alloc]initWithBlock:^{
    //  __strong typeof(weakSelf) strongSelf = weakSelf;
        NSLog(@"-------begin--------");
        [[NSRunLoop currentRunLoop]addPort:[[NSPort alloc]init] forMode:NSDefaultRunLoopMode];
     // [[NSRunLoop currentRunLoop]run]; // 不能释放RunLoop
        while (weakSelf && !weakSelf.bStop) {
             [[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        NSLog(@"-------end--------");
    }];
    [self.thread start];
}

#if 0
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"------");
    if (!self.thread) return;
    [self performSelector:@selector(test) onThread:self.thread withObject:nil waitUntilDone:NO];
}
#endif

- (void)test {
    NSLog(@"%s",__func__);
}

-(void)stop {
    self.bStop = YES;
    CFRunLoopStop(CFRunLoopGetCurrent());
    self.thread = nil;
    NSLog(@"%s",__func__);
}

- (IBAction)thReadFreeEvent:(id)sender {
    [self memoryDisplayLink];
    return;
   
    if (!self.thread) return;
    [self performSelector:@selector(stop) onThread:self.thread withObject:nil waitUntilDone:YES];
}


- (void)watchObserver {
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        switch (activity) {
            case kCFRunLoopEntry:
            {
                CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
                NSLog(@"kCFRunLoopEntry - %@",mode);
                CFRelease(mode);
            }
                break;
                
            case kCFRunLoopExit:
            {
                CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
                NSLog(@"kCFRunLoopExit - %@",mode);
                CFRelease(mode);
            }
                break;
                
            default:
                break;
        }
    });
    
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopCommonModes);
    CFRelease(observer);
}

- (void)observerTest {
    //监听RunLoop状态
    // void CFRunLoopAddObserver(CFRunLoopRef rl, CFRunLoopObserverRef observer, CFRunLoopMode mode);
    
    /**
     创建Observer
     @param allocator 分配器
     @param activities 需要监听的状态
     @param repeats 是否重复监听
     @param order 顺序
     @param callout 回调函数
     @param context 附加对象
     @return 创建好的Observer
     */
    //  CF_EXPORT CFRunLoopObserverRef CFRunLoopObserverCreate(CFAllocatorRef allocator, CFOptionFlags activities, Boolean repeats, CFIndex order, CFRunLoopObserverCallBack callout, CFRunLoopObserverContext *context);
    
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, runloopObserverCallBack, NULL);
    
    //    CF_EXPORT void CFRunLoopAddObserver(CFRunLoopRef rl, CFRunLoopObserverRef observer, CFRunLoopMode mode);
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopCommonModes);
    
    //    void CFRelease(CFTypeRef cf);
    CFRelease(observer);
}


//typedef void (*CFRunLoopObserverCallBack)(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info);
void runloopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
  
    switch (activity) {
        case kCFRunLoopEntry:
            NSLog(@"kCFRunLoopEntry");
            break;
        case kCFRunLoopBeforeTimers:
            NSLog(@"kCFRunLoopBeforeTimers");
            break;
        case kCFRunLoopBeforeSources:
            NSLog(@"kCFRunLoopBeforeSources");
            break;
        case kCFRunLoopBeforeWaiting:
            NSLog(@"kCFRunLoopBeforeSources");
            break;
        case kCFRunLoopAfterWaiting:
            NSLog(@"kCFRunLoopAfterWaiting");
            break;
        case kCFRunLoopExit:
            NSLog(@"kCFRunLoopExit");
            break;
        case kCFRunLoopAllActivities:
            NSLog(@"kCFRunLoopAllActivities");
            break;
            
        default:
            break;
    }
}

/*
 Source0
 触摸事件处理
 performSelector:onThread:
 
 Source1
 基于Port的线程间通信
 系统事件捕捉
 
 Timers
 NSTimer
 performSelector:withObject:afterDelay:
 
 Observers
 用于监听RunLoop的状态
 UI刷新（BeforeWaiting）
 Autorelease pool（BeforeWaiting）
 
 RunLoop运行逻辑
 01、通知Observers：进入Loop
 02、通知Observers：即将处理Timers
 03、通知Observers：即将处理Sources
 04、处理Blocks
 05、处理Source0（可能会再次处理Blocks）
 06、如果存在Source1，就跳转到第8步
 07、通知Observers：开始休眠（等待消息唤醒）
 08、通知Observers：结束休眠（被某个消息唤醒）
 01> 处理Timer
 02> 处理GCD Async To Main Queue
 03> 处理Source1
 09、处理Blocks
 10、根据前面的执行结果，决定如何操作
 01> 回到第02步
 02> 退出Loop
 11、通知Observers：退出Loop
 
 */

@end
