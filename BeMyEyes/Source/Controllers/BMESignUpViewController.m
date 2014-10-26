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
#import "NSString+BMEDeviceToken.h"
#import "BeMyEyes-Swift.h"

#define BMESignUpMinimumPasswordLength 6
#define BMESignUpLoggedInSegue @"LoggedIn"
#define BMERegisteredSegue @"Registered"

@interface BMESignUpViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet Button *registerButton;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MKLocalization registerForLocalization:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.activeTextField = nil;
}

- (void)shouldLocalize {
    [self.backButton setTitle:MKLocalizedFromTable(BME_SIGN_UP_BACK, BMESignUpLocalizationTable) forState:UIControlStateNormal];
    
    self.firstNameTextField.placeholder = MKLocalizedFromTable(BME_SIGN_UP_FIRST_NAME_PLACEHOLDER, BMESignUpLocalizationTable);
    self.lastNameTextField.placeholder = MKLocalizedFromTable(BME_SIGN_UP_LAST_NAME_PLACEHOLDER, BMESignUpLocalizationTable);
    
    self.emailTextField.placeholder = MKLocalizedFromTable(BME_SIGN_UP_EMAIL_PLACEHOLDER, BMESignUpLocalizationTable);
    self.passwordTextField.placeholder = MKLocalizedFromTable(BME_SIGN_UP_PASSWORD_PLACEHOLDER, BMESignUpLocalizationTable);
    
    self.registerButton.title = MKLocalizedFromTable(BME_SIGN_UP_REGISTER, BMESignUpLocalizationTable);
}

#pragma mark -
#pragma mark Private Methods

- (IBAction)signUpButtonPressed:(id)sender {
    [self performRegistration];
}

- (void)performRegistration {
    if ([self isInformationValid]) {
        [self dismissKeyboard];
        
        MRProgressOverlayView *progressOverlayView = [MRProgressOverlayView showOverlayAddedTo:self.view.window animated:YES];
        progressOverlayView.mode = MRProgressOverlayViewModeIndeterminate;
        progressOverlayView.titleLabelText = MKLocalizedFromTable(BME_SIGN_UP_OVERLAY_REGISTERING_TITLE, BMESignUpLocalizationTable);
        
        // Trim whitespace
        NSString *email = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *firstName = [self.firstNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *lastName = [self.lastNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [[BMEClient sharedClient] createUserWithEmail:email password:password firstName:firstName lastName:lastName role:self.role completion:^(BOOL success, NSError *error) {
            if (success && !error) {
                progressOverlayView.titleLabelText = MKLocalizedFromTable(BME_SIGN_UP_OVERLAY_LOGGING_IN_TITLE, BMESignUpLocalizationTable);
                
                NSString *deviceToken = [GVUserDefaults standardUserDefaults].deviceToken;
                if (!deviceToken) {
                    deviceToken = [NSString BMETemporaryDeviceToken];
                    [GVUserDefaults standardUserDefaults].deviceToken = deviceToken;
                    [GVUserDefaults standardUserDefaults].isTemporaryDeviceToken = YES;
                    [GVUserDefaults synchronize];
                }
                
                [[BMEClient sharedClient] registerDeviceWithAbsoluteDeviceToken:deviceToken active:NO production:BMEIsProductionOrAdHoc completion:^(BOOL success, NSError *error) {
                    if (success && !error) {
                        [[BMEClient sharedClient] loginWithEmail:email password:password deviceToken:deviceToken success:^(BMEToken *token) {
                            [progressOverlayView hide:YES];
                            
                            [self didLogin];
                        } failure:^(NSError *error) {
                            [progressOverlayView hide:YES];
                            
                            [self performSegueWithIdentifier:BMERegisteredSegue sender:self];
                            
                            NSLog(@"Failed logging in after sign up: %@", error);
                        }];
                    } else {
                        [progressOverlayView hide:YES];
                        
                        [self performSegueWithIdentifier:BMERegisteredSegue sender:self];
                        
                        NSLog(@"Failed registering device before automatic log in after sign up: %@", error);
                    }
                }];
            } else {
                [progressOverlayView hide:YES];
                
                if ([error code] == BMEClientErrorUserEmailAlreadyRegistered) {
                    NSString *title = MKLocalizedFromTable(BME_SIGN_UP_ALERT_EMAIL_ALREADY_REGISTERED_TITLE, BMESignUpLocalizationTable);
                    NSString *message = MKLocalizedFromTable(BME_SIGN_UP_ALERT_EMAIL_ALREADY_REGISTERED_MESSAGE, BMESignUpLocalizationTable);
                    NSString *cancelButton = MKLocalizedFromTable(BME_SIGN_UP_ALERT_EMAIL_ALREADY_REGISTERED_CANCEL, BMESignUpLocalizationTable);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
                    [alert show];
                } else {
                    NSString *title = MKLocalizedFromTable(BME_SIGN_UP_ALERT_UNKNOWN_ERROR_TITLE, BMESignUpLocalizationTable);
                    NSString *message = MKLocalizedFromTable(BME_SIGN_UP_ALERT_UNKNOWN_ERROR_MESSAGE, BMESignUpLocalizationTable);
                    NSString *cancelButton = MKLocalizedFromTable(BME_SIGN_UP_ALERT_UNKNOWN_ERROR_CANCEL, BMESignUpLocalizationTable);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
        }];
    }
}

- (void)didLogin {
    [[BMEClient sharedClient] updateUserInfoWithUTCOffset:nil];
    [[BMEClient sharedClient] updateDeviceWithDeviceToken:[GVUserDefaults standardUserDefaults].deviceToken active:![GVUserDefaults standardUserDefaults].isTemporaryDeviceToken productionOrAdHoc:BMEIsProductionOrAdHoc];
    
    [self performSegueWithIdentifier:BMESignUpLoggedInSegue sender:self];
}

- (BOOL)isInformationValid {
    NSString *email = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *firstName = [self.firstNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *lastName = [self.lastNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL isFirstNameEmpty = firstName == 0;
    BOOL isLastNameEmpty = lastName == 0;
    BOOL isEmailEmpty = email == 0;
    BOOL isPasswordEmpty = email == 0;
    
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
        
        NSString *title = MKLocalizedFromTable(BME_SIGN_UP_ALERT_EMPTY_FIELDS_TITLE, BMESignUpLocalizationTable);
        NSString *message = MKLocalizedFromTable(BME_SIGN_UP_ALERT_EMPTY_FIELDS_MESSAGE, BMESignUpLocalizationTable);
        NSString *cancelButton = MKLocalizedFromTable(BME_SIGN_UP_ALERT_EMPTY_FIELDS_CANCEL, BMESignUpLocalizationTable);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
        [alert show];
        
        return NO;
    } else if (![BMEEmailValidator isEmailValid:email]) {
        NSString *title = MKLocalizedFromTable(BME_SIGN_UP_ALERT_EMAIL_NOT_VALID_TITLE, BMESignUpLocalizationTable);
        NSString *message = MKLocalizedFromTable(BME_SIGN_UP_ALERT_EMAIL_NOT_VALID_MESSAGE, BMESignUpLocalizationTable);
        NSString *cancelButton = MKLocalizedFromTable(BME_SIGN_UP_ALERT_EMAIL_NOT_VALID_CANCEL, BMESignUpLocalizationTable);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
        [alert show];
        
        return NO;
    } else if ([password length] < BMESignUpMinimumPasswordLength) {
        NSString *title = MKLocalizedFromTable(BME_SIGN_UP_ALERT_PASSWORD_TOO_SHORT_TITLE, BMESignUpLocalizationTable);
        NSString *message = MKLocalizedFromTable(BME_SIGN_UP_ALERT_PASSWORD_TOO_SHORT_MESSAGE, BMESignUpLocalizationTable);
        NSString *cancelButton = MKLocalizedFromTable(BME_SIGN_UP_ALERT_PASSWORD_TOO_SHORT_CANCEL, BMESignUpLocalizationTable);
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

- (void)dismissKeyboard {
    if ([self.firstNameTextField isFirstResponder]) {
        [self.firstNameTextField resignFirstResponder];
    } else if ([self.lastNameTextField isFirstResponder]) {
        [self.lastNameTextField resignFirstResponder];
    } else if ([self.emailTextField isFirstResponder]) {
        [self.emailTextField resignFirstResponder];
    } else if ([self.passwordTextField isFirstResponder]) {
        [self.passwordTextField resignFirstResponder];
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
    if (textField == self.firstNameTextField) {
        [self.lastNameTextField becomeFirstResponder];
    } else if (textField == self.lastNameTextField) {
        [self.emailTextField becomeFirstResponder];
    } else if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [textField resignFirstResponder];
        [self performRegistration];
    }
    
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
