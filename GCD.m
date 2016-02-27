//
//  GCD.m
//  Block
//
//  Created by hairong chen on 16/2/23.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#import "GCD.h"


@implementation GCD

#pragma mark -GCD实现
//GCD实现
/*
 1>GCD实现需要使用的一些工具：
 .用于管理追加的Block的C语言层实现的FIFO队列
 .Atomic 函数中实现的用于排他控制的轻量级信号
 .用于管理线程的C语言层实现的一些容器
 
 但是还要内核级的实现,通常，应用程序中编写的线程管理用的代码要在系统级(iOS和OS X的核心级)实现
 因此，无论编程人员如何努力编写管理线程的代码，在性能方面也不能胜过XNU内核级所实现的GCD。
 使用使用GCD要比使用pthreads和NSThread这些一般的多线程编程API更好，并且，如果使用GCD就不必
 编写这操作线程反复出现类似的源代码(因定源代码片断)，而可以在线程中集中实现处理内容。尽量多使用
 GCD或者用Cocoa框架GCD的NSOperationQueue类的API
 
 2>用于实现Dispatch Queue而使用的软件组件
 组件名称               提供技术
 libdispatch         Dispatch Queue
 libc(pthreads)      pthread_workqueue
 XUN内核              workqueue
 
 3>编程人员所使用GCD的API全部为包含有libdispatch库的Ｃ函数，Dispatch Queue通过结构体和链表，被
 实现为FIFO队列，FIFO队列管理是通过dispatch_async()等函数所追加的Block,Block并不是直接加入FIFO
 队列，而是先加入Dispatch Continuation这一dispatch_continuation_t类型结构体中，然后再加入FIFO
 队列。Dispatch Continuation用于记忆Block所属的Dispatch Group和其他一些信息(执行上下文)
 
 4>Dispatch Queue可通过dispatch_set_target_queue()设定，可以设定执行该Dispatch Queue处理的
 Dispatch Queue为目标。该目标可像串珠子一样，设定多个连接在一起的Dispatch Queue,但是在连接串的最后
 必须设定Main Dispatch Queue，或各种优先级的Global Dispatch Queue,或是准备用于Serial Dispatch Queue
 的Global Dispatch Queue
 
 5>Global Dispatch Queue的8种优先级：
 .High priority
 .Default Priority
 .Low Priority
 .Background Priority
 .High Overcommit Priority
 .Default Overcommit Priority
 .Low Overcommit Priority
 .Background Overcommit Priority
附有Overcommit的Global Dispatch Queue使用在Serial Dispatch Queue中，不管系统状态如何，都会强
 制生成线程的 Dispatch Queue。
 这8种Global Dispatch Queue各使用1个pthread_workqueue,GCD初始化时，使用pthread_workqueue_create_np()
 生成pthread_workqueue 
 pthread_workqueue使用bsdthread_register和workq_open系统调用，在初始化XUN内核的workqueue之后获取workqueue
 信息
 
 6>XUN内核的4种workqueue 的优先级，与Global Dispatch Queue的4种执行优先级相同
 .WORKQUEUE_HIGH_PRIQUEUE
 .WORKQUEUE_DEFAULT_PRIQUEUE
 .WORKQUEUE_LOW_PRIQUEUE
 .WORKQUEUE_BG_PRIQUEUE
 
 7>Dispatch Queue中执行Block过程
 当在Global Dispatch Queue中执行Block时，libdispatch 从Global Dispatch Queue自身的FIFO队列中取
 出Dispatch Continuation,调用pthread_workqueue_additem_np(),将该Global Dispatch Queue自身、符
 合优先级的workqueue信息以及为执行Dispatch Continuation的回调函数等传递给参数。
 thread_workqueue_additem_np()使用workq_kernreturn系统调用，通知workqueue啬应当执行的项目，根据该
 通知，XUN内核基于系统状态判断是否要生成线程，如果是Overcommit优先级的Global Dispatch Queue，workqueue
 则始终生成线程。
 .该线程虽然与iOS和OS X中通常使用的线程大致相同，但是有一部分pthread API不能使用
 .workqueue生成的线程在实现用于workqueue的线程计划表中运行，与一般线程的上下文切不同，这里也隐藏着使用GCD的
 原因
 .workqueue的线程执行pthread_workqueue(),该函数用libdispatch的回调函数，在回调函数中执行执行加入到
 Dispatch Continuatin的Block
 .Block执行结束后，进行通知Dispatch Group结束，释放Dispatch Continuation等处理，开始准备执行加入到Dispatch Continuation中的下一个Block
 
 */


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

#pragma mark - GCDTest
 
- (void)GCDTest{
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
    
    //9.dispatch_barrier_async()
    dispatch_async(concurrentDispatchQueue, ^{NSLog(@"blk0 for reading");});
    dispatch_async(concurrentDispatchQueue, ^{NSLog(@"blk1 for reading");});
    dispatch_async(concurrentDispatchQueue, ^{NSLog(@"blk2 for reading");});
    dispatch_barrier_async(concurrentDispatchQueue, ^{NSLog(@"blk3 for writing");});
    dispatch_async(concurrentDispatchQueue, ^{NSLog(@"blk4 for reading");});
    dispatch_async(concurrentDispatchQueue, ^{NSLog(@"blk5 for reading");});
    dispatch_async(concurrentDispatchQueue, ^{NSLog(@"blk6 for reading");});
    
    //10.dispatch_apply()
    //0>
    dispatch_apply(10, globalDispatchQueueDefault, ^(size_t index) {
        NSLog(@"dispatch_apply = %zu",index);
    });
    NSLog(@"dispatch_apply() done.");
    
    //1>
    NSArray *array = self.datas;
    dispatch_apply(self.datas.count, globalDispatchQueueDefault, ^(size_t index){
       NSLog(@"index= %zu,element = %@",index,array[index]);
    });
    
    //3>在Global Dispatch Queue中非同步执行
    dispatch_async(globalDispatchQueueDefault, ^{
        //Global Dispatch Queue 等待dispatch_apply函数中全部处理执行结束
        dispatch_apply(self.datas.count, globalDispatchQueueDefault, ^(size_t index){
            NSLog(@"index= %zu,element = %@",index,array[index]);
        });
        //dispatch_apply()中处理全部执行结束
        
        //在Main Dispatch Queue中执行处理用户界用更新等
        dispatch_async(mainDispatchQueue, ^{NSLog(@"在Main Dispatch Queue中执行处理用户界用更新等...,Done");});
    });
    
    //11.dispatch_suspend()/dispatch_resume()
    /*
     这些函数对已经执行的处理没有影响，挂起后，追加到Dispatch Queue中但尚未执行的处理在些之扣停止执行，
     而恢复则使用这些处理能够继续执行。
     */
    dispatch_suspend(globalDispatchQueueDefault);
    dispatch_resume(globalDispatchQueueDefault);
    
    
    //12.dispatch Semaphore
    
    //Dispatch Semaphore的计数初始值设定为1,保证可访问的NSArray类的对象的线程同时只能有1个
     dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    //1>
    {
        NSMutableArray *array = [NSMutableArray new];
        for (int i = 0; i< 100000; i++) {
            
            dispatch_async(globalDispatchQueueDefault, ^{
                
                //等待Dispatch Semaphore,一直等待，直到Dispatch Semaphore的计数值达到大于等于1。
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                
                /*
                 Dispatch Semaphore的计数值达到大于等于1,所以将Dispatch Semaphore的计数值减去1
                 dispatch_semaphore_wait()执行返回。即执行到此进的Dispatch Semaphore的计数值恒
                 为0,由于可访问NSArray类对象的线程只有1个，因此可安全地进行更新。
                 */
                [array addObject:@(i)];
                
                /*
                 排他控制处理结束，所以通过dispatch_semaphore_signal()将Dispatch Semaphore的计
                 数值加1。如果有通过dispatch_semaphore_wait通过()等待Dispatch Semaphore和计数值
                 增加的线程，就由最先等待的线程执行。
                 */
                dispatch_semaphore_signal(semaphore);
            });
        }
    }
#if !OS_OBJECT_USE_OBJC
    dispatch_release(semaphore);
#endif
    
    //13.dispatch_once()
    //更新标志变量
    static int initialized = NO;
    if(initialized == NO){
        initialized = YES;
    }
    
    //可通过dispatch_once()简化
    static dispatch_once_t pred;
    dispatch_once(&pred,^{
        initialized = YES;
    });
    /*
    通过dispatch_once(),该源代码即使在多线程环境下执行，可保证100%安全
    之前的源代码在大多数情况下也是安全的，但在多核CPU中，在正在更新表示是否初始化的标志变量时读取，就有
    可能多次执行初始化处理。而用dispatch_once()初始化就不必担心这样的问题。
    这就是所说的单例模式，在生成单例对象时使用。
     */
    
    //死锁下面几种情况：
    /*
     //1>
     dispatch_sync(mainDispatchQueue, ^{NSLog(@"死锁1");});
     //2>
     dispatch_async(mainDispatchQueue, ^{
     dispatch_sync(mainDispatchQueue, ^{NSLog(@"死锁2");});
     });
     //3>
     dispatch_async(serialDispatchQueue, ^{
     dispatch_sync(serialDispatchQueue, ^{NSLog(@"死锁3");});
     });
     */
}

- (NSArray *)datas{
    return @[@"obj1",@"obj2",@"obj3",@"obj4",@"obj5"];
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
/*
1> 比如访问数据库或文件，为了高效率进行访问，读取处理追加到Concurrent Dispatch Queue中，写入处
 理在任一个读取处时没有执行的状态下，追加到Serial Dispatch Queue中即可(在写入处理结束之前，读
 取处理不可执行）,虽然利用Dispatch Group和dispatch_set_target_queue()也可实现，但是源代码会
 很复杂。
 2>dispatch_barrier_async()同dispatch_queue_create()生成的Concurrent Dispatch Queue一
 起用，首先，dispatch_queue_create()生成Concurrent Dispatch Queue，在dispatch_async中追加
 读处理，在blk2，blk4间加入写入处理，并将写入的内容读到blk4处理以及之后的处理中。
 
 3>dispatch_barrier_async()会等侍追加到Concurrent Dispatch Queue上的并行的处理全部结束之后，再
 将指定的处理追加到该Concurrent Dispatch Queue中。然后在由dispatch_barrier_async()追加的处理执行
 完毕后，Concurrent Dispatch Queue才恢复为一般的动作，追加到该Concurrent Dispatch Queue的处理又
 开始并行执行。
 
 dispatch_async(concurrentDispatchQueue, ^{NSLog(@"blk0 for reading");});
 dispatch_async(concurrentDispatchQueue, ^{NSLog(@"blk1 for reading");});
 dispatch_async(concurrentDispatchQueue, ^{NSLog(@"blk2 for reading");});
 dispatch_barrier_async(concurrentDispatchQueue, ^{NSLog(@"blk3 for writing");});
 dispatch_async(concurrentDispatchQueue, ^{NSLog(@"blk4 for reading");});
 dispatch_async(concurrentDispatchQueue, ^{NSLog(@"blk5 for reading");});
 dispatch_async(concurrentDispatchQueue, ^{NSLog(@"blk6 for reading");});
 */


#pragma mark -dispatch_sync
//11.dispatch_sync
/*
 dispatch_async():将指定的Block非同步地追加到指定的Dispatch Queue中，dispatch_async()不
 做任何等待。
 dispatch_sync():将指定的Block同步地追加到指定的Dispatch Queue中，在追加Block结束之前，
 dispatch_sync()会一直等待。
 
 一旦调用dispatch_sync()，那么在指定的处理执行结束之前，该函数不会返回，dispatch_sync()可简化
 源代码，也可说是简易版的dispatch_group_wait();
 
 在编程中，最好在深思熟虑、最好希望达到的目的之后再使用dispatch_sync()等同步等待处理执行的API,
 因为使用这种API时，稍有不慎就倒导致程序死锁。
 
 //1>在主线程中执行死锁：Main Dispatch Queue即主线程中执行指定的Block，并等待执行结束。而其实
 在主线程中正在执行这些源代码，所以无法执行追加到Main Dispatch Queue的Block
 dispatch_sync(mainDispatchQueue, ^{NSLog(@"死锁1");});
 
 //2>Main Dispatch Queue 中执行的Block等待Main Dispatch Queue中要执行的Block执行结束。
 dispatch_async(mainDispatchQueue, ^{
 dispatch_sync(mainDispatchQueue, ^{NSLog(@"死锁2");});
 });
 //3>
 dispatch_async(serialDispatchQueue, ^{
 dispatch_sync(serialDispatchQueue, ^{NSLog(@"死锁3");});
 });
 
 */

#pragma mark -dispatch_apply()
//12.dispatch_apply()
/*
1>dispatch_apply()是dispathc_sync()和Dispatch Group的关联API。该函数按指定的次数将指定的
 Block追加到指定的Dispatch Queue中，并等待全部处理执行结束。
 
 dispatch_apply(10, globalDispatchQueueDefault, ^(size_t index) {
 NSLog(@"dispatch_apply = %zu",index);
 });
 NSLog(@"dispatch_apply() done.");
 输出：
 dispatch_apply = 4
 dispatch_apply = 1
 dispatch_apply = 0
 ...
 dispatch_apply() done.
 Global Dispatch Queue中执行处理，所以各个处理的执行时间不定，但是输出结果中最后的done必定在最后
 的位置上，这是因为dispatch_apply()会等待全部处理执行结束
 
 2> dispatch_apply(10, globalDispatchQueueDefault, ^(size_t index)）
 第一个参数是复复次数，第二个参数为追加对象的Dispatch Queue,第三个参数为追加的处理，是带有参数的Block,
 与其他出现的例子不同，这是为了按第一个参数重复追加Block并区分各个Block而使用。
 eg:对数组对象的所有元素执行片理是，不必一个一个编写for循环部分：
 
 NSArray *array = self.datas;
 dispatch_apply(self.datas.count, globalDispatchQueueDefault, ^(size_t index){
 NSLog(@"index= %zu,element = %@",index,array[index]);
 });
 
 3>dispatch_apply()与dispatch_sync()函数相同，会等待处理执行结束，因此推荐在dispatch_async()
 中非同步地执行dispatch_apply()
 
 dispatch_async(globalDispatchQueueDefault, ^{
 //Global Dispatch Queue 等待dispatch_apply函数中全部处理执行结束
 dispatch_apply(self.datas.count, globalDispatchQueueDefault, ^(size_t index){
 NSLog(@"index= %zu,element = %@",index,array[index]);
 });
 //dispatch_apply()中处理全部执行结束
 
 //在Main Dispatch Queue中执行处理用户界用更新等
 dispatch_async(mainDispatchQueue, ^{NSLog(@"在Main Dispatch Queue中执行处理用户界用更新等...,Done");});
 });
 
 */

#pragma mark -dispatch_suspend()/dispatch_resume()
//12.dispatch_suspend()/dispatch_resume()

/*
 当追加大量处理到Dispatch Queue时，在追加处理的过程中，有时希望不执行已追加的处理，如演算结果被
 Block截获时，一些处理会对这个演算结果造成影响。
 在这种情况下，只要挂起Dispatch Queue即可，当可以执行时再恢复
 
 挂起指定的Dispatch Queue:
 dispatch_suspend(globalDispatchQueueDefault);
 
 恢复指定的Dispatch Queue:
 dispatch_resume(globalDispatchQueueDefault);
 
 这些函数对已经执行的处理没有影响，挂起后，追加到Dispatch Queue中但尚未执行的处理在些之扣停止执行，
 而恢复则使用这些处理能够继续执行。
 */

#pragma mark -dispatch Semaphore
//12.dispatch Semaphore

/*
 当并行执行的处理更新数据时，会产生数据不一致的情况，有时应用程序还会异常结束，虽然使用Serial Dispatch Queue
 和dispatch_barrier_async()可避免这类问题，但有必要进行更细粒度的排他控制
 
 1>dispatch Semaphore是持有计数的信号，该计数是多线程编程中的计数类型信号，所谓信号，类似于过马咱时常
 用的手旗，可以通过是举起手旗，不可通过时放下手旗。而在Dispatch Semaphore中，使用计数来实现该功能。计
 数为0时等待，计数为1或大于1时，减去1而不等待。
 
 2>dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);参数表示计数的初始值为1,
 从create可以看出，该函数与Dispatch Queue和Dispatch Group一样，必须通过dispatch_release()
 释放，也可通过dispatch_retain()持有。
 
 3>dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);
 dispatch_semaphore_wait()等待Dispatch Semaphore的计数值达到大于或等于1。当计数值大于等于1,或
 者在待机中计数大于等于1时，对该计数进行减法并从dispatch_semaphore_wait()返回;第二个参数与
 dispatch_group_wait()相同，由dispatch_time_t类型值指定等待时间。另外dispatch_semaphore_wait()
 的返回值也与dispatch_group_wait()相同。
 //Dispatch Semaphore的计数初始值设定为1,保证可访问的NSArray类的对象的线程同时只能有1个
 dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
 //1>
 {
 NSMutableArray *array = [NSMutableArray new];
 for (int i = 0; i< 100000; i++) {
 
 dispatch_async(globalDispatchQueueDefault, ^{
 
 //等待Dispatch Semaphore,一直等待，直到Dispatch Semaphore的计数值达到大于等于1。
 dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
 
 
 Dispatch Semaphore的计数值达到大于等于1,所以将Dispatch Semaphore的计数值减去1
 dispatch_semaphore_wait()执行返回。即执行到此进的Dispatch Semaphore的计数值恒
 为0,由于可访问NSArray类对象的线程只有1个，因此可安全地进行更新。
 [array addObject:@(i)];


 排他控制处理结束，所以通过dispatch_semaphore_signal()将Dispatch Semaphore的计
 数值加1。如果有通过dispatch_semaphore_wait通过()等待Dispatch Semaphore和计数值
 增加的线程，就由最先等待的线程执行。

 dispatch_semaphore_signal(semaphore);
});
}
}
#if !OS_OBJECT_USE_OBJC
dispatch_release(semaphore);
#endif
 */


#pragma mark -dispatch_once()
//12.dispatch_once()
/*
 dispatch_once()是保证在应用程序执行中只执行一次指定处理的API,下面这种经常出现的用来进行初始化的
 源代码可通过dispatch_once()简化
 static int initialized = NO;
 if(initialized == NO){
    initialized = YES;
 }
 
 如果用dispatch_once(),则源代码写为：
 static dispatch_once_t pred;
 dispatch_once(&pred,^{
    initialized = YES;
 });
 通过dispatch_once(),该源代码即使在多线程环境下执行，可保证100%安全
 之前蝗源代码在大多数情况下也是安全的，但在多核CPU中，在正在更新表示是否初始化的标志变量时读取，就有
 可能多次执行初始化处理。而用dispatch_once()初始化就不必担心这样的问题。
 这就是所说的单例模式，在生成单例对象时使用。
 */

#pragma mark -Dispatch I/O
//12.Dispatch I/O
/*
 在读取较大文件时，如果将文件分成合适的大小并使用Global Dispatch Queue并列读取的话，应该会比一般的
 读取速度快不少。现在的输入/输出硬件已经可以做到一次使用多个线程更快地并列读取了。能实现这一功能的就是
 Dispatch I/O和Dispath Data。
 通过Dispatch I/O读写文件时，使用Global Dispatch Queue将文件按某个大小read/write
 如下：
 */
- (void)readByteBySize{
    dispatch_queue_t queue = dispatch_queue_create("blog.csdn.com/baitxaps", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{/*读取 0-8181 字节*/});
    dispatch_async(queue, ^{/*读取 8181-15502 字节*/});
    dispatch_async(queue, ^{/*读取 15503-23335 字节*/});
    dispatch_async(queue, ^{/*读取 23336-555555 字节*/});
    dispatch_async(queue, ^{/*读取 555555-65535 字节*/});
}
/*
 像上面这样，将文件分割为一块一块地进行读取处理。分割读取的数据通过使用Dispatch Data可更为简单地进行结合和分割
 苹果使用Dispatch I/O和Dispath Data。
 */


/*
 Apple System Log API 用的源代码(libc-763.11 gen/asl.c)
 */
- (void)filesReader{
    dispatch_queue_t  pipe_q = dispatch_queue_create("PipeQ", NULL);
    dispatch_fd_t fd;//
    
    //生成Dispatch I/O,发生错误时用来执行处理的Block,以及执行该Block的Dispatch Queue
    dispatch_io_t pipe_channel = dispatch_io_create(DISPATCH_IO_STREAM, fd, pipe_q, ^(int error) {
        close(fd);
    });
    
   //char *out_fd = fdpair[1];
    //设定一次读取的分割大小
    dispatch_io_set_low_water(pipe_channel, SIZE_MAX);
    dispatch_data_t pipeData;//
    
    //使用Global Dispatch Queue并列读取
    dispatch_io_read(pipe_channel, 0, SIZE_MAX, pipe_q, ^(bool done, dispatch_data_t data, int error) {
        if (error == 0) {
            size_t len = dispatch_data_get_size(pipeData);
            if (len>0) {
                const char *bytes = NULL;
                char *encoede;
                
                dispatch_data_t md = dispatch_data_create_map(pipeData, (const void **)&bytes, &len);
               // encoede = asl_core_encode_buffef(bytes,len);//
                //asl_set((aslmsg)merged_msg,ASL_KEY_AUX_DATA,encoede);
                free(encoede);
               // _asl_send_message(NULL,merged_msg,-1,NULL);
               // asl_msg_release(merged_msg);
#if !OS_OBJECT_USE_OBJC
                dispatch_release(md);
#endif
            }
        }
        if (done) {
            //dispatch_semaphore_signal(sem);
#if !OS_OBJECT_USE_OBJC
            dispatch_release(pipe_channel);
            dispatch_release(pipe_q);
            
#endif
        }
    });
}

#pragma mark -Dispatch Source
//12.Dispatch Source
/*
 */













@end
