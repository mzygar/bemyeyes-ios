//
//  BMEToken.m
//  BeMyEyes
//
//  Created by Simon Støvring on 03/09/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import "BMEToken.h"

@implementation BMEToken

#pragma mark -
#pragma mark Lifecycle

- (void)dealloc {
    _token = nil;
    _expiryDate = nil;
}

@end
