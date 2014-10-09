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
@property (strong, nonatomic) BMEAccessView *accessVideoView;

@end

@implementation BMEAccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.gradientView];
    [self.gradientView keepInsets:UIEdgeInsetsZero];
    
    NSArray *views = @[self.messageLabel, self.accessNotificationsView, self.accessMicrophoneView, self.accessVideoView];
    [views horizontallySpaceInView:self.view];
    views.keepHorizontalMarginInsets.equal = 0;
    [views keepHeightsEqual];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
        _messageLabel.text = @"aælksdfjasælfdkj sdæflkj asæflkja sfdælkj asdlæfjk aslfdkj as";
        _messageLabel.textColor = [UIColor whiteColor];
    }
    return _messageLabel;
}

- (BMEAccessView *)accessNotificationsView
{
    if (!_accessNotificationsView) {
        _accessNotificationsView = [BMEAccessView new];
        _accessNotificationsView.titleLabel.text = @"Notifications";
        _accessNotificationsView.messageLabel.text = @"læksdfj læasdf æafsdjkl afsdjkl af jkfjkl fasjkl sdfakj lfæ asælfk js";
        [_accessNotificationsView addTarget:self action:@selector(touchUpInsideNotificationsView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _accessNotificationsView;
}

- (BMEAccessView *)accessMicrophoneView
{
    if (!_accessMicrophoneView) {
        _accessMicrophoneView = [BMEAccessView new];
        _accessMicrophoneView.titleLabel.text = @"Notifications";
        _accessMicrophoneView.messageLabel.text = @"læksdfj læasdf æafsdjkl";
        [BMEAccessControlHandler hasMicrophoneEnabled:^(BOOL isEnabled) {
            _accessMicrophoneView.selected = isEnabled;
        }];
        [_accessMicrophoneView addTarget:self action:@selector(touchUpInsideMicrophoneView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _accessMicrophoneView;
}

- (BMEAccessView *)accessVideoView
{
    if (!_accessVideoView) {
        _accessVideoView = [BMEAccessView new];
        _accessVideoView.titleLabel.text = @"Notifications";
        _accessVideoView.messageLabel.text = @"læksdfj læasdf æafsdjkl";
        [BMEAccessControlHandler hasVideoEnabled:^(BOOL isEnabled) {
            self.accessVideoView.selected = isEnabled;
        }];
        [_accessVideoView addTarget:self action:@selector(touchUpInsideVideoView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _accessVideoView;
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

- (void)touchUpInsideMicrophoneView
{
    if (self.accessMicrophoneView.selected) {
        return;
    }
    
    [BMEAccessControlHandler requireMicrophoneEnabled:^(BOOL isEnabled) {
        self.accessMicrophoneView.selected = isEnabled;
    }];
}

- (void)touchUpInsideVideoView
{
    if (self.accessVideoView.selected) {
        return;
    }
    
    [BMEAccessControlHandler requireVideoEnabled:^(BOOL isEnabled) {
        self.accessVideoView.selected = isEnabled;
    }];
}


@end
