//
//  BMECommunityStats.m
//  BeMyEyes
//
//  Created by Tobias DM on 29/09/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMECommunityStats.h"

@implementation BMECommunityStats

#pragma mark -
#pragma mark Lifecycle

- (void)dealloc {
    _blind = nil;
    _sighted = nil;
    _helped = nil;
}

@end
