//
//  BMETopNavigationController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 09/03/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMETopNavigationController.h"
#import "BMERightToLeftSegue.h"

#define BMEUnwindSettingsSegue @"UnwindSettings"

@implementation BMETopNavigationController

#pragma mark -
#pragma mark Segue

- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier {
    if ([identifier isEqualToString:BMEUnwindSettingsSegue]) {
        BMERightToLeftSegue *segue = [[BMERightToLeftSegue alloc] initWithIdentifier:identifier source:fromViewController destination:toViewController];
        segue.unwinding = YES;
        return segue;
    }
    
    return [super segueForUnwindingToViewController:toViewController fromViewController:fromViewController identifier:identifier];
}

@end
