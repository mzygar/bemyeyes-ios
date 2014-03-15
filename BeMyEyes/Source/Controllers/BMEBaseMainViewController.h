//
//  BMEBaseMainViewController.h
//  BeMyEyes
//
//  Created by Simon Støvring on 15/03/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEBaseViewController.h"

@interface BMEBaseMainViewController : BMEBaseViewController

- (void)requireMicrophoneEnabled:(void(^)(BOOL isEnabled))completion;

@end
