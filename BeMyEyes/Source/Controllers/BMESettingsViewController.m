//
//  BMESettingsViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 09/03/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMESettingsViewController.h"

@implementation BMESettingsViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

@end
