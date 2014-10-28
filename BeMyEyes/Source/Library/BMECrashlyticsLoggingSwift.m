//
//  BMECrashlyticsLoggingSwift.m
//  BeMyEyes
//
//  Created by Tobias Due Munk on 28/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMECrashlyticsLoggingSwift.h"

#import <Crashlytics/Crashlytics.h>

@implementation BMECrashlyticsLoggingSwift

+ (void)privateLog:(NSString *)string {
    CLSLog(string, nil);
}

+ (void)log:(NSString *)string {
    CLSNSLog(string, nil);
}

@end
