//
//  DismissSegue.m
//  
//
//  Created by Tobias DM on 11/10/14.
//
//

#import "DismissSegue.h"

@implementation DismissSegue

- (void)perform {
    UIViewController *sourceViewController = self.sourceViewController;
    [sourceViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
