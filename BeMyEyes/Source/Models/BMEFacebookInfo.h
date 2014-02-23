//
//  BMEFacebookInfo.h
//  BeMyEyes
//
//  Created by Simon Støvring on 23/02/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMEFacebookInfo : NSObject

@property (readonly, nonatomic) NSNumber *userId;
@property (readonly, nonatomic) NSString *email;
@property (readonly, nonatomic) NSString *firstName;
@property (readonly, nonatomic) NSString *lastName;

@end
