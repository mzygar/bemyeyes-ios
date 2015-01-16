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
#import "BMEScrollViewTextFieldHelper.h"
#import "BeMyEyes-Swift.h"
#import "BMEForgotPasswordViewController.h"
#import "PSPDFAlertView.h"
#import "PSTAlertController.h"

@interface BMELoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet Button *loginButton;
@property (weak, nonatomic) IBOutlet Button *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (strong, nonatomic) BMEScrollViewTextFieldHelper *scrollViewHelper;

@property (strong, nonatomic) MRProgressOverlayView *loggingInOverlayView;
@end

@implementation BMELoginViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MKLocalization registerForLocalization:self];
    
    self.scrollViewHelper = [[BMEScrollViewTextFieldHelper alloc] initWithScrollview:self.scrollView inViewController:self];
}

- (void)dealloc {
    [self hideLoggingInOverlay];
    _loggingInOverlayView = nil;
}

- (void)shouldLocalize {
    [self.backButton setTitle:MKLocalizedFromTable(BME_LOGIN_BACK, BMELoginLocalizationTable) forState:UIControlStateNormal];
    
    self.emailTextField.placeholder = MKLocalizedFromTable(BME_LOGIN_EMAIL_PLACEHOLDER, BMELoginLocalizationTable);
    self.passwordTextField.placeholder = MKLocalizedFromTable(BME_LOGIN_PASSWORD_PLACEHOLDER, BMELoginLocalizationTable);
    
    self.loginButton.title = MKLocalizedFromTable(BME_LOGIN_PERFORM_LOG_IN, BMELoginLocalizationTable);
    self.facebookButton.title = MKLocalizedFromTable(BME_LOGIN_FACEBOOK, BMELoginLocalizationTable);
     [self.forgotPasswordButton setTitle:MKLocalizedFromTable(BME_LOGIN_FORGOT_PASSWORD, BMELoginLocalizationTable) forState:UIControlStateNormal];
}

- (BOOL)prefersStatusBarHidden
{
    return self.scrollViewHelper.prefersStatusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return self.scrollViewHelper.preferredStatusBarUpdateAnimation;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[BMEForgotPasswordViewController class]]) {
        BMEForgotPasswordViewController *viewController = (BMEForgotPasswordViewController *)segue.destinationViewController;
        [viewController prepopulateWithEmail:self.emailTextField.text];
    }
}

- (BOOL)accessibilityPerformEscape {
    [self.navigationController popViewControllerAnimated:NO];
    return YES;
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
    
    if (useFacebook) {
        [self performLoginWithFacebook];
    } else {
        [self performLoginWithEmail];
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
        
        NSString *title = MKLocalizedFromTable(BME_LOGIN_ALERT_EMPTY_FIELDS_TITLE, BMELoginLocalizationTable);
        NSString *message = MKLocalizedFromTable(BME_LOGIN_ALERT_EMPTY_FIELD_MESSAGE, BMELoginLocalizationTable);
        NSString *cancelButton = MKLocalizedFromTable(BME_LOGIN_ALERT_EMPTY_FIELDS_CANCEL, BMELoginLocalizationTable);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
        [alert show];
    } else {
        // Trim whitespace
        NSString *email = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [self loginWithEmail:email password:password];
        [self dismissKeyboard];
    }
}

- (void)performLoginWithFacebook {
    [self showLoggingInOverlay];
    
    [[BMEClient sharedClient] loginUsingFacebookWithDeviceToken:[GVUserDefaults standardUserDefaults].deviceToken success:^(BMEToken *token) {
        [self hideLoggingInOverlay];
        
        [self didLogin];
    } loginFailure:^(NSError *error) {
        [self hideLoggingInOverlay];
        
        
        if ([error code] == BMEClientErrorUserFacebookUserNotFound) {
            NSString *title = MKLocalizedFromTable(BME_LOGIN_ALERT_FACEBOOK_USER_NOT_REGISTERED_TITLE, BMELoginLocalizationTable);
            NSString *message = MKLocalizedFromTable(BME_LOGIN_ALERT_FACEBOOK_USER_NOT_REGISTERED_MESSAGE, BMELoginLocalizationTable);
            NSString *cancelButton = MKLocalizedFromTable(BME_LOGIN_ALERT_FACEBOOK_USER_NOT_REGISTERED_CANCEL, BMELoginLocalizationTable);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
            [alert show];
        } else {
            NSString *title = MKLocalizedFromTable(BME_LOGIN_ALERT_FACEBOOK_UNKNOWN_ERROR_TITLE, BMELoginLocalizationTable);
            NSString *message = MKLocalizedFromTable(BME_LOGIN_ALERT_FACEBOOK_UNKNOWN_ERROR_MESSAGE, BMELoginLocalizationTable);
            NSString *cancelButton = MKLocalizedFromTable(BME_LOGIN_ALERT_FACEBOOK_UNKNOWN_ERROR_CANCEL, BMELoginLocalizationTable);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
            [alert show];
        }
        
        NSLog(@"Could not log in with Facebook: %@", error);
    } accountFailure:^(NSError *error) {
        [self hideLoggingInOverlay];
        
        if ([error code] == BMEClientErrorUserFacebookAccessNotAllowed ||
            error.code == ACErrorPermissionDenied) {
            NSString *title = MKLocalizedFromTable(BME_LOGIN_ALERT_FACEBOOK_ACCESS_DENIED_TITLE, BMELoginLocalizationTable);
            NSString *message = MKLocalizedFromTable(BME_LOGIN_ALERT_FACEBOOK_ACCESS_DENIED_MESSAGE, BMELoginLocalizationTable);
            
            PSTAlertController *alert = [PSTAlertController alertControllerWithTitle:title message:message preferredStyle:PSTAlertControllerStyleAlert];
            
            NSString *ok = MKLocalizedFromTable(BME_LOGIN_ALERT_FACEBOOK_ACCESS_DENIED_OK, BMELoginLocalizationTable);
            [alert addAction:[PSTAlertAction actionWithTitle:ok handler:nil]];
            
            [alert showWithSender:self controller:self animated:YES completion:nil];
        } else if ([error code] == ACErrorAccountNotFound) {
            NSString *title = MKLocalizedFromTable(BME_LOGIN_ALERT_FACEBOOK_ACCOUNT_NOT_FOUND_TITLE, BMELoginLocalizationTable);
            NSString *message = MKLocalizedFromTable(BME_LOGIN_ALERT_FACEBOOK_ACCOUNT_NOT_FOUND_MESSAGE, BMELoginLocalizationTable);
            NSString *cancelButton = MKLocalizedFromTable(BME_LOGIN_ALERT_FACEBOOK_ACCOUNT_NOT_FOUND_CANCEL, BMELoginLocalizationTable);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
            [alert show];
        } else {
            NSString *title = MKLocalizedFromTable(BME_LOGIN_ALERT_FACEBOOK_NOT_LOGGED_IN_TITLE, BMELoginLocalizationTable);
            NSString *cancelButtonTitle = MKLocalizedFromTable(BME_LOGIN_ALERT_FACEBOOK_NOT_LOGGED_IN_MESSAGE, BMELoginLocalizationTable);
            NSString *message = MKLocalizedFromTable(BME_LOGIN_ALERT_FACEBOOK_NOT_LOGGED_IN_CANCEL, BMELoginLocalizationTable);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil, nil];
            [alert show];
        }
        
        NSLog(@"Could not log in with Facebook due to account error: %@", error);
    }];
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password {
    [self showLoggingInOverlay];
    
    [[BMEClient sharedClient] loginWithEmail:email password:password deviceToken:[GVUserDefaults standardUserDefaults].deviceToken success:^(BMEToken *token) {
        [self hideLoggingInOverlay];
        
        [self didLogin];
    } failure:^(NSError *error) {
        [self hideLoggingInOverlay];
        
        if ([error code] == BMEClientErrorUserIncorrectCredentials) {
            NSString *title = MKLocalizedFromTable(BME_LOGIN_ALERT_INCORRECT_CREDENTIALS_TITLE, BMELoginLocalizationTable);
            NSString *message = MKLocalizedFromTable(BME_LOGIN_ALERT_INCORRECT_CREDENTIALS_MESSAGE, BMELoginLocalizationTable);
            NSString *cancelButton = MKLocalizedFromTable(BME_LOGIN_ALERT_INCORRECT_CREDENTIALS_CANCEL, BMELoginLocalizationTable);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
            [alert show];
        } else {
            NSString *title = MKLocalizedFromTable(BME_LOGIN_ALERT_EMAIL_LOGIN_UNKNOWN_ERROR_TITLE, BMELoginLocalizationTable);
            NSString *message = MKLocalizedFromTable(BME_LOGIN_ALERT_EMAIL_LOGIN_UNKNOWN_ERROR_MESSAGE, BMELoginLocalizationTable);
            NSString *cancelButton = MKLocalizedFromTable(BME_LOGIN_ALERT_EMAIL_LOGIN_UNKNOWN_ERROR_CANCEL, BMELoginLocalizationTable);
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

- (void)showLoggingInOverlay {
    if (_loggingInOverlayView) {
        return;
    }
    self.loggingInOverlayView = [self addLoggingInOverlay];
}

- (void)hideLoggingInOverlay {
    if (!_loggingInOverlayView) {
        return;
    }
    [self.loggingInOverlayView hide:YES];
    _loggingInOverlayView = nil;
}

- (MRProgressOverlayView *)addLoggingInOverlay {
    MRProgressOverlayView *progressOverlayView = [MRProgressOverlayView showOverlayAddedTo:self.view.window animated:YES];
    progressOverlayView.mode = MRProgressOverlayViewModeIndeterminate;
    progressOverlayView.titleLabelText = MKLocalizedFromTable(BME_LOGIN_OVERLAY_LOGGING_IN_TITLE, BMELoginLocalizationTable);
    return progressOverlayView;
}

- (void)didLogin {
    [[BMEClient sharedClient] updateUserInfoWithUTCOffset:nil];
    [[BMEClient sharedClient] upsertDeviceWithNewToken:nil production:[GVUserDefaults standardUserDefaults].isRelease completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:BMEDidLogInNotification object:nil];
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
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [textField resignFirstResponder];
        [self performLoginUsingFacebook:NO];
    }
    return YES;
}

@end
