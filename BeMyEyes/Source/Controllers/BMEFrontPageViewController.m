//
//  BMEFrontPageViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 23/02/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEFrontPageViewController.h"

@interface BMEFrontPageViewController ()
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *appNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *askForRoleLabel;
@property (weak, nonatomic) IBOutlet UIButton *sightedRoleButton;
@property (weak, nonatomic) IBOutlet UIButton *blindRoleButton;
@property (weak, nonatomic) IBOutlet UIButton *alreadyRegisteredButton;

@property (assign, nonatomic) BMERole role;
@end

@implementation BMEFrontPageViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MKLocalization registerForLocalization:self];
}

- (void)shouldLocalize {
    self.welcomeLabel.text = MKLocalizedFromTable(BME_FRONT_PAGE_WELCOME_TO, BMEFrontPageLocalizationTable);
    self.appNameLabel.text = MKLocalizedFromTable(BME_FRONT_PAGE_APP_NAME, BMEFrontPageLocalizationTable);
    self.askForRoleLabel.text = MKLocalizedFromTable(BME_FRONT_PAGE_ASK_FOR_ROLE, BMEFrontPageLocalizationTable);
    
    [self.sightedRoleButton setTitle:MKLocalizedFromTable(BME_FRONT_PAGE_SIGHTED_ROLE, BMEFrontPageLocalizationTable) forState:UIControlStateNormal];
    [self.blindRoleButton setTitle:MKLocalizedFromTable(BME_FRONT_PAGE_BLIND_ROLE, BMEFrontPageLocalizationTable) forState:UIControlStateNormal];
    [self.alreadyRegisteredButton setTitle:MKLocalizedFromTable(BME_FRONT_PAGE_ALREADY_REGISTERED, BMEFrontPageLocalizationTable) forState:UIControlStateNormal];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

@end
