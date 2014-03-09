//
//  BMERightToLeft.m
//  BeMyEyes
//
//  Created by Simon Støvring on 09/03/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMERightToLeftSegue.h"

@implementation BMERightToLeftSegue

#pragma mark -
#pragma mark Segue

- (void)perform {
    UIViewController *sourceViewController = self.sourceViewController;
    UIViewController *destinationViewController = self.destinationViewController;

    CGRect destinationInitialFrame = destinationViewController.view.frame;
    destinationInitialFrame.origin.x = self.isUnwinding ? CGRectGetWidth(sourceViewController.view.frame) : -CGRectGetWidth(sourceViewController.view.frame);
    destinationViewController.view.frame = destinationInitialFrame;
    
    if (self.isUnwinding) {
        [sourceViewController.view.superview insertSubview:destinationViewController.view atIndex:0];
    } else {
        sourceViewController.view.clipsToBounds = NO;
        [sourceViewController.view addSubview:destinationViewController.view];
    }
    
    [UIView animateWithDuration:0.50f animations:^{
        CGRect sourceFinalFrame = sourceViewController.view.frame;
        sourceFinalFrame.origin.x = self.isUnwinding ? -CGRectGetWidth(sourceViewController.view.frame) : CGRectGetWidth(sourceViewController.view.frame);
        sourceViewController.view.frame = sourceFinalFrame;
        
        if (self.isUnwinding) {
            CGRect destinationFinalFrame = destinationInitialFrame;
            destinationFinalFrame.origin.x = 0.0f;
            destinationViewController.view.frame = destinationFinalFrame;
        }
    } completion:^(BOOL finished) {
        [destinationViewController.view removeFromSuperview];
        
        if (self.isUnwinding) {
            [sourceViewController dismissViewControllerAnimated:NO completion:nil];
        } else {
            [sourceViewController presentViewController:destinationViewController animated:NO completion:nil];
        }
    }];
}

@end
