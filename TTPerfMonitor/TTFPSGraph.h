//
//  TTFPSGraph.h
//  TT
//
//  Created by 涂飞 on 16/7/27.
//  Copyright © 2016年 TT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTFPSGraph : UIView

@property (nonatomic, assign, readonly) NSUInteger FPS;
@property (nonatomic, assign, readonly) NSUInteger maxFPS;
@property (nonatomic, assign, readonly) NSUInteger minFPS;

- (instancetype)initWithFrame:(CGRect)frame
                        color:(UIColor *)color NS_DESIGNATED_INITIALIZER;

- (void)onTick:(NSTimeInterval)timestamp;

@end
