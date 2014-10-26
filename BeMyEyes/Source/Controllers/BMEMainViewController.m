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

#define BMEMainKnownLanguagesSegue @"KnownLanguages"
static NSString *const BMEAccessViewSegue = @"AccessView";

@interface BMEMainViewController ()
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (assign, nonatomic, getter = isLoggedOut) BOOL loggedOut;
@end

@implementation BMEMainViewController

#pragma mark -
#pragma mark Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogOut:) name:BMEDidLogOutNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self checkAppState];
}

- (void)handleAppBecameActive
{
    [self checkAppState];
}

- (void)checkAppState
{
    if (self.isLoggedOut) {
        self.view.window.rootViewController = [self.view.window.rootViewController.storyboard instantiateInitialViewController];
    } else {
        [self askForMoreLanguagesIfNecessary];
        [self askForAccessIfNecessary];
        if ([BMEClient sharedClient].currentUser.role == BMERoleHelper) {
            [BMEAccessControlHandler hasNotificationsEnabled:^(BOOL isEnabled) {
                if (isEnabled) {
                    // If user is helper and has notifications enabled, to a request to register for a possibly new device token
                    [BMEAccessControlHandler requireNotificationsEnabled:^(BOOL isEnabled) {
                    }];
                }
            }];
        }
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
    [self.settingsButton setAccessibilityLabel:MKLocalizedFromTable(BME_MAIN_SETTINGS_BUTTON_ACCESSIBILITY_LABEL, BMEMainLocalizationTable)];
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
}

- (void)askForMoreLanguagesIfNecessary {
    if ([GVUserDefaults standardUserDefaults].peopleHelped >= BMEPeopleHelpedBeforeAskingForMoreLanguages &&
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
    [BMEAccessControlHandler enabledForRole:[BMEClient sharedClient].currentUser.role completion:^(BOOL isEnabled) {
        if (isEnabled) {
            return;
        }
        [self performSegueWithIdentifier:BMEAccessViewSegue sender:self];
    }];
}

#pragma mark -
#pragma mark Notifications

- (void)didLogOut:(NSNotification *)notification {
    self.loggedOut = YES;
}

@end
