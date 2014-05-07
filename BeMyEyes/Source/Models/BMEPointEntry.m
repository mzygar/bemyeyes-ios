//
//  BMEPointEntry.m
//  BeMyEyes
//
//  Created by Simon Støvring on 07/05/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEPointEntry.h"

@implementation BMEPointEntry

#pragma mark -
#pragma mark Lifecycle

- (void)dealloc {
    _message = nil;
    _date = nil;
}

@end
