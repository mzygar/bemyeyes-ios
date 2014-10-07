//
//  BMEUserLevel.h
//  BeMyEyes
//
//  Created by Tobias DM on 29/09/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMEUserLevel : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSNumber *threshold;

- (NSString *)localizableKeyForTitle;

@end
