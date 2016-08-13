//
//  StatusEntity.m
//  Block
//
//  Created by hairong chen on 16/8/13.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#import "StatusEntity.h"

@implementation User@end

@implementation StatusEntity

+ (StatusEntity *)statusWithDict:(NSDictionary *)dict {
    StatusEntity *status = [[self alloc] init];
    
    // KVC
    [status setValuesForKeysWithDictionary:dict];
    
    return status;
}

// 解决KVC报错
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        _ID = [value integerValue];
    }
    NSLog(@"%@ %@",key,value);
}

@end
