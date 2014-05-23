//
//  BMETermsViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 31/03/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMETermsViewController.h"

#define BMETermsUrl @"http://bemyeyes.org/terms"

@implementation BMETermsViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadURL:[NSURL URLWithString:BMETermsUrl]];
}

@end
