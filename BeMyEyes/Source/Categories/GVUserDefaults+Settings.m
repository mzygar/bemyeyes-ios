//
//  GVUserDefaults+Settings.m
//  BeMyEyes
//
//  Created by Simon Støvring on 18/04/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "GVUserDefaults+Settings.h"

@implementation GVUserDefaults (Settings)

@dynamic api, isRelease, deviceToken, isTemporaryDeviceToken, peopleHelped,
         hasAskedForMoreLanguages;

#pragma mark -
#pragma mark Settings

- (NSDictionary *)setupDefaults {
    return @{ @"api" : @(BMESettingsAPIPublic) };
}

#pragma mark -
#pragma mark Public Methods

+ (BOOL)synchronize {
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
