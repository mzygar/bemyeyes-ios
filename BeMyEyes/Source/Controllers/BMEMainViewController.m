//
//  BMEMainViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 09/03/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEMainViewController.h"

@implementation BMEMainViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

#pragma mark -
#pragma mark Private Methods

- (IBAction)popController:(UIStoryboardSegue *)segue { }

@end
