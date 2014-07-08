//
//  BMEUser.m
//  BeMyEyes
//
//  Created by Simon Støvring on 04/09/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import "BMEUser.h"

@implementation BMEUser

#pragma mark -
#pragma mark Lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _identifier = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(identifier))];
        _userId = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(userId))];
        _username = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(username))];
        _email = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(email))];
        _firstName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(firstName))];
        _lastName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(lastName))];
        _languages = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(languages))];
        _role = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(role))];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.identifier forKey:NSStringFromSelector(@selector(identifier))];
    [aCoder encodeObject:self.userId forKey:NSStringFromSelector(@selector(userId))];
    [aCoder encodeObject:self.username forKey:NSStringFromSelector(@selector(username))];
    [aCoder encodeObject:self.email forKey:NSStringFromSelector(@selector(email))];
    [aCoder encodeObject:self.firstName forKey:NSStringFromSelector(@selector(firstName))];
    [aCoder encodeObject:self.lastName forKey:NSStringFromSelector(@selector(lastName))];
    [aCoder encodeObject:self.languages forKey:NSStringFromSelector(@selector(languages))];
    [aCoder encodeInteger:self.role forKey:NSStringFromSelector(@selector(role))];
}

- (void)dealloc {
    _userId =  nil;
    _username = nil;
    _email = nil;
    _firstName = nil;
    _lastName = nil;
    _languages = nil;
}

#pragma mark -
#pragma mark Public Methods

- (BOOL)isHelper {
    return self.role == BMERoleHelper;
}

- (BOOL)isBlind {
    return self.role == BMERoleBlind;
}

@end
