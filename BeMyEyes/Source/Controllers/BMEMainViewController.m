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

#define BMEMainKnownLanguagesSegue @"KnownLanguages"

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
    
    switch ([BMEClient sharedClient].currentUser.role) {
        case BMERoleHelper:
            [self displayHelperView];
            break;
        case BMERoleBlind:
            [self displayBlindView];
            break;
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.isLoggedOut) {
        self.view.window.rootViewController = [self.view.window.rootViewController.storyboard instantiateInitialViewController];
    } else {
        [self askForMoreLanguagesIfNecessary];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
            title = NSLocalizedStringFromTable(@"ALERT_MORE_LANGAUGES_HELPER_TITLE", @"BMEMainViewController", @"Title in alert view shown when asking the helper if he knows more langauges");
            message = NSLocalizedStringFromTable(@"ALERT_MORE_LANGAUGES_HELPER_MESSAGE", @"BMEMainViewController", @"Message in alert view shown when asking the helper if he knows more langauges");
            cancelButton = NSLocalizedStringFromTable(@"ALERT_MORE_LANGAUGES_HELPER_CANCEL", @"BMEMainViewController", @"Title of cancel button in alert view shown when asking the helper if he knows more langauges");
            confirmButton = NSLocalizedStringFromTable(@"ALERT_MORE_LANGAUGES_HELPER_CONFIRM", @"BMEMainViewController", @"Title of confirm button in alert view shown when asking the helper if he knows more langauges");
        } else {
            title = NSLocalizedStringFromTable(@"ALERT_MORE_LANGAUGES_BLIND_TITLE", @"BMEMainViewController", @"Title in alert view shown when asking the blind if he knows more langauges");
            message = NSLocalizedStringFromTable(@"ALERT_MORE_LANGAUGES_BLIND_MESSAGE", @"BMEMainViewController", @"Message in alert view shown when asking the blind if he knows more langauges");
            cancelButton = NSLocalizedStringFromTable(@"ALERT_MORE_LANGAUGES_BLIND_CANCEL", @"BMEMainViewController", @"Title of cancel button in alert view shown when asking the blind if he knows more langauges");
            confirmButton = NSLocalizedStringFromTable(@"ALERT_MORE_LANGAUGES_BLIND_CONFIRM", @"BMEMainViewController", @"Title of confirm button in alert view shown when asking the blind if he knows more langauges");
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

#pragma mark -
#pragma mark Notifications

- (void)didLogOut:(NSNotification *)notification {
    self.loggedOut = YES;
}

@end
