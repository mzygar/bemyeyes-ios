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
@property (weak, nonatomic) IBOutlet UISegmentedControl *apiSegmentedControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTopMarginConstraint;

@property (assign, nonatomic) UIStatusBarStyle statusBarStyleWhenPresented;
@end

@implementation BMESecretSettingsViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

#pragma mark -
#pragma mark Private Methods

- (IBAction)dismissButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)apiSegmentedControlValueChanged:(id)sender {
    [GVUserDefaults standardUserDefaults].api = self.apiSegmentedControl.selectedSegmentIndex;
}

@end
