//
//  BMEAppDelegate.m
//  BeMyEyes
//
//  Created by Simon Støvring on 22/02/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEAppDelegate.h"
#import <HPSocialNetworkManager/HPAccountManager.h>
#import <PSAlertView/PSPDFAlertView.h>
#import "BMEClient.h"

@implementation BMEAppDelegate

#pragma mark -
#pragma mark Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self configureRESTClient];
    [self checkIfLoggedIn];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [[HPAccountManager sharedManager] handleOpenURL:url];
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
            PSPDFAlertView *alertView = [[PSPDFAlertView alloc] initWithTitle:title message:message];
            [alertView addButtonWithTitle:actionButton block:^{
//                [self handleAnswerActionForShortId:shortId];
            }];
            [alertView setCancelButtonWithTitle:cancelButton block:nil];
            [alertView show];
        }
    } else if (application.applicationState == UIApplicationStateInactive) {
        // If the application state was inactive, this means the user pressed an action button from a notification
        if (shortId) {
//            [self handleAnswerActionForShortId:shortId];
        }
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // We cannot register the device of the user without knowing who he is.
    // That is, he needs to be logged in and thus have a token.
    if ([BMEClient sharedClient].token) {
        [[BMEClient sharedClient] registerDeviceWithDeviceToken:deviceToken productionOrAdHoc:NO completion:^(BOOL success, NSError *error) {
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

- (void)requirePushNotificationsEnabled:(void (^)(BOOL))handler {
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

#pragma mark -
#pragma mark Private Methods

- (void)configureRESTClient {
    [[BMEClient sharedClient] setUsername:BMEAPIUsername password:BMEAPIPassword];
    [BMEClient sharedClient].facebookAppId = BMEFacebookAppId;
}

- (void)checkIfLoggedIn {
    if ([[BMEClient sharedClient] token] != nil && [[BMEClient sharedClient] isTokenValid]) {
        UIViewController *mainController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:BMEMainControllerIdentifier];
        [self replaceTopController:mainController];
        
        [[BMEClient sharedClient] loginUsingTokenWithCompletion:^(BOOL success, NSError *error) {
            if (!success || error) {
                self.window.rootViewController = [self.window.rootViewController.storyboard instantiateInitialViewController];
            } else {
                [self didLogin];
            }
        }];
    }
}

- (void)didLogin {
    [self registerForRemoteNotifications];
}

- (void)replaceTopController:(UIViewController *)topController {
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    navigationController.viewControllers = @[ topController ];
}

@end
