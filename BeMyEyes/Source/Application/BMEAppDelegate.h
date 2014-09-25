//
//  BMEAppDelegate.h
//  BeMyEyes
//
//  Created by Simon Støvring on 22/02/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TheAppDelegate ((BMEAppDelegate *)[UIApplication sharedApplication].delegate)

@interface BMEAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)registerForRemoteNotifications;
- (void)requireMicrophoneEnabled:(void(^)(BOOL isEnabled))completion;

@end
