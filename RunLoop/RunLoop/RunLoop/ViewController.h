//
//  ViewController.h
//  RunLoop
//
//  Created by William on 2016/5/22.
//  Copyright © 2016 技术研发-IOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/*
 Proxy中代码如下, 使用便利构造器创建Proxy对象, 同时存储target
 Proxy不实现任何target调用的方法, 而是使用消息转发的方式, 将消息转发给target, 这样不论定时器调用任何方法, 都能交给target去执行
 
 此时ViewController中, CADisplayLink绑定[Proxy proxyWithTarget:self], 调用-displayLinkTest方法
 当运行程序时, 因为Proxy没有实现-displayLinkTest方法, 此时Proxy就会通过消息转发, 将displayLinkTest转交给target去执行
 */
@interface Proxy:NSObject @end
@interface Proxy ()
@property (nonatomic, weak) id target;
@end

@implementation Proxy
+ (instancetype _Nullable )proxyWithTarget:(id)target {
    Proxy *proxy = [[Proxy alloc] init];
    proxy.target = target;
    return proxy;
}

- (id _Nullable )forwardingTargetForSelector:(SEL)aSelector {
    return self.target;
}
@end


/*
 NSProxy没有任何的父类, 与NSObject一样遵守<NSObject>协议
 NSProxy是用来做消息转发的类, 如果自己没有实现目标方法, 那么就会立刻进入消息转发
 */
@interface BWProxy : NSProxy
@property (nonatomic, weak) id _Nullable target;
+ (instancetype _Nullable )proxyWithTarget:(id)target;
@end

@implementation BWProxy
+ (instancetype _Nullable )proxyWithTarget:(id )target {
    BWProxy *proxy = [BWProxy alloc];// NSProxy没有init方法, 只需要调用alloc创建对象即可
    proxy.target = target;
    return proxy;
}
- (nullable NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [self.target methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.target];
}

@end


@interface ViewController : UIViewController


@end

NS_ASSUME_NONNULL_END
