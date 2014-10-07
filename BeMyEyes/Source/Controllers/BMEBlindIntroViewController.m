//
//  BMEBlindIntroViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 28/08/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEBlindIntroViewController.h"
#import "BMESignUpMethodViewController.h"

static NSString *const BMEIntroSignUpMethodSegue = @"SignUpMethod";

@interface BMEBlindIntroViewController ()
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@end

@implementation BMEBlindIntroViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MKLocalization registerForLocalization:self];
}

- (void)shouldLocalize {
    [self.backButton setTitle:MKLocalizedFromTable(BME_BLIND_INTRO_BACK, BMEBlindIntroLocalizationTable) forState:UIControlStateNormal];
    [self.continueButton setTitle:MKLocalizedFromTable(BME_BLIND_INTRO_CONTINUE, BMEBlindIntroLocalizationTable) forState:UIControlStateNormal];

    self.descriptionLabel.text = MKLocalizedFromTable(BME_BLIND_INTRO_DESCRIPTION, BMEBlindIntroLocalizationTable);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:BMEIntroSignUpMethodSegue]) {
        ((BMESignUpMethodViewController *)segue.destinationViewController).role = BMERoleBlind;
    }
}

@end
