//
//  BMEUserTask.m
//  BeMyEyes
//
//  Created by Tobias DM on 07/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEUserTask.h"

@implementation BMEUserTask

#pragma mark -
#pragma mark Lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _type = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(type))];
        _completed = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(completed))];
        _points = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(points))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.type forKey:NSStringFromSelector(@selector(type))];
    [aCoder encodeBool:self.completed forKey:NSStringFromSelector(@selector(completed))];
    [aCoder encodeInteger:self.points forKey:NSStringFromSelector(@selector(points))];
}

- (void)dealloc {
}

#pragma mark - Public methods

- (NSString *)localizableKeyForType {
    switch (self.type) {
        case BMEUserTaskTypeShareOnFacebook:
            return BME_HELPER_MAIN_TASK_SHARE_ON_FACEBOOK_DESCRIPTION;
        case BMEUserTaskTypeShareOnTwitter:
            return BME_HELPER_MAIN_TASK_SHARE_ON_TWITTER_DESCRIPTION;
        case BMEUserTaskTypeWatchVideo:
            return BME_HELPER_MAIN_TASK_WATCH_VIDEO_DESCRIPTION;
        default:
            break;
    }
    return nil;
}

+ (NSString *)serverKeyForType:(BMEUserTaskType)type
{
    switch (type) {
        case BMEUserTaskTypeShareOnFacebook:
            return @"share_on_facebook";
        case BMEUserTaskTypeShareOnTwitter:
            return @"share_on_twitter";
        case BMEUserTaskTypeWatchVideo:
            return @"watch_video";
        default:
            return nil;
    }
}

+ (BMEUserTaskType)taskTypeForServerKey:(NSString *)key
{
    for (NSNumber *typeNum in @[@(BMEUserTaskTypeShareOnFacebook), @(BMEUserTaskTypeShareOnTwitter), @(BMEUserTaskTypeWatchVideo)]) {
        BMEUserTaskType type = typeNum.integerValue;
        if ([key isEqualToString:[self serverKeyForType:type]]) {
            return type;
        }
    }
    return BMEUserTaskTypeUnknown;
}

@end
