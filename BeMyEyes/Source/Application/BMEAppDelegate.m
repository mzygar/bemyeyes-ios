//
//  BMEAppDelegate.m
//  BeMyEyes
//
//  Created by Simon Støvring on 22/02/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEAppDelegate.h"
#import "BMEClient.h"

#import <HPSocialNetworkManager/HPAccountManager.h>

@implementation BMEAppDelegate

#pragma mark -
#pragma mark Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self configureRESTClient];
    [self checkIfLoggedIn];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [[HPAccountManager sharedManager] handleOpenURL:url];
}

#pragma mark -
#pragma mark Private Methods

- (void)configureRESTClient {
    [[BMEClient sharedClient] setUsername:BMEAPIUsername password:BMEAPIPassword];
    [BMEClient sharedClient].facebookAppId = BMEFacebookAppId;
}

- (void)checkIfLoggedIn {
    if ([[BMEClient sharedClient] token] != nil && [[BMEClient sharedClient] isTokenValid]) {
        UIViewController *mainController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:BMEMainControllerIdentifier];
        [self replaceTopController:mainController];
        
        [[BMEClient sharedClient] loginUsingTokenWithCompletion:^(BOOL success, NSError *error) {
            if (!success || error) {
                self.window.rootViewController = [self.window.rootViewController.storyboard instantiateInitialViewController];
            }
        }];
    }
}

- (void)replaceTopController:(UIViewController *)topController {
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    navigationController.viewControllers = @[ topController ];
}

@end
