//
//  BMEEmailValidator.h
//  BeMyEyes
//
//  Created by Simon Støvring on 01/06/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMEEmailValidator : NSObject

+ (BOOL)isEmailValid:(NSString *)email;

@end
