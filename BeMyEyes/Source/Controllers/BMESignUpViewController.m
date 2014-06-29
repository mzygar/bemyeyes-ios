//
//  BMESignUpViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 22/02/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMESignUpViewController.h"
#import <MRProgress/MRProgress.h>
#import "BMEAppDelegate.h"
#import "BMEClient.h"
#import "BMEEmailValidator.h"

#define BMESignUpMinimumPasswordLength 6
#define BMESignUpLoggedInSegue @"LoggedIn"
#define BMERegisteredSegue @"Registered"

@interface BMESignUpViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (strong, nonatomic) UITextField *activeTextField;
@property (assign, nonatomic) CGSize keyboardSize;

@property (assign, nonatomic, getter = hasScrolled) BOOL scrolled;
@end

@implementation BMESignUpViewController

#pragma mark -
#pragma mark Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.activeTextField = nil;
}

#pragma mark -
#pragma mark Private Methods

- (IBAction)signUpButtonPressed:(id)sender {
    if (self.role == BMERoleHelper) {
        [TheAppDelegate requirePushNotificationsEnabled:^(BOOL isEnabled) {
            if (isEnabled) {
                [self performRegistration];
            }
        }];
    } else {
        [self performRegistration];
    }
}

- (void)performRegistration {
    if ([self isInformationValid]) {
        MRProgressOverlayView *progressOverlayView = [MRProgressOverlayView showOverlayAddedTo:self.view.window animated:YES];
        progressOverlayView.mode = MRProgressOverlayViewModeIndeterminate;
        progressOverlayView.titleLabelText = NSLocalizedStringFromTable(@"OVERLAY_REGISTERING_TITLE", @"BMESignUpViewController", @"Title in overlay displayed when registering");
        
        NSString *email = [self.emailTextField text];
        NSString *password = [self.passwordTextField text];
        NSString *firstName = [self.firstNameTextField text];
        NSString *lastName = [self.lastNameTextField text];
        [[BMEClient sharedClient] createUserWithEmail:email password:password firstName:firstName lastName:lastName role:self.role completion:^(BOOL success, NSError *error) {
            if (success && !error) {
                progressOverlayView.titleLabelText = NSLocalizedStringFromTable(@"OVERLAY_LOGGING_IN_TITLE", @"BMESignUpViewController", @"Title in overlay displayed when logging in");
                
                [TheAppDelegate requireDeviceRegisteredForRemoteNotifications:^(BOOL isRegistered, NSString *deviceToken, NSError *error) {
                    if (!error) {
                        [[BMEClient sharedClient] loginWithEmail:email password:password deviceToken:deviceToken success:^(BMEToken *token) {
                            [progressOverlayView hide:YES];
                        
                            [self didLogin];
                        } failure:^(NSError *error) {
                            [progressOverlayView hide:YES];
                        
                            [self performSegueWithIdentifier:BMERegisteredSegue sender:self];
                        }];
                    } else {
                        [progressOverlayView hide:YES];
                    }
                }];
            } else {
                [progressOverlayView hide:YES];
                
                if ([error code] == BMEClientErrorUserEmailAlreadyRegistered) {
                    NSString *title = NSLocalizedStringFromTable(@"ALERT_EMAIL_ALREADY_REGISTERED_TITLE", @"BMESignUpViewController", @"Title in alert view shown when e-mail is already registered.");
                    NSString *message = NSLocalizedStringFromTable(@"ALERT_EMAIL_ALREADY_REGISTERED_MESSAGE", @"BMESignUpViewController", @"Message in alert view shown when e-mail is already registered.");
                    NSString *cancelButton = NSLocalizedStringFromTable(@"ALERT_EMAIL_ALREADY_REGISTERED_CANCEL", @"BMESignUpViewController", @"Title of cancel button in alert view shown when e-mail is already registered.");
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
                    [alert show];
                } else {
                    NSString *title = NSLocalizedStringFromTable(@"ALERT_SIGN_UP_UNKNOWN_ERROR_TITLE", @"BMESignUpViewController", @"Title in alert view shown when a network error occurred.");
                    NSString *message = NSLocalizedStringFromTable(@"ALERT_SIGN_UP_UNKNOWN_ERROR_MESSAGE", @"BMESignUpViewController", @"Message in alert view shown when a network error occurred.");
                    NSString *cancelButton = NSLocalizedStringFromTable(@"ALERT_SIGN_UP_UNKNOWN_ERROR_CANCEL", @"BMESignUpViewController", @"Title of cancel button in alert view shown when a network error occurred.");
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
        }];
    }
}

- (void)didLogin {
    [self performSegueWithIdentifier:BMESignUpLoggedInSegue sender:self];
}

- (BOOL)isInformationValid {
    BOOL isFirstNameEmpty = [self.firstNameTextField text] == 0;
    BOOL isLastNameEmpty = [self.lastNameTextField text] == 0;
    BOOL isEmailEmpty = [self.emailTextField text] == 0;
    BOOL isPasswordEmpty = [self.passwordTextField text] == 0;
    
    if (isFirstNameEmpty || isLastNameEmpty || isEmailEmpty || isPasswordEmpty) {
        if (isFirstNameEmpty) {
            [self.firstNameTextField becomeFirstResponder];
        } else if (isLastNameEmpty) {
            [self.lastNameTextField becomeFirstResponder];
        } else if (isEmailEmpty) {
            [self.emailTextField becomeFirstResponder];
        } else if (isPasswordEmpty) {
            [self.passwordTextField becomeFirstResponder];
        }
        
        NSString *title = NSLocalizedStringFromTable(@"ALERT_EMPTY_FIELDS_TITLE", @"BMESignUpViewController", @"Title in alert view shown when one or more fields are empty.");
        NSString *message = NSLocalizedStringFromTable(@"ALERT_EMPTY_FIELDS_MESSAGE", @"BMESignUpViewController", @"Message in alert view shown when one or more fields are empty.");
        NSString *cancelButton = NSLocalizedStringFromTable(@"ALERT_EMPTY_FIELDS_CANCEL", @"BMESignUpViewController", @"Title of cancel button in alert view shown when one or more fields are empty.");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
        [alert show];
        
        return NO;
    } else if (![BMEEmailValidator isEmailValid:[self.emailTextField text]]) {
        NSString *title = NSLocalizedStringFromTable(@"ALERT_EMAIL_NOT_VALID_TITLE", @"BMESignUpViewController", @"Title in alert view shown when the e-mail is not valid.");
        NSString *message = NSLocalizedStringFromTable(@"ALERT_EMAIL_NOT_VALID_MESSAGE", @"BMESignUpViewController", @"Message in alert view shown when the e-mail is not valid.");
        NSString *cancelButton = NSLocalizedStringFromTable(@"ALERT_EMAIL_NOT_VALID_CANCEL", @"BMESignUpViewController", @"Title of cancel button in alert view shown when the e-mail is not valid.");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
        [alert show];
        
        return NO;
    } else if ([[self.passwordTextField text] length] < BMESignUpMinimumPasswordLength) {
        NSString *title = NSLocalizedStringFromTable(@"ALERT_PASSWORD_TOO_SHORT_TITLE", @"BMESignUpViewController", @"Title in alert view shown when the password is too short.");
        NSString *message = NSLocalizedStringFromTable(@"ALERT_PASSWORD_TOO_SHORT_MESSAGE", @"BMESignUpViewController", @"Message in alert view shown when the password is too short.");
        NSString *cancelButton = NSLocalizedStringFromTable(@"ALERT_PASSWORD_TOO_SHORT_CANCEL", @"BMESignUpViewController", @"Title of cancel button in alert view shown when the password is too short.");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
        [alert show];
        
        return NO;
    }
    
    return YES;
}

- (void)scrollIfNecessary {
    CGRect rect = self.view.frame;
    rect.size.height -= self.keyboardSize.height;
    
    CGRect textFieldFrame = [self.activeTextField convertRect:self.activeTextField.frame toView:self.scrollView];
    if (CGRectGetMaxY(textFieldFrame) > CGRectGetMaxY(rect)) {
        CGRect visibleRect = CGRectZero;
        visibleRect.origin = CGPointMake(0.0f, CGRectGetMinY(textFieldFrame));
        visibleRect.size = CGSizeMake(CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(textFieldFrame) + 20.0f);
        
        CGPoint scrollOffset = CGPointMake(0.0f, CGRectGetMaxY(textFieldFrame) - CGRectGetMaxY(rect));
        [self.scrollView setContentOffset:scrollOffset animated:YES];
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        
        self.scrolled = YES;
    } else {
        [self resetScrollIfNecessary];
    }
}

- (void)resetScrollIfNecessary {
    if (self.hasScrolled) {
        self.scrollView.contentInset = UIEdgeInsetsZero;
        self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
        [self.scrollView setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
    
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        
        self.scrolled = NO;
    }
}

#pragma mark -
#pragma mark Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeTextField = textField;
    
    [self scrollIfNecessary];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark -
#pragma mark Notifications

- (void)keyboardDidShow:(NSNotification *)notification {
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect convertedKeyboardFrame = [self.view convertRect:keyboardFrame fromView:self.view.window];
    self.keyboardSize = convertedKeyboardFrame.size;
    
    [self scrollIfNecessary];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self resetScrollIfNecessary];
}

@end
