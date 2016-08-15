//
//  runloop.h
//  Block
//
//  Created by hairong chen on 16/2/25.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface runloop : NSObject
//AFNetworking 中RunLoop的创建
- (NSThread *)networkRequestThread;

//接到crash的singal 后后动重启RunLoop
- (void)restartRuningRunLoop;

//异步测试
- (void)runUnitlBlock:(BOOL(^)())block timeout:(NSTimeInterval)timeout;
- (BOOL)upgradeRunUnitlBlock:(BOOL(^)())block timeout:(NSTimeInterval)timeout;

//TableView 延迟加载图片新思路
#if TARGET_OS_IPHONE
- (void)delayLoadingImage;
#endif

- (void)createThread;
- (void)threadAgain;
- (void)createTimer;
@end
