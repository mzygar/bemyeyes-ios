//
//  BMEUser.h
//  BeMyEyes
//
//  Created by Simon Støvring on 04/09/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMEUser : NSObject <NSCoding>

@property (readonly, nonatomic) NSString *identifier;
@property (readonly, nonatomic) NSString *userId;
@property (readonly, nonatomic) NSString *username;
@property (readonly, nonatomic) NSString *email;
@property (readonly, nonatomic) NSString *firstName;
@property (readonly, nonatomic) NSString *lastName;
@property (readonly, nonatomic) NSArray *languages;
@property (readonly, nonatomic) BMERole role;

- (BOOL)isHelper;
- (BOOL)isBlind;

@end
