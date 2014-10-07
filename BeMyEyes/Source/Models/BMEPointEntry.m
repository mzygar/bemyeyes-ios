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
    } else if ([self.title isEqualToString:@"helped"]) {
        return BME_HELPER_MAIN_POINTS_ENTRY_HELPED_DESCRIPTION;
    } else if ([self.title isEqualToString:@"helped_failed"]) {
        return BME_HELPER_MAIN_POINTS_ENTRY_ATTEMPTED_HELP_DESCRIPTION;
    }
    return nil;
}

@end
