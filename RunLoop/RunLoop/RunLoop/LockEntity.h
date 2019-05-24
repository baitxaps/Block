//
//  LockEntity.h
//  RunLoop
//
//  Created by William on 2016/5/23.
//  Copyright © 2016 技术研发-IOS. All rights reserved.
//

#import "BaseEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface LockEntity : BaseEntity

- (void)pthrea_rwlock_test;
- (void)dispatch_barrier_async_test;

@end

NS_ASSUME_NONNULL_END
