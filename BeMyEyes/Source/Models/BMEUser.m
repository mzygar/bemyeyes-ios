//
//  BMEUser.m
//  BeMyEyes
//
//  Created by Simon Støvring on 04/09/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import "BMEUser.h"
#import "BMEUserLevel.h"
#import <SDWebImage/SDImageCache.h>

@implementation BMEUser

@synthesize profileImage = _profileImage;

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
        _type = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(type))];
        _peopleHelped = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(peopleHelped))];
        _totalPoints = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(totalPoints))];
        _currentLevel = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(currentLevel))];
        _nextLevel = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(nextLevel))];
        _lastPointEntries = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(lastPointEntries))];
        _completedTasks = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(completedTasks))];
        _remainingTasks = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(remainingTasks))];
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
    [aCoder encodeInteger:self.type forKey:NSStringFromSelector(@selector(type))];
    [aCoder encodeObject:self.peopleHelped forKey:NSStringFromSelector(@selector(peopleHelped))];
    [aCoder encodeObject:self.totalPoints forKey:NSStringFromSelector(@selector(totalPoints))];
    [aCoder encodeObject:self.currentLevel forKey:NSStringFromSelector(@selector(currentLevel))];
    [aCoder encodeObject:self.nextLevel forKey:NSStringFromSelector(@selector(nextLevel))];
    [aCoder encodeObject:self.lastPointEntries forKey:NSStringFromSelector(@selector(lastPointEntries))];
    [aCoder encodeObject:self.completedTasks forKey:NSStringFromSelector(@selector(completedTasks))];
    [aCoder encodeObject:self.remainingTasks forKey:NSStringFromSelector(@selector(remainingTasks))];
}

- (void)dealloc {
    _userId =  nil;
    _username = nil;
    _email = nil;
    _firstName = nil;
    _lastName = nil;
    _languages = nil;
    _peopleHelped = nil;
    _totalPoints = nil;
    _lastPointEntries = nil;
    _completedTasks = nil;
    _remainingTasks = nil;
}

#pragma mark -
#pragma mark Public Methods

- (BOOL)isHelper {
    return self.role == BMERoleHelper;
}

- (BOOL)isBlind {
    return self.role == BMERoleBlind;
}

- (BOOL)isNative {
    return self.type == BMEUserTypeNative;
}

- (int)pointsToNextLevel {
    return self.nextLevel == nil ? 0 : self.nextLevel.threshold.integerValue - self.totalPoints.integerValue;
}

- (double)levelProgress {
    double dist = (double)[self distanceBetweenCurrentAndNextLevel];
    if (dist > 0) {
        return 1 - ((double)[self pointsToNextLevel]) / dist;
    } else {
        return 0;
    }
}

- (NSString*)description
{
    return [NSString stringWithFormat: @"<Identifier: %@, UserId: %@, Username: %@, Email: %@>",
            self.identifier, self.userId, self.username, self.email];
}

#pragma mark -
#pragma mark Private Methods

- (int)distanceBetweenCurrentAndNextLevel {
    return self.nextLevel.threshold.integerValue - self.currentLevel.threshold.integerValue;
}

#pragma mark - Setters and getters

/**
 @attention Writing image data to disk is asynch.
 */
- (void) setProfileImage:(UIImage *)profileImage
{
    if (profileImage) {
        [[SDImageCache sharedImageCache] storeImage: profileImage
                                             forKey: self.identifier];
    }

    _profileImage = profileImage;
}

/**
 This method will block the current thread to attempt to load a profile image from disk.
 */
- (UIImage*) profileImage
{
    if (_profileImage == nil) {
        SDImageCache *cache = [SDImageCache sharedImageCache];
        UIImage *imageFromMemory = [cache imageFromMemoryCacheForKey: self.identifier];
        if (!imageFromMemory) {
            UIImage *imageFromDisk = [cache imageFromDiskCacheForKey: self.identifier];
            if (imageFromDisk) {
                _profileImage = imageFromDisk;
            }
        }
    }
    
    return _profileImage;
}

@end
