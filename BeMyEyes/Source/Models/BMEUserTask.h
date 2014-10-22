//
//  BMEUserTask.h
//  BeMyEyes
//
//  Created by Tobias DM on 07/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMEUserTask : NSObject

typedef NS_ENUM(NSUInteger, BMEUserTaskType)
{
    BMEUserTaskTypeShareOnTwitter = 0,
    BMEUserTaskTypeShareOnFacebook = 1,
    BMEUserTaskTypeWatchVideo = 2,
    BMEUserTaskTypeUnknown,
};

@property (assign, nonatomic) BMEUserTaskType type;
@property (assign, nonatomic) BOOL completed;
@property (assign, nonatomic) NSUInteger points;

- (NSString *)localizableKeyForType;
+ (NSString *)serverKeyForType:(BMEUserTaskType)type;
+ (BMEUserTaskType)taskTypeForServerKey:(NSString *)key;

@end
