//
//  BMELoginViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 22/02/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMELoginViewController.h"
#import "BMEClient.h"

#define BMELoginControllerLoggedInSegue @"LoggedIn"

@interface BMELoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@end

@implementation BMELoginViewController

#pragma mark -
#pragma mark Private Methods

- (IBAction)facebookButtonPressed:(id)sender {
    [self loginWithFacebookSuccess];
}

- (IBAction)loginButtonPressed:(id)sender {
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
    }
}

- (IBAction)forgotPasswordButtonPressed:(id)sender {
    
}

#pragma mark -
#pragma mark Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark -
#pragma mark Private Methods

- (void)loginWithEmail:(NSString *)email password:(NSString *)password {
    [[BMEClient sharedClient] loginWithEmail:email password:password success:^(BMEToken *token) {
        [self didLogin];
    } failure:^(NSError *error) {
        if (error.code == BMEClientErrorUserFacebookUserNotFound) {
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
    }];
}

- (void)loginWithFacebookSuccess {
    [[BMEClient sharedClient] loginUsingFacebookWithSuccesss:^(BMEToken *token) {
        [self didLogin];
    } loginFailure:^(NSError *error) {
        if (error.code == BMEClientErrorUserFacebookUserNotFound) {
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
    } accountFailure:^(NSError *error) {
        NSString *title = NSLocalizedStringFromTable(@"ALERT_FACEBOOK_NOT_LOGGED_IN_TITLE", @"BMELoginViewController", @"Title in alert view shown when log in to Facebook failed");
        NSString *cancelButtonTitle = NSLocalizedStringFromTable(@"ALERT_FACEBOOK_NOT_LOGGED_IN_CANCEL", @"BMELoginViewController", @"Title of cancel button in alert view shown when log in to Facebook failed");
        NSString *message = NSLocalizedStringFromTable(@"ALERT_FACEBOOK_NOT_LOGGED_IN_MESSAGE", @"BMELoginViewController", @"Message in alert view shown when logging into Facebook but it failed because authentication failed");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil, nil];
        [alert show];
    }];
}

- (void)didLogin {
    [self performSegueWithIdentifier:BMELoginControllerLoggedInSegue sender:self];
}

@end
