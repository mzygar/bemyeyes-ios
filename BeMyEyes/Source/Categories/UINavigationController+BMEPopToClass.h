//
//  UINavigationController+BMEPopToClas.h
//  BeMyEyes
//
//  Created by Simon Støvring on 22/08/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (BMEPopToClas)

- (BOOL)BMEPopToViewControllerOfClass:(Class)controllerClass animated:(BOOL)animated;

@end
