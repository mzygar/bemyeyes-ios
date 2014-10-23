//
//  BMEAccessViewController.m
//  BeMyEyes
//
//  Created by Tobias DM on 08/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEAccessViewController.h"
#import "BMEAccessView.h"
#import "UIView+Layout.h"
#import "BeMyEyes-Swift.h"
#import "BMEAccessControlHandler.h"

@interface BMEAccessViewController ()

@property (strong, nonatomic) GradientView *gradientView;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) BMEAccessView *accessNotificationsView;
@property (strong, nonatomic) BMEAccessView *accessMicrophoneView;
@property (strong, nonatomic) BMEAccessView *accessCameraView;

@end

@implementation BMEAccessViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.gradientView];
    [self.gradientView keepInsets:UIEdgeInsetsZero];
    
    NSArray *accessViews;
    switch (self.role) {
        case BMERoleHelper:
            accessViews = @[self.accessNotificationsView, self.accessMicrophoneView, self.accessCameraView];
            break;
        case BMERoleBlind:
            accessViews = @[self.accessMicrophoneView, self.accessCameraView];
            break;
    }
    
    NSArray *views = [@[self.messageLabel] arrayByAddingObjectsFromArray:accessViews];
    [views horizontallySpaceInView:self.view];
    accessViews.keepHorizontalInsets.equal = 0;
    self.messageLabel.keepHorizontalInsets.equal = 15;
    
    [self checkAccess];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAppBecameActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)handleAppBecameActive
{
    [self checkAccess];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - 

- (void)checkAccess
{
    [BMEAccessControlHandler enabledForRole:self.role completion:^(BOOL isEnabled) {
        if (isEnabled) {
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        
        if (_accessNotificationsView) {
            [BMEAccessControlHandler hasNotificationsEnabled:^(BOOL isEnabled) {
                _accessNotificationsView.selected = isEnabled;
            }];
        }
        if (_accessMicrophoneView) {
            [BMEAccessControlHandler hasMicrophoneEnabled:^(BOOL isEnabled) {
                _accessMicrophoneView.selected = isEnabled;
            }];
        }
        if (_accessCameraView) {
            [BMEAccessControlHandler hasVideoEnabled:^(BOOL isEnabled) {
                self.accessCameraView.selected = isEnabled;
            }];
        }
    }];
}


#pragma mark - Setters and Getters

- (GradientView *)gradientView
{
    if (!_gradientView) {
        _gradientView = [GradientView new];
    }
    return _gradientView;
}

- (UILabel *)messageLabel
{
    if (!_messageLabel) {
        _messageLabel = [UILabel new];
        _messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 0;
        _messageLabel.text = MKLocalizedFromTable(BME_ACCESS_INTRO_MESSAGE, BMEAccessLocalization);
        _messageLabel.textColor = [UIColor whiteColor];
    }
    return _messageLabel;
}

- (BMEAccessView *)accessNotificationsView
{
    if (!_accessNotificationsView) {
        _accessNotificationsView = [BMEAccessView new];
        _accessNotificationsView.titleLabel.text = MKLocalizedFromTable(BME_ACCESS_NOTIFICATIONS_TITLE, BMEAccessLocalization);
        _accessNotificationsView.messageLabel.text = MKLocalizedFromTable(BME_ACCESS_NOTIFICATIONS_EXPLANATION_HELPER, BMEAccessLocalization);
        [_accessNotificationsView addTarget:self action:@selector(touchUpInsideNotificationsView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _accessNotificationsView;
}

- (BMEAccessView *)accessMicrophoneView
{
    if (!_accessMicrophoneView) {
        _accessMicrophoneView = [BMEAccessView new];
        _accessMicrophoneView.titleLabel.text = MKLocalizedFromTable(BME_ACCESS_MICROPHONE_TITLE, BMEAccessLocalization);
        NSString *messageLocalizableKey;
        switch (self.role) {
            case BMERoleHelper:
                messageLocalizableKey = BME_ACCESS_MICROPHONE_EXPLANATION_HELPER;
                break;
            case BMERoleBlind:
                messageLocalizableKey = BME_ACCESS_MICROPHONE_EXPLANATION_BLIND;
                break;
        }
        _accessMicrophoneView.messageLabel.text = MKLocalizedFromTable(messageLocalizableKey, BMEAccessLocalization);
        [_accessMicrophoneView addTarget:self action:@selector(touchUpInsideMicrophoneView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _accessMicrophoneView;
}

- (BMEAccessView *)accessCameraView
{
    if (!_accessCameraView) {
        _accessCameraView = [BMEAccessView new];
        _accessCameraView.titleLabel.text = MKLocalizedFromTable(BME_ACCESS_CAMERA_TITLE, BMEAccessLocalization);
        NSString *messageLocalizableKey;
        switch (self.role) {
            case BMERoleHelper:
                messageLocalizableKey = BME_ACCESS_CAMERA_EXPLANATION_HELPER;
                break;
            case BMERoleBlind:
                messageLocalizableKey = BME_ACCESS_CAMERA_EXPLANATION_BLIND;
                break;
        }
        _accessCameraView.messageLabel.text = MKLocalizedFromTable(messageLocalizableKey, BMEAccessLocalization);
        [_accessCameraView addTarget:self action:@selector(touchUpInsideCameraView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _accessCameraView;
}


#pragma mark - 

- (UIView *)newSpacerBetweenView:(UIView *)v1 :(UIView *)v2
{
    UIView *spacer = [self newSpacer];
    spacer.keepTopOffsetTo(v1).equal =
    spacer.keepBottomOffsetTo(v2).equal = 0;
    return spacer;
}

- (UIView *)newSpacer
{
    UIView *spacer = [UIView new];
    spacer.backgroundColor = [UIColor greenColor];
    spacer.keepWidth.equal = 5;
    [self.view addSubview:spacer];
    return spacer;
}


#pragma mark - 

- (void)touchUpInsideNotificationsView
{
    if (self.accessNotificationsView.selected) {
        return;
    }
    [BMEAccessControlHandler requireNotificationsEnabled:^(BOOL isEnabled) {
        self.accessNotificationsView.selected = isEnabled;
    }];
}

- (void)touchUpInsideMicrophoneView
{
    if (self.accessMicrophoneView.selected) {
        return;
    }
    [BMEAccessControlHandler requireMicrophoneEnabled:^(BOOL isEnabled) {
        self.accessMicrophoneView.selected = isEnabled;
    }];
}

- (void)touchUpInsideCameraView
{
    if (self.accessCameraView.selected) {
        return;
    }
    [BMEAccessControlHandler requireCameraEnabled:^(BOOL isEnabled) {
        self.accessCameraView.selected = isEnabled;
    }];
}


@end
