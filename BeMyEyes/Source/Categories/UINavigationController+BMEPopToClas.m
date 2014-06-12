//
//  UINavigationController+BMEPopToClas.m
//  BeMyEyes
//
//  Created by Simon Støvring on 22/08/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import "UINavigationController+BMEPopToClass.h"

@implementation UINavigationController (BMEPopToClas)

#pragma mark -
#pragma mark Public Methods

- (BOOL)BMEPopToViewControllerOfClass:(Class)controllerClass animated:(BOOL)animated {
    UIViewController *controller = nil;
    NSArray *controllers = [self viewControllers];
    for (UIViewController *currentController in controllers) {
        if ([currentController isKindOfClass:controllerClass]) {
            controller = currentController;
            break;
        }
    }
    
    if (controller) {
        [self popToViewController:controller animated:animated];
        return YES;
    }
    
    return NO;
}

@end
