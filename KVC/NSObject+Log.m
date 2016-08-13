//
//  NSObject+Log.m
//  Block
//
//  Created by hairong chen on 16/8/13.
//  Copyright © 2016年 hairong chen. All rights reserved.
//

#import "NSObject+Log.h"

@implementation NSObject (Log)

// 自动打印属性字符串
+ (void)resolveDict:(NSDictionary *)dict {
    NSMutableString *strM = [NSMutableString string];
    // 1.遍历字典，把字典中的所有key取出来，生成对应的属性代码
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        // 类型经常变，抽出来
        NSString *type;
        if ([obj isKindOfClass:NSClassFromString(@"__NSCFString")]) {
            type = @"NSString";
        }else if ([obj isKindOfClass:NSClassFromString(@"__NSCFArray")]){
            type = @"NSArray";
        }else if ([obj isKindOfClass:NSClassFromString(@"__NSCFNumber")]){
            type = @"NSInteger";
        }else if ([obj isKindOfClass:NSClassFromString(@"__NSCFDictionary")]){
            type = @"NSDictionary";
        }else if ([obj isKindOfClass:NSClassFromString(@"__NSCFBoolean")]){
            type = @"BOOL";
        }
        // 属性字符串
        NSString *str;
        if ([type containsString:@"NS"]) {
            str = [NSString stringWithFormat:@"@property (nonatomic, strong) %@ *%@;",type,key];
        }else{
            str = [NSString stringWithFormat:@"@property (nonatomic, assign) %@ %@;",type,key];
        }
        // 每生成属性字符串，就自动换行。
        [strM appendFormat:@"\n%@\n",str];
        
    }];
    NSLog(@"%@",strM);
}

@end

/**
 
 NSString *filePath = [[NSBundle mainBundle] pathForResource:@"status.plist" ofType:nil];
 NSDictionary *statusDict = [NSDictionary dictionaryWithContentsOfFile:filePath];
 
 // 获取字典数组
 NSArray *dictArr = statusDict[@"statuses"];
 // 自动生成模型的属性字符串
 [NSObject resolveDict:dictArr[0][@"user"]];
 _statuses = [NSMutableArray array];
 // 遍历字典数组
 for (NSDictionary *dict in dictArr) {
 StatusEntity *status = [StatusEntity modelWithDict:dict];
 [_statuses addObject:status];
 }
 
 // 测试数据
 NSLog(@"%@ %@",_statuses,[_statuses[0] user]);
 */
