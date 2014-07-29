//
//  BMEVideoViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 29/07/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEVideoViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface BMEVideoViewController ()
@property (strong, nonatomic) MPMoviePlayerController *moviePlayerController;
@property (assign, nonatomic) BOOL statusBarVisible;
@end

@implementation BMEVideoViewController

#pragma mark -
#pragma mark Lifecycle

- (instancetype)initWithContentURL:(NSURL *)contentURL {
    if (self = [super init]) {
        if (contentURL) {
            _moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:contentURL];
        }
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.moviePlayerController) {
        self.moviePlayerController.view.frame = self.view.bounds;
        self.moviePlayerController.controlStyle = MPMovieControlStyleNone;
        [self.view addSubview:self.moviePlayerController.view];
        [self.moviePlayerController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        
        [self playVideo];
    }
    
    NSString *cancelTitle = NSLocalizedStringFromTable(@"CANCEL_TITLE", @"BMEVideoViewController", @"Title of cancel button");
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelButton.tintColor = [UIColor whiteColor];
    cancelButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f];
    [cancelButton setTitle:cancelTitle forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(60));
        make.height.equalTo(@(60));
        make.top.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![UIApplication sharedApplication].statusBarHidden) {
        self.statusBarVisible = YES;
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.statusBarVisible) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _moviePlayerController = nil;
}

#pragma mark -
#pragma mark Private Methods

- (void)playVideo {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayerController];
    
    [self.moviePlayerController prepareToPlay];
    [self.moviePlayerController play];
}

- (void)cancelButtonPressed:(id)sender {
    [self.moviePlayerController stop];
}

#pragma mark -
#pragma mark Notifications

- (void)playbackFinished:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayerController];

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
