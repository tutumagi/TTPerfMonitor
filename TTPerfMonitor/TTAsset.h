//
//  TTAsset.h
//  Demo
//
//  Created by 涂飞 on 16/9/14.
//  Copyright © 2016年 Tu. All rights reserved.
//

#ifndef TTAsset_h
#define TTAsset_h

#import <Foundation/Foundation.h>

extern NSException *_TTNotImplementedException(SEL cmd, Class cls);
/**
 * Throw an assertion for unimplemented methods.
 */
#define TT_NOT_IMPLEMENTED(method) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wmissing-method-return-type\"") \
_Pragma("clang diagnostic ignored \"-Wunused-parameter\"") \
method NS_UNAVAILABLE { @throw _TTNotImplementedException(_cmd, [self class]); } \
_Pragma("clang diagnostic pop")


#endif /* TTAsset_h */
