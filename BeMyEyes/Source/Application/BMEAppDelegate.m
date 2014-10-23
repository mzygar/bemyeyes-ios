//
//  BMEAppDelegate.m
//  BeMyEyes
//
//  Created by Simon Støvring on 22/02/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEAppDelegate.h"
#import <Appirater/Appirater.h>
#import <PSAlertView/PSPDFAlertView.h>
#import <MRProgress/MRProgress.h>
#import "BMEClient.h"
#import "BMECallViewController.h"
#import "BMECallAudioPlayer.h"
#import "BMEAccessControlHandler.h"
#import <Crashlytics/Crashlytics.h>

@interface BMEAppDelegate () <UIAlertViewDelegate>
@property (strong, nonatomic) PSPDFAlertView *callAlertView;
@property (strong, nonatomic) BMECallAudioPlayer *callAudioPlayer;
@property (assign, nonatomic, getter = isLaunchedWithShortID) BOOL launchedWithShortID;
@end

#define DEVELOPMENT 1
#ifdef DEVELOPMENT
static const BMESettingsAPI api = BMESettingsAPIDevelopment;
#endif

@implementation BMEAppDelegate

#pragma mark -
#pragma mark Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString *shortIdInLaunchOptions = [self shortIdInLaunchOptions:launchOptions];
    self.launchedWithShortID = (shortIdInLaunchOptions != nil);
    
#ifdef DEVELOPMENT
    [GVUserDefaults standardUserDefaults].api = api;
#endif
    
    [Crashlytics startWithAPIKey:@"41644116426a80147f822825bb643b3020b0f9d3"];
    
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
    [GVUserDefaults synchronize];
    
    // We enter the background, reset the launched with short ID state to prepare for next launch
    self.launchedWithShortID = NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if ([[BMEClient sharedClient] isLoggedIn] && !self.launchedWithShortID) {
        [self checkForPendingRequestIfIconHasBadge];
    }
    
    [self resetBadgeIcon];
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
                NSString *name = MKLocalizedFromTable(BME_APP_DELEGATE_ALERT_PUSH_REQUEST_DEFAULT_NAME, BMEAppDelegateLocalizationTable);
                if ([locArgs count] > 0) {
                    name = locArgs[0];
                }
                
                NSString *title = MKLocalizedFromTable(BME_APP_DELEGATE_ALERT_PUSH_REQUEST_TITLE, BMEAppDelegateLocalizationTable);
                NSString *message = [NSString stringWithFormat:NSLocalizedString(locKey, nil), name];
                NSString *actionButton = NSLocalizedString(actionLocKey, nil);
                NSString *cancelButton = MKLocalizedFromTable(BME_APP_DELEGATE_ALERT_PUSH_REQUEST_CANCEL, BMEAppDelegateLocalizationTable);
                
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
    
    NSString *normalizedDeviceToken = BMENormalizedDeviceTokenStringWithDeviceToken(deviceToken);
    NSString *existingDeviceToken = [GVUserDefaults standardUserDefaults].deviceToken;
    
    void(^completionHandler)(NSError *) = ^(NSError *error) {
        if (!error && normalizedDeviceToken) {
            [GVUserDefaults standardUserDefaults].deviceToken = normalizedDeviceToken;
            [GVUserDefaults standardUserDefaults].isTemporaryDeviceToken = NO;
            [GVUserDefaults synchronize];
        }
    };
    
    if (existingDeviceToken) {
        NSLog(@"Update device token '%@' to: %@", existingDeviceToken, normalizedDeviceToken);
        
        // Update using existing device token
        [[BMEClient sharedClient] updateDeviceWithDeviceToken:existingDeviceToken newToken:normalizedDeviceToken active:YES production:BMEIsProductionOrAdHoc completion:^(BOOL success, NSError *error) {
            completionHandler(error);
            
            if (error) {
                NSLog(@"Failed updating device: %@", error);
            }
        }];
    } else {
        NSLog(@"Register new device token: %@", normalizedDeviceToken);
        
        // Register new device token
        [[BMEClient sharedClient] registerDeviceWithAbsoluteDeviceToken:normalizedDeviceToken active:YES production:BMEIsProductionOrAdHoc completion:^(BOOL success, NSError *error) {
            completionHandler(error);
            
            if (error) {
                NSLog(@"Failed registering device: %@", error);
            }
        }];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed registering for remote notifications: %@", error);
    [GVUserDefaults standardUserDefaults].deviceToken = nil;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSLog(@"Did register user notification settings");
    [application registerForRemoteNotifications];
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
        UIViewController *mainController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:BMEMainNavigationControllerIdentifier];
        [self replaceTopController:mainController];
        
        [[BMEClient sharedClient] loginUsingUserTokenWithDeviceToken:[GVUserDefaults standardUserDefaults].deviceToken completion:^(BOOL success, NSError *error) {
            if (success) {
                [self didLogin];
            } else {
                NSLog(@"Could not automatically log in: %@", error);
                
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
    [[BMEClient sharedClient] updateDeviceWithDeviceToken:[GVUserDefaults standardUserDefaults].deviceToken active:![GVUserDefaults standardUserDefaults].isTemporaryDeviceToken productionOrAdHoc:BMEIsProductionOrAdHoc];
    
    if (!self.isLaunchedWithShortID) {
        [self checkForPendingRequestIfIconHasBadge];
    }
}

- (void)replaceTopController:(UIViewController *)topController {
    self.window.rootViewController = topController;
}

- (NSString *)shortIdInLaunchOptions:(NSDictionary *)launchOptions {
    NSDictionary *userInfo = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    NSDictionary *alertInfo = [apsInfo objectForKey:@"alert"];
    return [alertInfo objectForKey:@"short_id"];
}

- (void)didAnswerCallWithShortId:(NSString *)shortId {
    [BMEAccessControlHandler requireMicrophoneEnabled:^(BOOL isEnabled) {
        if (isEnabled) {
            BMECallViewController *callController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:BMECallControllerIdentifier];
            callController.callMode = BMECallModeAnswer;
            callController.shortId = shortId;
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:callController];
            navigationController.navigationBarHidden = YES;
            
            [self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
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
        MRProgressOverlayView *progressOverlayView = [MRProgressOverlayView showOverlayAddedTo:self.window animated:YES];
        progressOverlayView.mode = MRProgressOverlayViewModeIndeterminate;
        progressOverlayView.titleLabelText = MKLocalizedFromTable(BME_APP_DELEGATE_OVERLAY_LOADING_PENDING_REQUEST_TITLE, BMEAppDelegateLocalizationTable);
    
        [[BMEClient sharedClient] checkForPendingRequest:^(NSString *shortId, BOOL success, NSError *error) {
            [progressOverlayView hide:YES];
            
            if (success) {
                if (shortId) {
                    [self didAnswerCallWithShortId:shortId];
                } else {
                    NSString *title = MKLocalizedFromTable(BME_APP_DELEGATE_ALERT_PENDING_REQUEST_HANDLED_TITLE, BMEAppDelegateLocalizationTable);
                    NSString *message = MKLocalizedFromTable(BME_APP_DELEGATE_ALERT_PENDING_REQUEST_HANDLED_MESSAGE, BMEAppDelegateLocalizationTable);
                    NSString *cancelButton = MKLocalizedFromTable(BME_APP_DELEGATE_ALERT_PENDING_REQUEST_HANDLED_CANCEL, BMEAppDelegateLocalizationTable);
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
                    [alertView show];
                }
            } else {
                NSLog(@"Could not load pending request: %@", error);
                
                NSString *title = MKLocalizedFromTable(BME_APP_DELEGATE_ALERT_PENDING_REQUEST_NOT_LOADED_TITLE, BMEAppDelegateLocalizationTable);
                NSString *message = MKLocalizedFromTable(BME_APP_DELEGATE_ALERT_PENDING_REQUEST_NOT_LOADED_MESSAGE, BMEAppDelegateLocalizationTable);
                NSString *cancelButton = MKLocalizedFromTable(BME_APP_DELEGATE_ALERT_PENDING_REQUEST_NOT_LOADED_CANCEL, BMEAppDelegateLocalizationTable);
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
                [alertView show];
            }
        }];
    }
}

@end
