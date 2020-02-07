//
//  ViewController.m
//  Pthread
//
//  Created by hairong chen on 2016/1/1.
//  Copyright © 2016 hairong chen. All rights reserved.
//

#import <pthread/pthread.h>
#import <Foundation/Foundation.h>

@interface Pthread : NSObject
- (void)execPthread;
@end

@interface Pthread ()
@property(nonatomic,assign) NSInteger tks;
@property(nonatomic,strong) NSMutableArray *strings;
@property(nonatomic,strong) dispatch_queue_t barrierqueue ;
@end

@implementation Pthread

- (void)execPthread {
 
    //新建 就绪 运行 阻塞 死亡
    
    // waitUntilDone:YES 等待方法之行完毕，才会执行后续代码
//    [self performSelectorOnMainThread:@selector(setTks:)
//                           withObject:@(10)
//                        waitUntilDone:YES ];
//    for (int i =0; i<=10; i++)NSLog(@"%02d",i);
    
//   [self queueBarrier];
    [self GCDThead];
}

@synthesize tks = _tks;

-(NSInteger)tks {
    @synchronized (self) {
        return _tks;
    }
}

- (void)setTks:(NSInteger)tks {
    @synchronized (self) {
        _tks = tks;
    }
}

- (NSMutableArray *)strings {
    if (!_strings) {
        _strings = [[NSMutableArray alloc]init];
    }
    return _strings;
}

//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
////    self.tks = 10;
////    NSThread *th1 = [[NSThread alloc]initWithTarget:self selector:@selector(sellTickets) object:nil];
////    [th1 start];
////    NSThread *th2 = [[NSThread alloc]initWithTarget:self selector:@selector(sellTickets) object:nil];
////    [th2 start];

//
////    [self GCDThead];
//
//    [self nsoperation];
//    NSLog(@"self.strings.count = %zd",self.strings.count);
//}

- (void)nsoperation {
    // 1. NSInvocationOperation
    NSInvocationOperation *op =[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(queueSerial) object:nil];
    // [op start]; // 更新操作状态，调用main方法，不开启新的线程
    
    // 2.NSoperationQueue 开启子线程
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperation:op];
    
    // 3 NSBlockOperation
//    NSBlockOperation *opblock = [NSBlockOperation blockOperationWithBlock:^{
//        NSLog(@"%@",[NSThread currentThread]);
//    }];
//  [opblock start];//更新OP操作状态,调用main方法，不开启新的线程
    
    //4 开启子线程
    // NSOperationQueue *opblockqueue = [[NSOperationQueue alloc]init];
    // [opblockqueue addOperation:op];
    
    // 5. 并发队列 异步执行
    NSOperationQueue *opblockqueue = [[NSOperationQueue alloc]init];
    opblockqueue.maxConcurrentOperationCount = 2;
  // [opblockqueue cancelAllOperations];// 取消所有操作
  // opblockqueue.suspended = YES/NO;   // 暂停/继续 操作
  // 暂停操作，当前正在执行的操作，会执行完毕，后续的操作会暂停
  // 取消所有操作,当前正在执行的操作，会执行完毕，取消后续所有操作
    
      for (int i = 0; i < 10; i ++) {
        [opblockqueue addOperationWithBlock:^{
            NSLog(@"%@,i=%d",[NSThread currentThread],i);
            
            // 获取当前操作所在的队列
            [NSOperationQueue currentQueue];
            
            // 线程间通信，回到主线程更新UI
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                
            }];
        }];
    }
}

//GCD
- (void)GCDThead {
    //1.task(block):执行什么操作
    // queue:用来存放任务
    // 将任务添加到队列中，取出FIFO
    // dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    // dispatch_block_t task = ^ { NSLog(@"task %@",[NSThread currentThread]);};
    // dispatch_async(queue, task);
    
    //2.同步不开启新的线程
    //  串行队列，同步/异步执行:dispatch_async/dispatch_sync
    //  串行队列，同步执行:不开线程，同步执行（在当前线程执行 顺序执行）
    //  串行队列，异步执行:开一个线程，顺序执行
    [self queueSerial];
    
    //ø!!!ø
    // 同步和异步决定了要不要开启新的线程
        /*同步：在当前线程中执行，不具备开启新线程的能力
         异步：在新的线程执行任务，具备开启新线程的能力
         */
    // 并发和串行决定了任务的执行方式
        /*（ 并发队列:可以多个任务并发执行，（自动开启多个线程同时执行任务）,
         只有在异步函数下有效
        串行队列:让任务一个接着一个地执行）
         */
    
    //3.并行队列，同步执行<==> 串行执行，同步执行 .同步，不开启新线程，顺序执行
    // 并行队列，异步执行: 开启多个线程，无序执行
    [self queueConcurrent];
    
    // 4.主队列(全局串行队列)，异步执行:主线程，顺序执行
    // 主队列的特点：先执行完主线程上的代码，才会执行主队列中的任务
    // 主队列，同步执行： 死锁(主线程上执行才会死锁)
    [self queuemain];
    // 主队列，异步执行：不开线程，同步执行
        //特点：如果主线程正在执行代码暂时不调度作务，等主线程执行结束后在执行任务
        //主队列又叫全局串行队列
    // 主队列，同步执行
        // 死锁,原因：当程序执行到下面这段的时候
        // 主队列：如果主线程正在执行代码，就不调度任务
        // 同步执行：如果第一个任务没有执行，就继续等待第一个任务执行完成，
        // 再执行下一个任务此时互相等待，程序无法往下执行
    // 主队列和串行队列区别：
       // 串行队列：必须等待一个任务执行完成，再高度另一个任务
       // 主队列：以先进先出调度任务，如果主线程上有代码在执行，主队列不会调度队列
    
    // 5. 全局队列本质就是并发队列
        // 全局队列和并发队列的区别：并发队列有名称，可以跟踪错误，全局队列没有
        // 在ARC中不需要考虑释放内存，dispatch_release(q)不充计调用。在MRC中需要手动释放内存，
        // 并发队列是create创建出来的，在MRC中见到Create 就要release,全局队列不需要release(只有一个)
        // 一般使用全局队列
    
    // 6.Barrier阻塞
    // 主要用于在多个异步操作完成之后，统一对非线程安全的对象进行更新
    // 适合于大规模的I/O操作
    // 当访问数据库或文件的时候，更新数据的时候不能和其他更新或读取的操作在同一时间执行，
    // 可以使用调度组不过有点复杂。可以使用dispatch_barrier_async解决
    //
    
    // 7.man dipatch_group_async 看内部实现 调度组
    // dispatch_group_t dispatchGroup = dispatch_group_create();
    // dispatch_group_enter(dispatchGroup);
    // dispatch_group_leave(dispatchGroup);
    // dispatch_group_notify
    // dispatch_group_wait(group, DISPATCH_TIME_FOREVER);等待组中的任务都执行完毕，才会继续执行后续的代码
}

- (void)queueBarrier {
    //dispatch_barrier_sync 此处要用并发队列，不能用全局队列
    _barrierqueue = dispatch_queue_create("barrierqueue", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0;i<=10;i++) {
        dispatch_async(self.barrierqueue, ^{
            NSString *string = [NSString stringWithFormat:@"%02d",i];
            dispatch_barrier_async(self.barrierqueue, ^{
                [self.strings addObject:string];
                NSLog(@"save the data %@ %@",string,[NSThread currentThread]);
            });
            
            NSLog(@"load the data %d  %@",i,[NSThread currentThread]);
        });
    }
}


- (void)queueSerial {
    dispatch_queue_t queueSerial = dispatch_queue_create("queueSerial", DISPATCH_QUEUE_SERIAL);
    for (int i = 0;i<10;i++) {
        dispatch_sync(queueSerial, ^{
          //  NSLog(@"sync:i =%d thread=%@",i,[NSThread currentThread]);
        });

        dispatch_async(queueSerial, ^{
            NSLog(@"async:i =%d thread=%@",i,[NSThread currentThread]);
        });
    }
}

- (void)queueConcurrent {
    dispatch_queue_t queueConcurrent = dispatch_queue_create("queueConcurrent", DISPATCH_QUEUE_CONCURRENT);
      for (int i = 0; i < 10; i ++) {
          dispatch_sync(queueConcurrent, ^{
            //  NSLog(@"sync:i =%d thread=%@",i,[NSThread currentThread]);
          });
          
          dispatch_async(queueConcurrent, ^{
             NSLog(@"async:i =%d thread=%@",i,[NSThread currentThread]);
           });
      }
}

- (void)queuemain {
    for (int i = 0;i<10;i ++) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"async:i =%d thread=%@",i,[NSThread currentThread]);
        });
// dead lock
//        dispatch_sync(dispatch_get_main_queue(), ^{
//                  NSLog(@"async:i =%d thread=%@",i,[NSThread currentThread]);
//              });
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0;i<10;i ++) {
            // 执行同步在子线程上执行,任务在主线程执行
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSLog(@"async:i =%d thread=%@",i,[NSThread currentThread]);
            });
        }
    });
}

- (void)sellTickets {
    while (YES) {
        [NSThread sleepForTimeInterval:1];
        @synchronized (self) {
            if (self.tks>0) {
                self.tks = self.tks -1;
                NSLog(@"tks=%ld",(long)self.tks);
            }else {
                NSLog(@"sell out.");
                break;
            }
        }
    }
}


-(void)thread {
    //1 for No address
    //2 attr
    //3 callback
    //4 params
    //5 return type 0 success,no 0 failure
    
    pthread_t pthread;
    NSString *param = @"thread";
    int re = pthread_create(&pthread, NULL, callback, (__bridge void *)(param));
    if (re==0) {
        NSLog(@"success");
    }
    
    // 任意一个对象内部都有一把锁
    @synchronized (self) {}
}

void *callback(void *param)
{
    NSString *pm = (__bridge NSString *)(param);
    NSLog(@"param= %@",pm);
    return NULL;
}

@end





























