//
//  BMESignUpMethodViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 22/02/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMESignUpMethodViewController.h"
#import "BMEClient.h"

@interface BMESignUpMethodViewController ()
@property (weak, nonatomic) IBOutlet UILabel *signUpTopLabel;
@property (weak, nonatomic) IBOutlet UILabel *signUpBottomLabel;
@property (weak, nonatomic) IBOutlet UILabel *termsTopLabel;
@property (weak, nonatomic) IBOutlet UILabel *termsBottomLabel;
@end

@implementation BMESignUpMethodViewController

#pragma mark -
#pragma mark Private Methods

- (IBAction)facebookButtonPressed:(id)sender {

}

- (IBAction)signUpButtonTouched:(id)sender {
    self.signUpTopLabel.alpha = 0.50f;
    self.signUpBottomLabel.alpha = 0.50f;
}

- (IBAction)signUpButtonReleased:(id)sender {
    self.signUpTopLabel.alpha = 1.0f;
    self.signUpBottomLabel.alpha = 1.0f;
}

- (IBAction)termsButtonTouched:(id)sender {
    self.termsTopLabel.alpha = 0.50f;
    self.termsBottomLabel.alpha = 0.50f;
}

- (IBAction)termsButtonReleased:(id)sender {
    self.termsTopLabel.alpha = 1.0f;
    self.termsBottomLabel.alpha = 1.0f;
}

@end
