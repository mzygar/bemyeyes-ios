//
//  BMEAppDelegate.m
//  BeMyEyes
//
//  Created by Simon Støvring on 22/02/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEAppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <PSAlertView/PSPDFAlertView.h>
#import <Appirater/Appirater.h>
#import "BMEClient.h"
#import "BMECallViewController.h"
#import "BMECallAudioPlayer.h"

@interface BMEAppDelegate () <UIAlertViewDelegate>
@property (strong, nonatomic) PSPDFAlertView *callAlertView;
@property (strong, nonatomic) BMECallAudioPlayer *callAudioPlayer;
@property (copy, nonatomic) void(^requireRemoteNotificationsHandler)(BOOL, NSString*, NSError*);
@property (assign, nonatomic, getter = isLaunchedWithShortID) BOOL launchedWithShortID;
@end

@implementation BMEAppDelegate

#pragma mark -
#pragma mark Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString *shortIdInLaunchOptions = [self shortIdInLaunchOptions:launchOptions];
    self.launchedWithShortID = (shortIdInLaunchOptions != nil);
    
    [NewRelicAgent startWithApplicationToken:@"AA9b45f5411736426b5fac31cce185b50d173d99ea"];
    [self configureRESTClient];
    [self checkIfLoggedIn];
    
    if (self.isLaunchedWithShortID) {
        [self performSelector:@selector(didAnswerCallWithShortId:) withObject:shortIdInLaunchOptions afterDelay:0.0f];
        [self resetBadgeIcon];
    }
    
    if ([BMEAppStoreId length] > 0) {
        [Appirater setAppId:BMEAppStoreId];
        [Appirater setDaysUntilPrompt:5];
        [Appirater setUsesUntilPrompt:2];
        [Appirater setSignificantEventsUntilPrompt:2];
        [Appirater setTimeBeforeReminding:2];
        [Appirater appLaunched:NO];
    }
    
    UITapGestureRecognizer *secretTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSecretTapGesture:)];
    secretTapGesture.numberOfTouchesRequired = 4;
    secretTapGesture.numberOfTapsRequired = 3;
    [self.window addGestureRecognizer:secretTapGesture];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // We enter the background, reset the launched with short ID state to prepare for next launch
    self.launchedWithShortID = NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if ([[BMEClient sharedClient] isLoggedIn] && !self.launchedWithShortID) {
        [self checkForPendingRequestIfIconHasBadge];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    if (!apsInfo) {
        return;
    }
    
    id alert = [apsInfo objectForKey:@"alert"];
    if (!alert) {
        return;
    }
    
    if (application.applicationState == UIApplicationStateActive) {
        if ([alert isKindOfClass:[NSDictionary class]]) {
            NSString *shortId = [alert objectForKey:@"short_id"];;
            if (shortId) {
                if (self.callAlertView) {
                    [self.callAlertView dismissWithClickedButtonIndex:[self.callAlertView cancelButtonIndex] animated:NO];
                }
                
                NSString *actionLocKey = [alert objectForKey:@"action-loc-key"];
                NSString *locKey = [alert objectForKey:@"loc-key"];
                NSArray *locArgs = [alert objectForKey:@"loc-args"];
                NSString *name = NSLocalizedStringFromTable(@"ALERT_PUSH_REQUEST_DEFAULT_NAME", @"BMEAppDelegate", @"Default name used in alert view shown when a call is received while the app was active. The name is only used if no name is provided in localizable arguments.");
                if ([locArgs count] > 0) {
                    name = locArgs[0];
                }
                
                NSString *title = NSLocalizedStringFromTable(@"ALERT_PUSH_REQUEST_TITLE", @"BMEAppDelegate", @"Title in alert view shown when a call is received while the app was active");
                NSString *message = [NSString stringWithFormat:NSLocalizedString(locKey, nil), name];
                NSString *actionButton = NSLocalizedString(actionLocKey, nil);
                NSString *cancelButton = NSLocalizedStringFromTable(@"ALERT_PUSH_REQUEST_CANCEL", @"BMEAppDelegate", @"Title of cancel button in alert view shown when a call is received while the app was active");
                
                [self playCallTone];
                
                __weak typeof(self) weakSelf = self;
                self.callAlertView = [[PSPDFAlertView alloc] initWithTitle:title message:message];
                [self.callAlertView addButtonWithTitle:actionButton block:^{
                    [weakSelf didAnswerCallWithShortId:shortId];
                    [weakSelf stopCallTone];
                }];
                [self.callAlertView setCancelButtonWithTitle:cancelButton block:^{
                    [weakSelf stopCallTone];
                }];
                [self.callAlertView show];
            }
        } else if ([alert isKindOfClass:[NSString class]]) {
            PSPDFAlertView *alertView = [[PSPDFAlertView alloc] initWithTitle:nil message:alert];
            [alertView setCancelButtonWithTitle:@"OK" block:nil];
            [alertView show];
        }
    } else if (application.applicationState == UIApplicationStateInactive) {
        // If the application state was inactive, this means the user pressed an action button from a notification
        if ([alert isKindOfClass:[NSDictionary class]]) {
            NSString *shortId = [alert objectForKey:@"short_id"];;
            if (shortId) {
                // The app was launched from a remote notification that contained a short ID
                self.launchedWithShortID = YES;
                [self didAnswerCallWithShortId:shortId];
            }
        }
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Did register for remote notifications");
    [[BMEClient sharedClient] registerDeviceWithDeviceToken:deviceToken productionOrAdHoc:BMEIsProductionOrAdHoc completion:^(BOOL success, NSError *error) {
        NSString *normalizedDeviceToken = BMENormalizedDeviceTokenStringWithDeviceToken(deviceToken);
        if (!error && normalizedDeviceToken) {
            [GVUserDefaults standardUserDefaults].deviceToken = normalizedDeviceToken;
            
            if (self.requireRemoteNotificationsHandler) {
                self.requireRemoteNotificationsHandler(YES, normalizedDeviceToken, error);
                self.requireRemoteNotificationsHandler = nil;
            }
        } else {
            if (self.requireRemoteNotificationsHandler) {
                self.requireRemoteNotificationsHandler(NO, nil, error);
                self.requireRemoteNotificationsHandler = nil;
            }
        }
        
        if (error) {
            NSLog(@"Failed registering device: %@", error);
        }
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed registering for remote notifications: %@", error);
    
    if (self.requireRemoteNotificationsHandler) {
        self.requireRemoteNotificationsHandler(NO, nil, error);
        self.requireRemoteNotificationsHandler = nil;
    }
}

#pragma mark -
#pragma mark Public Methods

- (void)registerForRemoteNotifications {
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

- (void)requirePushNotificationsEnabled:(void (^)(BOOL isEnabled))handler {
    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    BOOL isEnabled = types & UIRemoteNotificationTypeAlert;
    if (!isEnabled) {
        NSString *title = NSLocalizedStringFromTable(@"ALERT_PUSH_NOT_ENABLED_TITLE", @"BMEAppDelegate", @"Title in alert view shown if push notifications are not enabled");
        NSString *message = NSLocalizedStringFromTable(@"ALERT_PUSH_NOT_ENABLED_MESSAGE", @"BMEAppDelegate", @"MEssage in alert view shown if push notifications are not enabled");
        NSString *cancelButton = NSLocalizedStringFromTable(@"ALERT_PUSH_NOT_ENABLED_CANCEL", @"BMEAppDelegate", @"Title of cancel button in alert view shown if push notifications are not enabled");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
        [alert show];
    }
 
    if (handler) {
        handler(isEnabled);
    }
}

- (void)requireMicrophoneEnabled:(void(^)(BOOL isEnabled))completion {
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (!granted) {
            NSString *title = NSLocalizedStringFromTable(@"ALERT_MICROPHONE_DISABLED_TITLE", @"BMEAppDelegate", @"Title in alert view shown when the microphone is disabled");
            NSString *message = NSLocalizedStringFromTable(@"ALERT_MICROPHONE_DISABLED_MESSAGE", @"BMEAppDelegate", @"Message in alert view shown when the microphone is disabled");
            NSString *cancelButton = NSLocalizedStringFromTable(@"ALERT_MICROPHONE_DISABLED_CANCEL_BUTTON", @"BMEAppDelegate", @"Title of cancel button in alert view shown when the microphone is disabled");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
            [alert show];
        }
        
        if (completion) {
            completion(granted);
        }
    }];
}

- (void)requireDeviceRegisteredForRemoteNotifications:(void(^)(BOOL isRegistered, NSString *deviceToken, NSError *error))handler {
    self.requireRemoteNotificationsHandler = handler;
    [self registerForRemoteNotifications];
}

#pragma mark -
#pragma mark Private Methods

- (void)configureRESTClient {
    [[BMEClient sharedClient] setUsername:BMEAPIUsername password:BMEAPIPassword];
    [BMEClient sharedClient].facebookAppId = BMEFacebookAppId;
}

- (void)checkIfLoggedIn {
    NSLog(@"Check if logged in");
    if ([GVUserDefaults standardUserDefaults].deviceToken != nil && [[BMEClient sharedClient] isTokenValid]) {
        UIViewController *mainController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:BMEMainControllerIdentifier];
        [self replaceTopController:mainController];
        
        [[BMEClient sharedClient] loginUsingUserTokenWithDeviceToken:[GVUserDefaults standardUserDefaults].deviceToken completion:^(BOOL success, NSError *error) {
            if (success) {
                [self didLogin];
            } else {
                NSLog(@"Could not automatically log in: %@", error);
                NSString *message = [NSString stringWithFormat:@"Log in failed and you have automatically been logged out. (Error code %i)", [error code]];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"DEMO ONLY" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
                
                [self loginFailed];
            }
        }];
    } else {
        NSLog(@"Device token: %@", [GVUserDefaults standardUserDefaults].deviceToken);
        NSLog(@"Is valid: %@", [BMEClient sharedClient].isTokenValid ? @"YES" : @"NO");
    }
}

- (void)loginFailed {
    self.window.rootViewController = [self.window.rootViewController.storyboard instantiateInitialViewController];
    
    [[BMEClient sharedClient] logoutWithCompletion:nil];
    [[BMEClient sharedClient] resetLogin];
    [self resetBadgeIcon];
}

- (void)didLogin {
    [[BMEClient sharedClient] updateUserInfoWithUTCOffset:nil];
    [[BMEClient sharedClient] updateDeviceWithDeviceToken:[GVUserDefaults standardUserDefaults].deviceToken productionOrAdHoc:BMEIsProductionOrAdHoc];
    
    if (!self.isLaunchedWithShortID) {
        [self checkForPendingRequestIfIconHasBadge];
    }
}

- (void)replaceTopController:(UIViewController *)topController {
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    navigationController.viewControllers = @[ topController ];
}

- (NSString *)shortIdInLaunchOptions:(NSDictionary *)launchOptions {
    NSDictionary *userInfo = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    NSDictionary *alertInfo = [apsInfo objectForKey:@"alert"];
    return [alertInfo objectForKey:@"short_id"];
}

- (void)didAnswerCallWithShortId:(NSString *)shortId {
    [self requireMicrophoneEnabled:^(BOOL isEnabled) {
        if (isEnabled) {
            BMECallViewController *callController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:BMECallControllerIdentifier];
            callController.callMode = BMECallModeAnswer;
            callController.shortId = shortId;
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:callController];
            navigationController.navigationBarHidden = YES;
            
            UINavigationController *rootNavigationController = (UINavigationController *)self.window.rootViewController;
            [rootNavigationController presentViewController:navigationController animated:YES completion:nil];
        }
    }];
}

- (void)presentSecretSettings {
    UIViewController *secretSettingsController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:BMESecretSettingsControllerIdentifier];
    
    UIViewController *presentFromController = self.window.rootViewController;
    if (presentFromController.presentedViewController) {
        presentFromController = presentFromController.presentedViewController;
    }
    
    [presentFromController presentViewController:secretSettingsController animated:YES completion:nil];
}

- (void)handleSecretTapGesture:(UITapGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self presentSecretSettings];
    }
}

- (void)playCallTone {
    if (!self.callAudioPlayer) {
        NSError *error = nil;
        self.callAudioPlayer = [BMECallAudioPlayer playerWithError:&error];
        if (!error) {
            if ([self.callAudioPlayer prepareToPlay]) {
                [self.callAudioPlayer play];
            }
        }
    }
}

- (void)stopCallTone {
    if (self.callAudioPlayer) {
        [self.callAudioPlayer stop];
        self.callAudioPlayer = nil;
    }
}

- (void)resetBadgeIcon {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)checkForPendingRequestIfIconHasBadge {
    NSUInteger badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
    if (badgeCount > 0) {
        [[BMEClient sharedClient] checkForPendingRequest:^(NSString *shortId, BOOL success, NSError *error) {
            if (success) {
                if (shortId) {
                    [self didAnswerCallWithShortId:shortId];
                } else {
                    NSString *title = NSLocalizedStringFromTable(@"ALERT_PENDING_REQUEST_HANDLED_TITLE", @"BMEAppDelegate", @"Title in alert view shown when the app icon shows a badge but the pending request has been answered or cancelled");
                    NSString *message = NSLocalizedStringFromTable(@"ALERT_PENDING_REQUEST_HANDLED_MESSAGE", @"BMEAppDelegate", @"Message in alert view shown when the app icon shows a badge but the pending request has been answered or cancelled");
                    NSString *cancelButton = NSLocalizedStringFromTable(@"ALERT_PENDING_REQUEST_HANDLED_CANCEL", @"BMEAppDelegate", @"Title of cancel button in alert view shown when the app icon shows a badge but the pending request has been answered or cancelled");
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
                    [alertView show];
                }
            } else {
                NSLog(@"Could not load pending request: %@", error);
                
                NSString *title = NSLocalizedStringFromTable(@"ALERT_PENDING_REQUEST_NOT_LOADED_TITLE", @"BMEAppDelegate", @"Title in alert view shown when the app icon shows a badge but the pending request could not be loaded");
                NSString *message = NSLocalizedStringFromTable(@"ALERT_PENDING_REQUEST_NOT_LOADED_MESSAGE", @"BMEAppDelegate", @"Message in alert view shown when the app icon shows a badge but the pending request could not be loaded");
                NSString *cancelButton = NSLocalizedStringFromTable(@"ALERT_PENDING_REQUEST_NOT_LOADED_CANCEL", @"BMEAppDelegate", @"Title of cancel button in alert view shown when the app icon shows a badge but the pending rcould not be loaded");
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
                [alertView show];
            }
        }];
    }

    [self resetBadgeIcon];
}

@end
