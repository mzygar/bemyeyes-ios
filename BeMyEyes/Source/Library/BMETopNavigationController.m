//
//  BMETopNavigationController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 09/03/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMETopNavigationController.h"
#import "BMERightToLeftSegue.h"

@implementation BMETopNavigationController

#pragma mark -
#pragma mark Lifecycle

- (BOOL)shouldAutorotate {
    return [[self activeViewController] shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations {
    return [[self activeViewController] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [[self activeViewController] preferredInterfaceOrientationForPresentation];;
}

#pragma mark -
#pragma mark Private Methods

- (UIViewController *)activeViewController {
    if (self.presentedViewController) {
        return self.presentedViewController;
    }
    
    return self.topViewController;
}

@end
