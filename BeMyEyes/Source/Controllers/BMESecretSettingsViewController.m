//
//  BMESecretSettingsViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 18/04/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMESecretSettingsViewController.h"

enum {
    BMESettingsAPISegmentedControlDevelopment = 0,
    BMESettingsAPISegmentedControlStaging,
    BMESettingsAPISegmentedControlPublic
};

@interface BMESecretSettingsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *apiTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *apiDescriptionLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *apiSegmentedControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTopMarginConstraint;

@property (assign, nonatomic) UIStatusBarStyle statusBarStyleWhenPresented;
@end

@implementation BMESecretSettingsViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MKLocalization registerForLocalization:self];
    
    self.contentTopMarginConstraint.constant = 0.0f;
    
    self.apiSegmentedControl.selectedSegmentIndex = [GVUserDefaults standardUserDefaults].api;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.statusBarStyleWhenPresented = [UIApplication sharedApplication].statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:self.statusBarStyleWhenPresented animated:YES];
}

- (void)shouldLocalize {
    self.apiTitleLabel.text = MKLocalizedFromTable(BME_SECRET_SETTINGS_API_TITLE, BMESecretSettingsLocalizationTable);
    self.apiDescriptionLabel.text = MKLocalizedFromTable(BME_SECRET_SETTINGS_API_DESCRIPTION, BMESecretSettingsLocalizationTable);
    
    [self.apiSegmentedControl setTitle:MKLocalizedFromTable(BME_SECRET_SETTINGS_API_DEVELOPMENT, BMESecretSettingsLocalizationTable) forSegmentAtIndex:0];
    [self.apiSegmentedControl setTitle:MKLocalizedFromTable(BME_SECRET_SETTINGS_API_STAGING, BMESecretSettingsLocalizationTable) forSegmentAtIndex:1];
    [self.apiSegmentedControl setTitle:MKLocalizedFromTable(BME_SECRET_SETTINGS_API_PUBLIC, BMESecretSettingsLocalizationTable) forSegmentAtIndex:2];
}

#pragma mark -
#pragma mark Private Methods

- (IBAction)dismissButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)apiSegmentedControlValueChanged:(id)sender {
    [GVUserDefaults standardUserDefaults].api = self.apiSegmentedControl.selectedSegmentIndex;
}

@end
