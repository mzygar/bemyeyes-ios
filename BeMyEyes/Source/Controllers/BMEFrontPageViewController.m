//
//  BMEFrontPageViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 23/02/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEFrontPageViewController.h"
#import "BMEIntroViewController.h"

#define BMEFrontPageIntroSegue @"Intro"

@interface BMEFrontPageViewController ()
@property (assign, nonatomic) BMERole role;
@end

@implementation BMEFrontPageViewController

#pragma mark -
#pragma mark Private Methods

- (IBAction)helperButtonPressed:(id)sender {
    self.role = BMERoleHelper;
}

- (IBAction)blindButtonPressed:(id)sender {
    self.role = BMERoleBlind;
}

#pragma mark -
#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:BMEFrontPageIntroSegue]) {
        ((BMEIntroViewController *)segue.destinationViewController).role = self.role;
    }
}

@end
