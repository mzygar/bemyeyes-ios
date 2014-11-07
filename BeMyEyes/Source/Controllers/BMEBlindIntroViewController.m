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
@property (weak, nonatomic) IBOutlet UITextView *descriptionView;
@end

@implementation BMEBlindIntroViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.descriptionView.textContainer.lineFragmentPadding = 0;

    CGFloat top = CGRectGetMaxY(self.backButton.frame);
    CGFloat bottom = self.continueButton.frame.size.height;
    self.descriptionView.textContainerInset = UIEdgeInsetsMake(top, 15, bottom, 15);
    self.descriptionView.scrollIndicatorInsets = UIEdgeInsetsMake(top, 0, bottom, 0);
    
    [MKLocalization registerForLocalization:self];
}

- (void)shouldLocalize {
    [self.backButton setTitle:MKLocalizedFromTable(BME_BLIND_INTRO_BACK, BMEBlindIntroLocalizationTable) forState:UIControlStateNormal];
    [self.continueButton setTitle:MKLocalizedFromTable(BME_BLIND_INTRO_CONTINUE, BMEBlindIntroLocalizationTable) forState:UIControlStateNormal];

    self.descriptionView.text = MKLocalizedFromTable(BME_BLIND_INTRO_DESCRIPTION, BMEBlindIntroLocalizationTable);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:BMEIntroSignUpMethodSegue]) {
        ((BMESignUpMethodViewController *)segue.destinationViewController).role = BMERoleBlind;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.descriptionView flashScrollIndicators];
}

@end
