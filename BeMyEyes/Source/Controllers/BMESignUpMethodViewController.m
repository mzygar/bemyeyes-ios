//
//  BMESignUpMethodViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 22/02/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMESignUpMethodViewController.h"
#import <MRProgress/MRProgress.h>
#import <Accounts/Accounts.h>
#import "BMEAppDelegate.h"
#import "BMESignUpViewController.h"
#import "BMEClient.h"
#import "BMEUser.h"
#import "BMEFacebookInfo.h"
#import "NSString+BMEDeviceToken.h"
#import "BeMyEyes-Swift.h"

#define BMESignUpMethodSignUpSegue @"SignUp"

@interface BMESignUpMethodViewController ()
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *headlineLabel;
@property (weak, nonatomic) IBOutlet Button *facebookButton;
@property (weak, nonatomic) IBOutlet UILabel *termsTopLabel;
@property (weak, nonatomic) IBOutlet UILabel *termsBottomLabel;
@property (weak, nonatomic) IBOutlet UILabel *privacyTopLabel;
@property (weak, nonatomic) IBOutlet UILabel *privacyBottomLabel;
@property (weak, nonatomic) IBOutlet Button *emailSignUpButton;
@property (weak, nonatomic) IBOutlet UIButton *termsButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyButton;

@end

@implementation BMESignUpMethodViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MKLocalization registerForLocalization:self];}

- (void)shouldLocalize {
    [self.backButton setTitle:MKLocalizedFromTable(BME_SIGN_UP_METHOD_BACK, BMESignUpMethodLocalizationTable) forState:UIControlStateNormal];
    
    self.headlineLabel.text = MKLocalizedFromTable(BME_SIGN_UP_METHOD_HEADLINE, BMESignUpMethodLocalizationTable);
    
    self.facebookButton.title = MKLocalizedFromTable(BME_SIGN_UP_METHOD_FACEBOOK, BMESignUpMethodLocalizationTable);
    
    self.emailSignUpButton.title = MKLocalizedFromTable(BME_SIGN_UP_METHOD_EMAIL, BMESignUpMethodLocalizationTable);
    
    self.termsTopLabel.text = MKLocalizedFromTable(BME_SIGN_UP_METHOD_TERMS_AND_AGREEMENTS_TOP, BMESignUpMethodLocalizationTable);
    self.termsBottomLabel.text = MKLocalizedFromTable(BME_SIGN_UP_METHOD_TERMS_AND_AGREEMENTS_BOTTOM, BMESignUpMethodLocalizationTable);
    
    self.privacyTopLabel.text = MKLocalizedFromTable(BME_SIGN_UP_METHOD_PRIVACY_POLICY_TOP, BMESignUpMethodLocalizationTable);
    self.privacyBottomLabel.text = MKLocalizedFromTable(BME_SIGN_UP_METHOD_PRIVACY_POLICY_BOTTOM, BMESignUpMethodLocalizationTable);
    
    self.termsButton.accessibilityLabel = MKLocalizedFromTable(BME_SIGN_UP_METHOD_TERMS_ACCESSIBILITY_LABEL, BMESignUpMethodLocalizationTable);
    self.termsButton.accessibilityHint = MKLocalizedFromTable(BME_SIGN_UP_METHOD_TERMS_ACCESSIBILITY_HINT, BMESignUpMethodLocalizationTable);
    
    self.privacyButton.accessibilityLabel = MKLocalizedFromTable(BME_SIGN_UP_METHOD_PRIVACY_ACCESSIBILITY_LABEL, BMESignUpMethodLocalizationTable);
    self.privacyButton.accessibilityHint = MKLocalizedFromTable(BME_SIGN_UP_METHOD_PRIVACY_ACCESSIBILITY_HINT, BMESignUpMethodLocalizationTable);
}

#pragma mark -
#pragma mark Private Methods

- (IBAction)facebookButtonPressed:(id)sender {
    [self performFacebookRegistration];
}

- (IBAction)signUpButtonPressed:(id)sender {
    [self presentSignUp];
}

- (IBAction)termsButtonTouched:(id)sender {
    self.termsTopLabel.alpha = 0.50f;
    self.termsBottomLabel.alpha = 0.50f;
}

- (IBAction)termsButtonReleased:(id)sender {
    self.termsTopLabel.alpha = 1.0f;
    self.termsBottomLabel.alpha = 1.0f;
}

- (IBAction)privacyButtonTouched:(id)sender {
    self.privacyTopLabel.alpha = 0.50f;
    self.privacyBottomLabel.alpha = 0.50f;
}

- (IBAction)privacyButtonReleased:(id)sender {
    self.privacyTopLabel.alpha = 1.0f;
    self.privacyBottomLabel.alpha = 1.0f;
}

- (void)performFacebookRegistration {
    MRProgressOverlayView *progressOverlayView = [MRProgressOverlayView showOverlayAddedTo:self.view.window animated:YES];
    progressOverlayView.mode = MRProgressOverlayViewModeIndeterminate;
    progressOverlayView.titleLabelText = MKLocalizedFromTable(BME_SIGN_UP_METHOD_OVERLAY_REGISTERING_TITLE, BMESignUpMethodLocalizationTable);
    
    [[BMEClient sharedClient] authenticateWithFacebook:^(BMEFacebookInfo *fbInfo, NSError *error) {
        if (!error) {
            [[BMEClient sharedClient] createFacebookUserId:[fbInfo.userId longLongValue] email:fbInfo.email firstName:fbInfo.firstName lastName:fbInfo.lastName role:self.role completion:^(BOOL success, NSError *error) {
                if (success && !error) {
                    progressOverlayView.titleLabelText = MKLocalizedFromTable(BME_SIGN_UP_METHOD_OVERLAY_LOGGING_IN_TITLE, BMESignUpMethodLocalizationTable);
                
                    NSString *deviceToken = [GVUserDefaults standardUserDefaults].deviceToken;
                    if (!deviceToken) {
                        deviceToken = [NSString BMETemporaryDeviceToken];
                        [GVUserDefaults standardUserDefaults].deviceToken = deviceToken;
                        [GVUserDefaults standardUserDefaults].isTemporaryDeviceToken = YES;
                        [GVUserDefaults synchronize];
                    }
                    
                    [[BMEClient sharedClient] registerDeviceWithAbsoluteDeviceToken:deviceToken active:NO production:BMEIsProductionOrAdHoc completion:^(BOOL success, NSError *error) {
                        if (success && !error) {
                            [[BMEClient sharedClient] loginWithEmail:fbInfo.email userId:[fbInfo.userId longLongValue] deviceToken:deviceToken success:^(BMEToken *token) {
                                [progressOverlayView hide:YES];
                                
                                [self didLogin];
                            } failure:^(NSError *error) {
                                [progressOverlayView hide:YES];
                                
                                NSLog(@"Failed logging in after sign up: %@", error);
                            }];
                        } else {
                            [progressOverlayView hide:YES];
                            
                            NSLog(@"Failed registering device before automatic log in after sign up: %@", error);
                        }
                    }];    
                } else {
                    [progressOverlayView hide:YES];
                    
                    if ([error code] == BMEClientErrorUserEmailAlreadyRegistered)  {
                        NSString *title = MKLocalizedFromTable(BME_SIGN_UP_METHOD_ALERT_FACEBOOK_EMAIL_ALREADY_REGISTERED_TITLE, BMESignUpMethodLocalizationTable);
                        NSString *message = MKLocalizedFromTable(BME_SIGN_UP_METHOD_ALERT_FACEBOOK_EMAIL_ALREADY_REGISTERED_MESSAGE, BMESignUpMethodLocalizationTable);
                        NSString *cancelButton = MKLocalizedFromTable(BME_SIGN_UP_METHOD_ALERT_FACEBOOK_EMAIL_ALREADY_REGISTERED_CANCEL, BMESignUpMethodLocalizationTable);
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
                        [alert show];
                    } else {
                        NSString *title = MKLocalizedFromTable(BME_SIGN_UP_METHOD_ALERT_FACEBOOK_SIGN_UP_UNKNOWN_ERROR_TITLE, BMESignUpMethodLocalizationTable);
                        NSString *message = MKLocalizedFromTable(BME_SIGN_UP_METHOD_ALERT_FACEBOOK_SIGN_UP_UNKNOWN_ERROR_MESSAGE, BMESignUpMethodLocalizationTable);
                        NSString *cancelButton = MKLocalizedFromTable(BME_SIGN_UP_METHOD_ALERT_FACEBOOK_SIGN_UP_UNKNOWN_ERROR_CANCEL, BMESignUpMethodLocalizationTable);
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
                        [alert show];
                    }
                }
            }];
        } else {
            [progressOverlayView hide:YES];
            
            if ([error code] == ACErrorAccountNotFound) {
                NSString *title = MKLocalizedFromTable(BME_SIGN_UP_METHOD_ALERT_FACEBOOK_ACCOUNT_NOT_FOUND_TITLE, BMESignUpMethodLocalizationTable);
                NSString *message = MKLocalizedFromTable(BME_SIGN_UP_METHOD_ALERT_FACEBOOK_ACCOUNT_NOT_FOUND_MESSAGE, BMESignUpMethodLocalizationTable);
                NSString *cancelButton = MKLocalizedFromTable(BME_SIGN_UP_METHOD_ALERT_FACEBOOK_ACCOUNT_NOT_FOUND_CANCEL, BMESignUpMethodLocalizationTable);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
                [alert show];
            } else {
                NSString *title = MKLocalizedFromTable(BME_SIGN_UP_METHOD_ALERT_NOT_LOGGED_IN_TITLE, BMESignUpMethodLocalizationTable);
                NSString *message = MKLocalizedFromTable(BME_SIGN_UP_METHOD_ALERT_NOT_LOGGED_IN_MESSAGE, BMESignUpMethodLocalizationTable);
                NSString *cancelButtonTitle = MKLocalizedFromTable(BME_SIGN_UP_METHOD_ALERT_NOT_LOGGED_IN_CANCEL, BMESignUpMethodLocalizationTable);
            
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil, nil];
                [alert show];
            }
        }
    }];
}

- (void)presentSignUp {
    [self performSegueWithIdentifier:BMESignUpMethodSignUpSegue sender:self];
}

- (void)didLogin {
    [[BMEClient sharedClient] updateUserInfoWithUTCOffset:nil];
    [[BMEClient sharedClient] updateDeviceWithDeviceToken:[GVUserDefaults standardUserDefaults].deviceToken active:![GVUserDefaults standardUserDefaults].isTemporaryDeviceToken productionOrAdHoc:BMEIsProductionOrAdHoc];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BMEDidLogInNotification object:nil];
}

#pragma mark -
#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:BMESignUpMethodSignUpSegue]) {
        ((BMESignUpViewController *)segue.destinationViewController).role = self.role;
    }
}

@end
