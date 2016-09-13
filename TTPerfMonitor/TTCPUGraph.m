//
//  TTCPUGraph.m
//  TT
//
//  Created by 涂飞 on 16/7/28.
//  Copyright © 2016年 TT. All rights reserved.
//

#import "TTCPUGraph.h"
#import "TTAsset.h"

#import <mach/mach.h>

static //c++
float cpu_usage()
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

@interface TTCPUGraph ()
{
    CGFloat *_cpuUsages;
}

@property (nonatomic, assign) CGFloat preCpuUsage;
@property (nonatomic, strong) UILabel *cpuLabel;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, assign) NSUInteger length;
@property (nonatomic, assign) NSUInteger height;

@property (nonatomic, assign) CGFloat maxCpuUsage;
@property (nonatomic, assign) CGFloat minCpuUsage;

@property (nonatomic, strong) UIColor *bgColor;
@end

@implementation TTCPUGraph

TT_NOT_IMPLEMENTED(- (instancetype)initWithFrame:(CGRect)frame);
TT_NOT_IMPLEMENTED(- (instancetype)initWithCoder:(NSCoder *)aDecoder);

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color{
    if (self = [super initWithFrame:frame])
    {
        _maxCpuUsage = 100.0;
        _minCpuUsage = 0.0;
        _preCpuUsage = CGFLOAT_MAX;
        
        _length = (NSUInteger)frame.size.width;
        _height = (NSUInteger)frame.size.height;
        _cpuUsages = calloc(sizeof(CGFloat), _length);
        
        _bgColor = color;
        [self.layer addSublayer:self.shapeLayer];
        [self addSubview:self.cpuLabel];
    }
    return self;
}

- (void)dealloc{
    free(_cpuUsages);
}

- (void)update{
    CGFloat curCpuUsage = cpu_usage();
    [self updateWithCpuUsage:curCpuUsage];
}

- (void)updateWithCpuUsage:(CGFloat)curCpuUsage{
    if (_preCpuUsage == CGFLOAT_MAX)
    {
        _preCpuUsage = curCpuUsage;
    }
    else
    {
        _cpuLabel.text = [NSString stringWithFormat:@"%.1f%%", curCpuUsage];
        CGFloat scale = 100.0 / _height;
        
        //cpu使用率 打点数据 前移一个位置
        for (int i = 0; i < _length - 1; ++i)
        {
            _cpuUsages[i] = _cpuUsages[i+1];
        }
        _cpuUsages[_length - 1] = curCpuUsage / scale;
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 0, _height);
        for (int i = 0; i < _length; ++i)
        {
            CGPathAddLineToPoint(path, NULL, i, _height - _cpuUsages[i]);
        }
        CGPathAddLineToPoint(path, NULL, _length - 1, _height);
        
        self.shapeLayer.path = path;
        
        _preCpuUsage = curCpuUsage;
        
        CGPathRelease(path);
    }
}

- (UILabel *)cpuLabel{
    if (!_cpuLabel)
    {
        _cpuLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _cpuLabel.font = [UIFont boldSystemFontOfSize:11];
        _cpuLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _cpuLabel;
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
