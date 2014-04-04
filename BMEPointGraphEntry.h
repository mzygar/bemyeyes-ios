//
//  BMEPointGraphEntry.h
//  BeMyEyes
//
//  Created by Simon Støvring on 04/04/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMEPointGraphEntry : NSObject

@property (readonly, nonatomic) NSUInteger points;
@property (readonly, nonatomic) NSDate *date;

- (instancetype)initWithPoints:(NSUInteger)points date:(NSDate *)date;
+ (instancetype)entryWithPoints:(NSUInteger)points date:(NSDate *)date;

@end
