//
//  BMESpeaker.m
//  BeMyEyes
//
//  Created by Simon Støvring on 23/03/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMESpeaker.h"

@interface BMESpeaker ()
@property (strong, nonatomic) AVSpeechSynthesizer *speechSynthesizer;
@end

@implementation BMESpeaker

#pragma mark -
#pragma mark Lifecycle

+ (BMESpeaker *)sharedInstance {
    static BMESpeaker *sharedInstance = nil;
    
    if (!sharedInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [BMESpeaker new];
        });
    }
    
    return sharedInstance;
}

- (void)dealloc {
    self.speechSynthesizer = nil;
}

#pragma mark -
#pragma mark Public Methods

+ (void)speak:(NSString *)string {
    [[self sharedInstance] speak:string];
}

#pragma mark -
#pragma mark Private Methods

- (void)speak:(NSString *)string {
    if ([self.speechSynthesizer isSpeaking]) {
        [self.speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryWord];
    }
    
    AVSpeechUtterance *speechUtterance = [AVSpeechUtterance speechUtteranceWithString:string];
    [self.speechSynthesizer speakUtterance:speechUtterance];
}

- (AVSpeechSynthesizer *)speechSynthesizer {
    if (!_speechSynthesizer) {
        _speechSynthesizer = [AVSpeechSynthesizer new];
    }
    
    return _speechSynthesizer;
}

@end
