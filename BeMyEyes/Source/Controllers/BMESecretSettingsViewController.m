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
    BMESettingsAPISegmentedControlInternal,
    BMESettingsAPISegmentedControlPublic
};

@interface BMESecretSettingsViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *apiSegmentedControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTopMarginConstraint;
@end

@implementation BMESecretSettingsViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.contentTopMarginConstraint.constant = 0.0f;
    
    self.apiSegmentedControl.selectedSegmentIndex = [GVUserDefaults standardUserDefaults].api;
}

#pragma mark -
#pragma mark Private Methods

- (IBAction)apiSegmentedControlValueChanged:(id)sender {
    [GVUserDefaults standardUserDefaults].api = self.apiSegmentedControl.selectedSegmentIndex;
}

@end
