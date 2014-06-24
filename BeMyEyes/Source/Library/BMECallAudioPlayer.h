//
//  BMECallAudioPlayer.h
//  BeMyEyes
//
//  Created by Simon Støvring on 24/06/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface BMECallAudioPlayer : AVAudioPlayer

- (instancetype)initWithError:(NSError **)error;
+ (instancetype)playerWithError:(NSError **)error;

@end
