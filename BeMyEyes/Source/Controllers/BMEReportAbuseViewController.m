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
@property (weak, nonatomic) IBOutlet UILabel *headlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *chooseReasonLabel;

@property (weak, nonatomic) IBOutlet UILabel *reason1Label;
@property (weak, nonatomic) IBOutlet UILabel *reason2Label;
@property (weak, nonatomic) IBOutlet UILabel *reason3Label;

@property (weak, nonatomic) IBOutlet RadioButton *reason1StateRadioButton;
@property (weak, nonatomic) IBOutlet RadioButton *reason2StateRadioButton;
@property (weak, nonatomic) IBOutlet RadioButton *reason3StateRadioButton;

@property (weak, nonatomic) IBOutlet UIButton *reason1Button;
@property (weak, nonatomic) IBOutlet UIButton *reason2Button;
@property (weak, nonatomic) IBOutlet UIButton *reason3Button;

@property (weak, nonatomic) IBOutlet Button *reportButton;
@property (weak, nonatomic) IBOutlet Button *skipButton;
@end

@implementation BMEReportAbuseViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MKLocalization registerForLocalization:self];
    
    if ([[BMEClient sharedClient].currentUser isHelper]) {
        NSUInteger peopleHelped = [GVUserDefaults standardUserDefaults].peopleHelped;
        [GVUserDefaults standardUserDefaults].peopleHelped = peopleHelped + 1;
    }
}

- (void)dealloc {
    _requestIdentifier = nil;
}

- (void)shouldLocalize {
    self.headlineLabel.text = MKLocalizedFromTable(BME_REPORT_ABUSE_HEADLINE, BMEReportAbuseLocalizationTable);
    self.chooseReasonLabel.text = MKLocalizedFromTable(BME_REPORT_ABUSE_CHOOSE_REASON, BMEReportAbuseLocalizationTable);
    
    self.reportButton.title = MKLocalizedFromTable(BME_REPORT_ABUSE_REPORT, BMEReportAbuseLocalizationTable);
    self.skipButton.title = MKLocalizedFromTable(BME_REPORT_ABUSE_SKIP, BMEReportAbuseLocalizationTable);
    
    [self writeReasons];
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
    NSString *title = MKLocalizedFromTable(BME_REPORT_ABUSE_ALERT_CONFIRM_REPORT_ABUSE_TITLE, BMEReportAbuseLocalizationTable);
    NSString *message = MKLocalizedFromTable(BME_REPORT_ABUSE_ALERT_CONFIRM_REPORT_ABUSE_MESSAGE, BMEReportAbuseLocalizationTable);
    NSString *confirm = MKLocalizedFromTable(BME_REPORT_ABUSE_ALERT_CONFIRM_REPORT_ABUSE_CONFIRM, BMEReportAbuseLocalizationTable);
    NSString *cancel = MKLocalizedFromTable(BME_REPORT_ABUSE_ALERT_CONFIRM_REPORT_ABUSE_CANCEL, BMEReportAbuseLocalizationTable);
    
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
    progressOverlayView.titleLabelText = MKLocalizedFromTable(BME_REPORT_ABUSE_OVERLAY_REPORTING_TITLE, BMEReportAbuseLocalizationTable);
    
    [[BMEClient sharedClient] reportAbuseForRequestWithId:self.requestIdentifier reason:[self selectedReason] completion:^(BOOL success, NSError *error) {
        [progressOverlayView hide:YES];
        
        if (!error) {
            [self dismiss];
        } else {
            NSString *title = MKLocalizedFromTable(BME_REPORT_ABUSE_ALERT_REPORTING_FAILED_TITLE, BMEReportAbuseLocalizationTable);
            NSString *message = MKLocalizedFromTable(BME_REPORT_ABUSE_ALERT_REPORTING_FAILED_MESSAGE, BMEReportAbuseLocalizationTable);
            NSString *cancelButton = MKLocalizedFromTable(BME_REPORT_ABUSE_ALERT_REPORTING_FAILED_CANCEL, BMEReportAbuseLocalizationTable);
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
        reason1 = MKLocalizedFromTable(BME_REPORT_ABUSE_REPORT_TEXT_1_BLIND, BMEReportAbuseLocalizationTable);
        reason2 = MKLocalizedFromTable(BME_REPORT_ABUSE_REPORT_TEXT_2_BLIND, BMEReportAbuseLocalizationTable);
        reason3 = MKLocalizedFromTable(BME_REPORT_ABUSE_REPORT_TEXT_3_BLIND, BMEReportAbuseLocalizationTable);
    } else {
        reason1 = MKLocalizedFromTable(BME_REPORT_ABUSE_REPORT_TEXT_1_HELPER, BMEReportAbuseLocalizationTable);
        reason2 = MKLocalizedFromTable(BME_REPORT_ABUSE_REPORT_TEXT_2_HELPER, BMEReportAbuseLocalizationTable);
        reason3 = MKLocalizedFromTable(BME_REPORT_ABUSE_REPORT_TEXT_3_HELPER, BMEReportAbuseLocalizationTable);
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
    
    if (self.reason1StateRadioButton.selected) {
        label1 = MKLocalizedFromTable(BME_REPORT_ABUSE_ACCESSIBILITY_LABEL_1_SELECTED, BMEReportAbuseLocalizationTable);
    } else {
        label1 = MKLocalizedFromTable(BME_REPORT_ABUSE_ACCESSIBILITY_LABEL_1, BMEReportAbuseLocalizationTable);
    }
    
    if (self.reason2StateRadioButton.selected) {
        label2 = MKLocalizedFromTable(BME_REPORT_ABUSE_ACCESSIBILITY_LABEL_2_SELECTED, BMEReportAbuseLocalizationTable);
    } else {
        label2 = MKLocalizedFromTable(BME_REPORT_ABUSE_ACCESSIBILITY_LABEL_2, BMEReportAbuseLocalizationTable);
    }
    
    if (self.reason3StateRadioButton.selected) {
        label3 = MKLocalizedFromTable(BME_REPORT_ABUSE_ACCESSIBILITY_LABEL_3_SELECTED, BMEReportAbuseLocalizationTable);
    } else {
        label3 = MKLocalizedFromTable(BME_REPORT_ABUSE_ACCESSIBILITY_LABEL_3, BMEReportAbuseLocalizationTable);
    }
    
    self.reason1Button.accessibilityLabel = label1;
    self.reason2Button.accessibilityLabel = label2;
    self.reason3Button.accessibilityLabel = label3;
}

- (void)selectReasonNumber:(NSUInteger)number {
    self.reason1StateRadioButton.selected = (number == 1);
    self.reason2StateRadioButton.selected = (number == 2);
    self.reason3StateRadioButton.selected = (number == 3);
    
    if (![self.reportButton isEnabled]) {
        self.reportButton.enabled = YES;
        [self.reportButton setBackgroundColor:[UIColor colorWithRed:235.0f/255.0f green:96.0f/255.0f blue:51.0f/255.0f alpha:1.0f]];
    }
    
    [self writeAccessibilityLabels];
}   

- (NSString *)selectedReason {
    NSString *reason = nil;
    if (self.reason1StateRadioButton.selected) {
        reason = self.reason1Label.text;
    } else if (self.reason2StateRadioButton.selected) {
        reason = self.reason2Label.text;
    } else if (self.reason3StateRadioButton.selected) {
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
