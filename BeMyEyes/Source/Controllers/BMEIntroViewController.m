//
//  BMEIntroViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 23/02/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEIntroViewController.h"

@implementation BMEIntroViewController

- (BOOL)accessibilityPerformEscape {
    [self.navigationController popViewControllerAnimated:NO];
    return YES;
}

@end
