//
//  BMEBaseViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 22/02/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEBaseViewController.h"

@implementation BMEBaseViewController

#pragma mark -
#pragma mark Lifecycle

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    BOOL isIpad = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
    return isIpad ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark -
#pragma mark Private Methods

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
