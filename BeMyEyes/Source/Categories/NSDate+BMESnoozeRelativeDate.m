//
//  NSDate+BMESnoozeRelativeDate.m
//  BeMyEyes
//
//  Created by Simon Støvring on 19/04/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "NSDate+BMESnoozeRelativeDate.h"

#define BMERelativeTimeSecond (CGFloat)1
#define BMERelativeTimeMinute (CGFloat)(60 * BMERelativeTimeSecond)
#define BMERelativeTimeHour (CGFloat)(60 * BMERelativeTimeMinute)
#define BMERelativeTimeDay (CGFloat)(24 * BMERelativeTimeHour)
#define BMERelativeTimeWeek (CGFloat)(7 * BMERelativeTimeDay)
#define BMERelativeTimeMonth (CGFloat)(4 * BMERelativeTimeWeek)
#define BMERelativeTimeYear (CGFloat)(365 * BMERelativeTimeDay)

@implementation NSDate (BMESnoozeRelativeDate)

#pragma mark -
#pragma mark Public Methods

#pragma mark -
#pragma mark Public Methods

- (NSString *)BMESnoozeRelativeDate {
    NSDate *currentDate = [NSDate date];
    CGFloat deltaSeconds = fabs([self timeIntervalSinceDate:currentDate]);
    if (deltaSeconds < 1.50f * BMERelativeTimeSecond) {
        return NSLocalizedStringFromTable(@"SECOND", @"BMESnoozeRelativeDate", nil);
    } else if (deltaSeconds < BMERelativeTimeMinute) {
        return [NSString stringWithFormat:NSLocalizedStringFromTable(@"SECONDS", @"BMESnoozeRelativeDate", nil), deltaSeconds];
    } else if (deltaSeconds < 1.50f * BMERelativeTimeMinute) {
        return NSLocalizedStringFromTable(@"MINUTE", @"BMESnoozeRelativeDate", nil);
    } else if (deltaSeconds < BMERelativeTimeHour) {
        CGFloat minutes = deltaSeconds / BMERelativeTimeMinute;
        return [NSString stringWithFormat:NSLocalizedStringFromTable(@"MINUTES", @"BMESnoozeRelativeDate", nil), minutes];
    } else if (deltaSeconds < 1.50f * BMERelativeTimeHour) {
        return NSLocalizedStringFromTable(@"HOUR", @"BMESnoozeRelativeDate", nil);
    } else if (deltaSeconds < BMERelativeTimeDay) {
        CGFloat hours = deltaSeconds / BMERelativeTimeHour;
        return [NSString stringWithFormat:NSLocalizedStringFromTable(@"HOURS", @"BMESnoozeRelativeDate", nil), hours];
    } else if (deltaSeconds < 1.50f * BMERelativeTimeDay) {
        return NSLocalizedStringFromTable(@"DAY", @"BMESnoozeRelativeDate", nil);
    } else if (deltaSeconds < BMERelativeTimeWeek) {
        CGFloat days = deltaSeconds / BMERelativeTimeDay;
        return [NSString stringWithFormat:NSLocalizedStringFromTable(@"DAYS", @"BMESnoozeRelativeDate", nil), days];
    } else if (deltaSeconds < 1.50f * BMERelativeTimeWeek) {
        return NSLocalizedStringFromTable(@"WEEK", @"BMESnoozeRelativeDate", nil);
    } else if (deltaSeconds < BMERelativeTimeMonth) {
        CGFloat weeks = deltaSeconds / BMERelativeTimeWeek;
        return [NSString stringWithFormat:NSLocalizedStringFromTable(@"WEEKS", @"BMESnoozeRelativeDate", nil), weeks];
    } else if (deltaSeconds < 1.50f * BMERelativeTimeMonth) {
        return NSLocalizedStringFromTable(@"MONTH", @"BMESnoozeRelativeDate", nil);
    } else if (deltaSeconds < BMERelativeTimeYear) {
        CGFloat months = deltaSeconds / BMERelativeTimeMonth;
        return [NSString stringWithFormat:NSLocalizedStringFromTable(@"MONTHS", @"BMESnoozeRelativeDate", nil), months];
    } else if (deltaSeconds < 1.50f * BMERelativeTimeYear) {
        return NSLocalizedStringFromTable(@"YEAR", @"BMESnoozeRelativeDate", nil);
    } else {
        CGFloat years = deltaSeconds / BMERelativeTimeYear;
        return [NSString stringWithFormat:NSLocalizedStringFromTable(@"YEARS", @"BMESnoozeRelativeDate", nil), years];
    }
}

@end
