//
//  BMEOpenTokSession.m
//  BeMyEyes
//
//  Created by Simon Støvring on 27/08/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import "BMEOpenTokSession.h"

@implementation BMEOpenTokSession

#pragma mark -
#pragma mark Lifecycle

- (void)dealloc {
    _sessionId = nil;
    _token = nil;
}

@end
