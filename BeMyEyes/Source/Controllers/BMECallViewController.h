//
//  BMECallViewController.h
//  BeMyEyes
//
//  Created by Simon Støvring on 23/03/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEBaseViewController.h"

typedef NS_ENUM(NSInteger, BMECallMode) {
    BMECallModeUnknown = -1,
    BMECallModeCreate = 0,
    BMECallModeAnswer,
};

@interface BMECallViewController : BMEBaseViewController <MKLocalizable>

@property (assign, nonatomic) BMECallMode callMode;
@property (copy, nonatomic) NSString *shortId;

@end
