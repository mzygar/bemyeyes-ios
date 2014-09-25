//
//  BMERegisteredViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 09/03/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMERegisteredViewController.h"

@interface BMERegisteredViewController ()
@property (weak, nonatomic) IBOutlet UILabel *headlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@end

@implementation BMERegisteredViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MKLocalization registerForLocalization:self];
}

- (void)shouldLocalize {
    self.headlineLabel.text = MKLocalizedFromTable(BME_REGISTERED_HEADLINE, BMERegisteredLocalizationTable);
    self.descriptionLabel.text = MKLocalizedFromTable(BME_REGISTERED_DESCRIPTION, BMERegisteredLocalizationTable);
    [self.loginButton setTitle:MKLocalizedFromTable(BME_REGISTERED_LOG_IN, BMERegisteredLocalizationTable) forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark Private Methods

- (IBAction)logInButtonPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
