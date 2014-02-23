//
//  BMEIntroViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 23/02/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEIntroViewController.h"
#import "BMESignUpMethodViewController.h"

#define BMEIntroSignUpMethodSegue @"SignUpMethod"

@implementation BMEIntroViewController

#pragma mark -
#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:BMEIntroSignUpMethodSegue]) {
        ((BMESignUpMethodViewController *)segue.destinationViewController).role = self.role;
    }
}

@end
