//
//  BMEAccessControlHandler.m
//  BeMyEyes
//
//  Created by Tobias DM on 09/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEAccessControlHandler.h"
#import <AVFoundation/AVFoundation.h>

@implementation BMEAccessControlHandler

#pragma mark -
#pragma mark Public Methods


// Remote notifications
+ (void)registerForRemoteNotifications {
    NSLog(@"Register for remote notifications");
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    }
}


// Microphone
+ (void)requireMicrophoneEnabled:(void(^)(BOOL isEnabled))completion {
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (!granted) {
            NSString *title = MKLocalizedFromTable(BME_APP_DELEGATE_ALERT_MICROPHONE_DISABLED_TITLE, BMEAppDelegateLocalizationTable);
            NSString *message = MKLocalizedFromTable(BME_APP_DELEGATE_ALERT_MICROPHONE_DISABLED_MESSAGE, BMEAppDelegateLocalizationTable);
            NSString *cancelButton = MKLocalizedFromTable(BME_APP_DELEGATE_ALERT_MICROPHONE_DISABLED_CANCEL, BMEAppDelegateLocalizationTable);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
            [alert show];
        }
        
        if (completion) {
            completion(granted);
        }
    }];
}

+ (void)hasMicrophoneEnabled:(void(^)(BOOL isEnabled))completion {
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (completion) {
            completion(granted);
        }
    }];
}


// Video
+ (void)requireVideoEnabled:(void(^)(BOOL isEnabled))completion {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (!granted) {
            NSString *title = MKLocalizedFromTable(BME_APP_DELEGATE_ALERT_MICROPHONE_DISABLED_TITLE, BMEAppDelegateLocalizationTable);
            NSString *message = MKLocalizedFromTable(BME_APP_DELEGATE_ALERT_MICROPHONE_DISABLED_MESSAGE, BMEAppDelegateLocalizationTable);
            NSString *cancelButton = MKLocalizedFromTable(BME_APP_DELEGATE_ALERT_MICROPHONE_DISABLED_CANCEL, BMEAppDelegateLocalizationTable);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
            [alert show];
        }
        
        if (completion) {
            completion(granted);
        }
    }];
}

+ (void)hasVideoEnabled:(void(^)(BOOL isEnabled))completion {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if (deviceInput)
    {
        // Access to the camera succeeded.
        if (completion) {
            completion(YES);
        }
        return;
    }
    if (completion) {
        completion(NO);
    }
}

@end
