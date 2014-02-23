//
//  BMERoleConverter.m
//  BeMyEyes
//
//  Created by Simon Støvring on 04/09/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import "BMERoleConverter.h"
#import "BMEUser.h"

@implementation BMERoleConverter

#pragma mark -
#pragma mark Value Converter

- (BOOL)canTransformValueForClass:(Class)class {
    return (class == [BMEUser class]);
}

- (id)transformValue:(id)value forDynamicAttribute:(DCDynamicAttribute *)attribute dictionary:(NSDictionary *)dictionary parentObject:(id)parentObject {
    return [value isEqualToString:@"helper"] ? @(BMERoleHelper) : @(BMERoleBlind);
}

- (id)serializeValue:(id)value forDynamicAttribute:(DCDynamicAttribute *)attribute {
    switch ([value integerValue]) {
        case BMERoleHelper:
            return @"helper";
            break;
        default:
            return @"blind";
            break;
    }
}

@end