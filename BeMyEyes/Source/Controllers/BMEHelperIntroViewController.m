//
//  BMEHelperIntroViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 28/08/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEHelperIntroViewController.h"
#import "BMESignUpMethodViewController.h"

static NSString *const BMEIntroSignUpMethodSegue = @"SignUpMethod";

@interface BMEHelperIntroViewController ()
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UILabel *headlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *shortDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *longDescriptionLabel;
@end

@implementation BMEHelperIntroViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MKLocalization registerForLocalization:self];
}

- (void)shouldLocalize {
    [self.backButton setTitle:MKLocalizedFromTable(BME_HELPER_INTRO_BACK, BMEHelperIntroLocalizationTable) forState:UIControlStateNormal];
    [self.continueButton setTitle:MKLocalizedFromTable(BME_HELPER_INTRO_CONTINUE, BMEHelperIntroLocalizationTable) forState:UIControlStateNormal];
    
    self.headlineLabel.text = MKLocalizedFromTable(BME_HELPER_INTRO_HEADLINE, BMEHelperIntroLocalizationTable);
    self.shortDescriptionLabel.text = MKLocalizedFromTable(BME_HELPER_INTRO_SHORT_DESCRIPTION, BMEHelperIntroLocalizationTable);
    self.longDescriptionLabel.text = MKLocalizedFromTable(BME_HELPER_INTRO_LONG_DESCRIPTION, BMEHelperIntroLocalizationTable);
}

#pragma mark -
#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:BMEIntroSignUpMethodSegue]) {
        ((BMESignUpMethodViewController *)segue.destinationViewController).role = BMERoleHelper;
    }
}

@end
