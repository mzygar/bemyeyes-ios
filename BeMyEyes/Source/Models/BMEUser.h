//
//  BMEUser.h
//  BeMyEyes
//
//  Created by Simon Støvring on 04/09/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class BMEUserLevel;
#import "BMEUserTask.h"

typedef NS_ENUM(NSInteger, BMERole) {
    BMERoleBlind = 0,
    BMERoleHelper,
};

typedef NS_ENUM(NSInteger, BMEUserType) {
    BMEUserTypeNative = 0,
    BMEUserTypeFacebook,
};

@interface BMEUser : NSObject <NSCoding>

@property (readonly, nonatomic) NSString *identifier;
@property (readonly, nonatomic) NSString *userId;
@property (readonly, nonatomic) NSString *username;
@property (readonly, nonatomic) NSString *email;
@property (readonly, nonatomic) NSString *firstName;
@property (readonly, nonatomic) NSString *lastName;
@property (readonly, nonatomic) NSArray *languages;
@property (readonly, nonatomic) BMERole role;
@property (readonly, nonatomic) BMEUserType type;
@property (readonly, nonatomic) NSNumber *peopleHelped;
@property (readonly, nonatomic) NSNumber *totalPoints;
@property (readonly, nonatomic) BMEUserLevel *currentLevel;
@property (readonly, nonatomic) BMEUserLevel *nextLevel;
@property (readonly, nonatomic) NSArray *lastPointEntries;
@property (readonly, nonatomic) NSArray *completedTasks;
@property (readonly, nonatomic) NSArray *remainingTasks;
@property (readonly, nonatomic) UIImage *profileImage;

- (BOOL)isHelper;
- (BOOL)isBlind;
- (BOOL)isNative;
- (int)pointsToNextLevel;
- (double)levelProgress;

@end
