//
//  BMEBaseMainViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 15/03/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEBaseMainViewController.h"
#import <AVFoundation/AVFoundation.h>

@implementation BMEBaseMainViewController

#pragma mark -
#pragma mark Public Methods

- (void)requireMicrophoneEnabled:(void(^)(BOOL isEnabled))completion {
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (!granted) {
            NSString *title = NSLocalizedStringFromTable(@"ALERT_MICROPHONE_DISABLED_TITLE", @"BMEBaseMainViewController", @"Title in alert view shown when the microphone is disabled");
            NSString *message = NSLocalizedStringFromTable(@"ALERT_MICROPHONE_DISABLED_MESSAGE", @"BMEBaseMainViewController", @"Message in alert view shown when the microphone is disabled");
            NSString *cancelButton = NSLocalizedStringFromTable(@"ALERT_MICROPHONE_DISABLED_CANCEL_BUTTON", @"BMEBaseMainViewController", @"Title of cancel button in alert view shown when the microphone is disabled");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
            [alert show];
        }
        
        if (completion) {
            completion(granted);
        }
    }];
}

@end
