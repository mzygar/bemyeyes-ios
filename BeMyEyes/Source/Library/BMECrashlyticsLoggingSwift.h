//
//  BMECrashlyticsLoggingSwift.h
//  BeMyEyes
//
//  Created by Tobias Due Munk on 28/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMECrashlyticsLoggingSwift : NSObject

+ (void)privateLog:(NSString *)string;
+ (void)log:(NSString *)string;

@end
