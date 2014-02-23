//
//  BMEUser.m
//  BeMyEyes
//
//  Created by Simon Støvring on 04/09/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import "BMEUser.h"

@implementation BMEUser

#pragma mark -
#pragma mark Lifecycle

- (void)dealloc {
    _userId =  nil;
    _username = nil;
    _email = nil;
    _firstName = nil;
    _lastName = nil;
    _languages = nil;
}

@end
