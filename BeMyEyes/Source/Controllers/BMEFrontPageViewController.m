//
//  BMEFrontPageViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 23/02/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEFrontPageViewController.h"
#import "BMEIntroViewController.h"
#import "BMEVideoViewController.h"

#define BMEFrontPageIntroHelperSegue @"IntroHelper"
#define BMEFrontPageIntroBlindSegue @"IntroBlind"

@interface BMEFrontPageViewController ()
@property (assign, nonatomic) BMERole role;
@end

@implementation BMEFrontPageViewController

#pragma mark -
#pragma mark Private Methods

- (IBAction)helperButtonPressed:(id)sender {
    if (![GVUserDefaults standardUserDefaults].introPresentedToHelper) {
        [self presentHelperIntroVideo];
        [GVUserDefaults standardUserDefaults].introPresentedToHelper = YES;
    } else {
        [self presentHelperIntro];
    }
}

- (void)presentHelperIntro {
    [self performSegueWithIdentifier:BMEFrontPageIntroHelperSegue sender:self];
}

- (void)presentHelperIntroVideo {
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"intro" ofType:@"mp4"];
    NSURL *videoUrl = [NSURL fileURLWithPath:videoPath];
    BMEVideoViewController *videoController = [[BMEVideoViewController alloc] initWithContentURL:videoUrl];
    [self presentViewController:videoController animated:YES completion:^{
        [self presentHelperIntro];
    }];
}

#pragma mark -
#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:BMEFrontPageIntroHelperSegue]) {
        ((BMEIntroViewController *)segue.destinationViewController).role = BMERoleHelper;
    } else if ([segue.identifier isEqualToString:BMEFrontPageIntroBlindSegue]) {
        ((BMEIntroViewController *)segue.destinationViewController).role = BMERoleBlind;
    }
}

@end
