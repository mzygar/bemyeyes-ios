//
//  NSString+BMEDeviceToken.m
//  BeMyEyes
//
//  Created by Simon Støvring on 22/08/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "NSString+BMEDeviceToken.h"

#define BMEDeviceTokenTemporaryPrefix @"bmetemp"

@implementation NSString (BMEDeviceToken)

#pragma mark -
#pragma mark Public Methods

+ (NSString *)BMETemporaryDeviceToken {
    return [NSString stringWithFormat:@"%@-%@", BMEDeviceTokenTemporaryPrefix, [[NSUUID UUID] UUIDString]];
}

@end
