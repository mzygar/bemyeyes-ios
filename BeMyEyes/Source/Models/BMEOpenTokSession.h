//
//  BMEOpenTokSession.h
//  BeMyEyes
//
//  Created by Simon Støvring on 27/08/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMEOpenTokSession : NSObject

@property (readonly, nonatomic) NSString *sessionId;
@property (readonly, nonatomic) NSString *token;

@end
