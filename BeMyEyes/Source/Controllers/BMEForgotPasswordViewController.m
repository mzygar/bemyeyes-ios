//
//  BMEForgotPasswordViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 13/06/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEForgotPasswordViewController.h"
#import <MRProgress/MRProgress.h>
#import "BMEEmailValidator.h"
#import "BMEClient.h"
#import "BMEScrollViewTextFieldHelper.h"
#import "BeMyEyes-Swift.h"

@interface BMEForgotPasswordViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet Button *sendPasswordButton;
@property (strong, nonatomic) BMEScrollViewTextFieldHelper *scrollViewHelper;
@property (strong, nonatomic) NSString *prepopulatingEmail;
@end

@implementation BMEForgotPasswordViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MKLocalization registerForLocalization:self];
    
    self.scrollViewHelper = [[BMEScrollViewTextFieldHelper alloc] initWithScrollview:self.scrollView inViewController:self];
    self.emailTextField.text = self.prepopulatingEmail;
}

- (void)shouldLocalize {
    [self.backButton setTitle:MKLocalizedFromTable(BME_FORGOT_PASSWORD_BACK, BMEForgotPasswordLocalizationTable) forState:UIControlStateNormal];
    
    self.descriptionLabel.text = MKLocalizedFromTable(BME_FORGOT_PASSWORD_DESCRIPTION, BMEForgotPasswordLocalizationTable);
    
    self.emailTextField.placeholder = MKLocalizedFromTable(BME_FORGOT_PASSWORD_EMAIL_PLACEHOLDER, BMEForgotPasswordLocalizationTable);
    
    self.sendPasswordButton.title = MKLocalizedFromTable(BME_FORGOT_PASSWORD_EMAIL_PLACEHOLDER, BMEForgotPasswordLocalizationTable);
}

- (BOOL)prefersStatusBarHidden
{
    return self.scrollViewHelper.prefersStatusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return self.scrollViewHelper.preferredStatusBarUpdateAnimation;
}


#pragma mark - Public Methods

- (void)prepopulateWithEmail:(NSString *)email {
    self.prepopulatingEmail = email;
    self.emailTextField.text = self.prepopulatingEmail;
}


#pragma mark -
#pragma mark Private Methods

- (IBAction)sendNewPasswordButtonPressed:(id)sender {
    if ([self.emailTextField isFirstResponder]) {
        [self.emailTextField resignFirstResponder];
    }
    
    [self performSendPasswordToEmail];
}

- (void)performSendPasswordToEmail {
    if ([self performEmailValidation]) {
        NSString *email = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self sendNewPasswordToEmail:email];
    }
}

- (BOOL)performEmailValidation {
    NSString *email = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([BMEEmailValidator isEmailValid:email]) {
        return YES;
    } else {
        NSString *title = MKLocalizedFromTable(BME_FORGOT_PASSWORD_ALERT_EMAIL_NOT_VALID_TITLE, BMEForgotPasswordLocalizationTable);
        NSString *message = MKLocalizedFromTable(BME_FORGOT_PASSWORD_ALERT_EMAIL_NOT_VALID_MESSAGE, BMEForgotPasswordLocalizationTable);
        NSString *cancelButton = MKLocalizedFromTable(BME_FORGOT_PASSWORD_ALERT_EMAIL_NOT_VALID_CANCEL, BMEForgotPasswordLocalizationTable);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
        [alert show];
        
        return NO;
    }
}

- (void)sendNewPasswordToEmail:(NSString *)email {
    MRProgressOverlayView *progressOverlayView = [MRProgressOverlayView showOverlayAddedTo:self.view.window animated:YES];
    progressOverlayView.mode = MRProgressOverlayViewModeIndeterminate;
    progressOverlayView.titleLabelText = MKLocalizedFromTable(BME_FORGOT_PASSWORD_OVERLAY_SENDING_REQUEST_FOR_NEW_PASSWORD_TITLE, BMEForgotPasswordLocalizationTable);
    
    [[BMEClient sharedClient] sendNewPasswordToEmail:email completion:^(BOOL success, NSError *error) {
        [progressOverlayView hide:YES];
        
        if (error && [error code] != BMEClientErrorUserNotFound && [error code] != BMEClientErrorNotPermitted) {
            NSString *title = MKLocalizedFromTable(BME_FORGOT_PASSWORD_ALERT_SEND_NEW_PASSWORD_REQUEST_FAILED_TITLE, BMEForgotPasswordLocalizationTable);
            NSString *message = MKLocalizedFromTable(BME_FORGOT_PASSWORD_ALERT_SEND_NEW_PASSWORD_REQUEST_FAILED_MESSAGE, BMEForgotPasswordLocalizationTable);
            NSString *cancelButton = MKLocalizedFromTable(BME_FORGOT_PASSWORD_ALERT_SEND_NEW_PASSWORD_REQUEST_FAILED_CANCEL, BMEForgotPasswordLocalizationTable);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
            [alert show];
        } else {
            self.emailTextField.text = nil;
            
            NSString *title = MKLocalizedFromTable(BME_FORGOT_PASSWORD_ALERT_SEND_NEW_PASSWORD_REQUEST_SUCCESS_TITLE, BMEForgotPasswordLocalizationTable);
            NSString *message = MKLocalizedFromTable(BME_FORGOT_PASSWORD_ALERT_SEND_NEW_PASSWORD_REQUEST_SUCCESS_MESSAGE, BMEForgotPasswordLocalizationTable);
            NSString *cancelButton = MKLocalizedFromTable(BME_FORGOT_PASSWORD_ALERT_SEND_NEW_PASSWORD_REQUEST_SUCCESS_CANCEL, BMEForgotPasswordLocalizationTable);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
            [alert show];
        }
        
        if (error) {
            NSLog(@"Could not send request for new password: %@", error);
        }
    }];
}

#pragma mark -
#pragma mark Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.scrollViewHelper.activeView = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.scrollViewHelper.activeView = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [textField resignFirstResponder];
        [self performSendPasswordToEmail];
    }
    return YES;
}

@end
