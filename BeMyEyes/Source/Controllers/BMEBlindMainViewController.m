//
//  BMEBlindMainViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 15/03/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEBlindMainViewController.h"
#import "BMEAppDelegate.h"
#import "BMECallViewController.h"

#define BMEBlindMainCallSegue @"Call"

@interface BMEBlindMainViewController ()
@property (weak, nonatomic) IBOutlet UIButton *connectToCommunityButton;
@end

@implementation BMEBlindMainViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MKLocalization registerForLocalization:self];
    
    self.connectToCommunityButton.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)shouldLocalize {
    [self.connectToCommunityButton setTitle:MKLocalizedFromTable(BME_BLIND_MAIN_CONNECT_TO_COMMUNITY, BMEBlindMainLocalizationTable) forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark Private Methods

- (IBAction)connectToCommunityButtonPressed:(id)sender {
    [self performSegueWithIdentifier:BMEBlindMainCallSegue sender:self];
}

#pragma mark -
#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:BMEBlindMainCallSegue]) {
        BMECallViewController *callController = (BMECallViewController *)segue.destinationViewController;
        callController.callMode = BMECallModeCreate;
    }
}

@end
