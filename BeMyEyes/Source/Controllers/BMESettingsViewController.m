//
//  BMESettingsViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 09/03/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMESettingsViewController.h"
#import <MRProgress/MRProgress.h>
#import "BMEClient.h"

#define BMEUnwindSettingsSegue @"UnwindSettings"
#define BMESettingsSecretSettingsSegue @"SecretSettings"
#define BMESettingsTwoFingerDoubleTapInvalidateDelay 3.0f

@interface BMESettingsViewController ()
@property (strong, nonatomic) NSTimer *invalidateTwoFignerDoubleTapTimer;
@property (assign, nonatomic, getter = isTwoFingerDoubleTapTriggered) BOOL twoFingerDoubleTapTriggered;
@end

@implementation BMESettingsViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *twoFingerDoubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerDoubleTap:)];
    twoFingerDoubleTapGesture.numberOfTouchesRequired = 2;
    twoFingerDoubleTapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:twoFingerDoubleTapGesture];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)dealloc {
    [self.invalidateTwoFignerDoubleTapTimer invalidate];
    
    self.invalidateTwoFignerDoubleTapTimer = nil;
}

#pragma mark -
#pragma mark Private Methods

- (IBAction)popController:(UIStoryboardSegue *)segue { }

- (IBAction)logOutButtonPressed:(id)sender {
    MRProgressOverlayView *progressOverlayView = [MRProgressOverlayView showOverlayAddedTo:self.view.window animated:YES];
    progressOverlayView.mode = MRProgressOverlayViewModeIndeterminate;
    progressOverlayView.titleLabelText = NSLocalizedStringFromTable(@"OVERLAY_LOGGING_OUT_TITLE", @"BMESettingsViewController", @"Title in overlay shown when logging out");
    
    [[BMEClient sharedClient] logoutWithCompletion:^(BOOL success, NSError *error) {
        [progressOverlayView hide:YES];
        
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:BMEDidLogOutNotification object:nil];
            
            [self performSegueWithIdentifier:BMEUnwindSettingsSegue sender:self];
        } else {
            NSString *title = NSLocalizedStringFromTable(@"ALERT_LOG_OUT_FAILED_TITLE", @"BMESettingsViewController", @"Title in alert view shown when log out failed");
            NSString *message = NSLocalizedStringFromTable(@"ALERT_LOG_OUT_FAILED_MESSAGE", @"BMESettingsViewController", @"Messaage in alert view shown when log out failed");
            NSString *cancelTitle = NSLocalizedStringFromTable(@"ALERT_LOG_OUT_FAILED_CANCEL", @"BMESettingsViewController", @"Title of cancel button in alert view shown when log out failed");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelTitle otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
}

- (void)presentSecretSettings {
    [self performSegueWithIdentifier:BMESettingsSecretSettingsSegue sender:self];
}

- (void)handleTwoFingerDoubleTap:(UITapGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self presentSecretSettings];
//        [self becomeFirstResponder];
//        self.twoFingerDoubleTapTriggered = YES;
//        [self.invalidateTwoFignerDoubleTapTimer invalidate];
//        self.invalidateTwoFignerDoubleTapTimer = [NSTimer scheduledTimerWithTimeInterval:BMESettingsTwoFingerDoubleTapInvalidateDelay target:self selector:@selector(invalidateTwoFingerDoubleTapTimerTriggered:) userInfo:nil repeats:NO];
    }
}

- (void)invalidateTwoFingerDoubleTapTimerTriggered:(NSTimer *)timer {
    [self resignFirstResponder];
    self.invalidateTwoFignerDoubleTapTimer = nil;
    self.twoFingerDoubleTapTriggered = NO;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake && self.twoFingerDoubleTapTriggered) {
        [self resignFirstResponder];
        [self.invalidateTwoFignerDoubleTapTimer invalidate];
        self.invalidateTwoFignerDoubleTapTimer = nil;
        self.twoFingerDoubleTapTriggered = NO;
    }
}

@end
