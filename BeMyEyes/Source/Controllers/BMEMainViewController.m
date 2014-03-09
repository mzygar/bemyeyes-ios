//
//  BMEMainViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 09/03/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEMainViewController.h"

@interface BMEMainViewController ()
@property (assign, nonatomic, getter = isLoggedOut) BOOL loggedOut;
@end

@implementation BMEMainViewController

#pragma mark -
#pragma mark Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogOut:) name:BMEDidLogOutNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    if (self.isLoggedOut) {
        self.view.window.rootViewController = [self.view.window.rootViewController.storyboard instantiateInitialViewController];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Private Methods

- (IBAction)popController:(UIStoryboardSegue *)segue { }

#pragma mark -
#pragma mark Notifications

- (void)didLogOut:(NSNotification *)notification {
    self.loggedOut = YES;
}

@end
