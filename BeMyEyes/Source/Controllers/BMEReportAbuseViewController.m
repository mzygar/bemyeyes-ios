//
//  BMEReportAbuseViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 12/06/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEReportAbuseViewController.h"
#import <Appirater/Appirater.h>
#import <MRProgress/MRProgress.h>
#import <PSAlertView/PSPDFAlertView.h>
#import "UINavigationController+BMEPopToClass.h"
#import "BMEMainViewController.h"
#import "BMEClient.h"
#import "BMEUser.h"

@interface BMEReportAbuseViewController ()
@property (weak, nonatomic) IBOutlet UILabel *reason1Label;
@property (weak, nonatomic) IBOutlet UILabel *reason2Label;
@property (weak, nonatomic) IBOutlet UILabel *reason3Label;

@property (weak, nonatomic) IBOutlet UIImageView *reason1StateImageView;
@property (weak, nonatomic) IBOutlet UIImageView *reason2StateImageView;
@property (weak, nonatomic) IBOutlet UIImageView *reason3StateImageView;

@property (weak, nonatomic) IBOutlet UIButton *reason1Button;
@property (weak, nonatomic) IBOutlet UIButton *reason2Button;
@property (weak, nonatomic) IBOutlet UIButton *reason3Button;

@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@end

@implementation BMEReportAbuseViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[BMEClient sharedClient].currentUser isHelper]) {
        NSUInteger peopleHelped = [GVUserDefaults standardUserDefaults].peopleHelped;
        [GVUserDefaults standardUserDefaults].peopleHelped = peopleHelped + 1;
    }
    
    [self writeReasons];
}

- (void)dealloc {
    _requestIdentifier = nil;
}

#pragma mark -
#pragma mark Private Methods

- (IBAction)skipButtonPressed:(id)sender {
    if ([BMEAppStoreId length] > 0) {
        [Appirater userDidSignificantEvent:YES];
    }
    
    [self dismiss];
}

- (IBAction)reportButtonPressed:(id)sender {
    [self confirmReportAbuse];
}

- (IBAction)reason1ButtonPressed:(id)sender {
    [self selectReasonNumber:1];
}

- (IBAction)reason2ButtonPressed:(id)sender {
    [self selectReasonNumber:2];
}

- (IBAction)reason3ButtonPressed:(id)sender {
    [self selectReasonNumber:3];
}

- (void)confirmReportAbuse {
    NSString *title = NSLocalizedStringFromTable(@"ALERT_CONFIRM_REPORT_ABUSE_TITLE", @"BMEReportAbuseViewController", @"Title in alert view shown when asking the user to confirm that he wants to report abuse");
    NSString *message = NSLocalizedStringFromTable(@"ALERT_CONFIRM_REPORT_ABUSE_MESSAGE", @"BMEReportAbuseViewController", @"Message in alert view shown when asking the user to confirm that he wants to report abuse");
    NSString *confirm = NSLocalizedStringFromTable(@"ALERT_CONFIRM_REPORT_ABUSE_CONFIRM", @"BMEReportAbuseViewController", @"Title of confirm in alert view shown when asking the user to confirm that he wants to report abuse");
    NSString *cancel = NSLocalizedStringFromTable(@"ALERT_CONFIRM_REPORT_ABUSE_CANCEL", @"BMEReportAbuseViewController", @"Title of cancel button in alert view shown when asking the user to confirm that he wants to report abuse");
    
    PSPDFAlertView *alertView = [[PSPDFAlertView alloc] initWithTitle:title message:message];
    [alertView setCancelButtonWithTitle:cancel block:nil];
    [alertView addButtonWithTitle:confirm block:^{
        [self reportAbuse];
    }];
    [alertView show];
}

- (void)reportAbuse {
    MRProgressOverlayView *progressOverlayView = [MRProgressOverlayView showOverlayAddedTo:self.view.window animated:YES];
    progressOverlayView.mode = MRProgressOverlayViewModeIndeterminate;
    progressOverlayView.titleLabelText = NSLocalizedStringFromTable(@"OVERLAY_REPORTING_TITLE", @"BMEReportAbuseViewController", @"Title in overlay displayed when reporting abuse");
    
    [[BMEClient sharedClient] reportAbuseForRequestWithId:self.requestIdentifier reason:[self selectedReason] completion:^(BOOL success, NSError *error) {
        [progressOverlayView hide:YES];
        
        if (!error) {
            [self dismiss];
        } else {
            NSString *title = NSLocalizedStringFromTable(@"ALERT_REPORTING_FAILED_TITLE", @"BMEReportAbuseViewController", @"Title in alert view shown when reporting failed");
            NSString *message = NSLocalizedStringFromTable(@"ALERT_REPORTING_FAILED_MESSAGE", @"BMEReportAbuseViewController", @"Message in alert view shown when reporting failed");
            NSString *cancelButton = NSLocalizedStringFromTable(@"ALERT_REPORTING_FAILED_CANCEL", @"BMEReportAbuseViewController", @"Title of cancel button in alert view show when reporting failed");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:nil, nil];
            [alert show];
            
            NSLog(@"Could not report abuse for request with ID '%@': %@", self.requestIdentifier, error);
        }
    }];
}

- (void)writeReasons {
    NSString *reason1, *reason2, *reason3;
    
    BOOL isBlind = ([BMEClient sharedClient].currentUser.role == BMERoleBlind);
    if (isBlind) {
        reason1 = NSLocalizedStringFromTable(@"REPORT_TEXT_1_BLIND", @"BMEReportAbuseViewController", @"Text 1 for reporting abuse as a blind person.");
        reason2 = NSLocalizedStringFromTable(@"REPORT_TEXT_2_BLIND", @"BMEReportAbuseViewController", @"Text 2 for reporting abuse as a blind person.");
        reason3 = NSLocalizedStringFromTable(@"REPORT_TEXT_3_BLIND", @"BMEReportAbuseViewController", @"Text 3 for reporting abuse as a blind person.");
    } else {
        reason1 = NSLocalizedStringFromTable(@"REPORT_TEXT_1_HELPER", @"BMEReportAbuseViewController", @"Text 1 for reporting abuse as a helper.");
        reason2 = NSLocalizedStringFromTable(@"REPORT_TEXT_2_HELPER", @"BMEReportAbuseViewController", @"Text 2 for reporting abuse as a helper.");
        reason3 = NSLocalizedStringFromTable(@"REPORT_TEXT_3_HELPER", @"BMEReportAbuseViewController", @"Text 3 for reporting abuse as a helper.");
    }
    
    self.reason1Label.accessibilityElementsHidden = YES;
    self.reason2Label.accessibilityElementsHidden = YES;
    self.reason3Label.accessibilityElementsHidden = YES;
    
    self.reason1Label.text = reason1;
    self.reason2Label.text = reason2;
    self.reason3Label.text = reason3;
    
    if (isBlind) {
        [self writeAccessibilityLabels];
    }
}

- (void)writeAccessibilityLabels {
    NSString *label1, *label2, *label3;
    
    if ([self.reason1StateImageView isHighlighted]) {
        label1 = NSLocalizedStringFromTable(@"REPORT_ACCESSIBILITY_LABEL_1", @"BMEReportAbuseViewController", @"Accesibility label for reason 1 when the reason is not selected");
    } else {
        label1 = NSLocalizedStringFromTable(@"REPORT_ACCESSIBILITY_LABEL_1_SELECTED", @"BMEReportAbuseViewController", @"Accesibility label for reason 1 when the reason is selected");
    }
    
    if ([self.reason2StateImageView isHighlighted]) {
        label2 = NSLocalizedStringFromTable(@"REPORT_ACCESSIBILITY_LABEL_2", @"BMEReportAbuseViewController", @"Accesibility label for reason 2 when the reason is not selected");
    } else {
        label2 = NSLocalizedStringFromTable(@"REPORT_ACCESSIBILITY_LABEL_2_SELECTED", @"BMEReportAbuseViewController", @"Accesibility label for reason 2 when the reason is selected");
    }
    
    if ([self.reason3StateImageView isHighlighted]) {
        label3 = NSLocalizedStringFromTable(@"REPORT_ACCESSIBILITY_LABEL_3", @"BMEReportAbuseViewController", @"Accesibility label for reason 3 when the reason is not selected");
    } else {
        label3 = NSLocalizedStringFromTable(@"REPORT_ACCESSIBILITY_LABEL_3_SELECTED", @"BMEReportAbuseViewController", @"Accesibility label for reason 3 when the reason is selected");
    }
    
    self.reason1Button.accessibilityLabel = label1;
    self.reason2Button.accessibilityLabel = label2;
    self.reason3Button.accessibilityLabel = label3;
}

- (void)selectReasonNumber:(NSUInteger)number {
    self.reason1StateImageView.highlighted = (number == 1);
    self.reason2StateImageView.highlighted = (number == 2);
    self.reason3StateImageView.highlighted = (number == 3);
    
    if (![self.reportButton isEnabled]) {
        self.reportButton.enabled = YES;
        [self.reportButton setBackgroundColor:[UIColor colorWithRed:235.0f/255.0f green:96.0f/255.0f blue:51.0f/255.0f alpha:1.0f]];
    }
    
    [self writeAccessibilityLabels];
}   

- (NSString *)selectedReason {
    NSString *reason = nil;
    if ([self.reason1StateImageView isHighlighted]) {
        reason = self.reason1Label.text;
    } else if ([self.reason2StateImageView isHighlighted]) {
        reason = self.reason2Label.text;
    } else if ([self.reason3StateImageView isHighlighted]) {
        reason = self.reason3Label.text;
    }
    
    return reason;
}

- (void)dismiss {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController BMEPopToViewControllerOfClass:[BMEMainViewController class] animated:YES];
    }
}

@end
