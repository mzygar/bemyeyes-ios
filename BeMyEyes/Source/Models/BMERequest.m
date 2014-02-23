//
//  BMERequest.m
//  BeMyEyes
//
//  Created by Simon Støvring on 27/08/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import "BMERequest.h"

@implementation BMERequest

#pragma mark -
#pragma mark Lifecycle

- (void)dealloc {
    _shortId = nil;
    _openTok = nil;
    _blindName = nil;
    _helperName = nil;
}

@end
