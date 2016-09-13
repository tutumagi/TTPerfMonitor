//
//  TTMEMGraph.m
//  TT
//
//  Created by 涂飞 on 16/7/28.
//  Copyright © 2016年 TT. All rights reserved.
//

#import "TTMEMGraph.h"
#import <mach/mach.h>
#import "TTAsset.h"

//获取占用内存
static vm_size_t TTGetResidentMemorySize(void)
{
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if (kerr != KERN_SUCCESS) {
        return 0;
    }
    
    return info.resident_size;
}

@interface TTMEMGraph ()
{
    CGFloat *_memUsages;
}

@property (nonatomic, assign) CGFloat preMemUsage;
@property (nonatomic, strong) UILabel *memLabel;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, assign) NSUInteger length;
@property (nonatomic, assign) NSUInteger height;

@property (nonatomic, assign) CGFloat maxMemUsage;
@property (nonatomic, assign) CGFloat minMemUsage;

@property (nonatomic, strong) UIColor *bgColor;
@end

@implementation TTMEMGraph

TT_NOT_IMPLEMENTED(- (instancetype)initWithFrame:(CGRect)frame);
TT_NOT_IMPLEMENTED(- (instancetype)initWithCoder:(NSCoder *)aDecoder);

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color{
    if (self = [super initWithFrame:frame])
    {
        _maxMemUsage = CGFLOAT_MIN;
        _minMemUsage = CGFLOAT_MAX;
        
        _preMemUsage = CGFLOAT_MAX;
        
        _length = (NSUInteger)frame.size.width;
        _height = (NSUInteger)frame.size.height;
        _memUsages = calloc(sizeof(CGFloat), _length);
        
        _bgColor = color;
        [self.layer addSublayer:self.shapeLayer];
        [self addSubview:self.memLabel];
    }
    return self;
}

- (void)dealloc{
    free(_memUsages);
}

- (void)update{
    CGFloat now = TTGetResidentMemorySize() / 1024.0 / 1024.0;
    [self updateWithNowValue:now];
}

- (void)updateWithNowValue:(CGFloat)now{
    if (_preMemUsage == CGFLOAT_MAX)
    {
        _preMemUsage = now;
    }
    else
    {
        _maxMemUsage = MAX(now, _maxMemUsage);
        
        _memLabel.text = [NSString stringWithFormat:@"%.1fMB", now];
        CGFloat scale = _maxMemUsage / _height;
        
        //cpu使用率 打点数据 前移一个位置
        for (int i = 0; i < _length - 1; ++i)
        {
            _memUsages[i] = _memUsages[i+1];
        }
        _memUsages[_length - 1] = now / scale;
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 0, _height);
        for (int i = 0; i < _length; ++i)
        {
            CGPathAddLineToPoint(path, NULL, i, _height - _memUsages[i]);
        }
        CGPathAddLineToPoint(path, NULL, _length - 1, _height);
        
        self.shapeLayer.path = path;
        
        _preMemUsage = now;
        
        CGPathRelease(path);
    }
}

- (UILabel *)memLabel{
    if (!_memLabel)
    {
        _memLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _memLabel.font = [UIFont boldSystemFontOfSize:9];
        _memLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _memLabel;
}

- (CAShapeLayer *)shapeLayer{
    if (!_shapeLayer)
    {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.frame = self.bounds;
        _shapeLayer.fillColor = _bgColor.CGColor;
        _shapeLayer.backgroundColor = [_bgColor colorWithAlphaComponent:0.2].CGColor;
    }
    
    return _shapeLayer;
}

@end
