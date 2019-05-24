//
//  WRThread.h
//  RunLoop
//
//  Created by William on 2016/5/22.
//  Copyright © 2016 技术研发-IOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WRThread : NSThread

@end

@interface PthreadTest : NSObject
- (void)recursive;
- (void)pthreadTest ;
@end

NS_ASSUME_NONNULL_END
