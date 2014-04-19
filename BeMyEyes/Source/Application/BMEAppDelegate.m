//
//  BMEAppDelegate.m
//  BeMyEyes
//
//  Created by Simon Støvring on 22/02/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEAppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <HIPSocialAuth/HIPSocialAuthManager.h>
#import <PSAlertView/PSPDFAlertView.h>
#import "BMEClient.h"
#import "BMECallViewController.h"

@interface BMEAppDelegate ()
@property (strong, nonatomic) PSPDFAlertView *callAlertView;
@end

@implementation BMEAppDelegate

#pragma mark -
#pragma mark Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self configureRESTClient];
    [self checkIfLoggedIn];
    [self checkIfAppOpenedByAnsweringWithLaunchOptions:launchOptions];
    
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [[HIPSocialAuthManager sharedManager] handleOpenURL:url];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    if (!apsInfo) {
        return;
    }
    
    NSDictionary *alertInfo = [apsInfo objectForKey:@"alert"];
    if (!alertInfo) {
        return;
    }
    
    NSString *shortId = [alertInfo objectForKey:@"short_id"];
    
    if (application.applicationState == UIApplicationStateActive) {
        if (shortId) {
            if (self.callAlertView) {
                [self.callAlertView dismissWithClickedButtonIndex:[self.callAlertView cancelButtonIndex] animated:NO];
            }
            
            NSString *actionLocKey = [alertInfo objectForKey:@"action-loc-key"];
            NSString *locKey = [alertInfo objectForKey:@"loc-key"];
            NSArray *locArgs = [alertInfo objectForKey:@"loc-args"];
            NSString *name = NSLocalizedStringFromTable(@"ALERT_PUSH_REQUEST_DEFAULT_NAME", @"BMEAppDelegate", @"Default name used in alert view shown when a call is received while the app was active. The name is only used if no name is provided in localizable arguments.");
            if ([locArgs count] > 0) {
                name = locArgs[0];
            }
            
            NSString *title = NSLocalizedStringFromTable(@"ALERT_PUSH_REQUEST_TITLE", @"BMEAppDelegate", @"Title in alert view shown when a call is received while the app was active");
            NSString *message = [NSString stringWithFormat:NSLocalizedString(locKey, nil), name];
            NSString *actionButton = NSLocalizedString(actionLocKey, nil);
            NSString *cancelButton = NSLocalizedStringFromTable(@"ALERT_PUSH_REQUEST_CANCEL", @"BMEAppDelegate", @"Title of cancel button in alert view shown when a call is received while the app was active");
            
            __weak typeof(self) weakSelf = self;
            self.callAlertView = [[PSPDFAlertView alloc] initWithTitle:title message:message];
            [self.callAlertView addButtonWithTitle:actionButton block:^{
                [weakSelf didAnswerCallWithShortId:shortId];
            }];
            [self.callAlertView setCancelButtonWithTitle:cancelButton block:nil];
            [self.callAlertView show];
        }
    } else if (application.applicationState == UIApplicationStateInactive) {
        // If the application state was inactive, this means the user pressed an action button from a notification
        if (shortId) {
            [self didAnswerCallWithShortId:shortId];
        }
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // We cannot register the device of the user without knowing who he is.
    // That is, he needs to be logged in and thus have a token.
    if ([BMEClient sharedClient].token) {
        [[BMEClient sharedClient] registerDeviceWithDeviceToken:deviceToken productionOrAdHoc:BMEIsProductionOrAdHoc completion:^(BOOL success, NSError *error) {
            if (error) {
                NSLog(@"Failed registering device: %@", error);
            }
        }];
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

#pragma mark -
#pragma mark Private Methods

- (void)configureRESTClient {
    [[BMEClient sharedClient] setUsername:BMEAPIUsername password:BMEAPIPassword];
    [BMEClient sharedClient].facebookAppId = BMEFacebookAppId;
}

- (void)checkIfLoggedIn {
    NSLog(@"Check if logged in");
    if ([[BMEClient sharedClient] token] != nil && [[BMEClient sharedClient] isTokenValid]) {
        UIViewController *mainController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:BMEMainControllerIdentifier];
        [self replaceTopController:mainController];
        
        [[BMEClient sharedClient] loginUsingTokenWithCompletion:^(BOOL success, NSError *error) {
            if (error) {
                NSLog(@"Error: %@", error);
            }
         
            switch ([error code]) {
                case BMEClientErrorUserNotFound:
                case BMEClientErrorUserFacebookUserNotFound:
                case BMEClientErrorUserTokenNotFound:
                case BMEClientErrorUserTokenExpired:
                    NSLog(@"Log in not valid. Log out.");
                    self.window.rootViewController = [self.window.rootViewController.storyboard instantiateInitialViewController];
                    [[BMEClient sharedClient] logoutWithCompletion:nil];
                    NSLog(@"Could not automatically log in: %@", error);
                    break;
                default:
                    NSLog(@"Did log in");
                    [self didLogin];
                    break;
            }
        }];
    } else {
        NSLog(@"Token: %@", [BMEClient sharedClient].token);
        NSLog(@"Is valid: %@", [BMEClient sharedClient].isTokenValid ? @"YES" : @"NO");
    }
}

- (void)didLogin {
    [self registerForRemoteNotifications];
}

- (void)replaceTopController:(UIViewController *)topController {
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    navigationController.viewControllers = @[ topController ];
}

- (void)checkIfAppOpenedByAnsweringWithLaunchOptions:(NSDictionary *)launchOptions {
    NSDictionary *userInfo = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    NSDictionary *alertInfo = [apsInfo objectForKey:@"alert"];
    if ([alertInfo objectForKey:@"short_id"]) {
        NSString *shortId = [alertInfo objectForKey:@"short_id"];
        [self performSelector:@selector(didAnswerCallWithShortId:) withObject:shortId afterDelay:0.0f];
    }
}

- (void)didAnswerCallWithShortId:(NSString *)shortId {
    [self requireMicrophoneEnabled:^(BOOL isEnabled) {
        if (isEnabled) {
            BMECallViewController *callController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:BMECallControllerIdentifier];
            callController.callMode = BMECallModeAnswer;
            callController.shortId = shortId;
            
            UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
            [navigationController presentViewController:callController animated:YES completion:nil];
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

@end
