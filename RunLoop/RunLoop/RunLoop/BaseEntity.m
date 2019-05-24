//
//  BaseEntity.m
//  RunLoop
//
//  Created by William on 2016/5/23.
//  Copyright © 2016 技术研发-IOS. All rights reserved.
//

#import "BaseEntity.h"
@interface BaseEntity ()
@property (nonatomic ,assign) NSInteger money;
@property (nonatomic ,assign) NSInteger tickets;
@end

@implementation BaseEntity

- (void)moneyTest {
    self.money = 1000;
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        for (int i = 0; i<5; i++) {
            [self __saveMoney];
        }
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i<5; i++) {
            [self __drayMoney];
        }
    });
}

- (void)ticketsTest {
    self.tickets = 10;
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        for (int i = 0; i <5; i++) {
            [self __sellingTickets];
        }
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i <5; i++) {
            [self __sellingTickets];
        }
    });
}

- (void)__saveMoney {
    NSInteger oldMoney = self.money;
    sleep(.2);
    oldMoney += 1000;
    self.money = oldMoney;
    
    NSLog(@"存 1000,当前禾余额%ld元 - %@",oldMoney,[NSThread currentThread]);
}

- (void)__drayMoney {
    NSInteger oldMoney = self.money;
    sleep(.2);
    oldMoney -= 500;
    self.money = oldMoney;
    
    NSLog(@"取 500,当前禾余额%ld元 - %@",oldMoney,[NSThread currentThread]);
}

- (void)__sellingTickets {
    NSInteger oldTickets = self.tickets;
    sleep(0.2);
    oldTickets --;
    self.tickets = oldTickets;
    NSLog(@"卖票 ,当前剩余额%ld张票 - %@",oldTickets,[NSThread currentThread]);
}
@end
