//
//  BMEPointGraphEntry.m
//  BeMyEyes
//
//  Created by Simon Støvring on 04/04/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEPointGraphEntry.h"

@implementation BMEPointGraphEntry

#pragma mark -
#pragma mark Lifecycle

- (instancetype)initWithPoints:(NSUInteger)points date:(NSDate *)date {
    if (self = [super init]) {
        _points = points;
        _date = date;
    }
    
    return self;
}

+ (instancetype)entryWithPoints:(NSUInteger)points date:(NSDate *)date {
    return [[[self class] alloc] initWithPoints:points date:date];
}

- (void)dealloc {
    _date = nil;
}

@end
