//
//  BMESettingsViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 09/03/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMESettingsViewController.h"
#import <MRProgress/MRProgress.h>
#import <MessageUI/MessageUI.h>
#import "BMEClient.h"
#import "BMEUser.h"
#import "BMEEmailValidator.h"

#define BMEUnwindSettingsSegue @"UnwindSettings"

@interface BMESettingsViewController () <UITextFieldDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UISwitch *boostSwitch;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (assign, nonatomic) BOOL shouldSave;
@end

@implementation BMESettingsViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self populateFields];
    
    self.versionLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"VERSION_TITLE", @"BMESettingsViewController", @"Version title"), [self versionString]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self saveIfSettingChanged];
}

#pragma mark -
#pragma mark Private Methods

- (IBAction)logOutButtonPressed:(id)sender {
    MRProgressOverlayView *progressOverlayView = [MRProgressOverlayView showOverlayAddedTo:self.view.window animated:YES];
    progressOverlayView.mode = MRProgressOverlayViewModeIndeterminate;
    progressOverlayView.titleLabelText = NSLocalizedStringFromTable(@"OVERLAY_LOGGING_OUT_TITLE", @"BMESettingsViewController", @"Title in overlay shown when logging out");
    
    [[BMEClient sharedClient] logoutWithCompletion:^(BOOL success, NSError *error) {
        [progressOverlayView hide:YES];
        
        if (!error || [error code] == BMEClientErrorUserTokenNotFound) {
            [[NSNotificationCenter defaultCenter] postNotificationName:BMEDidLogOutNotification object:nil];
            
            [self performSegueWithIdentifier:BMEUnwindSettingsSegue sender:self];
        } else {
            NSString *title = NSLocalizedStringFromTable(@"ALERT_LOG_OUT_FAILED_TITLE", @"BMESettingsViewController", @"Title in alert view shown when log out failed");
            NSString *message = NSLocalizedStringFromTable(@"ALERT_LOG_OUT_FAILED_MESSAGE", @"BMESettingsViewController", @"Messaage in alert view shown when log out failed");
            NSString *cancelTitle = NSLocalizedStringFromTable(@"ALERT_LOG_OUT_FAILED_CANCEL", @"BMESettingsViewController", @"Title of cancel button in alert view shown when log out failed");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelTitle otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
}

- (IBAction)changePasswordButtonPressed:(id)sender {
    
}

- (IBAction)boostSwitchValueChanged:(id)sender {
    
}

- (IBAction)settingValueChanged:(id)sender {
    self.shouldSave = YES;
}

- (IBAction)feedbackButtonPressed:(id)sender {
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSString *initialBody = [NSString stringWithFormat:@"\n\n%@ %@", appName, [self versionString]];
    MFMailComposeViewController *mailComposeController = [MFMailComposeViewController new];
    mailComposeController.mailComposeDelegate = self;
    [mailComposeController setToRecipients:@[ BMEFeedbackRecipientEmail ]];
    [mailComposeController setSubject:BMEFeedbackEmailSubject];
    [mailComposeController setMessageBody:initialBody isHTML:NO];
    [self presentViewController:mailComposeController animated:YES completion:nil];
}

- (void)validateEmail {
    if (![BMEEmailValidator isEmailValid:[self.emailTextField text]]) {
        self.emailTextField.text = [BMEClient sharedClient].currentUser.email;
    }
}

- (void)populateFields {
    BMEUser *user = [BMEClient sharedClient].currentUser;
    self.firstNameTextField.text = user.firstName;
    self.lastNameTextField.text = user.lastName;
    self.emailTextField.text = user.email;
}

- (void)saveIfSettingChanged {
    if (self.shouldSave) {
        [self save];
        self.shouldSave = NO;
    }
}

- (void)save {
    [[BMEClient sharedClient] updateCurrentUserWithFirstName:[self.firstNameTextField text] lastName:[self.lastNameTextField text] email:[self.emailTextField text] completion:^(BOOL success, NSError *error) {
        [self populateFields];
        
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:BMEDidUpdateProfileNotification object:nil];
        } else {
            NSLog(@"Could not save user information: %@", error);
        }
    }];
}

- (NSString *)versionString {
    NSString *majorVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return [NSString stringWithFormat:@"%@ (%@)", majorVersion, minorVersion];
}

#pragma mark -
#pragma mark Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self validateEmail];
    [self saveIfSettingChanged];
    
    return NO;
}

#pragma mark -
#pragma mark Mail Compose View Controller Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
