//
//  BMEPointEntry.h
//  BeMyEyes
//
//  Created by Simon Støvring on 07/05/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMEPointEntry : NSObject

@property (readonly, nonatomic) NSUInteger point;
@property (readonly, nonatomic) NSString *event;
@property (readonly, nonatomic) NSDate *date;

- (NSString *)localizableKeyForTitle;

@end
