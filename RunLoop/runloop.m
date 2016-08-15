//
//  runloop.m
//  Block
//
//  Created by hairong chen on 16/2/25.
//  Copyright © 2016年 hairong chen. All rights reserved.
//
#import "runloop.h"

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

@end
