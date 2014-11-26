//
//  BMERoleConverter.m
//  BeMyEyes
//
//  Created by Simon Støvring on 04/09/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import "BMEUserTypeConverter.h"
#import "BMEUser.h"

@implementation BMEUserTypeConverter

#pragma mark -
#pragma mark Value Converter

- (BOOL)canTransformValueForClass:(Class)class {
    return (class == [BMEUser class]);
}

- (id)transformValue:(id)value forDynamicAttribute:(DCDynamicAttribute *)attribute dictionary:(NSDictionary *)dictionary parentObject:(id)parentObject {
    return [value isEqualToNumber:@1] ? @(BMEUserTypeFacebook) : @(BMEUserTypeNative);
}

- (id)serializeValue:(id)value forDynamicAttribute:(DCDynamicAttribute *)attribute {
    switch ([value integerValue]) {
        case BMEUserTypeFacebook:
            return @1;
            break;
        case BMEUserTypeNative:
            return @0;
            break;
        default:
            return @0;
            break;
    }
}

@end