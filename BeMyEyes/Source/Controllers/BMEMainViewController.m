//
//  BMEMainViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 09/03/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEMainViewController.h"
#import <PSAlertView/PSPDFAlertView.h>
#import "BMEClient.h"
#import "BMEUser.h"
#import "BMEAccessControlHandler.h"
#import "BMEAccessViewController.h"
#import "BMECallViewController.h"

#define BMEMainKnownLanguagesSegue @"KnownLanguages"
static NSString *const BMEAccessViewSegue = @"AccessView";

@interface BMEMainViewController ()
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (assign, nonatomic, getter = isLoggedOut) BOOL loggedOut;
@property (weak, nonatomic) UIViewController *currentViewController;
@end

@implementation BMEMainViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MKLocalization registerForLocalization:self];
    
    BMERole role = [BMEClient sharedClient].currentUser.role;
    switch (role) {
        case BMERoleHelper:
            [self displayHelperView];
            break;
        case BMERoleBlind:
            [self displayBlindView];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAppBecameActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initiateCall) name:BMEInitiateCallIfPossibleNotification object:nil];
    
    [[BMEClient sharedClient] verifyTokenAuthOnServerWithCompletion:^(BOOL valid) {
        if (!valid) { // Force user to log out
            NSString *title = MKLocalizedFromTable(BME_MAIN_ALERT_FORCED_LOGOUT_TITLE, BMEMainLocalizationTable);
            NSString *message = MKLocalizedFromTable(BME_MAIN_ALERT_FORCED_LOGOUT_MESSAGE, BMEMainLocalizationTable);
            NSString *confirmButton = MKLocalizedFromTable(BME_MAIN_ALERT_FORCED_LOGOUT_CONFIRM, BMEMainLocalizationTable);
        
            PSPDFAlertView *alertView = [[PSPDFAlertView alloc] initWithTitle:title message:message];
            [alertView addButtonWithTitle:confirmButton block:^{
                [[BMEClient sharedClient] logoutWithCompletion:^(BOOL success, NSError *error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:BMEDidLogOutNotification object:nil];
                }];
            }];
            [alertView show];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self checkAccess];
    [self askForMoreLanguagesIfNecessary];
}

- (void)handleAppBecameActive
{
    [self checkAccess];
}

- (void)checkAccess
{
    if ([BMEClient sharedClient].currentUser.role == BMERoleHelper) {
        [BMEAccessControlHandler hasNotificationsEnabled:^(BOOL isUserEnabled, BOOL validToken) {
            if (isUserEnabled) {
                // If user is helper and has notifications enabled, to a request to register for a possibly new device token
                [BMEAccessControlHandler requireNotificationsEnabled:^(BOOL isUserEnabled, BOOL validToken) {
                    [self askForAccessIfNecessary];
                }];
            } else {
                [self askForAccessIfNecessary];
            }
        }];
    } else {
        [self askForAccessIfNecessary];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:BMEAccessViewSegue]) {
        BMERole role = [BMEClient sharedClient].currentUser.role;
        ((BMEAccessViewController *)segue.destinationViewController).role = role;
    }
}

- (void)shouldLocalize {
    self.settingsButton.accessibilityLabel = MKLocalizedFromTable(BME_MAIN_SETTINGS_BUTTON_ACCESSIBILITY_LABEL, BMEMainLocalizationTable);
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return _currentViewController ? self.currentViewController : nil;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return _currentViewController ? self.currentViewController : nil;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    if (_currentViewController) {
        return self.currentViewController.preferredStatusBarUpdateAnimation;
    }
    return super.preferredStatusBarUpdateAnimation;
}

#pragma mark -
#pragma mark Private Methods

- (IBAction)popController:(UIStoryboardSegue *)segue { }

- (void)displayHelperView {
    [self displayMainControllerWithIdentifier:BMEMainHelperControllerIdentifier];
}

- (void)displayBlindView {
    [self displayMainControllerWithIdentifier:BMEMainBlindControllerIdentifier];
}

- (void)displayMainControllerWithIdentifier:(NSString *)identifier {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    [self addChildViewController:controller];
    [self.view insertSubview:controller.view belowSubview:self.settingsButton];
    [controller.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.currentViewController = controller;
}

- (void)askForMoreLanguagesIfNecessary {
    if ([BMEClient sharedClient].currentUser.peopleHelped.integerValue >= BMEPeopleHelpedBeforeAskingForMoreLanguages &&
        ![GVUserDefaults standardUserDefaults].hasAskedForMoreLanguages) {
        NSString *title, *message, *cancelButton, *confirmButton;
        if ([[BMEClient sharedClient].currentUser isHelper]) {
            title = MKLocalizedFromTable(BME_MAIN_ALERT_MORE_LANGAUGES_HELPER_TITLE, BMEMainLocalizationTable);
            message = MKLocalizedFromTable(BME_MAIN_ALERT_MORE_LANGAUGES_HELPER_MESSAGE, BMEMainLocalizationTable);
            cancelButton = MKLocalizedFromTable(BME_MAIN_ALERT_MORE_LANGAUGES_HELPER_CANCEL, BMEMainLocalizationTable);
            confirmButton = MKLocalizedFromTable(BME_MAIN_ALERT_MORE_LANGAUGES_HELPER_CONFIRM, BMEMainLocalizationTable);
        } else {
            title = MKLocalizedFromTable(BME_MAIN_ALERT_MORE_LANGAUGES_BLIND_TITLE, BMEMainLocalizationTable);
            message = MKLocalizedFromTable(BME_MAIN_ALERT_MORE_LANGAUGES_BLIND_MESSAGE, BMEMainLocalizationTable);
            cancelButton = MKLocalizedFromTable(BME_MAIN_ALERT_MORE_LANGAUGES_BLIND_CANCEL, BMEMainLocalizationTable);
            confirmButton = MKLocalizedFromTable(BME_MAIN_ALERT_MORE_LANGAUGES_BLIND_CONFIRM, BMEMainLocalizationTable);
        }
        
        PSPDFAlertView *alertView = [[PSPDFAlertView alloc] initWithTitle:title message:message];
        [alertView setCancelButtonWithTitle:cancelButton block:nil];
        [alertView addButtonWithTitle:confirmButton block:^{
            [self performSegueWithIdentifier:BMEMainKnownLanguagesSegue sender:self];
        }];
        [alertView show];
        
        [GVUserDefaults standardUserDefaults].hasAskedForMoreLanguages = YES;
    }
}

- (void)askForAccessIfNecessary
{
    [BMEAccessControlHandler enabledForRole:[BMEClient sharedClient].currentUser.role completion:^(BOOL isEnabled, BOOL validToken) {
        if (isEnabled) {
            if (!validToken) {
                // User has enable push, but something else went wrong
                NSString *title = MKLocalizedFromTable(BME_MAIN_ALERT_NOTIFICATIONS_ERROR_TITLE, BMEMainLocalizationTable);
                NSString *message = MKLocalizedFromTable(BME_MAIN_ALERT_NOTIFICATIONS_ERROR_MESSAGE, BMEMainLocalizationTable);
                NSString *cancelButton = MKLocalizedFromTable(BME_MAIN_ALERT_CANCEL, BMEMainLocalizationTable);
                PSPDFAlertView *alertView = [[PSPDFAlertView alloc] initWithTitle:title message:message];
                [alertView setCancelButtonWithTitle:cancelButton block:nil];
                [alertView show];
                return;
            }
            return;
        }
        [self performSegueWithIdentifier:BMEAccessViewSegue sender:self];
    }];
}



#pragma mark - Call

- (BOOL)inCall {
    return [self.navigationController.visibleViewController isKindOfClass:[BMECallViewController class]];
}

- (BOOL)ableToCall {
    BOOL inCall = [self inCall];
    return !inCall; // Not in call
}

- (BOOL)accessibilityPerformMagicTap {
    if ([self inCall]) {
        // Do nothing
    } else if([self ableToCall]) {
        return [self initiateCall];
    }
    return NO;
}

- (BOOL)initiateCall {
    if (![BMEClient sharedClient].currentUser.isBlind) {
        return NO;
    }
    
    BMECallViewController *callController = [self.storyboard instantiateViewControllerWithIdentifier:BMECallControllerIdentifier];
    callController.callMode = BMECallModeCreate;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:callController];
    navigationController.navigationBarHidden = YES;
    
    [self presentViewController:navigationController animated:YES completion:nil];
    return YES;
}

@end
