//
//  BMETermsViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 31/03/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMETermsViewController.h"

#define BMETermsUrl @"http://bemyeyes.org/terms"

@interface BMETermsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@end

@implementation BMETermsViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MKLocalization registerForLocalization:self];
    
    [self loadURL:[NSURL URLWithString:BMETermsUrl]];
}

- (void)shouldLocalize {
    [self.backButton setTitle:MKLocalizedFromTable(BME_TERMS_BACK, BMETermsLocalizationTable) forState:UIControlStateNormal];
}

- (BOOL)accessibilityPerformEscape {
    [self.navigationController popViewControllerAnimated:NO];
    return YES;
}

@end
