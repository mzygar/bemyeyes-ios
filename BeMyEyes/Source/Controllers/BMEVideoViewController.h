//
//  BMEVideoViewController.h
//  BeMyEyes
//
//  Created by Simon Støvring on 29/07/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEBaseViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface BMEVideoViewController : BMEBaseViewController

@property (readonly, nonatomic) MPMoviePlayerController *moviePlayerController;
@property (strong, nonatomic) void (^finishedPlaying)();

- (instancetype)initWithContentURL:(NSURL *)contentURL;

@end
