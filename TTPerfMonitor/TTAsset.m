//
//  TTAssert.m
//  Demo
//
//  Created by 涂飞 on 16/9/14.
//  Copyright © 2016年 Tu. All rights reserved.
//
#import "TTAsset.h"


NSException *_TTNotImplementedException(SEL cmd, Class cls)
{
    NSString *msg = [NSString stringWithFormat:@"%s is not implemented "
                     "for the class %@", sel_getName(cmd), cls];
    return [NSException exceptionWithName:@"TTNotDesignatedInitializerException"
                                   reason:msg userInfo:nil];
}

