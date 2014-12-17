//
//  BMEPrivacyPolicyViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 23/05/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEPrivacyPolicyViewController.h"

#define BMEPrivacyPolicyUrl @"http://bemyeyes.org/privacy"

@interface BMEPrivacyPolicyViewController ()
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@end

@implementation BMEPrivacyPolicyViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MKLocalization registerForLocalization:self];
    
    [self loadURL:[NSURL URLWithString:BMEPrivacyPolicyUrl]];
}

- (void)shouldLocalize {
    [self.backButton setTitle:MKLocalizedFromTable(BME_PRIVACY_POLICY_BACK, BMEPrivacyPolicyLocalizationTable) forState:UIControlStateNormal];
}

- (BOOL)accessibilityPerformEscape {
    [self.navigationController popViewControllerAnimated:NO];
    return YES;
}

@end
