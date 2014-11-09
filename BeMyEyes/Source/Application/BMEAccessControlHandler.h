//
//  BMEAccessControlHandler.h
//  BeMyEyes
//
//  Created by Tobias DM on 09/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMEAccessControlHandler : NSObject

+ (void)requireNotificationsEnabled:(void(^)(BOOL isEnabled, BOOL validToken))completion;
+ (void)hasNotificationsEnabled:(void(^)(BOOL isEnabled, BOOL validToken))completion;
+ (void)requireMicrophoneEnabled:(void(^)(BOOL isEnabled))completion;
+ (void)hasMicrophoneEnabled:(void(^)(BOOL isEnabled))completion;
+ (void)requireCameraEnabled:(void(^)(BOOL isEnabled))completion;
+ (void)hasVideoEnabled:(void(^)(BOOL isEnabled))completion;

+ (void)enabledForRole:(BMERole)role completion:(void(^)(BOOL isEnabled, BOOL validToken))completion;

@end
