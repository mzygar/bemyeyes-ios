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
        return MKLocalizedFromTable(BME_SNOOZE_RELATIVE_DATE_SECOND, BMESnoozeRelativeDateLocalizationTable);
    } else if (deltaSeconds < BMERelativeTimeMinute) {
        return MKLocalizedFromTableWithFormat(BME_SNOOZE_RELATIVE_DATE_SECONDS, BMESnoozeRelativeDateLocalizationTable, deltaSeconds);
    } else if (deltaSeconds < 1.50f * BMERelativeTimeMinute) {
        return MKLocalizedFromTable(BME_SNOOZE_RELATIVE_DATE_MINUTE, BMESnoozeRelativeDateLocalizationTable);
    } else if (deltaSeconds < BMERelativeTimeHour) {
        CGFloat minutes = deltaSeconds / BMERelativeTimeMinute;
        return MKLocalizedFromTableWithFormat(BME_SNOOZE_RELATIVE_DATE_MINUTES, BMESnoozeRelativeDateLocalizationTable, minutes);
    } else if (deltaSeconds < 1.50f * BMERelativeTimeHour) {
        return MKLocalizedFromTable(BME_SNOOZE_RELATIVE_DATE_HOUR, BMESnoozeRelativeDateLocalizationTable);
    } else if (deltaSeconds < BMERelativeTimeDay) {
        CGFloat hours = deltaSeconds / BMERelativeTimeHour;
        return MKLocalizedFromTableWithFormat(BME_SNOOZE_RELATIVE_DATE_HOURS, BMESnoozeRelativeDateLocalizationTable, hours);
    } else if (deltaSeconds < 1.50f * BMERelativeTimeDay) {
        return MKLocalizedFromTable(BME_SNOOZE_RELATIVE_DATE_DAY, BMESnoozeRelativeDateLocalizationTable);
    } else if (deltaSeconds < BMERelativeTimeWeek) {
        CGFloat days = deltaSeconds / BMERelativeTimeDay;
        return MKLocalizedFromTableWithFormat(BME_SNOOZE_RELATIVE_DATE_DAYS, BMESnoozeRelativeDateLocalizationTable, days);
    } else if (deltaSeconds < 1.50f * BMERelativeTimeWeek) {
        return MKLocalizedFromTable(BME_SNOOZE_RELATIVE_DATE_WEEK, BMESnoozeRelativeDateLocalizationTable);
    } else if (deltaSeconds < BMERelativeTimeMonth) {
        CGFloat weeks = deltaSeconds / BMERelativeTimeWeek;
        return MKLocalizedFromTableWithFormat(BME_SNOOZE_RELATIVE_DATE_WEEKS, BMESnoozeRelativeDateLocalizationTable, weeks);
    } else if (deltaSeconds < 1.50f * BMERelativeTimeMonth) {
        return MKLocalizedFromTable(BME_SNOOZE_RELATIVE_DATE_MONTH, BMESnoozeRelativeDateLocalizationTable);
    } else if (deltaSeconds < BMERelativeTimeYear) {
        CGFloat months = deltaSeconds / BMERelativeTimeMonth;
        return MKLocalizedFromTableWithFormat(BME_SNOOZE_RELATIVE_DATE_MONTHS, BMESnoozeRelativeDateLocalizationTable, months);
    } else if (deltaSeconds < 1.50f * BMERelativeTimeYear) {
        return MKLocalizedFromTable(BME_SNOOZE_RELATIVE_DATE_YEAR, BMESnoozeRelativeDateLocalizationTable);
    } else {
        CGFloat years = deltaSeconds / BMERelativeTimeYear;
        return MKLocalizedFromTableWithFormat(BME_SNOOZE_RELATIVE_DATE_YEARS, BMESnoozeRelativeDateLocalizationTable, years);
    }
}

@end
