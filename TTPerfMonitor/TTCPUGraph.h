//
//  TTCPUGraph.h
//  TT
//
//  Created by 涂飞 on 16/7/28.
//  Copyright © 2016年 Tu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTCPUGraph : UIView

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color NS_DESIGNATED_INITIALIZER;

- (void)update;

@end
