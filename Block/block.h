//
//  block.h
//  Block
//
//  Created by hairong chen on 16/2/19.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef int(^blk_t)(int);

int func(blk_t blk,int rate);

@interface block : NSObject
- (void)BlockTest1;
- (void)BlockTest2;

- (void)essenceBlock;
- (void)staticBlock;
- (int)methodUsingBlock:(blk_t)blk rate:(int)rate;
@end


typedef void (^tblk_t)(void);
@interface TObj:NSObject{
    tblk_t tblk_,oblk_,bblk_;
    id obj_;
}
@end

