//
//  BaseEntity.h
//  RunLoop
//
//  Created by William on 2016/5/23.
//  Copyright © 2016 技术研发-IOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseEntity : NSObject

- (void)moneyTest;
- (void)ticketsTest;

- (void)__saveMoney;
- (void)__drayMoney;

- (void)__sellingTickets;

@end

NS_ASSUME_NONNULL_END
