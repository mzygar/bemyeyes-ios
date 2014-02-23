//
//  BMEToken.h
//  BeMyEyes
//
//  Created by Simon Støvring on 03/09/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMEToken : NSObject

@property (readonly, nonatomic) NSString *token;
@property (readonly, nonatomic) NSDate *expiryDate;

@end
