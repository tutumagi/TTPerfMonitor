//
//  TTPerfMonitor.h
//  TT
//
//  Created by 涂飞 on 16/7/27.
//  Copyright © 2016年 TT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTPerfMonitor : NSObject

+ (instancetype)shareInstance;

- (void)show;
- (void)hide;

@end
