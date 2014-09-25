//
//  BMERequest.h
//  BeMyEyes
//
//  Created by Simon Støvring on 27/08/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMEOpenTokSession.h"

@interface BMERequest : NSObject

@property (readonly, nonatomic) NSString *identifier;
@property (readonly, nonatomic) NSString *shortId;
@property (readonly, nonatomic) BMEOpenTokSession *openTok;
@property (readonly, nonatomic) NSString *blindName;
@property (readonly, nonatomic) NSString *helperName;
@property (readonly, nonatomic, getter = isAnswered) BOOL answered;

@end
