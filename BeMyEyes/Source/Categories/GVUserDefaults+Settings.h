//
//  GVUserDefaults+Settings.h
//  BeMyEyes
//
//  Created by Simon Støvring on 18/04/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "GVUserDefaults.h"

typedef NS_ENUM(NSInteger, BMESettingsAPI) {
    BMESettingsAPIDevelopment = 0,
    BMESettingsAPIStaging,
    BMESettingsAPIPublic
};

@interface GVUserDefaults (Settings)

@property (assign, nonatomic) BMESettingsAPI api;

@end
