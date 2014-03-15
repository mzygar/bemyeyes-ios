//
//  BMEBlindMainViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 15/03/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEBlindMainViewController.h"
#import <MRProgress/MRProgressOverlayView.h>
#import "BMEClient.h"

@interface BMEBlindMainViewController ()
@property (weak, nonatomic) IBOutlet UIButton *connectToCommunityButton;
@end

@implementation BMEBlindMainViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.connectToCommunityButton.titleLabel.textAlignment = NSTextAlignmentCenter;
}

#pragma mark -
#pragma mark Private Methods

- (IBAction)connectToCommunityButtonPressed:(id)sender {
    [self requireMicrophoneEnabled:^(BOOL isEnabled) {
        if (isEnabled) {
            [self createRequest];
        }
    }];
}

- (void)createRequest {
    MRProgressOverlayView *progressOverlayView = [MRProgressOverlayView showOverlayAddedTo:self.view.window animated:YES];
    progressOverlayView.mode = MRProgressOverlayViewModeIndeterminate;
    progressOverlayView.titleLabelText = NSLocalizedStringFromTable(@"HUD_CREATING_REQUEST_TITLE", @"BMEBlindMainViewController", @"Title in hud shown when creating request");
    
    [[BMEClient sharedClient] createRequestWithSuccess:^(BMERequest *request) {
        [progressOverlayView hide:YES];
    } failure:^(NSError *error) {
        [progressOverlayView hide:YES];
        
        NSString *title = NSLocalizedStringFromTable(@"ALERT_FAILED_CREATING_REQUEST_TITLE", @"BMEBlindMainViewController", @"Title in alert showed when failed creating request");
        NSString *message = NSLocalizedStringFromTable(@"ALERT_FAILED_CREATING_REQUEST_MESSAGE", @"BMEBlindMainViewController", @"Message in alert showed when failed creating request");
        NSString *cancel = NSLocalizedStringFromTable(@"ALERT_FAILED_CREATING_REQUEST_CANCEL", @"BMEBlindMainViewController", @"Cancel in alert showed when failed creating request");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancel otherButtonTitles:nil, nil];
        [alertView show];
        
        NSLog(@"Request could not be created: %@", error);
    }];
}

@end
