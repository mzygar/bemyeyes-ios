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

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _point = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(point))];
        _title = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(title))];
        _date = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(date))];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.point forKey:NSStringFromSelector(@selector(point))];
    [aCoder encodeObject:self.title forKey:NSStringFromSelector(@selector(title))];
    [aCoder encodeObject:self.date forKey:NSStringFromSelector(@selector(date))];
}

- (void)dealloc {
    _title = nil;
    _date = nil;
}

#pragma mark - Public methods

- (NSString *)localizableKeyForTitle {
    if ([self.title isEqualToString:@"signup"]) {
        return BME_HELPER_MAIN_POINTS_ENTRY_SIGNUP_DESCRIPTION;
    } else if ([self.title isEqualToString:@"answer_push_message"]) {
        return BME_HELPER_MAIN_POINTS_ENTRY_ANSWER_PUSH_MESSAGE_DESCRIPTION;
    } else if ([self.title isEqualToString:@"answer_push_message_technical_error"]) {
        return BME_HELPER_MAIN_POINTS_ENTRY_ANSWER_PUSH_MESSAGE_TECHNICAL_ERROR_DESCRIPTION;
    } else if ([self.title isEqualToString:@"finish_helping_request"]) {
        return BME_HELPER_MAIN_POINTS_ENTRY_FINISH_HELPING_REQUEST_DESCRIPTION;
    } else if ([self.title isEqualToString:@"finish_10_helping_request_in_a_week"]) {
        return BME_HELPER_MAIN_POINTS_ENTRY_FINISH_10_HELPING_REQUESTS_IN_A_WEEK_DESCRIPTION;
    } else if ([self.title isEqualToString:@"finish_5_high_fives_in_a_week"]) {
        return BME_HELPER_MAIN_POINTS_ENTRY_FINISH_5_HIGH_FIVES_IN_A_WEEK_DESCRIPTION;
    } else if ([self.title isEqualToString:@"share_on_twitter"]) {
        return BME_HELPER_MAIN_POINTS_ENTRY_SHARE_ON_TWITTER_DESCRIPTION;
    } else if ([self.title isEqualToString:@"share_on_facebook"]) {
        return BME_HELPER_MAIN_POINTS_ENTRY_SHARE_ON_FACEBOOK_DESCRIPTION;
    } else if ([self.title isEqualToString:@"watch_video"]) {
        return BME_HELPER_MAIN_POINTS_ENTRY_WATCH_VIDEO_DESCRIPTION;
    }
    return nil;
}

@end
