//
//  TTPerfMonitor.m
//  TT
//
//  Created by 涂飞 on 16/7/27.
//  Copyright © 2016年 TT. All rights reserved.
//

#import "TTPerfMonitor.h"

#import <mach/mach.h>

#import "TTFPSGraph.h"
#import "TTCPUGraph.h"
#import "TTMEMGraph.h"

static CGFloat const TTPerfMonitorBarHeight = 50;


@interface TTPerfMonitor ()

@property (nonatomic, strong) UIView *container;

@property (nonatomic, strong) UILabel *cpuNameLabel;
@property (nonatomic, strong) UILabel *memNameLabel;
@property (nonatomic, strong) UILabel *fpsNameLabel;

@property (nonatomic, strong) TTCPUGraph *cpuGraph;
@property (nonatomic, strong) TTMEMGraph *memoryGraph;
@property (nonatomic, strong) TTFPSGraph *uiFpsGraph;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation TTPerfMonitor

+ (instancetype)shareInstance{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (UIView *)container
{
    if (!_container) {
        _container = [[UIView alloc] initWithFrame:CGRectMake(10, 25, 140, TTPerfMonitorBarHeight)];
        _container.backgroundColor = UIColor.whiteColor;
        _container.layer.borderWidth = 2;
        _container.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [_container addGestureRecognizer:self.panGestureRecognizer];
//        [_container addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                                 action:@selector(tap)]];
    }
    
    return _container;
}

- (UILabel *)cpuNameLabel{
    if (!_cpuNameLabel)
    {
        _cpuNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 2, 40, 12)];
        _cpuNameLabel.font = [UIFont systemFontOfSize:9];
        _cpuNameLabel.textColor = [UIColor grayColor];
        _cpuNameLabel.text = @"CPU";
        _cpuNameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _cpuNameLabel;
}

- (UILabel *)memNameLabel{
    if (!_memNameLabel)
    {
        _memNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 2, 40, 12)];
        _memNameLabel.font = [UIFont systemFontOfSize:9];
        _memNameLabel.textColor = [UIColor grayColor];
        _memNameLabel.text = @"MEM";
        _memNameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _memNameLabel;
}

- (UILabel *)fpsNameLabel{
    if (!_fpsNameLabel)
    {
        _fpsNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 2, 40, 12)];
        _fpsNameLabel.font = [UIFont systemFontOfSize:9];
        _fpsNameLabel.textColor = [UIColor grayColor];
        _fpsNameLabel.text = @"FPS";
        _fpsNameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _fpsNameLabel;
}



- (TTCPUGraph *)cpuGraph{
    if (!_cpuGraph)
    {
        _cpuGraph = [[TTCPUGraph alloc] initWithFrame:CGRectMake(5, 14, 40, 30) color:[UIColor lightGrayColor]];
    }
    return _cpuGraph;
}

- (TTMEMGraph *)memoryGraph{
    if (!_memoryGraph)
    {
        _memoryGraph = [[TTMEMGraph alloc] initWithFrame:CGRectMake(50, 14, 40, 30) color:[UIColor lightGrayColor]];
    }
    return _memoryGraph;
}

- (TTFPSGraph *)uiFpsGraph{
    if (!_uiFpsGraph)
    {
        _uiFpsGraph = [[TTFPSGraph alloc] initWithFrame:CGRectMake(95, 14, 40, 30)
                                                    color:[UIColor lightGrayColor]];
    }
    
    return _uiFpsGraph;
}

- (UIPanGestureRecognizer *)panGestureRecognizer{
    if (!_panGestureRecognizer)
    {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
    }
    return _panGestureRecognizer;
}

- (void)onPanGesture:(UIPanGestureRecognizer *)gesture{
    CGPoint translation = [gesture translationInView:self.container.superview];
    self.container.center = CGPointMake(
                                        self.container.center.x + translation.x,
                                        self.container.center.y + translation.y
                                        );
    [gesture setTranslation:CGPointMake(0, 0)
                               inView:self.container.superview];
}

- (void)threadUpdate:(CADisplayLink *)displayLink
{
    [_uiFpsGraph onTick:displayLink.timestamp];
}

- (void)updateStats
{
    [self.cpuGraph update];
    [self.memoryGraph update];
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_after(
                   dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
                       __strong __typeof__(weakSelf) strongSelf = weakSelf;
                       if (strongSelf && strongSelf->_container.superview) {
                           [strongSelf updateStats];
                       }
                   });
}


- (void)show
{
    if (_container) {
        return;
    }
    
    [self.container addSubview:self.cpuNameLabel];
    [self.container addSubview:self.memNameLabel];
    [self.container addSubview:self.fpsNameLabel];
    [self.container addSubview:self.cpuGraph];
    [self.container addSubview:self.memoryGraph];
    [self.container addSubview:self.uiFpsGraph];
    
//    [self redirectLogs];
    
    
    [self updateStats];
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [window addSubview:self.container];
    
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self
                                                 selector:@selector(threadUpdate:)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop]
                         forMode:NSRunLoopCommonModes];
    
}

- (void)hide
{
    if (!_container) {
        return;
    }
    
    [_displayLink invalidate];
    
    [self.container removeFromSuperview];
    _cpuNameLabel = nil;
    _memNameLabel = nil;
    _fpsNameLabel = nil;
    _cpuGraph = nil;
    _memoryGraph = nil;
    _uiFpsGraph = nil;
    _container = nil;
}

@end
