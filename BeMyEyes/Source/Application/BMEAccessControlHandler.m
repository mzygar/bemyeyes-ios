//
//  BMEAccessControlHandler.m
//  BeMyEyes
//
//  Created by Tobias DM on 09/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEAccessControlHandler.h"
#import <AVFoundation/AVFoundation.h>


@interface BMEAccessControlHandler() <UIAlertViewDelegate>

@property (strong, nonatomic) void (^notificationsCompletion)(BOOL isEnabled, BOOL validToken);

@end


@implementation BMEAccessControlHandler

+ (BMEAccessControlHandler *)sharedInstance
{
    static BMEAccessControlHandler *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [BMEAccessControlHandler new];
        
        [[GVUserDefaults standardUserDefaults] addObserver:sharedInstance
                                                forKeyPath:NSStringFromSelector(@selector(deviceToken))
                                                   options:0
                                                   context:NULL];
    });
    return sharedInstance;
}

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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(deviceToken))] &&
        object == [GVUserDefaults standardUserDefaults]) {
        [BMEAccessControlHandler hasNotificationsEnabled:^(BOOL isEnabled, BOOL validToken) {
            if (!isEnabled) {
                [BMEAccessControlHandler showNotificationsAlert];
            }
            if (self.notificationsCompletion) {
                self.notificationsCompletion(isEnabled, validToken);
                _notificationsCompletion = nil;
            }
        }];
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


#pragma mark -
#pragma mark Public Methods

+ (void)enabledForRole:(BMERole)role completion:(void (^)(BOOL isEnabled, BOOL validToken))completion
{
#if TARGET_IPHONE_SIMULATOR
    completion(YES, YES);
    return;
#endif
    
    switch (role) {
        case BMERoleBlind:
        {
            // Ask for microphone + video
            [self hasMicrophoneEnabled:^(BOOL isEnabled) {
                if (!isEnabled) {
                    completion(NO, YES);
                    return;
                }
                [self hasVideoEnabled:^(BOOL isEnabled) {
                    completion(isEnabled, YES);
                }];
            }];
        }
            break;
        case BMERoleHelper:
        {
            // Ask for notifications + microphone + video
            [self hasNotificationsEnabled:^(BOOL isEnabled, BOOL validToken) {
                if (!isEnabled) {
                    completion(NO, validToken);
                    return;
                }
                [self hasMicrophoneEnabled:^(BOOL isEnabled) {
                    if (!isEnabled) {
                        completion(NO, validToken);
                        return;
                    }
                    [self hasVideoEnabled:^(BOOL isEnabled) {
                        completion(isEnabled, validToken);
                    }];
                }];
            }];
        }
            break;
            
        default:
            break;
    }
}


// Remote notifications

+ (void)requireNotificationsEnabled:(void(^)(BOOL isEnabled, BOOL validToken))completion {
    // Store completion block
    [self sharedInstance].notificationsCompletion = completion;
    [self registerForRemoteNotifications];
}

+ (void)hasNotificationsEnabled:(void(^)(BOOL isUserEnabled, BOOL validToken))completion {
    // System – require badge and alert
    BOOL isUserEnabled = NO;
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        BOOL isRegisteredForRemoteNotifications = [UIApplication sharedApplication].isRegisteredForRemoteNotifications;
        UIUserNotificationSettings *userNotificationSettings = [UIApplication sharedApplication].currentUserNotificationSettings;
        UIUserNotificationType types = userNotificationSettings.types;
        BOOL hasAlertEnabled = types & UIUserNotificationTypeAlert;
        BOOL hasBadgeEnabled = types & UIUserNotificationTypeBadge;
        BOOL hasAlertAndBadgeEnabled = hasAlertEnabled && hasBadgeEnabled;
        isUserEnabled = isRegisteredForRemoteNotifications && hasAlertAndBadgeEnabled;
    } else { // iOS 7 and older
        UIRemoteNotificationType types = [UIApplication sharedApplication].enabledRemoteNotificationTypes;
        BOOL hasAlertEnabled = types & UIRemoteNotificationTypeAlert;
        BOOL hasBadgeEnabled = types & UIRemoteNotificationTypeBadge;
        BOOL hasAlertAndBadgeEnabled = hasAlertEnabled && hasBadgeEnabled;
        isUserEnabled = hasAlertAndBadgeEnabled;
    }
    // Token
    NSString *deviceToken = [GVUserDefaults standardUserDefaults].deviceToken;
    BOOL hasNotificationsToken = deviceToken != nil;
    BOOL hasValidToken = hasNotificationsToken;
    // Combined
    completion(isUserEnabled, hasValidToken);
}


// Microphone

+ (void)requireMicrophoneEnabled:(void(^)(BOOL isEnabled))completion {
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (!granted) {
            [self showMicrophoneAlert];
        }
        
        if (completion) {
            completion(granted);
        }
    }];
}

+ (void)hasMicrophoneEnabled:(void(^)(BOOL isEnabled))completion {
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(recordPermission)]) {
        BOOL enabled;
        switch ([AVAudioSession sharedInstance].recordPermission) {
            case AVAudioSessionRecordPermissionUndetermined:
                enabled = NO;
                break;
            case AVAudioSessionRecordPermissionDenied:
                enabled = NO;
                break;
            case AVAudioSessionRecordPermissionGranted:
                enabled = YES;
            default:
                break;
        }
        completion(enabled);
    } else {
        // Fallback for iOS 7
        [self requireMicrophoneEnabled:completion];
    }
}


// Video

+ (void)requireCameraEnabled:(void(^)(BOOL isEnabled))completion {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!granted) {
                [self showCameraAlert];
            }
            if (completion) {
                completion(granted);
            }
        });
    }];
}

+ (void)hasVideoEnabled:(void(^)(BOOL isEnabled))completion {
    BOOL enabled;
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        case AVAuthorizationStatusNotDetermined:
            enabled = NO;
            break;
        case AVAuthorizationStatusDenied:
            enabled = NO;
            break;
        case AVAuthorizationStatusRestricted:
            enabled = NO;
            break;
        case AVAuthorizationStatusAuthorized:
            enabled = YES;
        default:
            break;
    }
    if (completion) {
        completion(enabled);
    }
}


#pragma mark - Private


+ (void)showNotificationsAlert
{
    [self showAlertWithTitle:MKLocalizedFromTable(BME_APP_DELEGATE_ALERT_FAILED_REGISTERING_REMOTE_NOTIFICATIONS_TITLE, BMEAppDelegateLocalizationTable)
                     message:MKLocalizedFromTable(BME_APP_DELEGATE_ALERT_FAILED_REGISTERING_REMOTE_NOTIFICATIONS_MESSAGE, BMEAppDelegateLocalizationTable)];
}

+ (void)showMicrophoneAlert
{
    [self showAlertWithTitle:MKLocalizedFromTable(BME_APP_DELEGATE_ALERT_MICROPHONE_DISABLED_TITLE, BMEAppDelegateLocalizationTable)
            message:MKLocalizedFromTable(BME_APP_DELEGATE_ALERT_MICROPHONE_DISABLED_MESSAGE, BMEAppDelegateLocalizationTable)];
}

+ (void)showCameraAlert
{
    [self showAlertWithTitle:MKLocalizedFromTable(BME_APP_DELEGATE_ALERT_CAMERA_DISABLED_TITLE, BMEAppDelegateLocalizationTable)
            message:MKLocalizedFromTable(BME_APP_DELEGATE_ALERT_CAMERA_DISABLED_MESSAGE, BMEAppDelegateLocalizationTable)];
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    NSString *cancelButton;
    if ([self canGoToSystemSettings]) {
        cancelButton = MKLocalizedFromTable(BME_APP_DELEGATE_ALERT_ACCESS_DISABLED_CANCEL_CAN_GO_TO_SETTINGS, BMEAppDelegateLocalizationTable);
    } else {
        cancelButton = MKLocalizedFromTable(BME_APP_DELEGATE_ALERT_ACCESS_DISABLED_CANCEL, BMEAppDelegateLocalizationTable);
    }
    UIAlertView *alert;
    if ([self canGoToSystemSettings]) {
        NSString *openSettingsButton =  MKLocalizedFromTable(BME_APP_DELEGATE_ALERT_ACCESS_DISABLED_GO_TO_SETTINGS, BMEAppDelegateLocalizationTable);
        alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:[self sharedInstance] cancelButtonTitle:cancelButton otherButtonTitles:openSettingsButton, nil];
    } else {
        alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
    }
    [alert show];
}


#pragma mark - System Settings

+ (BOOL)canGoToSystemSettings
{
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) {
        return NO; 
    } else {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        return [[UIApplication sharedApplication] canOpenURL:url];
    }
}

+ (void)openSystemSettings
{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    [BMEAccessControlHandler openSystemSettings];
}

@end
