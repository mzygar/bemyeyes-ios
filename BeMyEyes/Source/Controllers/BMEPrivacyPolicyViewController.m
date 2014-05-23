//
//  BMEPrivacyPolicyViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 23/05/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEPrivacyPolicyViewController.h"

#define BMEPrivacyPolicyUrl @"http://bemyeyes.org/privacy"

@implementation BMEPrivacyPolicyViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadURL:[NSURL URLWithString:BMEPrivacyPolicyUrl]];
}

@end
