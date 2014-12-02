//
//  BMEHelperMainViewController.h
//  BeMyEyes
//
//  Created by Simon Støvring on 15/03/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEBaseViewController.h"

@interface BMEHelperMainViewController : BMEBaseViewController <MKLocalizable>

@property (strong, nonatomic) BMEUser *user;
@property (strong, nonatomic) BMECommunityStats *stats;

@end
