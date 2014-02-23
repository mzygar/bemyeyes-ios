//
//  BMESignUpMethodViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 22/02/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMESignUpMethodViewController.h"
#import "BMESignUpViewController.h"
#import "BMEClient.h"
#import "BMEFacebookInfo.h"

#define BMESignUpLoggedInSegue @"LoggedIn"
#define BMESignUpMethodSignUpSegue @"SignUp"

@interface BMESignUpMethodViewController ()
@property (weak, nonatomic) IBOutlet UILabel *signUpTopLabel;
@property (weak, nonatomic) IBOutlet UILabel *signUpBottomLabel;
@property (weak, nonatomic) IBOutlet UILabel *termsTopLabel;
@property (weak, nonatomic) IBOutlet UILabel *termsBottomLabel;
@end

@implementation BMESignUpMethodViewController

#pragma mark -
#pragma mark Private Methods

- (IBAction)facebookButtonPressed:(id)sender {
    [[BMEClient sharedClient] authenticateWithFacebook:^(BMEFacebookInfo *fbInfo) {
        [[BMEClient sharedClient] createFacebookUserId:[fbInfo.userId integerValue] email:fbInfo.email firstName:fbInfo.firstName lastName:fbInfo.lastName role:self.role completion:^(BOOL success, NSError *error) {
            if (success && !error) {
                [[BMEClient sharedClient] loginWithEmail:fbInfo.email userId:[fbInfo.userId integerValue] success:^(BMEToken *token) {
                    [self didLogin];
                } failure:^(NSError *error) {
                    
                }];
            } else {
                if (error.code == BMEClientErrorUserEmailAlreadyRegistered)  {
                    NSString *title = NSLocalizedStringFromTable(@"ALERT_FACEBOOK_EMAIL_ALREADY_REGISTERED_TITLE", @"SignUpChooseMethodViewController", @"Title in alert view shown when e-mail is already registered.");
                    NSString *message = NSLocalizedStringFromTable(@"ALERT_FACEBOOK_EMAIL_ALREADY_REGISTERED_MESSAGE", @"SignUpChooseMethodViewController", @"Message in alert view shown when e-mail is already registered.");
                    NSString *cancelButton = NSLocalizedStringFromTable(@"ALERT_FACEBOOK_EMAIL_ALREADY_REGISTERED_CANCEL", @"SignUpChooseMethodViewController", @"Title of cancel button in alert view shown when e-mail is already registered.");
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
                    [alert show];
                } else {
                    NSString *title = NSLocalizedStringFromTable(@"ALERT_FACEBOOK_SIGN_UP_UNKNOWN_ERROR_TITLE", @"SignUpChooseMethodViewController", @"Title in alert view shown when a TITLEnetwork error occurred during Facebook log in.");
                    NSString *message = NSLocalizedStringFromTable(@"ALERT_FACEBOOK_SIGN_UP_UNKNOWN_ERROR_MESSAGE", @"SignUpChooseMethodViewController", @"Message in alert view shown when a network error occurred during Facebook log in.");
                    NSString *cancelButton = NSLocalizedStringFromTable(@"ALERT_FACEBOOK_SIGN_UP_UNKNOWN_ERROR_CANCEL", @"SignUpChooseMethodViewController", @"Title of cancel button in alert view shown when a network error occurred during Facebook log in.");
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
        }];
    } failure:^(NSError *error) {
        NSString *title = NSLocalizedStringFromTable(@"ALERT_NOT_LOGGED_IN_TITLE", @"SignUpChooseMethodViewController", @"Title in alert view shown when log in to Facebook failed");
        NSString *cancelButtonTitle = NSLocalizedStringFromTable(@"ALERT_NOT_LOGGED_IN_CANCEL", @"SignUpChooseMethodViewController", @"Title of cancel button in alert view shown when log in to Facebook failed");
        NSString *message = message = NSLocalizedStringFromTable(@"ALERT_NOT_LOGGED_IN_MESSAGE", @"SignUpChooseMethodViewController", @"Message in alert view shown when logging into Facebook but it failed because authentication failed");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil, nil];
        [alert show];
    }];
}

- (IBAction)signUpButtonTouched:(id)sender {
    self.signUpTopLabel.alpha = 0.50f;
    self.signUpBottomLabel.alpha = 0.50f;
}

- (IBAction)signUpButtonReleased:(id)sender {
    self.signUpTopLabel.alpha = 1.0f;
    self.signUpBottomLabel.alpha = 1.0f;
}

- (IBAction)termsButtonTouched:(id)sender {
    self.termsTopLabel.alpha = 0.50f;
    self.termsBottomLabel.alpha = 0.50f;
}

- (IBAction)termsButtonReleased:(id)sender {
    self.termsTopLabel.alpha = 1.0f;
    self.termsBottomLabel.alpha = 1.0f;
}

- (void)didLogin {
    [self performSegueWithIdentifier:BMESignUpLoggedInSegue sender:self];
}

#pragma mark -
#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:BMESignUpMethodSignUpSegue]) {
        ((BMESignUpViewController *)segue.destinationViewController).role = self.role;
    }
}

@end
