//
//  BMECallAudioPlayer.m
//  BeMyEyes
//
//  Created by Simon Støvring on 24/06/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMECallAudioPlayer.h"

@implementation BMECallAudioPlayer

#pragma mark -
#pragma mark Lifecycle

- (instancetype)initWithError:(NSError *__autoreleasing *)error {
    NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"call-repeat" ofType:@"aiff"];
    NSURL *audioUrl = [NSURL fileURLWithPath:audioPath];
    if (self = [super initWithContentsOfURL:audioUrl error:error]) {
        self.numberOfLoops = -1;
    }
    
    return self;
}

+ (instancetype)playerWithError:(NSError *__autoreleasing *)error {
    return [[[self class] alloc] initWithError:error];
}

@end
