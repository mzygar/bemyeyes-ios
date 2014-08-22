//
//  BMELoginViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 22/02/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMELoginViewController.h"
#import <MRProgress/MRProgress.h>
#import <Accounts/Accounts.h>
#import "BMEAppDelegate.h"
#import "BMEClient.h"
#import "BMEUser.h"
#import "NSString+BMEDeviceToken.h"

#define BMELoginLoggedInSegue @"LoggedIn"

@interface BMELoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (strong, nonatomic) MRProgressOverlayView *loggingInOverlayView;
@end

@implementation BMELoginViewController

#pragma mark -
#pragma mark Lifecycle

- (void)dealloc {
    if (_loggingInOverlayView) {
        [_loggingInOverlayView hide:YES];
    }
    
    _loggingInOverlayView = nil;
}

#pragma mark -
#pragma mark Private Methods

- (IBAction)facebookButtonPressed:(id)sender {
    
    [self performLoginUsingFacebook:YES];
}

- (IBAction)loginButtonPressed:(id)sender {
    [self performLoginUsingFacebook:NO];
}

- (void)performLoginUsingFacebook:(BOOL)useFacebook {
    [self dismissKeyboard];
    
    self.loggingInOverlayView = [self addLoggingInOverlay];
    
    void(^loginHandler)(void) = ^{
        if (useFacebook) {
            [self performLoginWithFacebook];
        } else {
            [self performLoginWithEmail];
        }
    };
    
    NSString *existingDeviceToken = [GVUserDefaults standardUserDefaults].deviceToken;
    if (existingDeviceToken) {
        loginHandler();
    } else {
        NSString *tempDeviceToken = [NSString BMETemporaryDeviceToken];
        [[BMEClient sharedClient] registerDeviceWithAbsoluteDeviceToken:tempDeviceToken active:NO production:BMEIsProductionOrAdHoc completion:^(BOOL success, NSError *error) {
            if (success) {
                [GVUserDefaults standardUserDefaults].deviceToken = tempDeviceToken;
                loginHandler();
            } else {
                NSString *title = nil;
                NSString *message = nil;
                NSString *cancelButton = nil;
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
                [alertView show];
            }
        }];
    }
}

- (void)performLoginWithEmail {
    BOOL isEmailEmpty = [self.emailTextField.text length] == 0;
    BOOL isPasswordEmpty = [self.passwordTextField.text length] == 0;
    
    if (isEmailEmpty || isPasswordEmpty) {
        if (isEmailEmpty) {
            [self.emailTextField becomeFirstResponder];
        } else if (isPasswordEmpty) {
            [self.passwordTextField becomeFirstResponder];
        }
        
        NSString *title = NSLocalizedStringFromTable(@"ALERT_EMPTY_FIELDS_TITLE", @"BMELoginViewController", @"Title in alert view shown when the e-mail or password is empty");
        NSString *message = NSLocalizedStringFromTable(@"ALERT_EMPTY_FIELD_MESSAGE", @"BMELoginViewController", @"Message in alert view shown when the e-mail or password is empty");
        NSString *cancelButton = NSLocalizedStringFromTable(@"ALERT_EMPTY_FIELDS_CANCEL", @"BMELoginViewController", @"Title of cancel button in alert view show when the e-mail or password is empty");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
        [alert show];
    } else {
        [self loginWithEmail:self.emailTextField.text password:self.passwordTextField.text];
        [self dismissKeyboard];
    }
}

- (void)performLoginWithFacebook {
    [[BMEClient sharedClient] loginUsingFacebookWithDeviceToken:[GVUserDefaults standardUserDefaults].deviceToken success:^(BMEToken *token) {
        [self.loggingInOverlayView hide:YES];
        
        [self didLogin];
    } loginFailure:^(NSError *error) {
        [self.loggingInOverlayView hide:YES];
        
        if ([error code] == BMEClientErrorUserFacebookUserNotFound) {
            NSString *title = NSLocalizedStringFromTable(@"ALERT_FACEBOOK_USER_NOT_REGISTERED_TITLE", @"BMELoginViewController", @"Title in alert view shown when Facebook user not found during log in.");
            NSString *message = NSLocalizedStringFromTable(@"ALERT_FACEBOOK_USER_NOT_REGISTERED_MESSAGE", @"BMELoginViewController", @"Message in alert view shown when Facebook user not found during log in.");
            NSString *cancelButton = NSLocalizedStringFromTable(@"ALERT_FACEBOOK_USER_NOT_REGISTERED_CANCEL", @"BMELoginViewController", @"Title of cancel button in alert view shown when Facebook user not found during log in.");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
            [alert show];
        } else {
            NSString *title = NSLocalizedStringFromTable(@"ALERT_FACEBOOK_LOGIN_UNKNOWN_ERROR_TITLE", @"BMELoginViewController", @"Title in alert view shown when a network error occurred during Facebook log in.");
            NSString *message = NSLocalizedStringFromTable(@"ALERT_FACEBOOK_LOGIN_UNKNOWN_ERROR_MESSAGE", @"BMELoginViewController", @"Message in alert view shown when a network error occurred during Facebook log in.");
            NSString *cancelButton = NSLocalizedStringFromTable(@"ALERT_FACEBOOK_LOGIN_UNKNOWN_ERROR_CANCEL", @"BMELoginViewController", @"Title of cancel button in alert view shown when a network error occurred during Facebook log in.");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
            [alert show];
        }
        
        NSLog(@"Could not log in with Facebook: %@", error);
    } accountFailure:^(NSError *error) {
        [self.loggingInOverlayView hide:YES];
        
        if ([error code] == ACErrorAccountNotFound) {
            NSString *title = NSLocalizedStringFromTable(@"ALERT_FACEBOOK_ACCOUNT_NOT_FOUND_TITLE", @"BMELoginViewController", @"Title in alert view shown when no Facebook account was found.");
            NSString *message = NSLocalizedStringFromTable(@"ALERT_FACEBOOK_ACCOUNT_NOT_FOUND_MESSAGE", @"BMELoginViewController", @"Message in alert view shown when no Facebook account was found.");
            NSString *cancelButton = NSLocalizedStringFromTable(@"ALERT_FACEBOOK_ACCOUNT_NOT_FOUND_CANCEL", @"BMELoginViewController", @"Title of cancel button in alert view shown when no Facebook account was found.");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
            [alert show];
        } else {
            NSString *title = NSLocalizedStringFromTable(@"ALERT_FACEBOOK_NOT_LOGGED_IN_TITLE", @"BMELoginViewController", @"Title in alert view shown when log in to Facebook failed");
            NSString *cancelButtonTitle = NSLocalizedStringFromTable(@"ALERT_FACEBOOK_NOT_LOGGED_IN_CANCEL", @"BMELoginViewController", @"Title of cancel button in alert view shown when log in to Facebook failed");
            NSString *message = NSLocalizedStringFromTable(@"ALERT_FACEBOOK_NOT_LOGGED_IN_MESSAGE", @"BMELoginViewController", @"Message in alert view shown when logging into Facebook but it failed because authentication failed");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil, nil];
            [alert show];
        }
        
        NSLog(@"Could not log in with Facebook due to account error: %@", error);
    }];
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password {
    [[BMEClient sharedClient] loginWithEmail:email password:password deviceToken:[GVUserDefaults standardUserDefaults].deviceToken success:^(BMEToken *token) {
        [self.loggingInOverlayView hide:YES];
        
        [self didLogin];
    } failure:^(NSError *error) {
        [self.loggingInOverlayView hide:YES];
        
        if ([error code] == BMEClientErrorUserIncorrectCredentials) {
            NSString *title = NSLocalizedStringFromTable(@"ALERT_INCORRECT_CREDENTIALS_TITLE", @"BMELoginViewController", @"Title in alert view shown when credentials are incorrect.");
            NSString *message = NSLocalizedStringFromTable(@"ALERT_INCORRECT_CREDENTIALS_MESSAGE", @"BMELoginViewController", @"Message in alert view shown when credentials are incorrect.");
            NSString *cancelButton = NSLocalizedStringFromTable(@"ALERT_INCORRECT_CREDENTIALS_CANCEL", @"BMELoginViewController", @"Title of cancel button in alert view shown when credentials are incorrect.");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
            [alert show];
        } else {
            NSString *title = NSLocalizedStringFromTable(@"ALERT_EMAIL_LOGIN_UNKNOWN_ERROR_TITLE", @"BMELoginViewController", @"Title in alert view shown when a network error occurred during e-mail log in.");
            NSString *message = NSLocalizedStringFromTable(@"ALERT_EMAIL_LOGIN_UNKNOWN_ERROR_MESSAGE", @"BMELoginViewController", @"Message in alert view shown when a network error occurred.");
            NSString *cancelButton = NSLocalizedStringFromTable(@"ALERT_EMAIL_LOGIN_UNKNOWN_ERROR_CANCEL", @"BMELoginViewController", @"Title of cancel button in alert view shown when a network error occurred during e-mail log in.");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
            [alert show];
        }
        
        NSLog(@"Could not log in: %@", error);
    }];
}

- (void)dismissKeyboard {
    if ([self.emailTextField isFirstResponder]) {
        [self.emailTextField resignFirstResponder];
    } else if ([self.passwordTextField isFirstResponder]) {
        [self.passwordTextField resignFirstResponder];
    }
}

- (MRProgressOverlayView *)addLoggingInOverlay {
    MRProgressOverlayView *progressOverlayView = [MRProgressOverlayView showOverlayAddedTo:self.view.window animated:YES];
    progressOverlayView.mode = MRProgressOverlayViewModeIndeterminate;
    progressOverlayView.titleLabelText = NSLocalizedStringFromTable(@"OVERLAY_LOGGING_IN_TITLE", @"BMELoginViewController", @"Title in overlay displayed when logging in");
    return progressOverlayView;
}

- (void)didLogin {
    [[BMEClient sharedClient] updateUserInfoWithUTCOffset:nil];
    [[BMEClient sharedClient] updateDeviceWithDeviceToken:[GVUserDefaults standardUserDefaults].deviceToken productionOrAdHoc:BMEIsProductionOrAdHoc];
    [self performSegueWithIdentifier:BMELoginLoggedInSegue sender:self];
}

#pragma mark -
#pragma mark Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

@end
