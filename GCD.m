//
//  GCD.m
//  Block
//
//  Created by hairong chen on 16/2/23.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#import "GCD.h"

@implementation GCD
/*
 1.多线程
 由于一个CPU一次只能执行一个命令，不能执行某处分开的并列的两个命令，因此通过CPU执行的CPU命令列就
 好比一条无分叉的大道，其执行不会出现分歧
 一个CPU执行的CPU命令列为一条无分叉路径:线程，这时无分叉路径不只1条，存在有多条时即：多线程。
 现在一个物理CPU芯片实际上有64个(64核)CPU,在多线程中，1个CPU核执行多条不同路径上的不同命令。
 
 2.上下文切换
 1个CPU核一次能够执行的CPU命令始终为1,OS X和iOS的核心XUN内核在发生操作系统事件时（如每隔一定时间，
 唤起系统调用等情况)会切换执行路径。执行中路径的状态,如CPU的寄存器等信息保存到各自路径专用的内存块中，
 从切换目标路径专用的内存块中，复原CPU寄存器等信息，继续执行切换路径的CPU命令列：上下文切换
 
 由于使用多线程的程序可以在某个线程和其他线程之间反复多次进行上下文切换，因些看上去就像1个CPU核能够
 并列执行多个线程一样，而且在具有多个CPU核的情况下，就是真的提供了多个CPU核并行执行多个线程的技术
 
 3.多线程问题
 多线程实际上是一种易发生各种问题的编程技术，比如多个线程更新相同的资源会导致数据的不一致(数据竞争)、
 停止等待事件的线程会导致多个线程相互技续等待(死锁)、使用太多线程会消耗大量内存等
 
 4.主线程
 应用程序在启动时，通过最先执行的线程。主线程来描绘用户界面、处理触摸屏幕的事件等。如果在该主线程中进行
 长时间的处理，就会妨碍主线程的执行(阻塞),在OS和iOS的应用程序中，会妨碍主线程中被称为RunLoop的主循环的
 执行，从面导致不能更新用户界面、应用程序的画面长时间停滞等问题
 
 5.GCD
 使用多线程编程，在执行长时间的处理时仍可保证用户界面的响应性能,GCD大大简化了编于复杂的多本程编程源代码
开发者要做的只是定义想执行的任务并追加到适当的Dispatch Queue中
1> dispatch_async(queue,^{
    //想执行的任务
 });
 定义一个Block语法，dispatch_async函数追加赋值在变量queue的Dispatch Queue中：指定的Block在另一线程中执行
 
 2>Dispatch Queue就是执行处理的等待队列，应用程序编程人员过dispatch_async()等API,在Block语法中记述想要执行
 的处理并将其追加到Dispatch Queue中，Dispatch Queue按照追加的顺序FIFO执行处理。另外在执行处理时存在两种
 Dispatch Queue，一种是等待现在执行处理的Serial Dispatch Queue结束,另一种是不等等待现在执行的Concurrent Dispatch Queue结束.
 
 比较这两种Dispatch Queue,在dispatch_async中追加多个处理，源码如下：
  dispathc_async(queue,blk0);
  dispathc_async(queue,blk1);
  dispathc_async(queue,blk2);
  dispathc_async(queue,blk3);
  dispathc_async(queue,blk4);
  dispathc_async(queue,blk5);
  dispathc_async(queue,blk6);
 当变量queue为Serial Dispatch Queue时，因为要等待现在执行中的处理结束，所以首先执行blk0,blko执行结束后，接
 着执行blk1,blk1执行结束后再执行blk2,...,同时执行的处理只能有1个，即执行该源代码后，一定按照以下顺序进行处理：
 blk0
 blk1
 blk2
 blk3
 blk4
 blk5
 blk6
 当变量queue为Concurrent Dispatch Queue时，因为不用等待现在执行中的处理结束，所以首先执行blk0,不管blko执行结束后，都
 开始执行blk1,不管blk1执行结束，都开始再执行blk2,...,这样虽然不用等待处理结束，可以并行多个处理，但并行的处理数取决于当前
 系统的状态：iOS和OS X基于Dispatch Queue中的处理数、CPU核数以及CPU负荷当前系统的状态来决定Concurrent Dispatch Queue
 中并行执行的得理数。
 使用多个线程同进执行多个处理:并行执行
 
 3>iOS和OS X的核心--XNU内核决定应当使用的线程数，并只生成所需的线程执行处理。另外，当处理结束，应当执行的处理数减少时，XUN
 内核会结束不再需要的线程。XUN内核仅用Concurrent Dispatch Queue便可完美地管理并行执行多人处理的线程
 
 4>如何得到Dispatch Queue
 .通过GCD的API dispatch_queue_create()生成Dispatch Queue
 .获取系统标准提供的Dispatch Queue
  dispatch_queue_t serialDispatchQueue = dispatch_queue_create("blog.csdn.net/baitxaps", NULL);

 Serial Dispatch Queue注意：
 当生成多个Serial Dispatch Queue时，各个Serial Dispatch Queue将并行执行，虽然在1个Serial Dispatch Queue中
 同进只能执行一个追加处理，但如果将处理分别追加到4个Serial Dispatch Queue中，各个Serial Dispatch Queue执行1个，
 即为同时执行4个处理
 一旦生成Serial Dispatch Queue并追加处理，系统对于一个Serial Dispatch Queue就只生成并使用一个线程。如果生成
 1000个Serial Dispatch Queue，那么就生成1000个线程，过多使用多线程，就会消耗大量内存，引起大量的上下文切换，大
 幅度降低系统的响应性能
 
 只在为了避免多线程编程问题之一：多个线程更新相同资源导致数据竞争时使用Serial Dispatch Queue
 Serial Dispatch Queue的生成个数应当仅限所必需的数量，eg:更新数据库时1个表成1个Serial Dispatch Queue，
 更新文件时1个文件或是可以分割的1个文件块生成1个Serial Dispatch Queue。
 当想并行执行不发生数据竞争等问题处理时，使用Concurrent Dispatch Queue,而且对于Concurrent Dispatch Queue来
 说，不管生成多少，由于XUN内核只使用有效管理的线程，因此不会发生Serial Dispatch Queue那些问题
 
 5>dispatch_queue_create()函数
 .第一个参数指定Serial Dispatch Queue的名称(可为NULL),该名称在Xcode和Instruments调试器中作为Dispathc Queue名称表示
 该名称出会出现在应用程序崩溃时所生成的CrashLog中
 第二个参数指定为NULL
.生成Concurrent Dispatch Queue时：
 dispatch_queue_t concurrentDispatchQueue = dispatch_queue_create("blog.csdn.com/baitxaps", DISPATCH_QUEUE_CONCURRENT);
 
 dispatch_async(concurrentDispatchQueue,^{
    NSLog(@"Block on concurrentDispatchQueue");
 });
 
 该源代码在Concurrent Dispatch Queue中执行指定的Block,尽管有ARC这一通过编译器自动管理内存的优秀技术，但生成的Dispatch Queue
 必须由程序员负责用dispatch_release函数释放。这是因为Dispatch Queue并没有像Block那样具有作为OC对象来处理的技术
 dispatch_release(concurrentDispatchQueue);
 该名称中含有release,由此可以推测出相应地也存在dispatch_retain();
 */

#pragma mark - testConcurrentQueue

- (void)testConcurrentQueue{
    //0.
    dispatch_queue_t serialDispatchQueue = dispatch_queue_create("blog.csdn.net/baitxaps", NULL);
    //1.
    dispatch_queue_t concurrentDispatchQueue = dispatch_queue_create("blog.csdn.com/baitxaps", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(concurrentDispatchQueue,^{
        NSLog(@"Block on concurrentDispatchQueue");
    });
    
#if !OS_OBJECT_USE_OBJC
   //dispatch_release(serialDispatchQueue);
    dispatch_release(concurrentDispatchQueue);
#endif
    
    
    //2.各种Dispatch Queue获取方法
    /*
     对于 Main Dispatch Queue和Global Dispatch Queue执行dispatch_retain、dispatch_release函数不会引用作何变化，
     也不会有任何问题
     */
    dispatch_queue_t mainDispatchQueue = dispatch_get_main_queue();//main Dispatch Queue
    dispatch_queue_t globalDispatchQueueHigh = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);//最高优先级
    dispatch_queue_t globalDispatchQueueDefault = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);//默认优先级
    dispatch_queue_t globalDispatchQueueLow = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);//默认优先级
    dispatch_queue_t globalDispatchQueueBackground = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);//后台优先级
  
    //3.默认优先级的Global Dispatch Queue中执行Block
    dispatch_async(globalDispatchQueueDefault, ^{
        // 并行执行的处理
        //...
        dispatch_async(mainDispatchQueue, ^{
            //只能在主线程中执行的处理
            //...
        });
        
    });
    
    //4.指定变更执行优先级(在后台执行动作处理的Serial Dispatch Queue的生成方法)
    dispatch_set_target_queue(serialDispatchQueue, globalDispatchQueueBackground);
    
    //5.在指定时间后执行处理的情况，用dispatch_after
    dispatch_time_t  time =dispatch_time(DISPATCH_TIME_NOW, 3ull *NSEC_PER_MSEC);
    dispatch_after(time, mainDispatchQueue, ^{
        NSLog(@"waited at least 3 seconds.");
    });
    
    //6.dispatch_walltime()
    dispatch_time_t seconds = getDispatchTimeByDate([NSDate date]);
    NSLog(@"second = %llu",seconds);
    
    //7.Dispatch Group
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, globalDispatchQueueDefault, ^{NSLog(@"blk0");});
    dispatch_group_async(group, globalDispatchQueueDefault, ^{NSLog(@"blk1");});
    dispatch_group_async(group, globalDispatchQueueDefault, ^{NSLog(@"blk2");});
    
    dispatch_group_notify(group, mainDispatchQueue, ^{NSLog(@"done");});
#if !OS_OBJECT_USE_OBJC
    dispatch_release(group);
#endif
    
    //7.dispatch_group_wait()
    dispatch_group_t group_wait = dispatch_group_create();
    dispatch_group_async(group_wait, globalDispatchQueueDefault, ^{NSLog(@"blk0");});
    dispatch_group_async(group_wait, globalDispatchQueueDefault, ^{NSLog(@"blk1");});
    dispatch_group_async(group_wait, globalDispatchQueueDefault, ^{NSLog(@"blk2");});
    
    dispatch_group_wait(group_wait, DISPATCH_TIME_FOREVER);
#if !OS_OBJECT_USE_OBJC
    dispatch_release(group_wait);
#endif
    
    //8.
    time = dispatch_time(DISPATCH_TIME_NOW,1ull *NSEC_PER_SEC);
    dispatch_group_t group_result = dispatch_group_create();
    long result = dispatch_group_wait(group_result, time);
   // long result = dispatch_group_wait(group_result, DISPATCH_TIME_NOW);
    if (result == 0) {
        //属于Dispatch Group的全部内容处理执行结束
    }else{
        //属于Dispatch Group的某一个处理还在执行中
    }
    
}

dispatch_time_t getDispatchTimeByDate(NSDate *date){
    NSTimeInterval interval;
    double second,subsecond;
    struct timespec time;
    
    //以1970/01/01 GMT为基准时间，返回实例保存的时间与1970/01/01 GMT的时间间隔
    interval = [date timeIntervalSince1970];
    
    //分解interval，以得到interval的整数和小数部分
    //返回值interval的小数部分  interval 的整数部分
    subsecond = modf(interval, &second);
    time.tv_sec = second;
    time.tv_nsec = subsecond *NSEC_PER_SEC;
    dispatch_time_t  milestone = dispatch_walltime(&time, 0);
    
    return milestone;
}

#pragma mark - Main Dispatch Queue/Global Dispatch Queue
//6.Main Dispatch Queue/Global Dispatch Queue
/*
  获取系统标准提供的Dispatch Queue:
 Main Dispatch Queue:在主线程中执行Dispatch Queue
 因为主线程只有1个，所以 Main Dispatch Queue自然就是Serial Dispatch Queue,追加到Main Dispatch Queue的处理在
 主线程的RunLoop中执行（用户界面更新等）
 Global Dispatch Queue:所有应用程序都能够使用的Concurrent Dispatch Queue
 没有必要通过dispatch_queue_create()逐个生成Concurrent Dispatch Queue,只要获取Global Dispatch Queue使用即可
 Global Dispatch Queue 4个执行优先级：
    High Priority
    Default Priority
    Low Priority
    Background Priority
 通过XNU内核管理的用于Global Dispatch Queue的线程，将各自使用的Global Dispatch Queue 的
 执行优先级作为线程的执行优先级使用，在向Global Dispatch Queue 追加处理时，应选择与处理内容对
 应的执行优先级的Global Dispatch Queue。通过XNU内核用于Global Dispatch Queue的线程并不能保证
 实时性，因此执行优先级只是大致的判断
 
 */

#pragma mark -dispatch_set_target_queue
//7.dispatch_set_target_queue
/*
 1>dispatch_set_target_queue()生成的Dispatch Queue不管是Serial Dispatch Queue 还是Concurrent
 Dispatch Queue，都使用与默认优先级Global Dispatch Queue相同执行的线程。而变更生成的Dispatch Queue
 的执行优先级要使用dispatch_set_target_queue(),在后台执行动作处理的Serial Dispatch Queue的生成方法如
 testConcurrentQueue方法中第4点
 
 2>dispatch_set_target_queue(parameter1,parameter2)
 paramter1:要变更执行优先级的Dispathc Queue
 parameter2:要使用的执行优先级相同优先级的Global Dispatch Queue
 如果paramter1指定系统提供的Main Dispatch Queue和Global Dispatch Queue则不知道会出现什么状况，因此这些
 均不可指定。
 将Dispatch Queue指定dispatch_set_target_queue()的参数，不仅可以变更Dispatch Queue的执行优先级，还可以
 作成Dispatch Queue的执行阶层。如果在多个Serial Dispatch Queue中用dispatch_set_target_queue()指定目标
 为某一个Serial Dispatch Queue，那么原来应并行执行多个Serial Dispatch Queue,在目标Serial Dispatch Queue上
 只能同时执行一个处理。
 
 3>在必须将不可并行执行的处理追加到多个Serial Dispatch Queue中时，如果使用dispatch_set_target_queue()将目标
 指定为某一个Serial Dispatch Queue,即可防止处理并行执行。
 
 */

#pragma mark -dispatch_after
//8.dispatch_after
/*
 1>经常会有这产的情况，想在3秒后执行处理，可能不仅限于3秒，总之，这种想在指定时间后执行处理的情况，可使用dispatch_after()
 来实现
 //ull(unsigned long long),NSEC_PER_MSEC以毫秒为单位计算
 dispatch_time_t  time =dispatch_time(DISPATCH_TIME_NOW, 3ull *NSEC_PER_SEC);
    dispatch_after(time, mainDispatchQueue, ^{
    NSLog(@"waited at least 3 seconds.");
 });
 注意：
 dispatch_after()并不是在指定时间后执行处理，而只是在指定时间追加处理到Dispatch Queue,此源代码与在3秒后用dispatch_async()
 追加Block到Main Dispatch Queue的相同
 
 2>因为Main Dispatch Queue在主线程的RunLoop中执行，所以在比如每隔1/60秒执行的RunLoop中，Block最快在3秒后执行，最慢在3秒+1/60秒
 后执行，并且Main Dispatch Queue有大量处理追加或主线程的处理本身有延迟时，这相时间会更长
 
 3> dispatch_after(p1,p2,p3)
 p1:指定时间的dispatch_time_t类型的值,该值使用dispatch_time()或dispatch_walltime()作成
 p2:指定要追加处理的Dispatch Queu
 p3:指定记述要执行处理的Block
 
 dispatch_time()用于计算相对时间
 dispatch_walltime()用于计算绝对时间
 如用disptch_after()中想指定2016.2.26 10h10m11s这一绝对时间的情况，如:
 */

#pragma mark -Dispatch Group
//9.Dispatch Group

/*
1>在追加到Dispatch Queue中的多个处理全部结束后想执行处理，这种情况会经常出现，只使用一个Serial Dispatch Queue
 时，只要将想执行的处理全部追加到该Serial Dispatch Queue中并在最后追加结束处理即可，但是，在使用
 Concurrent Dispatch Queue时或同进使用多个Dispatch Queue时，源代码就会变得颇为复杂
 
 2>追加3个Block到Global Dispatch Queue,这些Block如果全部执行完毕，就会执行Main Dispatch Queue中结束处理的
 Block:
 
 dispatch_group_t group = dispatch_group_create();
 dispatch_group_async(group, globalDispatchQueueDefault, ^{NSLog(@"blk0");});
 dispatch_group_async(group, globalDispatchQueueDefault, ^{NSLog(@"blk1");});
 dispatch_group_async(group, globalDispatchQueueDefault, ^{NSLog(@"blk2");});
 
 dispatch_group_notify(group, mainDispatchQueue, ^{NSLog(@"done");});
#if !OS_OBJECT_USE_OBJC
 dispatch_release(group);
#endif
 
 因为向Global Dispatch Queue即Concurrent Dispatch Queue追加处理，多个线程并行执行，所以
 追加处理的执行顺序不定。执行时会发生变化，但是此执行结果的done一定是最后输出的
 
 3>无论向什么样的Dispatch Queue中追加处理，使用Dispatch Group都可监视这些处理执行的结束，一旦
 检测到所有处理执行结束，就可将结束的处理追加到Dispatch Queue中
 
 4>dispatch_group_async()与dispatch_async()相同，都追加Block到指定的Dispatch Queue,与dispatch_async()
 不同的是指定生成的Dispatch Group为第一个参数，指定的Block属于指定的Dispatch Group。
 
 5>追加Block到Dispatch Queue时同样，Block通过dispathc_retain()持有Dispatch Group,从
 而使得该Block属于Dispatch Group。这样如果Block执行结束，该Block就通过dispatch_release()释放
 持有的Dispatch Group，一旦Dispatch Group使用结束，不用考虑属于该Dispatch Group的Block,立即
 通过dispatch_release()释放即可
 
 6>dispatch_group_notify(p1,p2,p3);
  在追加到Dispatch Group中的处理全部执行结束时，该源代码中使用的dispatch_group_notify()会将执行Block
 追加到Dispatch Queue中。
 p1,指定要监视的Dispatch Group,在追加到Dispatch Group的全部全部处理执行结束时，将p3的Block追加到p2
 的Dispatch Queue中。
 在dispatch_group_notify()中不管指定什么样的Dispatch Queue,属于Dispatch Group的全部处理在追加指定
 的Block时都已执行结束
 
 7>dispatch_group_wait()
 另外，在Dispatch Group中也可以使用dispatch_group_wait()仅等全部处理执行结束。
 dispatch_group_t group_w = dispatch_group_create();
 dispatch_group_async(group_w, globalDispatchQueueDefault, ^{NSLog(@"blk0");});
 dispatch_group_async(group_w, globalDispatchQueueDefault, ^{NSLog(@"blk1");});
 dispatch_group_async(group_w, globalDispatchQueueDefault, ^{NSLog(@"blk2");});
 
 dispatch_group_wait(group_w, DISPATCH_TIME_FOREVER);
 #if !OS_OBJECT_USE_OBJC
 dispatch_release(group_w);
 #endif
 
 dispatch_group_wait(p1,p2)
 p2:指定为等待的时间(超时），它属于dispatch_time_t类型的值，DISPATCH_TIME_FOREVER永久等待，只要
 Dispatch Group的处理尚未执行结束，就会一直等待，中途不能取消。如同dispatch_after()说明中出现的那样
 指定等待间隔为1秒应做如下处理：
 
 time = dispatch_time(DISPATCH_TIME_NOW,1ull *NSEC_PER_SEC);
 dispatch_group_t group_result = dispatch_group_create();
 long result = dispatch_group_wait(group_result, time);
 if (result == 0) {
 //属于Dispatch Group的全部内容处理执行结束
 }else{
 //属于Dispatch Group的某一个处理还在执行中
 }
 
 如果dispatch_group_wait()返回不是0,即虽然经过了指定的时间，但属于Dispatch Group的某一个处理还在执行中，如果
 返回值为0,那么全部处理执行结束。当等待时间为DISPATCH_TIME_FOREVER，由dispatch_group_wait()返回时，由于属于
 Dispatch Group的处理必定全部执行结束，因此返回值恒为0。
 这时的”等待“意味着一旦调用dispatch_group_wait()，该函数就处于调用的状态而不返回。即执行dispatch_group_wait()的
 现在线程(当前线程)停止。在经过dispatch_group_wait()中指定的时间或属于指定Dispatch Group和处理全部执行结束之前，
 执行该函数的线程停止。
 
 指定DISPATCH_TIME_NOW，则不用作何等待即可判定属于Dispatch Group的处理是否执行结束：
 long result = dispatch_group_wait(group_result, DISPATCH_TIME_NOW);
 
 在主线程的RunLoop的每次循环中，可检查执行是否结束，从而不耗费多余的等待时间，虽然这样也可以，但一般在这
 种情形dispatch_group_notify()追加结束处理到Main Dispatch Queue中，这时因为dispatch_group_notify()
 可以简化源码
 
 
 */

#pragma mark -dispatch_barrier_async
//10.dispatch_barrier_async

































@end
